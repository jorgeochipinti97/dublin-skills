# api-architect

## Activation Prompts

### Design mode (new API)

```
Diseñame una API para [dominio / producto]
```

```
Necesito armar una API escalable para [caso de uso]
```

```
Design a production-ready API for [use case] — auth, scaling, reliability, observability
```

```
Architectá una API REST/GraphQL para [producto], stack [Node/NestJS/FastAPI/Go]
```

### Audit mode (existing API)

```
Audita esta API y decime qué está mal
```

```
Review my API for scalability, security, reliability gaps
```

```
Diagnosticá mi API actual — [pegar OpenAPI / listar endpoints]
```

## Flow

1. The skill blocks and asks for context:
   - **Design**: domain, clients, scale, latency budget, consistency, auth, stack, constraints, SLO
   - **Audit**: what exists, pain points, scale, team, stack, compliance
2. You answer in one block.
3. The skill outputs a blueprint (design mode) or prioritized diagnosis (audit mode) with the WHY behind every decision.
4. For NestJS implementations → pair with `hexagonal-architect` for the code layout.
5. For DB / cloud hardening → pair with `infra-security`.

## Example Use Cases

- Public B2B REST API with OpenAPI + SDK generation
- Internal GraphQL BFF for a React app
- gRPC mesh for microservice-to-microservice traffic
- Webhook delivery system with retries + signing
- Multi-tenant SaaS API with RLS isolation
- Payments API with idempotency keys + strong consistency
- Real-time collaborative API (WebSocket + pub/sub)
- AI/LLM gateway with rate limiting + cost control
- Audit of a legacy monolith API pre-rewrite
- SLO + reliability review before a launch
