---
name: react-performance
description: Audit and optimize React/Next.js application performance. Use when reviewing code for unnecessary useEffect, optimizing renders, splitting bundles, improving Core Web Vitals, choosing between Server and Client Components, or analyzing runtime performance. Targets React 18/19 and Next.js 14/15+.
---

# React Performance

Eliminate unnecessary complexity, reduce renders, ship less JavaScript.

## Audit Workflow

Review in this order:
1. **useEffect abuse** — derived state, event handlers disguised as effects, fetch without cleanup
2. **Component boundaries** — Server vs Client, 'use client' placement, component splitting
3. **Rendering** — unnecessary re-renders, missing keys, inline objects/functions in JSX
4. **Data fetching** — waterfalls, missing preloading, no caching
5. **Bundle** — large deps, missing code splitting, no lazy loading
6. **Measure** — profiling tools, Core Web Vitals targets

## useEffect Elimination

Most useEffect calls are code smells. Decision tree:

| Pattern | Replace With |
|---------|-------------|
| Sync state from other state/props | Derived value (compute during render) |
| Expensive derived computation | `useMemo` |
| React to user action | Event handler |
| Reset state on prop change | `key` prop to remount |
| Fetch data on mount | RSC, React Query, or SWR |

**Legitimate uses**: external system sync (DOM APIs, WebSocket), subscriptions with cleanup.

## Rendering Optimization

- **React 19+ with Compiler**: Do NOT add manual memoization. Compiler handles it.
- **React 18 / no compiler**: `useMemo` for expensive computations, `useCallback` for memoized children deps, `React.memo` for frequently-same-props components
- **Rule**: Profile FIRST, memoize SECOND. Never memoize without evidence.
- **Component splitting**: Isolate stateful parts so expensive siblings don't re-render
- **Children as props**: Parent re-renders don't re-render children passed as props
- **`useDeferredValue`**: For non-urgent updates (search results while typing)

## Server Components (Next.js)

- Default is Server Component. Only add `'use client'` if it uses state, effects, event handlers, or browser APIs
- **Push 'use client' down** — extract interactive parts into Client Component children
- **Streaming**: Wrap async components in `<Suspense>` for parallel streaming

## Bundle Optimization

- **Dynamic imports**: `next/dynamic` for heavy components, `ssr: false` if browser-only
- **Barrel file warning**: Import from specific file paths, not index re-exports
- **Tools**: `@next/bundle-analyzer`, `source-map-explorer`, `why-did-you-render`

## Data Fetching

- **`React.cache()`** for request deduplication across render tree
- **Preload pattern**: Fire fetch early in parent, consume in child via Suspense
- **Parallel**: `Promise.all()` instead of sequential awaits

## Anti-Patterns Checklist

| Anti-Pattern | Fix |
|---|---|
| useEffect for derived state | Compute during render |
| useEffect for event reactions | Move to event handler |
| useEffect to reset state on prop change | Use `key` prop |
| fetch in useEffect without abort | Use React Query/SWR or RSC |
| Inline `style={{}}` in memoized children | Extract to stable references |
| Entire page `'use client'` | Push boundary to interactive leaf |
| Barrel file imports | Import from specific path |
| `JSON.stringify` in dep arrays | Use primitive deps |
| State for mount-only values | Use `useRef` |
| Premature `useMemo`/`useCallback` | Profile first |

## Reference Files

- `references/react-patterns.md` — Detailed rendering patterns, useEffect alternatives, memoization
- `references/nextjs-patterns.md` — Server Components, caching, image/font optimization, streaming
- `references/code-examples.md` — BAD/GOOD code pairs for all patterns above

## Output Standards

- Be CONCISE — show problematic code, then fix, then one-line tradeoff explanation
- No verbose preambles. Lead with the code change.
