---
name: domain-modeler
description: Model business domains using DDD patterns - entities, value objects, aggregates, domain events. Use when designing the core business logic layer before writing code. Outputs domain model diagrams, ubiquitous language glossary, and business rules.
---

# Domain Modeler

Design the heart of your system: the business logic.

## Core Concepts

### Entity
Has identity that persists over time.
```typescript
// ✅ Entity - identity matters
class User {
  readonly id: UserId;        // Identity
  private email: Email;       // Can change
  private name: string;       // Can change
}

// Two users with same email are still different users
```

### Value Object
Defined by attributes, no identity. Immutable.
```typescript
// ✅ Value Object - defined by value
class Money {
  constructor(
    readonly amount: number,
    readonly currency: Currency
  ) {}
  
  add(other: Money): Money {
    // Returns NEW instance, immutable
    return new Money(this.amount + other.amount, this.currency);
  }
}

// Two Money(100, USD) are equal and interchangeable
```

### Aggregate
Cluster of entities/VOs with a root. Consistency boundary.
```typescript
// ✅ Aggregate - Order is the root
class Order {                    // Aggregate Root
  readonly id: OrderId;
  private items: OrderItem[];    // Entity, only accessed via Order
  private status: OrderStatus;   // Value Object
  
  addItem(product: Product, quantity: number): void {
    // Business rule enforced here
    if (this.status !== 'draft') {
      throw new CannotModifySubmittedOrder();
    }
    this.items.push(new OrderItem(product, quantity));
  }
}

// OrderItem can't exist without Order
// All changes to OrderItem go through Order
```

### Domain Event
Something that happened in the domain.
```typescript
// ✅ Domain Event - past tense, immutable
class OrderPlaced {
  constructor(
    readonly orderId: OrderId,
    readonly customerId: CustomerId,
    readonly items: ReadonlyArray<OrderItemSnapshot>,
    readonly total: Money,
    readonly placedAt: Date
  ) {}
}
```

## Modeling Process

### Step 1: Event Storming (Discover)
1. List all **events** (past tense: OrderPlaced, PaymentReceived)
2. Identify **commands** that trigger events (PlaceOrder, ProcessPayment)
3. Find **aggregates** that handle commands
4. Discover **policies** (When X happens, do Y)

### Step 2: Build Ubiquitous Language
Create a glossary everyone uses:

| Term | Definition | NOT |
|------|------------|-----|
| Order | A customer's intent to purchase items | Shopping cart |
| Fulfillment | Process of preparing order for delivery | Shipping |
| SKU | Unique product variant identifier | Product ID |

### Step 3: Define Aggregates
For each aggregate:
- What's the **root entity**?
- What **entities/VOs** belong inside?
- What **invariants** must always be true?
- What **commands** does it handle?
- What **events** does it emit?

### Step 4: Draw Boundaries
```
┌─────────────────────────────────────────────────────────┐
│                    Order Context                         │
│  ┌─────────────┐      ┌─────────────┐                   │
│  │   Order     │      │  Customer   │                   │
│  │  Aggregate  │      │ (reference) │                   │
│  └─────────────┘      └─────────────┘                   │
└─────────────────────────────────────────────────────────┘
         │ OrderPlaced
         ▼
┌─────────────────────────────────────────────────────────┐
│                  Fulfillment Context                     │
│  ┌─────────────┐      ┌─────────────┐                   │
│  │  Shipment   │      │  Warehouse  │                   │
│  │  Aggregate  │      │  Aggregate  │                   │
│  └─────────────┘      └─────────────┘                   │
└─────────────────────────────────────────────────────────┘
```

## Output: Domain Model Document

```markdown
# [Context Name] Domain Model

## Ubiquitous Language
| Term | Definition |
|------|------------|
| ... | ... |

## Aggregates

### [Aggregate Name]
**Root**: [EntityName]
**Contains**: [List of entities/VOs]

**Invariants**:
- [Rule that must always be true]
- [Another rule]

**Commands**:
- `CommandName(params)` → EventName

**Events**:
- `EventName` - [when it occurs]

## Domain Events Flow
[Diagram or list of event chains]
```

## Anti-Patterns
- ❌ Anemic domain (entities with only getters/setters)
- ❌ God aggregate (one aggregate doing everything)
- ❌ Leaking domain logic to services
- ❌ Using database IDs as domain identity
- ❌ Mutable value objects
