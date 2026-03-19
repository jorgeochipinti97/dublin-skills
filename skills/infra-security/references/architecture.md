# Architecture Patterns Reference

## Table of Contents
1. [Designing from Scratch: Framework](#designing-from-scratch-framework)
2. [High Availability Patterns](#high-availability-patterns)
3. [Scalability Patterns](#scalability-patterns)
4. [Disaster Recovery](#disaster-recovery)
5. [Cost-Performance Trade-offs](#cost-performance-trade-offs)
6. [Anti-Patterns to Avoid](#anti-patterns-to-avoid)

---

## Designing from Scratch: Framework

### The 5 Questions Before Designing
1. **Traffic**: expected req/s at launch, 6mo, 1yr? Burst pattern?
2. **Data**: volume, read/write ratio, consistency requirements, retention?
3. **Budget**: hard limit per month? Where is flexibility?
4. **Team**: ops capacity? Can you manage Kubernetes? On-call?
5. **Compliance**: PCI, SOC2, HIPAA, GDPR? Drives a lot of design

### Standard Architecture Tiers

```
Tier 1 — Startup/MVP (<100 req/s, <$500/mo)
┌─────────────────────────────────────────┐
│  CloudFront → ALB → 2x ECS Fargate      │
│  Aurora Serverless v2 (PostgreSQL)      │
│  ElastiCache Redis (single node)        │
│  S3 + Bedrock for AI features           │
│  Estimated: $200-400/mo                 │
└─────────────────────────────────────────┘

Tier 2 — Growth (100-1000 req/s, $1-5K/mo)
┌─────────────────────────────────────────┐
│  CloudFront + WAF → ALB → ECS EC2       │
│  Aurora PostgreSQL (Multi-AZ)           │
│  ElastiCache Redis (cluster mode)       │
│  SQS + Lambda for async workloads       │
│  Estimated: $1,000-3,000/mo             │
└─────────────────────────────────────────┘

Tier 3 — Scale (>1000 req/s, >$5K/mo)
┌─────────────────────────────────────────┐
│  CloudFront + WAF + Shield Advanced     │
│  EKS or ECS with Spot + On-demand mix   │
│  Aurora Global Database or CockroachDB  │
│  Redis Cluster + read replicas          │
│  Separate data plane from control plane │
│  Estimated: $5,000-50,000+/mo           │
└─────────────────────────────────────────┘
```

---

## High Availability Patterns

### Multi-AZ (Minimum for Production)
- Deploy across 2-3 AZs in every layer
- ALB automatically distributes across AZs
- ECS/EKS: spread tasks/pods across AZs via placement constraints
- RDS Multi-AZ: synchronous replication, auto-failover in ~1-2min

### Health Check Strategy
```
Route 53 health check → ALB target group health check → Container health check
    (DNS failover)          (remove unhealthy tasks)        (restart container)
```

### Circuit Breaker Pattern
Essential for AI workloads where LLM calls can be slow/fail:
```
Normal → [Request] → LLM
Open (tripped) → [Request] → Fallback/Cache/Error (no LLM call)
Half-open → [Test request] → Check if LLM recovered
```
Use `resilience4j` (Java), `pybreaker` (Python), or implement with Redis counters.

---

## Scalability Patterns

### Horizontal vs Vertical Scaling Decision
- **Horizontal first**: stateless services, web APIs, worker pools
- **Vertical for**: databases (simpler), GPU inference (parallelism within GPU)
- **Never vertical**: as a permanent solution for stateful compute

### Queue-Based Load Leveling
Critical for AI workloads — decouple request intake from processing:
```
API → SQS Queue → ECS Worker Pool
         │
         ├── Handles traffic bursts (queue absorbs spikes)
         ├── Worker pool scales based on queue depth (not req/s)
         └── Dead Letter Queue for failed jobs
```

Scaling trigger: `SQS ApproximateNumberOfMessages / desired_per_task`

### Read Replicas Pattern
```
Write → Primary DB
Read  → Read Replica (up to 15 for Aurora)

Route in application:
- Writes: primary connection string
- Reads: replica connection string (or use PgBouncer with routing)
- Use for: analytics queries, reporting, search — never for auth/transactions
```

### CQRS for AI Platforms
Separate read and write models when AI-generated data needs different querying:
```
Write Side: API → Command → Event Store → DynamoDB
Read Side:  Events → Projector → Read DB (Elasticsearch/PostgreSQL)
Query Side: GraphQL/REST → Read DB
```

---

## Disaster Recovery

### RTO/RPO Matrix

| Tier | RTO | RPO | Strategy | Estimated Cost |
|------|-----|-----|----------|----------------|
| Basic | 24h | 24h | Backup + Restore | +0% |
| Standard | 4h | 1h | Pilot Light (warm standby) | +10-20% |
| Advanced | 1h | 15min | Warm Standby | +50-100% |
| Critical | <5min | <1min | Multi-region Active-Active | +200-300% |

### Backup Strategy
```
RDS: Automated daily snapshots (7-35 day retention) + transaction logs (PITR)
S3: Versioning + Cross-Region Replication for critical buckets
EBS: AWS Backup with daily snapshots
DynamoDB: Point-in-time recovery (PITR) enabled
```

### Chaos Engineering (Optional but Recommended)
- Test AZ failure: terminate all instances in one AZ
- Test DB failover: manually failover RDS, measure app recovery time
- Test dependency failure: block access to third-party APIs, verify circuit breakers

---

## Cost-Performance Trade-offs

### The Cost Optimization Hierarchy
1. **Right-size first**: don't optimize what you haven't measured
2. **Spot/Preemptible**: 60-90% savings for fault-tolerant workloads
3. **Reserved capacity**: 30-60% for steady-state predictable workloads
4. **Architecture optimization**: eliminate waste (idle resources, unnecessary data transfer)
5. **Code optimization**: reduce compute time, cache aggressively

### Data Transfer Costs (often overlooked)
```
Free:
- Inbound to AWS
- Within same AZ (same region, same AZ)
- S3/DynamoDB via VPC Endpoints

Charged:
- Outbound to internet: $0.09/GB (first 10TB)
- Cross-AZ: $0.01/GB each way (adds up!)
- Cross-region: $0.02/GB

Mitigation:
- VPC Endpoints for S3/DynamoDB ($0)
- Place databases in same AZ as primary compute
- Use CloudFront for content delivery (cheaper egress)
```

### Serverless vs Container Cost Crossover
```
Lambda: ~$0.0000002/request + $0.0000166667/GB-second
ECS Fargate (0.25vCPU, 0.5GB): ~$0.012/hour

Crossover point (assuming 100ms avg duration, 128MB):
~$0.000002/request on Lambda
= ~6,000 requests/hour to equal Fargate cost
= ~144,000 requests/day

Below 144K req/day → Lambda cheaper
Above 144K req/day → Fargate or EC2 cheaper
```

---

## Anti-Patterns to Avoid

### The "Single Point of Failure" Collection
- Single NAT Gateway (create one per AZ)
- Single AZ deployment for databases
- Single ECS task with min=1
- Shared IAM role across multiple services
- Single region with no DR plan

### The "This Will Hurt Later" List
- **Monolith database**: all services sharing one RDS → extract per-service DBs early
- **Secrets in env vars**: rotate one secret = redeploy all services
- **No request tracing**: distributed systems without trace IDs = debugging nightmare
- **Implicit API contracts**: no versioning, no schema validation
- **Fat Lambda functions**: >50MB Lambda = slow cold starts, hard to debug
- **Missing idempotency keys**: retries on payment/AI calls can cause duplicates
- **Synchronous everything**: AI workload latency bleeds into user-facing APIs without queues

### Over-Engineering Traps
- Kubernetes before you have 10+ services
- Event sourcing without a team that understands it
- Multi-region before you have SLAs requiring it
- Service mesh before you have measurable latency problems
- Microservices before the domain boundaries are clear
