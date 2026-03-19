# React Performance Patterns

## useEffect Alternatives -- Complete Guide

### 1. Derived State (most common fix)

Any value that can be computed from existing props or state should NOT be in state.

```tsx
// ANTI-PATTERN: redundant state + effect chain
function ProductList({ products, category }: Props) {
  const [filtered, setFiltered] = useState<Product[]>([]);
  const [count, setCount] = useState(0);

  useEffect(() => {
    const result = products.filter(p => p.category === category);
    setFiltered(result);
  }, [products, category]);

  useEffect(() => {
    setCount(filtered.length);
  }, [filtered]);

  // Two unnecessary re-renders per products/category change
}

// FIX: derive everything inline
function ProductList({ products, category }: Props) {
  const filtered = products.filter(p => p.category === category);
  const count = filtered.length;
  // Zero extra renders. Computed on every render (cheap for <10k items).
}
```

When filtering/sorting is genuinely expensive (10k+ items, complex comparisons):

```tsx
const filtered = useMemo(
  () => products.filter(p => expensiveMatch(p, category)),
  [products, category]
);
```

### 2. Event Handlers (second most common fix)

If an effect runs in response to a user action, the logic belongs in the event handler.

```tsx
// ANTI-PATTERN: "effect chain" -- state change triggers effect triggers side effect
function CheckoutForm() {
  const [items, setItems] = useState<Item[]>([]);

  useEffect(() => {
    if (items.length === 0) {
      showToast('Cart is empty');
      redirect('/shop');
    }
  }, [items]);

  function removeItem(id: string) {
    setItems(prev => prev.filter(i => i.id !== id));
  }
}

// FIX: handle consequences in the action
function CheckoutForm() {
  const [items, setItems] = useState<Item[]>([]);

  function removeItem(id: string) {
    const next = items.filter(i => i.id !== id);
    setItems(next);
    if (next.length === 0) {
      showToast('Cart is empty');
      redirect('/shop');
    }
  }
}
```

### 3. Key Prop Reset

Reset component state when a prop changes by changing its `key`:

```tsx
// ANTI-PATTERN: resetting form state in effect
function EditProfile({ userId }: { userId: string }) {
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');

  useEffect(() => {
    setName('');
    setEmail('');
    // Easy to forget new fields here
  }, [userId]);
}

// FIX: key forces React to unmount and remount with fresh state
function ProfilePage({ userId }: { userId: string }) {
  return <EditProfile key={userId} userId={userId} />;
}

function EditProfile({ userId }: { userId: string }) {
  const [name, setName] = useState(''); // automatically fresh per userId
  const [email, setEmail] = useState('');
}
```

### 4. useSyncExternalStore

For subscribing to external stores (browser APIs, third-party state):

```tsx
// ANTI-PATTERN: manual subscription in effect
function useWindowWidth() {
  const [width, setWidth] = useState(window.innerWidth);
  useEffect(() => {
    const handler = () => setWidth(window.innerWidth);
    window.addEventListener('resize', handler);
    return () => window.removeEventListener('resize', handler);
  }, []);
  return width;
}

// BETTER: useSyncExternalStore handles SSR, tearing, and concurrent mode
function useWindowWidth() {
  return useSyncExternalStore(
    (callback) => {
      window.addEventListener('resize', callback);
      return () => window.removeEventListener('resize', callback);
    },
    () => window.innerWidth,
    () => 1024 // server snapshot
  );
}
```

### 5. Initializer Functions

For expensive initial state, pass a function to useState:

```tsx
// BAD: runs on every render
const [data] = useState(expensiveParse(rawData));

// GOOD: runs only on mount
const [data] = useState(() => expensiveParse(rawData));
```

---

## Memoization Strategy

### React 19 with Compiler

The React Compiler transforms your code at build time. It:
- Automatically memoizes JSX elements, inline objects, and functions
- Tracks dependencies at a finer granularity than manual deps arrays
- Eliminates the need for useMemo, useCallback, and React.memo in most cases

**Detection**: Check `babel.config.js` or `next.config.js` for `reactCompiler: true` or `babel-plugin-react-compiler`.

**When compiler is active**: Remove manual useMemo/useCallback unless wrapping a truly expensive computation (>1ms). The compiler handles render optimization automatically.

### React 18 / No Compiler -- Manual Memoization

Only memoize when you have EVIDENCE of a performance problem.

```tsx
// When to use React.memo
// Scenario: Parent re-renders frequently, child receives same props
const ExpensiveChart = React.memo(function Chart({ data }: { data: Point[] }) {
  // Complex SVG rendering
  return <svg>...</svg>;
});

// When to use useCallback
// Scenario: Callback passed to a memoized child
function Parent() {
  // Without useCallback, handleClick is new every render,
  // defeating React.memo on ExpensiveChart
  const handleClick = useCallback((point: Point) => {
    setSelected(point.id);
  }, []);

  return <ExpensiveChart data={data} onClick={handleClick} />;
}

// When to use useMemo
// Scenario: Computation takes >1ms (measure with performance.now())
function Dashboard({ transactions }: Props) {
  const summary = useMemo(() => {
    // Aggregating 50k transactions
    return transactions.reduce((acc, tx) => {
      // complex grouping, summing, percentile calculations
    }, initialAcc);
  }, [transactions]);
}
```

---

## Advanced Rendering Patterns

### Extracting state down

```tsx
// PROBLEM: typing in input re-renders the entire expensive list
function Page() {
  const [query, setQuery] = useState('');
  return (
    <div>
      <input value={query} onChange={e => setQuery(e.target.value)} />
      <VeryExpensiveList />  {/* re-renders on every keystroke */}
    </div>
  );
}

// FIX: extract the stateful part into its own component
function SearchInput() {
  const [query, setQuery] = useState('');
  return <input value={query} onChange={e => setQuery(e.target.value)} />;
}

function Page() {
  return (
    <div>
      <SearchInput />
      <VeryExpensiveList />  {/* never re-renders from typing */}
    </div>
  );
}
```

### Lifting content up (children pattern)

```tsx
// PROBLEM: color picker state causes children to re-render
function ColorPicker({ children }: { children: React.ReactNode }) {
  const [color, setColor] = useState('red');
  return (
    <div style={{ color }}>
      <input value={color} onChange={e => setColor(e.target.value)} />
      {children}  {/* stable reference, no re-render */}
    </div>
  );
}

// Usage: ExpensiveComponent does NOT re-render when color changes
<ColorPicker>
  <ExpensiveComponent />
</ColorPicker>
```

### Virtualization for large lists

When rendering 1000+ items, use virtualization to only render visible items:

```tsx
// react-window (lightweight)
import { FixedSizeList } from 'react-window';

function VirtualList({ items }: { items: Item[] }) {
  return (
    <FixedSizeList
      height={600}
      itemCount={items.length}
      itemSize={50}
      width="100%"
    >
      {({ index, style }) => (
        <div style={style}>
          <ItemRow item={items[index]} />
        </div>
      )}
    </FixedSizeList>
  );
}

// @tanstack/react-virtual (more flexible, headless)
import { useVirtualizer } from '@tanstack/react-virtual';

function VirtualList({ items }: { items: Item[] }) {
  const parentRef = useRef<HTMLDivElement>(null);
  const virtualizer = useVirtualizer({
    count: items.length,
    getScrollElement: () => parentRef.current,
    estimateSize: () => 50,
  });

  return (
    <div ref={parentRef} style={{ height: 600, overflow: 'auto' }}>
      <div style={{ height: virtualizer.getTotalSize() }}>
        {virtualizer.getVirtualItems().map(row => (
          <div
            key={row.key}
            style={{
              position: 'absolute',
              top: row.start,
              height: row.size,
              width: '100%',
            }}
          >
            <ItemRow item={items[row.index]} />
          </div>
        ))}
      </div>
    </div>
  );
}
```

### useTransition for expensive updates

```tsx
function FilterableList({ items }: { items: Item[] }) {
  const [query, setQuery] = useState('');
  const [isPending, startTransition] = useTransition();

  // deferredQuery updates at low priority
  const [deferredQuery, setDeferredQuery] = useState('');

  function handleChange(e: React.ChangeEvent<HTMLInputElement>) {
    setQuery(e.target.value);  // urgent: update input immediately
    startTransition(() => {
      setDeferredQuery(e.target.value);  // non-urgent: filter can wait
    });
  }

  const filtered = items.filter(i => i.name.includes(deferredQuery));

  return (
    <div>
      <input value={query} onChange={handleChange} />
      <div style={{ opacity: isPending ? 0.7 : 1 }}>
        {filtered.map(item => <ItemCard key={item.id} item={item} />)}
      </div>
    </div>
  );
}
```

---

## Performance Profiling Checklist

1. **React DevTools Profiler** -- Record renders, identify which components re-render and why
2. **React.StrictMode** -- Runs effects twice in dev to catch missing cleanup
3. **why-did-you-render** -- Logs unnecessary re-renders with prop diff
4. **Chrome Performance tab** -- Flame chart for long tasks, layout thrashing
5. **Lighthouse** -- Core Web Vitals: LCP < 2.5s, FID < 100ms, CLS < 0.1
6. **`performance.mark()`/`performance.measure()`** -- Custom timing for specific operations
