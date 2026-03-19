# AWS Reference

## Table of Contents
1. [Compute](#compute)
2. [Networking & Security](#networking--security)
3. [Serverless & Containers](#serverless--containers)
4. [AI/ML Services](#aiml-services)
5. [Storage & Databases](#storage--databases)
6. [IAM Patterns](#iam-patterns)
7. [Cost Optimization](#cost-optimization)

---

## Compute

### EC2 Instance Selection Guide

| Workload | Instance Family | Notes |
|----------|----------------|-------|
| General API/web | t3/t4g | Burstable, cheapest for low-traffic |
| CPU-intensive | c6i/c7g | Consistent compute, good for inference |
| Memory-heavy | r6i/r7g | DBs, large model loading |
| GPU inference | g4dn, g5, p3 | g4dn.xlarge (~$0.53/hr) is entry-level GPU |
| Batch/spot | Any with Spot | 60-90% discount, must handle interruption |

**Graviton (ARM) tip**: c7g/m7g are 20-40% cheaper than x86 equivalents for same perf — default to Graviton for new workloads unless x86 is required.

### Auto Scaling
- Use **Target Tracking** (simplest) for steady-state APIs
- Use **Step Scaling** for bursty AI inference workloads
- Always set min=2 for HA, never min=1 in production

---

## Networking & Security

### VPC Design (Standard 3-tier)
```
VPC (10.0.0.0/16)
├── Public Subnets (10.0.1.0/24, 10.0.2.0/24)  ← ALB, NAT GW
├── Private Subnets (10.0.10.0/24, 10.0.11.0/24) ← App servers, ECS tasks
└── Isolated Subnets (10.0.20.0/24, 10.0.21.0/24) ← RDS, ElastiCache
```

**Rules:**
- Never put app servers in public subnets
- Use VPC Endpoints for S3/DynamoDB (free, avoids NAT GW costs)
- NAT Gateway costs ~$0.045/hr + $0.045/GB — use VPC endpoints to minimize data through it

### Security Groups vs NACLs
- **Security Groups**: stateful, attach to resources — use for everything
- **NACLs**: stateless, subnet-level — only use for explicit block lists (DDoS, geo-blocking)

### ALB vs NLB vs CloudFront
- **ALB**: HTTP/HTTPS routing, path-based rules, WAF integration — default for web APIs
- **NLB**: TCP/UDP, ultra-low latency, static IP — for non-HTTP or very high throughput
- **CloudFront**: CDN + edge caching + WAF — always put in front of public APIs for DDoS protection

---

## Serverless & Containers

### Lambda
- **Cold start**: ~100-500ms (Python/Node), ~1-2s (Java/JVM)
- **Limits**: 15min timeout, 10GB memory, 512MB-10GB ephemeral storage
- **Best for**: event-driven, bursty, low-sustained-traffic APIs
- **Avoid for**: long-running tasks, websockets (use API GW + Lambda@Edge or ECS)

### ECS Fargate vs ECS EC2
| | Fargate | EC2 |
|--|---------|-----|
| Cost | Higher per unit | Lower at scale |
| Ops | Zero server mgmt | Need to manage cluster |
| Burst | Instant | Limited by cluster capacity |
| GPU | Not supported | Supported (g4dn etc.) |

**Rule of thumb**: Fargate until you're spending >$500/mo on compute, then evaluate EC2.

### EKS
- Use only if team has Kubernetes expertise or has >50 services
- EKS control plane = $0.10/hr ($73/mo) regardless of node count
- Prefer ECS for smaller teams — less operational overhead

---

## AI/ML Services

### Bedrock
- **Models available**: Claude (Anthropic), Llama, Mistral, Titan, Stable Diffusion
- **Pricing model**: per token (on-demand) or Provisioned Throughput (committed capacity)
- **On-demand Claude Sonnet**: ~$3/MTok input, $15/MTok output (check current pricing)
- **Provisioned Throughput**: needed for consistent low-latency; commit to Model Units (MUs)
- **Bedrock Agents**: built-in agent orchestration with action groups and knowledge bases
- **Knowledge Bases**: managed RAG with S3 + vector store (OpenSearch Serverless or Pinecone)

**Bedrock vs self-hosted models trade-off:**
- Bedrock: zero infra, pay-per-token, no cold starts, enterprise security
- Self-hosted (vLLM on EC2/EKS): 5-10x cheaper at scale, full control, requires GPU infra

### SageMaker
- Good for: custom model training, fine-tuning, batch inference at scale
- Overkill for: serving third-party models (use Bedrock or direct EC2/ECS)
- Real-time endpoints: auto-scaling, multiple models on same instance (multi-model endpoints)

---

## Storage & Databases

### S3
- Standard: $0.023/GB — default for most storage
- Intelligent-Tiering: auto-moves to cheaper tiers, good for unpredictable access
- Always enable versioning for production buckets with important data
- Block all public access by default — use presigned URLs for user access

### RDS vs Aurora
| | RDS PostgreSQL | Aurora PostgreSQL |
|--|---------------|------------------|
| Cost | Lower | ~20% higher |
| Performance | Good | 3x faster writes |
| Scaling | Manual | Auto-scaling storage, serverless option |
| HA | Multi-AZ (1 standby) | 6-way replication |

**Aurora Serverless v2**: excellent for AI workloads with bursty DB access — scales in 0.5 ACU increments.

### DynamoDB
- Best for: high-throughput key-value, session storage, queue-like patterns
- Avoid for: complex queries, joins, analytics
- On-demand pricing: $1.25/million write, $0.25/million read — prefer for unpredictable traffic

---

## IAM Patterns

### Least Privilege Checklist
- [ ] No `*` actions in production policies
- [ ] No inline policies — use managed policies
- [ ] Service roles per service (not shared roles)
- [ ] Resource-level ARNs in policies, not `*`
- [ ] Enable MFA for all human users
- [ ] Use IAM Identity Center (SSO) for human access, never IAM users

### Common Service Role Patterns
```json
// ECS Task Role — read S3, call Bedrock
{
  "Effect": "Allow",
  "Action": ["s3:GetObject", "s3:PutObject"],
  "Resource": "arn:aws:s3:::my-bucket/*"
},
{
  "Effect": "Allow",
  "Action": ["bedrock:InvokeModel"],
  "Resource": "arn:aws:bedrock:us-east-1::foundation-model/*"
}
```

### Secrets Management
- **Secrets Manager**: for DB passwords, API keys — auto-rotation supported ($0.40/secret/month)
- **Parameter Store**: for config/non-secret values — free tier available
- Never pass secrets as environment variables in ECS task definitions — use Secrets Manager references

---

## Cost Optimization

### Quick Wins
1. **Reserved Instances / Savings Plans**: 30-60% discount for 1-3yr commitment on steady-state workloads
2. **Spot Instances**: 60-90% off for fault-tolerant batch jobs, training
3. **VPC Endpoints**: eliminate NAT GW data costs for S3/DynamoDB traffic
4. **Right-sizing**: use AWS Compute Optimizer recommendations monthly
5. **S3 Lifecycle policies**: auto-move to Glacier for old data

### Cost Estimation Ballpark (2024)
| Component | Monthly Cost Range |
|-----------|-------------------|
| t3.medium EC2 (24/7) | ~$30 |
| NAT Gateway (low traffic) | ~$35-50 |
| ALB (low traffic) | ~$20 |
| RDS db.t3.medium Multi-AZ | ~$100 |
| EKS control plane | ~$73 |
| g4dn.xlarge EC2 (24/7) | ~$380 |
| Bedrock Claude Sonnet 1M tokens | ~$3-15 |

### Cost Monitoring
- Set **Budget Alerts** at 80% and 100% of expected spend
- Enable **Cost Anomaly Detection**
- Tag everything with `Environment`, `Team`, `Service` for cost allocation
