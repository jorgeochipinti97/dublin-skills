# Next.js Performance Patterns

## Server Components vs Client Components

### Decision Matrix

| Need | Component Type | Why |
|------|---------------|-----|
| Fetch data | Server | Direct DB/API access, zero client JS |
| Read files/env vars | Server | Access server-only resources |
| Static content | Server | No hydration cost |
| useState / useReducer | Client | State requires client runtime |
| useEffect / lifecycle | Client | Effects run in browser |
| onClick / onChange | Client | Event handlers need browser |
| Browser APIs (localStorage, etc.) | Client | Not available on server |
| Custom hooks with state/effects | Client | Depends on client features |

### Composition Pattern

Server Components can import Client Components, but NOT the other way around. Pass Server Components as children to Client Components:

```tsx
// layout.tsx (Server Component)
import { Sidebar } from './Sidebar';       // Client Component
import { UserNav } from './UserNav';       // Server Component (async data)

export default function Layout({ children }) {
  return (
    <Sidebar>                              {/* Client: handles collapse state */}
      <UserNav />                          {/* Server: fetches user, zero JS */}
      {children}
    </Sidebar>
  );
}
```

### Serialization boundary

Props passed from Server to Client Components must be serializable (no functions, classes, Dates, Maps):

```tsx
// BAD: passing a function from server to client
<ClientButton onClick={() => deleteItem(id)} />

// GOOD: pass data, let client define the handler
<ClientButton itemId={id} />

// Or use Server Actions
<ClientButton action={deleteItem} />
```

---

## Caching Strategies

### React.cache() -- request-level deduplication

```tsx
// lib/data.ts
import { cache } from 'react';

// Multiple components calling getUser() in the same request
// only execute the query once
export const getUser = cache(async (id: string) => {
  const user = await db.user.findUnique({ where: { id } });
  return user;
});
```

Scope: single server request. Resets on every new request.

### 'use cache' directive (Next.js 15+, experimental)

```tsx
// Cache at function level
async function getProducts() {
  'use cache';
  return db.product.findMany();
}

// Cache at component level
async function ProductList() {
  'use cache';
  const products = await db.product.findMany();
  return <ul>{products.map(p => <li key={p.id}>{p.name}</li>)}</ul>;
}

// Control cache lifetime
import { cacheLife } from 'next/cache';

async function getProducts() {
  'use cache';
  cacheLife('hours');  // predefined profile
  return db.product.findMany();
}
```

### Revalidation

```tsx
// Time-based
// next.config.js or fetch options
fetch(url, { next: { revalidate: 3600 } }); // revalidate every hour

// On-demand via Server Action
import { revalidatePath, revalidateTag } from 'next/cache';

async function updateProduct(id: string, data: ProductData) {
  'use server';
  await db.product.update({ where: { id }, data });
  revalidateTag('products');      // invalidate by tag
  revalidatePath('/products');    // invalidate by path
}

// Tag-based fetch
fetch(url, { next: { tags: ['products'] } });
```

---

## Image Optimization

```tsx
import Image from 'next/image';

// Always use next/image -- automatic WebP/AVIF, lazy loading, sizing
<Image
  src="/hero.jpg"
  alt="Hero image"
  width={1200}
  height={600}
  priority          // LCP image: disable lazy loading
  placeholder="blur" // show blurred version while loading
  sizes="(max-width: 768px) 100vw, 50vw"  // responsive sizing hints
/>

// For dynamic/unknown dimensions
<Image
  src={user.avatar}
  alt={user.name}
  fill                    // fills parent container
  className="object-cover"
  sizes="(max-width: 768px) 64px, 128px"
/>
```

**Common mistakes**:
- Missing `sizes` prop -- browser downloads largest image variant
- Missing `priority` on LCP image -- unnecessary lazy load delay
- Using `<img>` tag directly -- no optimization, no lazy loading
- Not setting `width`/`height` or `fill` -- causes layout shift (CLS)

---

## Font Optimization

```tsx
// app/layout.tsx
import { Inter, Instrument_Serif } from 'next/font/google';

const inter = Inter({
  subsets: ['latin'],
  display: 'swap',        // prevent FOIT
  variable: '--font-inter',
});

const serif = Instrument_Serif({
  weight: '400',
  subsets: ['latin'],
  display: 'swap',
  variable: '--font-serif',
});

export default function RootLayout({ children }) {
  return (
    <html className={`${inter.variable} ${serif.variable}`}>
      <body>{children}</body>
    </html>
  );
}
```

Next.js automatically self-hosts fonts (no external Google Fonts requests).

---

## Script Optimization

```tsx
import Script from 'next/script';

// Analytics: load after page is interactive
<Script src="https://analytics.example.com" strategy="afterInteractive" />

// Non-critical: load during idle time
<Script src="https://widget.example.com" strategy="lazyOnload" />

// Critical: inline in head (rare -- use sparingly)
<Script id="critical-config" strategy="beforeInteractive">
  {`window.CONFIG = { api: '${process.env.API_URL}' }`}
</Script>
```

---

## Streaming & Suspense

### Route-level loading

```tsx
// app/products/loading.tsx -- automatic Suspense wrapper for the route
export default function Loading() {
  return <ProductGridSkeleton />;
}
```

### Component-level streaming

```tsx
// Stream different parts of the page independently
export default function Dashboard() {
  return (
    <div className="grid grid-cols-3 gap-4">
      <Suspense fallback={<MetricsSkeleton />}>
        <Metrics />    {/* Fetches metrics, streams when ready */}
      </Suspense>
      <Suspense fallback={<ChartSkeleton />}>
        <RevenueChart />  {/* Independent data, independent stream */}
      </Suspense>
      <Suspense fallback={<TableSkeleton />}>
        <RecentOrders />
      </Suspense>
    </div>
  );
}
```

### Preloading data

```tsx
// Trigger fetch before component that needs it renders
import { getProduct, getReviews } from '@/lib/data';

export default async function ProductPage({ params }) {
  // Start both fetches immediately (parallel)
  const productPromise = getProduct(params.id);
  const reviewsPromise = getReviews(params.id);

  const product = await productPromise;

  return (
    <div>
      <ProductInfo product={product} />
      <Suspense fallback={<ReviewsSkeleton />}>
        <Reviews promise={reviewsPromise} />
      </Suspense>
    </div>
  );
}
```

---

## Bundle Analysis

### Setup

```bash
pnpm add @next/bundle-analyzer
```

```js
// next.config.js
const withBundleAnalyzer = require('@next/bundle-analyzer')({
  enabled: process.env.ANALYZE === 'true',
});

module.exports = withBundleAnalyzer(nextConfig);
```

```bash
ANALYZE=true pnpm build
```

### Common bundle issues

| Issue | Symptom | Fix |
|-------|---------|-----|
| Large dependency in client bundle | Chunk > 100kb | Dynamic import or move to server |
| Moment.js / date-fns full import | 70kb+ for dates | Use `dayjs` or import specific functions |
| Lodash full import | 70kb+ | `import debounce from 'lodash/debounce'` |
| Icon library full import | 50kb+ | Import specific icons |
| Barrel files defeating tree shaking | Unexpectedly large chunks | Direct file imports |
| Duplicate dependencies | Same lib in multiple chunks | Check `npm ls` for version conflicts |

### Dynamic imports for heavy components

```tsx
import dynamic from 'next/dynamic';

// Code editor -- only load when needed
const CodeEditor = dynamic(() => import('@/components/CodeEditor'), {
  loading: () => <div className="h-96 animate-pulse bg-muted rounded" />,
});

// Chart library -- skip SSR (uses canvas/DOM)
const Chart = dynamic(() => import('@/components/Chart'), {
  ssr: false,
  loading: () => <ChartSkeleton />,
});

// Conditional load -- only import if feature flag is on
const AdminPanel = dynamic(() => import('@/components/AdminPanel'));
```

---

## Route Segment Config

```tsx
// app/blog/[slug]/page.tsx

// Static: pre-render at build time
export const dynamic = 'force-static';

// Dynamic: always render on request
export const dynamic = 'force-dynamic';

// Revalidate every hour
export const revalidate = 3600;

// Generate static params for build
export async function generateStaticParams() {
  const posts = await getPosts();
  return posts.map(post => ({ slug: post.slug }));
}
```

---

## Parallel Routes

Render multiple pages simultaneously in the same layout:

```
app/
  @analytics/page.tsx    -- analytics panel
  @sidebar/page.tsx      -- sidebar content
  layout.tsx             -- composes both
  page.tsx               -- main content
```

```tsx
// layout.tsx
export default function Layout({
  children,
  analytics,
  sidebar,
}: {
  children: React.ReactNode;
  analytics: React.ReactNode;
  sidebar: React.ReactNode;
}) {
  return (
    <div className="flex">
      {sidebar}
      <main>{children}</main>
      {analytics}
    </div>
  );
}
```

Each slot loads independently and can have its own loading/error states.

---

## Core Web Vitals Targets

| Metric | Good | Needs Work | Poor |
|--------|------|------------|------|
| LCP (Largest Contentful Paint) | < 2.5s | 2.5-4s | > 4s |
| INP (Interaction to Next Paint) | < 200ms | 200-500ms | > 500ms |
| CLS (Cumulative Layout Shift) | < 0.1 | 0.1-0.25 | > 0.25 |

**Quick wins for each:**
- **LCP**: `priority` on hero image, preload fonts, reduce server response time
- **INP**: useTransition for expensive updates, avoid sync work in event handlers, code split heavy components
- **CLS**: Set explicit `width`/`height` on images, use `next/font` with `display: swap`, reserve space for dynamic content
