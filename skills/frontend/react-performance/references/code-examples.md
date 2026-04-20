# React Performance — Code Examples

## useEffect Elimination

### Replace with derived state

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

## Component Splitting

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
  return <div onScroll={e => setScrollY(e.currentTarget.scrollTop)}>{children}</div>;
}
```

### useDeferredValue

```tsx
const [query, setQuery] = useState('');
const deferredQuery = useDeferredValue(query);
// Input stays responsive, search results update with lower priority
<SearchResults query={deferredQuery} />
```

## Server Components

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

## Bundle Optimization

### Dynamic imports

```tsx
const HeavyEditor = dynamic(() => import('@/components/Editor'), {
  loading: () => <EditorSkeleton />,
  ssr: false,
});
```

### Barrel file imports

```tsx
// BAD: pulls entire library of icons
import { SearchIcon } from '@/components/icons';

// GOOD: import the specific file
import { SearchIcon } from '@/components/icons/SearchIcon';
```

## Data Fetching

### React.cache() for request deduplication

```tsx
const getUser = cache(async (id: string) => {
  return db.user.findUnique({ where: { id } });
});
```

### Preload pattern

```tsx
export const preloadProduct = (id: string) => void getProduct(id);

export default function Page({ id }) {
  preloadProduct(id);
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
