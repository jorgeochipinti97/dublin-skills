---
name: bind-api
description: "Integration with Banco Industrial (BIND) Argentina API - Open Banking Sandbox. Use when you need to: (1) Query accounts and transactions, (2) Make transfers via CVU/CBU, (3) Work with DEBIN (immediate debit), (4) Issue or deposit eCheqs (electronic checks), (5) Validate CBU/CVU ownership, (6) Create or manage CVUs, (7) Integrate Argentine banking services into fintech applications. Based on Open Bank Project standards."
---

# Bind API - Open Banking Argentina

Skill for integration with BIND (Banco Industrial) Argentina API, the first Argentine bank to offer open APIs.

## Base URL

```
Sandbox: https://sandbox.bind.com.ar
Production: Requires BIND approval
```

## Authentication

The API uses OAuth 2.0 with Direct Login for the sandbox.

### Direct Login (Sandbox)

```bash
curl -X POST "https://sandbox.bind.com.ar/api/auth/direct-login" \
  -H "Content-Type: application/json" \
  -d '{
    "username": "YOUR_USERNAME",
    "password": "YOUR_PASSWORD",
    "consumer_key": "YOUR_CONSUMER_KEY"
  }'
```

**Response:**
```json
{"token": "eyJ0eXAiOiJKV1QiLCJhbGciOi..."}
```

### Headers for Authenticated Requests

```
Authorization: DirectLogin token="YOUR_TOKEN"
Content-Type: application/json
```

## Main Endpoints

### 1. Account Query

```http
GET /obp/v4.0.0/my/accounts
```

Returns the authenticated user's accounts.

### 2. Account Detail

```http
GET /obp/v4.0.0/my/banks/{bank_id}/accounts/{account_id}/account
```

### 3. Transaction Query

```http
GET /obp/v4.0.0/my/banks/{bank_id}/accounts/{account_id}/transactions
```

**Query Parameters:** `from_date`, `to_date`, `limit`, `offset`

### 4. Transfers

```http
POST /obp/v4.0.0/banks/{bank_id}/accounts/{account_id}/transfer-to-account
```

### 5. DEBIN (Immediate Debit)

```http
POST /obp/v4.0.0/banks/{bank_id}/accounts/{account_id}/debin
GET /obp/v4.0.0/banks/{bank_id}/accounts/{account_id}/debin/{debin_id}
```

### 6. eCheqs (Electronic Checks)

```http
POST /obp/v4.0.0/banks/{bank_id}/accounts/{account_id}/echeq/issue
POST /obp/v4.0.0/banks/{bank_id}/accounts/{account_id}/echeq/deposit
```

### 7. CBU/CVU Validation

```http
GET /obp/v4.0.0/banks/validate-account-routing?scheme=CBU&address=...
```

### 8. Create CVU

```http
POST /obp/v4.0.0/banks/{bank_id}/accounts/{account_id}/cvu
```

## Resources

- **`references/api_reference.md`**: Complete endpoint documentation with request/response examples
- **`scripts/bind_client.ts`**: Example TypeScript client for integration

## Error Codes

| Code | Description |
|------|-------------|
| 400 | Bad Request - Invalid parameters |
| 401 | Unauthorized - Invalid or expired token |
| 403 | Forbidden - No permissions |
| 404 | Not Found - Resource not found |
| 429 | Rate limit exceeded |

## Important Notes

1. **BIND Bank Code**: 322 (BCRA code)
2. **Currency**: ARS (Argentine Pesos)
3. **Sandbox**: Synthetic data; production requires approval
4. **Rate Limiting**: Respect call limits
