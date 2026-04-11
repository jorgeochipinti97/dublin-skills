# data-viz-architect

## Activation Prompts

```
Armame un dashboard para [producto / API / caso de uso]
```

```
Tengo esta API y no sé qué gráficos usar para mostrar [X, Y, Z]
```

```
Necesito un dashboard de [ventas / analytics / monitoreo / usuarios]
```

```
Help me design a dashboard for [data source / use case]
```

```
I need to visualize [data] — which charts should I use and why?
```

```
¿Qué gráfico uso para mostrar [métrica] contra [dimensión]?
```

## Flow

1. The skill blocks and asks for context (data source, business question, audience, metrics, slicing, refresh cadence, stack).
2. You answer in one block (pasting a sample of the API response helps a lot).
3. The skill outputs a Markdown blueprint: metric hierarchy + layout + chart picks WITH reasons + filters + data flow + library + design notes.
4. Pass the blueprint to `product-ux-advisor` for UX review (empty/loading/error states, filter UX).
5. Pass the reviewed blueprint to `premium-frontend-design` for implementation.

## Example Use Cases

- SaaS product analytics dashboard (DAU, MAU, retention, funnel)
- Sales / revenue monitoring dashboard
- E-commerce orders & inventory dashboard
- Server / infrastructure monitoring
- Marketing campaign performance
- Financial trading / portfolio dashboard
- User behavior / event analytics
- Customer support queue & SLA
- IoT / sensor data visualization
- Personal habit / health tracker
