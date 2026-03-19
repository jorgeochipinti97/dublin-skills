# Azure Reference (Occasional Use)

## AWS → Azure Service Mapping

| AWS | Azure Equivalent | Notes |
|-----|-----------------|-------|
| EC2 | Azure VMs | B-series = burstable (like t3) |
| ECS/Fargate | Azure Container Instances / AKS | ACI = serverless containers |
| Lambda | Azure Functions | Consumption plan = pay-per-execution |
| S3 | Azure Blob Storage | Containers = S3 buckets |
| RDS | Azure Database for PostgreSQL | Flexible Server = managed PG |
| DynamoDB | Cosmos DB | NoSQL, global distribution |
| Bedrock | Azure OpenAI Service | GPT-4, embeddings |
| CloudFront | Azure CDN / Front Door | Front Door = CDN + WAF + LB |
| Route 53 | Azure DNS | Similar feature set |
| IAM | Entra ID (AAD) + RBAC | More complex, role assignments |
| VPC | Virtual Network (VNet) | Subnets, NSGs = Security Groups |
| CloudWatch | Azure Monitor + Log Analytics | |
| Secrets Manager | Azure Key Vault | Also stores certs and keys |

## Key Differences from AWS

### Networking
- **NSGs (Network Security Groups)** work like AWS Security Groups but attach to subnets OR NICs
- **VNet Peering** = VPC Peering (same concept)
- **Private Endpoints** = VPC Interface Endpoints
- No equivalent to VPC Gateway Endpoints (S3/DynamoDB free routing)

### Identity
- **Managed Identity** = EC2 Instance Role / ECS Task Role (preferred over service principals)
- **RBAC** is more granular — roles assigned at subscription/resource group/resource level
- Use Managed Identity for all Azure-to-Azure service auth

### Cost Notes
- Azure Spot VMs: up to 90% discount, can be evicted with 30s notice
- Reserved Instances: 1-3yr, similar savings to AWS (~30-60%)
- Egress costs similar to AWS (~$0.087/GB outbound)
- Azure Hybrid Benefit: significant savings if you have existing Windows Server/SQL Server licenses

## Azure AI (OpenAI Service)
```
Azure OpenAI vs direct OpenAI API:
+ Data stays in Azure region (compliance)
+ Private endpoints (no public internet)
+ Enterprise SLAs
+ Azure RBAC for access control
- Slightly higher latency to model updates
- Model availability lags direct OpenAI

Use Azure OpenAI when: compliance requires data residency, or already on Azure
```

## Quick Auth Setup (Managed Identity)
```python
from azure.identity import DefaultAzureCredential
from azure.keyvault.secrets import SecretClient

credential = DefaultAzureCredential()  # Uses Managed Identity in Azure, env vars locally
client = SecretClient(vault_url="https://myvault.vault.azure.net/", credential=credential)
secret = client.get_secret("my-secret").value
```
