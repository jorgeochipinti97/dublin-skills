# AI Infrastructure Reference

## Table of Contents
1. [AI as a Service Architecture Patterns](#ai-as-a-service-architecture-patterns)
2. [Agent Platforms](#agent-platforms)
3. [Model Serving](#model-serving)
4. [Vector Databases](#vector-databases)
5. [AWS Bedrock Deep Dive](#aws-bedrock-deep-dive)
6. [MLOps & Pipelines](#mlops--pipelines)
7. [Cost Optimization for AI Workloads](#cost-optimization-for-ai-workloads)

---

## AI as a Service Architecture Patterns

### The "Vercel for Agents" Pattern
Multi-tenant agent hosting platform — each customer deploys and runs their own agents:

```
                    ┌─────────────────────────────────────┐
                    │           Control Plane              │
                    │  (API GW + Lambda/ECS)               │
                    │  - Agent CRUD                        │
                    │  - Auth/multi-tenancy                │
                    │  - Billing/usage metering            │
                    └──────────────┬──────────────────────┘
                                   │
              ┌────────────────────┼────────────────────┐
              ▼                    ▼                    ▼
     ┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐
     │  Agent Runtime  │ │  Agent Runtime  │ │  Agent Runtime  │
     │  (ECS/Lambda)   │ │  (ECS/Lambda)   │ │  (ECS/Lambda)   │
     └────────┬────────┘ └────────┬────────┘ └────────┬────────┘
              │                   │                   │
              └───────────────────▼───────────────────┘
                          ┌──────────────┐
                          │   Bedrock    │
                          │  (LLM calls) │
                          └──────────────┘
```

**Key design decisions:**
- **Isolation**: separate ECS task per agent execution vs shared pool (cost vs isolation trade-off)
- **State**: store agent state in DynamoDB (fast) or S3 (cheap) between turns
- **Streaming**: use Server-Sent Events (SSE) for streaming LLM responses to clients
- **Metering**: track token usage per tenant in DynamoDB, aggregate for billing

### Tiered Service Levels
```
Free tier   → Lambda (cold starts OK, low cost)
Pro tier    → ECS Fargate (warm, consistent latency)
Enterprise  → Dedicated ECS cluster or EC2 (isolation, custom models)
```

---

## Agent Platforms

### Agent Orchestration Options

| Option | Pros | Cons | Best For |
|--------|------|------|----------|
| Bedrock Agents | Zero infra, AWS-native, action groups | Vendor lock-in, limited flexibility | Quick POC, AWS-heavy stack |
| LangGraph + ECS | Full control, any model | More code | Complex multi-step agents |
| CrewAI | Multi-agent, role-based | Less mature | Collaborative agent teams |
| Custom orchestration | Maximum flexibility | Most work | Production, unique requirements |

### Agent State Management
- **Short-term (within session)**: in-memory or Redis/ElastiCache
- **Long-term (cross-session)**: DynamoDB with TTL, or S3 for large payloads
- **Tool/action results**: store in S3, pass S3 URI to next step (avoid large payloads in DynamoDB)

### Multi-tenancy Patterns
```
Tenant isolation options:
1. Row-level isolation — single DB, tenant_id column (cheapest, less safe)
2. Schema-level isolation — separate DB schema per tenant (medium)
3. Resource-level isolation — separate ECS task, DynamoDB table per tenant (safest, expensive)
```

For AI platforms: use row-level for data + resource-level for compute (separate execution environments).

---

## Model Serving

### Self-Hosted vs Managed Trade-off

| | Bedrock/Managed | Self-hosted (vLLM/Ollama) |
|--|----------------|--------------------------|
| Cost at low volume | Low (pay per token) | High (GPU 24/7) |
| Cost at high volume | High | Low (amortized GPU) |
| Ops complexity | Zero | High |
| Latency | ~200-500ms | ~50-200ms |
| Model choice | Limited catalog | Any HuggingFace model |
| Break-even | ~5-10M tokens/day | ~5-10M tokens/day |

### vLLM on AWS (Self-hosted)
```
Recommended stack:
- Instance: g5.xlarge (A10G GPU, 24GB VRAM) — ~$1.00/hr
- Model: Llama 3.1 8B (fits in 8-16GB VRAM), Mistral 7B
- Serving: vLLM with OpenAI-compatible API
- Scaling: ECS with GPU-enabled EC2 launch type
- Load balancing: ALB with sticky sessions (or stateless with routing)

Docker command:
docker run --gpus all -p 8000:8000 vllm/vllm-openai \
  --model meta-llama/Llama-3.1-8B-Instruct \
  --tensor-parallel-size 1
```

### Inference Optimization
- **Batching**: vLLM does continuous batching automatically — don't send requests one by one
- **Quantization**: use 4-bit (GPTQ/AWQ) for 2x memory reduction, ~5% quality loss
- **KV Cache**: size your VRAM budget: model weights + KV cache for expected concurrent users
- **Speculative decoding**: 2-3x speedup for small models used as draft

---

## Vector Databases

### Comparison

| | pgvector | OpenSearch Serverless | Pinecone | Qdrant |
|--|---------|----------------------|---------|--------|
| Cost | Cheap (part of RDS) | $700+/mo minimum | Pay per vector | Self-host or cloud |
| Scale | Up to ~1M vectors well | Millions | Billions | Millions+ |
| Ops | Low (use existing PG) | Zero | Zero | Medium |
| Performance | Good | Good | Excellent | Excellent |
| Filtering | SQL | KNN + filter | Metadata filter | Payload filter |

**Decision guide:**
- <500K vectors + existing PostgreSQL → **pgvector** (no extra cost)
- Need managed + >1M vectors → **Pinecone** or **OpenSearch Serverless**
- Self-hosted + high performance → **Qdrant**

### pgvector Setup (AWS RDS/Aurora)
```sql
CREATE EXTENSION vector;
CREATE TABLE embeddings (
  id bigserial PRIMARY KEY,
  tenant_id uuid NOT NULL,
  content text,
  embedding vector(1536),  -- OpenAI/Bedrock Titan dimensions
  metadata jsonb,
  created_at timestamptz DEFAULT now()
);
CREATE INDEX ON embeddings USING hnsw (embedding vector_cosine_ops);
```

### Chunking Strategy for RAG
- Chunk size: 256-512 tokens (overlap 10-20%)
- Too small: loses context; too large: retrieval noise
- Use semantic chunking (sentence boundaries) over fixed-size when possible
- Store both chunk and parent document — retrieve chunk, return parent context

---

## AWS Bedrock Deep Dive

### Architecture: Bedrock-Powered API

```
Client → API GW → Lambda/ECS → Bedrock → Response
                      │
                      ├── DynamoDB (conversation history)
                      ├── S3 (documents/context)
                      └── ElastiCache (rate limiting, caching)
```

### Bedrock Agents with Action Groups
```python
# Action group Lambda handler pattern
def lambda_handler(event, context):
    action = event['actionGroup']
    function = event['function']
    parameters = event['parameters']

    # Execute tool
    result = execute_tool(action, function, parameters)

    return {
        "messageVersion": "1.0",
        "response": {
            "actionGroup": action,
            "function": function,
            "functionResponse": {
                "responseBody": {"TEXT": {"body": str(result)}}
            }
        }
    }
```

### Bedrock Knowledge Base Integration
- Supported vector stores: OpenSearch Serverless, Aurora pgvector, Pinecone, Redis Enterprise
- Ingestion: S3 → Bedrock KB (auto-chunking + embedding)
- Retrieval: semantic search + optional hybrid (BM25 + vector)
- Cost: embedding cost + vector store cost + retrieval per query

### Streaming with Bedrock
```python
import boto3
bedrock = boto3.client('bedrock-runtime')

response = bedrock.invoke_model_with_response_stream(
    modelId='anthropic.claude-3-5-sonnet-20241022-v2:0',
    body=json.dumps({
        "anthropic_version": "bedrock-2023-05-31",
        "max_tokens": 4096,
        "messages": [{"role": "user", "content": prompt}]
    })
)

for event in response['body']:
    chunk = json.loads(event['chunk']['bytes'])
    if chunk['type'] == 'content_block_delta':
        yield chunk['delta']['text']
```

### Multi-tenant Bedrock Cost Tracking
- Tag Bedrock invocations with tenant metadata via request headers
- Use CloudWatch metrics + custom dimensions for per-tenant usage
- Lambda middleware pattern: intercept all Bedrock calls, log tokens to DynamoDB for billing

---

## MLOps & Pipelines

### Data Pipeline for AI (AWS-native)
```
S3 (raw data) → EventBridge → Lambda (trigger) → Step Functions
                                                        │
                                          ┌─────────────┼─────────────┐
                                          ▼             ▼             ▼
                                     Validation    Chunking      Embedding
                                     (Lambda)     (Lambda)    (Bedrock/ECS)
                                          └─────────────┼─────────────┘
                                                        ▼
                                              Vector DB (pgvector/Pinecone)
```

### Model Fine-tuning Pipeline
- Data prep: S3 → SageMaker Processing Job (clean, format)
- Training: SageMaker Training Job with Spot Instances (70% cost saving)
- Evaluation: SageMaker Experiments to track metrics
- Deployment: SageMaker Endpoint or export to self-hosted

### Evaluation & Monitoring
- **Offline eval**: RAGAS for RAG pipelines (faithfulness, relevancy, context precision)
- **Online eval**: sample 5-10% of production requests, use LLM-as-judge
- **Drift detection**: monitor embedding distributions over time
- **Latency**: p50/p95/p99 per model, alert on p95 > SLA

---

## Cost Optimization for AI Workloads

### Caching Strategy (critical for AI cost)
```
Request → Cache lookup (Redis/ElastiCache)
              │
        Hit ──┴── Miss → Bedrock/LLM → Cache response
              │
         Return cached response (~$0 cost vs $0.015/1K tokens)
```

- Cache semantic similarity (not exact match): embed query, check cosine similarity > 0.95 threshold
- TTL based on content type: FAQ (long TTL), dynamic data (short TTL)
- Expected 20-40% cache hit rate reduces Bedrock costs significantly

### Token Optimization
- Compress system prompts aggressively — they're charged on every request
- Use Claude Haiku for classification/routing, Sonnet/Opus only for complex generation
- Implement prompt caching (Bedrock supports it) for repeated system prompts
- Truncate conversation history: keep last N turns + summary of earlier context

### GPU Cost Patterns
- **Development**: use g4dn.xlarge spot ($0.16/hr vs $0.53 on-demand)
- **Production inference**: reserved g5.xlarge 1yr ($0.60/hr → $0.42/hr)
- **Batch jobs**: Spot with SQS queue + auto-recovery on interruption
- **Scale-to-zero**: ECS with min=0 tasks + queue-based scaling for off-hours
