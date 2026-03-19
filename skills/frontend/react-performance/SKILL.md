---
name: react-performance
description: Audit and optimize React/Next.js application performance. Use when reviewing code for unnecessary useEffect, optimizing renders, splitting bundles, improving Core Web Vitals, choosing between Server and Client Components, or analyzing runtime performance. Targets React 18/19 and Next.js 14/15+.
---

# React Performance

Eliminate unnecessary complexity, reduce renders, ship less JavaScript.

## Audit Workflow

When asked to review performance, follow this order:

1. **Scan for useEffect abuse** -- derived state, event handlers disguised as effects, fetch-in-effect without cleanup
2. **Check component boundaries** -- Server vs Client Components, 'use client' placement, component splitting
3. **Analyze rendering** -- unnecessary re-renders, missing keys, inline object/function creation in JSX
4. **Review data fetching** -- waterfalls, missing preloading, no caching strategy
5. **Inspect bundle** -- large dependencies, missing code splitting, no lazy loading
6. **Measure** -- suggest profiling tools, Core Web Vitals targets

---

## useEffect Elimination

Most useEffect calls are code smells. Check every one against this decision tree:

### Replace with derived state (calculated during render)

```tsx
// BAD: synchronizing state with an effect
const [fullName, setFullName] = useState('');
useEffect(() => {
  setFullName(firstName + ' ' + lastName);
}, [firstName, lastName]);

// GOOD: just compute it
const fullName = firstName + ' ' + lastName;
```

```tsx
// BAD: filtering in effect
const [filtered, setFiltered] = useState([]);
useEffect(() => {
  setFiltered(items.filter(i => i.active));
}, [items]);

// GOOD: derive during render, memoize only if expensive
const filtered = useMemo(() => items.filter(i => i.active), [items]);
```

### Replace with event handlers

```tsx
// BAD: effect reacting to state change from user action
useEffect(() => {
  if (submitted) {
    sendAnalytics('form_submit');
    navigate('/thanks');
  }
}, [submitted]);

// GOOD: do it in the handler that caused the change
function handleSubmit() {
  sendAnalytics('form_submit');
  navigate('/thanks');
}
```

### Replace with key prop reset

```tsx
// BAD: resetting state with effect
useEffect(() => {
  setComment('');
}, [userId]);

// GOOD: use key to remount with fresh state
<CommentForm key={userId} />
```

### Legitimate useEffect uses

- Synchronizing with external systems (DOM APIs, third-party widgets, WebSocket)
- Setting up subscriptions (with cleanup)
- Fetching data on mount (prefer RSC, React Query, or SWR instead)

---

## Rendering Optimization

### React Compiler (React 19+)

React Compiler auto-memoizes -- it replaces manual useMemo, useCallback, and React.memo in most cases. If the project uses React 19+ with the compiler enabled, **do not add manual memoization**. The compiler handles it better with fine-grained dependency tracking.

### When manual memoization still matters (React 18 or no compiler)

- `useMemo` -- expensive computations only (sorting/filtering large arrays, complex math)
- `useCallback` -- only when passing to memoized children or as deps to other hooks
- `React.memo` -- components that receive the same props frequently but parent re-renders often

**Rule**: profile FIRST, memoize SECOND. Never memoize without evidence.

### Component splitting to reduce re-renders

```tsx
// BAD: entire page re-renders when clock ticks
function Page() {
  const [time, setTime] = useState(Date.now());
  useEffect(() => { /* interval */ }, []);
  return <div><Clock time={time} /><ExpensiveTree /></div>;
}

// GOOD: isolate the stateful part
function Page() {
  return <div><LiveClock /><ExpensiveTree /></div>;
}
function LiveClock() {
  const [time, setTime] = useState(Date.now());
  useEffect(() => { /* interval */ }, []);
  return <Clock time={time} />;
}
```

### Children as props pattern

```tsx
// Parent re-renders do NOT re-render children passed as props
function ScrollTracker({ children }: { children: React.ReactNode }) {
  const [scrollY, setScrollY] = useState(0);
  // children are stable -- they don't re-render when scrollY changes
  return <div onScroll={e => setScrollY(e.currentTarget.scrollTop)}>{children}</div>;
}
```

### useTransition / useDeferredValue

Use for non-urgent updates that can be deferred without blocking user input:

```tsx
const [query, setQuery] = useState('');
const deferredQuery = useDeferredValue(query);
// Input stays responsive, search results update with lower priority
<SearchResults query={deferredQuery} />
```

---

## Server Components & SSR (Next.js)

### Decision tree: Server vs Client Component

```
Does it use useState, useEffect, event handlers, or browser APIs?
  YES -> 'use client'
  NO  -> Keep as Server Component (default)

Does it only need interactivity in a small part?
  YES -> Extract the interactive part into a Client Component child
```

### Push 'use client' down

```tsx
// BAD: entire page is client
'use client';
export default function ProductPage({ id }) { ... }

// GOOD: only the interactive part is client
export default async function ProductPage({ id }) {
  const product = await getProduct(id); // runs on server, zero JS
  return (
    <div>
      <ProductDetails product={product} />  {/* Server Component */}
      <AddToCartButton productId={id} />    {/* Client Component */}
    </div>
  );
}
```

### Streaming with Suspense

```tsx
export default function Page() {
  return (
    <main>
      <Header />  {/* Instant */}
      <Suspense fallback={<ProductSkeleton />}>
        <ProductList />  {/* Streams when ready */}
      </Suspense>
      <Suspense fallback={<ReviewsSkeleton />}>
        <Reviews />  {/* Streams independently */}
      </Suspense>
    </main>
  );
}
```

---

## Bundle Optimization

### Dynamic imports

```tsx
const HeavyEditor = dynamic(() => import('@/components/Editor'), {
  loading: () => <EditorSkeleton />,
  ssr: false,  // only if component uses browser APIs
});
```

### Barrel file warning

Barrel files (`index.ts` re-exporting everything) can defeat tree shaking. Import directly:

```tsx
// BAD: pulls entire library of icons
import { SearchIcon } from '@/components/icons';

// GOOD: import the specific file
import { SearchIcon } from '@/components/icons/SearchIcon';
```

### Analysis tools

- `@next/bundle-analyzer` -- visual treemap of bundles
- `source-map-explorer` -- analyze production source maps
- `why-did-you-render` -- detect unnecessary re-renders in development

---

## Data Fetching

### React.cache() for request deduplication

```tsx
// Calling getUser(id) multiple times in one render tree
// only hits the database once
const getUser = cache(async (id: string) => {
  return db.user.findUnique({ where: { id } });
});
```

### Preload pattern

```tsx
// Trigger fetch early, consume later
export const preloadProduct = (id: string) => void getProduct(id);

// In the parent component
export default function Page({ id }) {
  preloadProduct(id); // fire immediately
  return (
    <Suspense fallback={<Skeleton />}>
      <ProductDetails id={id} />
    </Suspense>
  );
}
```

### Avoid waterfalls

```tsx
// BAD: sequential
const user = await getUser(id);
const posts = await getPosts(id);

// GOOD: parallel
const [user, posts] = await Promise.all([getUser(id), getPosts(id)]);
```

---

## Anti-Patterns Checklist

Flag these during code review:

| Anti-Pattern | Fix |
|---|---|
| useEffect for derived state | Compute during render |
| useEffect for event reactions | Move to event handler |
| useEffect to reset state on prop change | Use `key` prop |
| fetch inside useEffect without abort controller | Use React Query/SWR or RSC |
| Inline `style={{}}` or `() => {}` in JSX of memoized children | Extract to stable references |
| Entire page marked 'use client' | Push boundary down to interactive leaf |
| Barrel file imports | Import from specific file path |
| `JSON.stringify` in dependency arrays | Restructure to use primitive deps |
| State for values that never change after mount | Use `useRef` |
| Premature `useMemo`/`useCallback` everywhere | Profile first, memoize with evidence |

---

## Reference Files

Load when implementing specific optimizations:

- `references/react-patterns.md` -- Detailed React rendering patterns, useEffect alternatives, memoization strategy
- `references/nextjs-patterns.md` -- Server Components, caching, image/font optimization, streaming, bundle analysis

---

## Output Standards

When suggesting performance fixes:

1. Show the problematic code with explanation of WHY it's slow
2. Show the optimized version
3. Explain the tradeoff (if any)
4. Suggest measurement approach (profiler, Lighthouse, bundle size)
