# Security Reference

## Table of Contents
1. [Security Review Checklist](#security-review-checklist)
2. [IAM & Access Control](#iam--access-control)
3. [Network Security](#network-security)
4. [API Security](#api-security)
5. [AI-Specific Security](#ai-specific-security)
6. [Secrets Management](#secrets-management)
7. [Incident Response](#incident-response)

---

## Security Review Checklist

### Architecture Review
- [ ] All traffic encrypted in transit (TLS 1.2+)
- [ ] All data encrypted at rest (AES-256)
- [ ] No secrets in code, env vars in CI/CD, or Docker images
- [ ] Principle of least privilege for all service roles
- [ ] No public S3 buckets
- [ ] Security groups: deny by default, explicit allows only
- [ ] WAF in front of public-facing APIs
- [ ] DDoS protection (AWS Shield Standard is free, CloudFront helps)
- [ ] Audit logging enabled (CloudTrail, VPC Flow Logs)
- [ ] Vulnerability scanning in CI/CD pipeline

### Code Review (Security Lens)
- [ ] Input validation at all API boundaries
- [ ] SQL queries parameterized (no string concatenation)
- [ ] SSRF protections (block 169.254.169.254, 10.x, 172.16.x)
- [ ] Rate limiting on all public endpoints
- [ ] Authentication on all non-public endpoints
- [ ] Authorization checks (can this user access this resource?)
- [ ] No sensitive data in logs (PII, tokens, passwords)

---

## IAM & Access Control

### AWS IAM Hardening
```json
// Deny any action outside approved regions (Service Control Policy)
{
  "Effect": "Deny",
  "NotAction": [
    "iam:*", "organizations:*", "route53:*",
    "cloudfront:*", "sts:*", "support:*"
  ],
  "Resource": "*",
  "Condition": {
    "StringNotEquals": {
      "aws:RequestedRegion": ["us-east-1", "us-west-2"]
    }
  }
}
```

### Confused Deputy Prevention
When one AWS service calls another on your behalf, use `aws:SourceArn` condition:
```json
{
  "Condition": {
    "ArnLike": {
      "aws:SourceArn": "arn:aws:lambda:us-east-1:123456789:function:my-function"
    }
  }
}
```

### Zero Trust for Microservices
- Each service has its own IAM role with scoped permissions
- Service-to-service auth: use AWS SigV4 signing (not API keys)
- Use VPC endpoints + resource policies to restrict service access to within VPC

---

## Network Security

### Defense in Depth Layers
```
Internet
    │
    ▼
CloudFront + WAF (DDoS, OWASP rules, rate limiting, geo-blocking)
    │
    ▼
ALB (SSL termination, security headers)
    │
    ▼
Security Groups (port-level filtering)
    │
    ▼
Application (auth middleware, input validation)
    │
    ▼
Database (private subnet, SG allows only app SG)
```

### WAF Rules (AWS WAF)
Essential managed rule groups:
- `AWSManagedRulesCommonRuleSet` — OWASP Top 10
- `AWSManagedRulesKnownBadInputsRuleSet` — log4j, XXE, path traversal
- `AWSManagedRulesAmazonIpReputationList` — known malicious IPs
- Custom: rate limit by IP (100 req/5min for auth endpoints)

### VPC Flow Logs Analysis
```bash
# Find rejected connections (potential scan/attack)
aws logs filter-log-events \
  --log-group-name /aws/vpc/flowlogs \
  --filter-pattern "[version, account, eni, source, destination, srcport, destport, protocol, packets, bytes, windowstart, windowend, action=REJECT, flowlogstatus]" \
  --start-time $(date -d '1 hour ago' +%s000)
```

---

## API Security

### Authentication Patterns
| Pattern | Use When |
|---------|----------|
| JWT (short-lived, 15min) + Refresh Token | User-facing APIs |
| API Key + HMAC signature | Server-to-server |
| AWS SigV4 | AWS service-to-service |
| mTLS | High-security B2B |

### JWT Best Practices
- Short expiry (15min access, 7d refresh)
- Store refresh tokens in httpOnly cookies (not localStorage)
- Rotate signing keys quarterly
- Include `jti` (JWT ID) claim + maintain denylist for logout

### Rate Limiting Strategy for AI APIs
```
Per-IP: 60 req/min (unauthenticated)
Per-user free: 10 req/min, 100 req/day
Per-user pro: 60 req/min, 10K req/day
Per-tenant: configurable, enforce at API GW level
```

### OWASP API Top 10 Quick Reference
1. **Broken Object Level Auth** — always check `user_id == resource.owner_id`
2. **Broken Auth** — short-lived tokens, MFA for sensitive ops
3. **Broken Object Property Level Auth** — don't return fields user can't access
4. **Unrestricted Resource Consumption** — rate limit + max payload size
5. **Broken Function Level Auth** — check roles, not just authentication
6. **SSRF** — validate/block internal IPs in user-provided URLs
7. **Security Misconfiguration** — CORS, headers, exposed stack traces
8. **Injection** — parameterize everything, validate schemas
9. **Improper Inventory Management** — document all API versions, deprecate old ones
10. **Unsafe API Consumption** — validate responses from third-party APIs

---

## AI-Specific Security

### Prompt Injection Prevention
- Separate system instructions from user input clearly
- Use structured formats (JSON/XML) for tool calls, never string interpolation
- Validate that model output matches expected schema before using it
- Don't let users provide system prompts directly

```python
# BAD - user can override system instructions
prompt = f"You are a helpful assistant. {user_system_prompt}\n\nUser: {user_input}"

# GOOD - clear separation
messages = [
    {"role": "system", "content": FIXED_SYSTEM_PROMPT},
    {"role": "user", "content": sanitize(user_input)}
]
```

### Data Leakage in RAG Systems
- Apply document-level access control before retrieval (don't retrieve then filter)
- Tag embeddings with `tenant_id`, filter vector search by tenant
- Audit logs for all document retrievals — who retrieved what, when
- Don't log full prompts in production (contain PII/proprietary data)

### AI API Key Security
- Rotate API keys every 90 days
- Use AWS Secrets Manager for storage, never environment variables in plain text
- Set spending limits on AI provider accounts
- Monitor for unusual token consumption spikes (potential key compromise)

### Supply Chain Security for AI Models
- Verify model checksums when downloading from HuggingFace
- Scan model files for embedded code/exploits (ModelScan)
- Pin specific model versions, don't use `latest` or `main`
- Prefer models from verified publishers

---

## Secrets Management

### AWS Secrets Manager Pattern
```python
import boto3
from functools import lru_cache

@lru_cache(maxsize=None)
def get_secret(secret_name: str) -> dict:
    client = boto3.client('secretsmanager')
    response = client.get_secret_value(SecretId=secret_name)
    return json.loads(response['SecretString'])

# Usage - cached after first call
db_password = get_secret('prod/myapp/db')['password']
```

### Secret Rotation
- DB passwords: auto-rotation every 30 days via Secrets Manager + Lambda
- API keys (third-party): manual rotation every 90 days, tracked in runbook
- JWT signing keys: rotation requires coordinated deploy (deploy new key, drain old tokens)
- SSH keys: yearly rotation, use SSO/IAM Identity Center when possible

### Detecting Secret Leaks
- `git-secrets` or `truffleHog` in pre-commit hooks
- GitHub Advanced Security secret scanning (auto-detects AWS keys, etc.)
- `detect-secrets` baseline in CI/CD

---

## Incident Response

### Security Incident Runbook (AWS)

**Step 1: Contain**
```bash
# Isolate compromised EC2 — attach restrictive security group
aws ec2 modify-instance-attribute \
  --instance-id i-xxxx \
  --groups sg-lockdown-id  # SG with no inbound/outbound

# Disable compromised IAM key
aws iam update-access-key --access-key-id AKIA... --status Inactive
```

**Step 2: Investigate**
```bash
# Check CloudTrail for what the key did
aws cloudtrail lookup-events \
  --lookup-attributes AttributeKey=AccessKeyId,AttributeValue=AKIA... \
  --start-time 2024-01-01T00:00:00Z

# Check for new IAM users/roles created (common persistence technique)
aws iam list-users --query 'Users[?CreateDate>=`2024-01-01`]'
```

**Step 3: Remediate**
- Rotate all credentials that may have been exposed
- Terminate and replace compromised instances
- Review and tighten IAM policies
- Document timeline and root cause

### Indicators of Compromise (AWS)
- Unusual IAM activity: CreateUser, AttachUserPolicy, CreateAccessKey
- EC2 in unexpected regions
- S3 bucket policy changes
- Spike in data egress
- CloudTrail disabled or modified
