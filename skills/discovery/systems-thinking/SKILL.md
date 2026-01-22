---
name: systems-thinking
description: Analyze products as systems with feedback loops, leverage points, and emergent behavior. Use when designing scalable products, identifying bottlenecks, or understanding complex interactions. Outputs system maps, causal loop diagrams, and leverage point analysis.
---

# Systems Thinking

See your product as a system, not a collection of features.

## Core Principle

> "A system is more than the sum of its parts. It's the product of their interactions."

## System Elements

```
┌────────────────────────────────────────────────────────────┐
│                         SYSTEM                             │
│                                                            │
│  ┌──────────┐    Flows    ┌──────────┐    Flows           │
│  │  Stock   │ ──────────► │  Stock   │ ──────────►        │
│  │ (State)  │ ◄────────── │ (State)  │ ◄──────────        │
│  └──────────┘   Feedback  └──────────┘   Feedback         │
│       │                        │                          │
│       └────────────────────────┘                          │
│              Interconnections                              │
│                                                            │
│  Governed by: RULES (explicit and implicit)               │
└────────────────────────────────────────────────────────────┘
```

### Stocks
Things that accumulate. You can measure them at a point in time.
- Users, Revenue, Technical Debt, Trust, Knowledge

### Flows
Rates of change. Inflows increase stocks, outflows decrease them.
- User signups (inflow) vs Churn (outflow)
- Feature development (inflow) vs Bug creation (outflow)

### Feedback Loops
Circular causality. Two types:

**Reinforcing (R)** - Amplifies change (growth or collapse)
```
More Users → More Content → More Value → More Users → ...
```

**Balancing (B)** - Seeks equilibrium
```
More Users → More Load → Slower App → Less Users → ...
```

## Leverage Points (Meadows)

Where to intervene, from least to most effective:

| Level | Leverage Point | Example |
|-------|---------------|---------|
| 12 | Numbers (parameters) | Pricing, limits |
| 11 | Buffer sizes | Cache, queues |
| 10 | Stock-flow structures | Architecture |
| 9 | Delays | Feedback speed |
| 8 | Balancing loops | Rate limiting |
| 7 | Reinforcing loops | Viral mechanics |
| 6 | Information flows | Metrics visibility |
| 5 | Rules | Policies, constraints |
| 4 | Self-organization | Team autonomy |
| 3 | Goals | OKRs, North Star |
| 2 | Paradigm | Mental models |
| 1 | Transcending paradigms | Questioning assumptions |

**Rule**: Higher numbers = easier to change, lower impact. 
Lower numbers = harder to change, higher impact.

## Causal Loop Diagram

```
                    ┌──────────────────┐
                    │                  │
                    ▼                  │
            ┌──────────────┐           │
   ┌───────►│    Users     │───────────┤
   │        └──────────────┘           │
   │               │                   │
   │               │ +                 │
   │               ▼                   │
   │        ┌──────────────┐           │
   │        │   Content    │           │ (R) Reinforcing
   │        └──────────────┘           │
   │               │                   │
   │               │ +                 │
   │               ▼                   │
   │        ┌──────────────┐           │
   │        │   Value      │───────────┘
   │        └──────────────┘
   │               │
   │ +             │ -
   │               ▼
   │        ┌──────────────┐
   │        │    Load      │
   │        └──────────────┘
   │               │
   │               │ -
   │               ▼
   │        ┌──────────────┐
   └────────│ Performance  │ (B) Balancing
            └──────────────┘
```

## Analysis Framework

### Step 1: Map the System
1. Identify the **stocks** (what accumulates)
2. Draw the **flows** (what changes the stocks)
3. Find the **feedback loops** (circular causality)
4. Note the **delays** (time between cause and effect)

### Step 2: Find Bottlenecks
Where does flow get constrained?
- **Physical**: Server capacity, team size
- **Policy**: Approval processes, rate limits
- **Information**: Lack of visibility, slow feedback

### Step 3: Identify Leverage Points
Where can small changes create big effects?
- Reinforcing loops to amplify
- Balancing loops to stabilize
- Delays to shorten
- Information flows to improve

### Step 4: Anticipate Behavior
Common system behaviors:
- **Exponential growth**: Unchecked reinforcing loop
- **Goal-seeking**: Balancing loop toward target
- **Oscillation**: Delayed balancing loop
- **S-curve**: Growth hitting limits
- **Overshoot & collapse**: Delayed feedback + limits

## Output: System Map Document

```markdown
# [System Name] Analysis

## Stocks
| Stock | Description | Current State |
|-------|-------------|---------------|
| Users | Active monthly users | Growing |
| Tech Debt | Accumulated shortcuts | High |

## Key Flows
| Flow | Type | Affects | Rate |
|------|------|---------|------|
| Signups | Inflow | Users | +5%/month |
| Churn | Outflow | Users | -2%/month |

## Feedback Loops

### R1: Viral Growth
Users → Referrals → New Users → More Referrals
**Status**: Active, healthy

### B1: Performance Degradation  
Users → Load → Latency → Churn → Fewer Users
**Status**: Risk at 10K users

## Leverage Points Identified
1. **[High]** Add caching (affects B1)
2. **[Medium]** Improve referral flow (amplifies R1)
3. **[Low]** Adjust pricing (minimal impact)

## Recommendations
1. Address B1 before it dominates R1
2. Shorten feedback delay on performance metrics
```

## Anti-Patterns

- ❌ Treating symptoms instead of causes
- ❌ Ignoring feedback loops
- ❌ Assuming linear relationships
- ❌ Underestimating delays
- ❌ Optimizing parts instead of whole
- ❌ Pushing growth without considering limits
