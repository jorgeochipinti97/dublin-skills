# Bind API - Complete Reference

## Authentication

### Direct Login

```http
POST /api/auth/direct-login
Content-Type: application/json

{
  "username": "YOUR_USERNAME",
  "password": "YOUR_PASSWORD",
  "consumer_key": "YOUR_CONSUMER_KEY"
}
```

**Response 200:**
```json
{
  "token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9..."
}
```

**Headers for authenticated requests:**
```
Authorization: DirectLogin token="YOUR_TOKEN"
Content-Type: application/json
```

---

## Accounts

### List My Accounts

```http
GET /obp/v4.0.0/my/accounts
Authorization: DirectLogin token="..."
```

**Response 200:**
```json
{
  "accounts": [
    {
      "id": "8ca8a7e4-6d02-40e3-a129-0b2bf89de9f0",
      "label": "Checking Account ARS",
      "bank_id": "bind.322.ar",
      "account_routings": [
        {"scheme": "CBU", "address": "3220001800000123456789"},
        {"scheme": "CVU", "address": "0000003100000987654321"},
        {"scheme": "ALIAS", "address": "my.account.bind"}
      ]
    }
  ]
}
```

### Account Detail

```http
GET /obp/v4.0.0/my/banks/{bank_id}/accounts/{account_id}/account
Authorization: DirectLogin token="..."
```

**Response 200:**
```json
{
  "id": "8ca8a7e4-6d02-40e3-a129-0b2bf89de9f0",
  "label": "Checking Account ARS",
  "number": "1234567890",
  "owners": [
    {
      "id_owner": "20123456789",
      "display_name": "Juan Pérez"
    }
  ],
  "product_code": "CA_ARS",
  "balance": {
    "currency": "ARS",
    "amount": "150000.00"
  },
  "bank_id": "bind.322.ar",
  "account_routings": [
    {"scheme": "CBU", "address": "3220001800000123456789"},
    {"scheme": "CVU", "address": "0000003100000987654321"}
  ]
}
```

### Query Balance

```http
GET /obp/v4.0.0/my/banks/{bank_id}/accounts/{account_id}/balances
Authorization: DirectLogin token="..."
```

**Response 200:**
```json
{
  "balances": [
    {
      "type": "AVAILABLE",
      "currency": "ARS",
      "amount": "148500.00"
    },
    {
      "type": "CURRENT",
      "currency": "ARS",
      "amount": "150000.00"
    }
  ]
}
```

---

## Transactions

### List Transactions

```http
GET /obp/v4.0.0/my/banks/{bank_id}/accounts/{account_id}/transactions
Authorization: DirectLogin token="..."
```

**Query Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| from_date | string | Start date (ISO 8601): `2024-01-01T00:00:00Z` |
| to_date | string | End date (ISO 8601): `2024-01-31T23:59:59Z` |
| limit | integer | Maximum results (default: 50) |
| offset | integer | Offset for pagination |

**Response 200:**
```json
{
  "transactions": [
    {
      "id": "txn-12345-abcde",
      "this_account": {
        "id": "8ca8a7e4-6d02-40e3-a129-0b2bf89de9f0",
        "bank_id": "bind.322.ar"
      },
      "other_account": {
        "holder": {
          "name": "Company SA",
          "is_alias": false
        },
        "account_routings": [
          {"scheme": "CBU", "address": "0140000000000123456789"}
        ],
        "bank_routing": {
          "scheme": "BCRA_CODE",
          "address": "014"
        }
      },
      "details": {
        "type": "TRANSFER_RECEIVED",
        "description": "Invoice payment #1234",
        "posted": "2024-01-15T10:30:00Z",
        "completed": "2024-01-15T10:30:00Z",
        "value": {
          "currency": "ARS",
          "amount": "25000.00"
        },
        "new_balance": {
          "currency": "ARS",
          "amount": "175000.00"
        }
      }
    }
  ]
}
```

---

## Transfers

### Create Transfer by CBU/CVU

```http
POST /obp/v4.0.0/banks/{bank_id}/accounts/{account_id}/transfer-to-account
Authorization: DirectLogin token="..."
Content-Type: application/json

{
  "to": {
    "account_routing": {
      "scheme": "CBU",
      "address": "0140000000000123456789"
    }
  },
  "value": {
    "currency": "ARS",
    "amount": "10000.00"
  },
  "description": "Service payment",
  "challenge_type": "SANDBOX_TAN"
}
```

**Response 201:**
```json
{
  "transaction_id": "txn-67890-fghij",
  "status": "COMPLETED",
  "from": {
    "bank_id": "bind.322.ar",
    "account_id": "8ca8a7e4-6d02-40e3-a129-0b2bf89de9f0"
  },
  "to": {
    "account_routing": {
      "scheme": "CBU",
      "address": "0140000000000123456789"
    }
  },
  "value": {
    "currency": "ARS",
    "amount": "10000.00"
  },
  "description": "Service payment",
  "created_at": "2024-01-15T14:00:00Z",
  "completed_at": "2024-01-15T14:00:01Z"
}
```

### Transfer Between Own Accounts

```http
POST /obp/v4.0.0/banks/{bank_id}/accounts/{account_id}/transfer-to-own-account
Authorization: DirectLogin token="..."
Content-Type: application/json

{
  "to": {
    "bank_id": "bind.322.ar",
    "account_id": "other-account-id"
  },
  "value": {
    "currency": "ARS",
    "amount": "5000.00"
  },
  "description": "Internal transfer"
}
```

---

## DEBIN (Immediate Debit)

### Create DEBIN Request

```http
POST /obp/v4.0.0/banks/{bank_id}/accounts/{account_id}/debin
Authorization: DirectLogin token="..."
Content-Type: application/json

{
  "from": {
    "account_routing": {
      "scheme": "CBU",
      "address": "0140000000000123456789"
    }
  },
  "value": {
    "currency": "ARS",
    "amount": "15000.00"
  },
  "description": "Monthly fee collection",
  "expiration": "2024-01-20T23:59:59Z",
  "recurrence": "ONE_TIME"
}
```

**Response 201:**
```json
{
  "debin_id": "dbn-12345-abcde",
  "status": "PENDING",
  "from": {
    "account_routing": {
      "scheme": "CBU",
      "address": "0140000000000123456789"
    }
  },
  "to": {
    "bank_id": "bind.322.ar",
    "account_id": "8ca8a7e4-6d02-40e3-a129-0b2bf89de9f0"
  },
  "value": {
    "currency": "ARS",
    "amount": "15000.00"
  },
  "description": "Monthly fee collection",
  "expiration": "2024-01-20T23:59:59Z",
  "created_at": "2024-01-15T16:00:00Z"
}
```

### Query DEBIN Status

```http
GET /obp/v4.0.0/banks/{bank_id}/accounts/{account_id}/debin/{debin_id}
Authorization: DirectLogin token="..."
```

**Response 200:**
```json
{
  "debin_id": "dbn-12345-abcde",
  "status": "APPROVED",
  "approved_at": "2024-01-15T18:30:00Z",
  "transaction_id": "txn-99999-zzzzz"
}
```

**Possible statuses:**
- `PENDING`: Awaiting payer approval
- `APPROVED`: Approved and executed
- `REJECTED`: Rejected by payer
- `EXPIRED`: Expired without response
- `CANCELLED`: Cancelled by requester

### Cancel DEBIN

```http
DELETE /obp/v4.0.0/banks/{bank_id}/accounts/{account_id}/debin/{debin_id}
Authorization: DirectLogin token="..."
```

---

## eCheqs (Electronic Checks)

### Issue eCheq

```http
POST /obp/v4.0.0/banks/{bank_id}/accounts/{account_id}/echeq/issue
Authorization: DirectLogin token="..."
Content-Type: application/json

{
  "beneficiary": {
    "cuit": "20987654321",
    "name": "Supplier SRL"
  },
  "value": {
    "currency": "ARS",
    "amount": "50000.00"
  },
  "payment_date": "2024-02-15",
  "type": "COMUN",
  "concept": "Supplier payment"
}
```

**eCheq Types:**
- `COMUN`: Regular check (on indicated date)
- `DIFERIDO`: Deferred check
- `CERTIFICADO`: Certified check

**Response 201:**
```json
{
  "echeq_id": "ecq-12345-abcde",
  "echeq_number": "00001234",
  "status": "ISSUED",
  "issuer": {
    "cuit": "20123456789",
    "name": "My Company SA"
  },
  "beneficiary": {
    "cuit": "20987654321",
    "name": "Supplier SRL"
  },
  "value": {
    "currency": "ARS",
    "amount": "50000.00"
  },
  "issue_date": "2024-01-15",
  "payment_date": "2024-02-15",
  "type": "COMUN"
}
```

### Deposit Received eCheq

```http
POST /obp/v4.0.0/banks/{bank_id}/accounts/{account_id}/echeq/deposit
Authorization: DirectLogin token="..."
Content-Type: application/json

{
  "echeq_id": "ecq-99999-xxxxx",
  "endorsement": false
}
```

### Endorse eCheq

```http
POST /obp/v4.0.0/banks/{bank_id}/accounts/{account_id}/echeq/{echeq_id}/endorse
Authorization: DirectLogin token="..."
Content-Type: application/json

{
  "new_beneficiary": {
    "cuit": "20111222333",
    "name": "New Beneficiary SA"
  }
}
```

### List My eCheqs

```http
GET /obp/v4.0.0/banks/{bank_id}/accounts/{account_id}/echeq
Authorization: DirectLogin token="..."
```

**Query Parameters:**
- `status`: ISSUED, DEPOSITED, PAID, REJECTED, VOIDED
- `role`: ISSUER, BENEFICIARY
- `from_date`, `to_date`

---

## CBU/CVU Validation

### Validate Account

```http
GET /obp/v4.0.0/banks/validate-account-routing?scheme=CBU&address=0140000000000123456789
Authorization: DirectLogin token="..."
```

**Response 200:**
```json
{
  "valid": true,
  "scheme": "CBU",
  "address": "0140000000000123456789",
  "holder": {
    "name": "EXAMPLE COMPANY SA",
    "cuit": "30123456789",
    "cuit_type": "CUIT"
  },
  "bank": {
    "code": "014",
    "name": "BANCO DE LA PROVINCIA DE BUENOS AIRES"
  },
  "account_type": "CC",
  "currency": "ARS"
}
```

**Response 200 (invalid):**
```json
{
  "valid": false,
  "error": "CBU_INVALID_CHECKSUM"
}
```

---

## CVU (Clave Virtual Uniforme)

### Create CVU

```http
POST /obp/v4.0.0/banks/{bank_id}/accounts/{account_id}/cvu
Authorization: DirectLogin token="..."
Content-Type: application/json

{
  "alias": "my.company.payments",
  "holder_cuit": "20123456789",
  "reference": "collection-001"
}
```

**Response 201:**
```json
{
  "cvu": "0000003100000123456789",
  "alias": "my.company.payments",
  "holder_cuit": "20123456789",
  "reference": "collection-001",
  "account_id": "8ca8a7e4-6d02-40e3-a129-0b2bf89de9f0",
  "created_at": "2024-01-15T10:00:00Z",
  "status": "ACTIVE"
}
```

### List Account CVUs

```http
GET /obp/v4.0.0/banks/{bank_id}/accounts/{account_id}/cvu
Authorization: DirectLogin token="..."
```

### Deactivate CVU

```http
DELETE /obp/v4.0.0/banks/{bank_id}/accounts/{account_id}/cvu/{cvu}
Authorization: DirectLogin token="..."
```

---

## Webhooks

### Webhook Structure - Transfer Received

```json
{
  "type": "transfer.cvu.received",
  "timestamp": "2024-01-15T14:30:00Z",
  "data": {
    "transaction_id": "txn-12345-abcde",
    "charge": {
      "summary": "Customer payment #1234",
      "value": {
        "currency": "ARS",
        "amount": "5000.00"
      }
    },
    "from": {
      "bank_id": "322",
      "account_id": "collection-account"
    },
    "counterparty": {
      "id": "20111222333",
      "name": "EXAMPLE CUSTOMER",
      "id_type": "CUIT_CUIL",
      "bank_routing": {
        "scheme": "NAME",
        "address": "BANCO GALICIA"
      }
    }
  },
  "redeliveries": 0
}
```

### Webhook Types

| Type | Description |
|------|-------------|
| `transfer.cvu.received` | Incoming transfer to CVU |
| `transfer.cbu.received` | Incoming transfer to CBU |
| `debin.approved` | DEBIN approved |
| `debin.rejected` | DEBIN rejected |
| `echeq.deposited` | eCheq deposited |
| `echeq.paid` | eCheq paid |
| `echeq.rejected` | eCheq rejected |

---

## Error Codes

### HTTP Status Codes

| Code | Description |
|------|-------------|
| 200 | OK - Successful request |
| 201 | Created - Resource created |
| 400 | Bad Request - Invalid parameters |
| 401 | Unauthorized - Invalid/expired token |
| 403 | Forbidden - No permissions for resource |
| 404 | Not Found - Resource not found |
| 409 | Conflict - Conflict (e.g., duplicate operation) |
| 422 | Unprocessable Entity - Validation failed |
| 429 | Too Many Requests - Rate limit exceeded |
| 500 | Internal Server Error |
| 503 | Service Unavailable |

### Error Structure

```json
{
  "error": {
    "code": "INSUFFICIENT_FUNDS",
    "message": "Insufficient funds to perform the operation",
    "details": {
      "available_balance": "8000.00",
      "requested_amount": "10000.00"
    }
  }
}
```

### Common Error Codes

| Code | Description |
|------|-------------|
| `INVALID_TOKEN` | Invalid authentication token |
| `TOKEN_EXPIRED` | Expired token |
| `INSUFFICIENT_FUNDS` | Insufficient funds |
| `INVALID_CBU` | Invalid CBU |
| `INVALID_CVU` | Invalid CVU |
| `ACCOUNT_NOT_FOUND` | Account not found |
| `DUPLICATE_TRANSACTION` | Duplicate transaction |
| `RATE_LIMIT_EXCEEDED` | Request limit exceeded |
| `OPERATION_NOT_ALLOWED` | Operation not allowed |
| `BANK_HOLIDAY` | Bank holiday |
| `OUTSIDE_OPERATING_HOURS` | Outside operating hours |
