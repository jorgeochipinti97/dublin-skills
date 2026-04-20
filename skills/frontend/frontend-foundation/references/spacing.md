# Spacing System

One scale. Parent layouts own spacing. No arbitrary values.

## 1. The scale

Tailwind's default 4px increment scale is fine. **Restrict yourself to these values:**

| Token | px    | Use case |
|-------|-------|----------|
| `0`   | 0     | Reset |
| `1`   | 4     | Icon-to-label gap, tight inline |
| `2`   | 8     | Compact form internals |
| `3`   | 12    | Small gap, chip padding |
| `4`   | 16    | Default component padding, small gap |
| `6`   | 24    | Card padding, mobile section padding |
| `8`   | 32    | Medium gap, card-to-card |
| `12`  | 48    | Tablet section padding, large gap |
| `16`  | 64    | Desktop section padding (min) |
| `20`  | 80    | Desktop section padding (hero) |
| `24`  | 96    | Section spacing (min) |
| `32`  | 128   | Section spacing (major) |
| `40`  | 160   | Section spacing (hero-level) |
| `48`  | 192   | Section spacing (landing) |

**Forbidden:** `mt-[13px]`, `p-[22px]`, any arbitrary value. If the scale doesn't fit, you're fighting the design.

## 2. Breakpoints + container

```ts
// tailwind.config.ts (or @theme in v4)
screens: {
  sm:  '640px',   // phones (landscape)
  md:  '768px',   // tablets
  lg:  '1024px',  // laptops
  xl:  '1280px',  // desktops
  '2xl': '1440px', // large desktops
}

// Content max-width
container: {
  center: true,
  padding: { DEFAULT: '1.5rem', md: '2rem', lg: '3rem' },
  screens: { '2xl': '1280px' }, // don't stretch beyond this
}
```

## 3. Section padding scale

```tsx
// Mobile:  py-12  (48px)   or  py-16 (64px) for key sections
// Tablet:  md:py-20 (80px)
// Desktop: lg:py-24 (96px) or lg:py-32 (128px) for hero/feature

<section className="py-16 md:py-24 lg:py-32">
```

**Section spacing between sections:** let the `<Section>` primitive handle it with consistent `py-*`. Don't stack `mb-*` on individual sections.

## 4. Layout primitives (build these FIRST)

### `<Stack>` — vertical flex

```tsx
// components/layout/stack.tsx
import { cn } from "@/lib/utils";
import type { ComponentProps } from "react";

type StackProps = ComponentProps<"div"> & {
  gap?: 1 | 2 | 3 | 4 | 6 | 8 | 12 | 16;
  align?: "start" | "center" | "end" | "stretch";
};

const gapMap = {
  1: "gap-1", 2: "gap-2", 3: "gap-3", 4: "gap-4",
  6: "gap-6", 8: "gap-8", 12: "gap-12", 16: "gap-16",
};

const alignMap = {
  start: "items-start", center: "items-center",
  end: "items-end", stretch: "items-stretch",
};

export function Stack({ gap = 4, align = "stretch", className, ...props }: StackProps) {
  return (
    <div
      className={cn("flex flex-col", gapMap[gap], alignMap[align], className)}
      {...props}
    />
  );
}
```

### `<Row>` — horizontal flex

```tsx
type RowProps = ComponentProps<"div"> & {
  gap?: 1 | 2 | 3 | 4 | 6 | 8;
  align?: "start" | "center" | "end" | "baseline";
  justify?: "start" | "center" | "end" | "between" | "around";
  wrap?: boolean;
};

export function Row({
  gap = 4, align = "center", justify = "start", wrap, className, ...props
}: RowProps) {
  return (
    <div
      className={cn(
        "flex",
        wrap && "flex-wrap",
        gapMap[gap],
        alignMap[align],
        justifyMap[justify],
        className
      )}
      {...props}
    />
  );
}
```

### `<Grid>` — responsive grid

```tsx
type GridProps = ComponentProps<"div"> & {
  cols?: 1 | 2 | 3 | 4 | 6 | 12;
  mdCols?: 1 | 2 | 3 | 4 | 6 | 12;
  lgCols?: 1 | 2 | 3 | 4 | 6 | 12;
  gap?: 2 | 3 | 4 | 6 | 8 | 12;
};

export function Grid({
  cols = 1, mdCols, lgCols, gap = 6, className, ...props
}: GridProps) {
  return (
    <div
      className={cn(
        "grid",
        `grid-cols-${cols}`,
        mdCols && `md:grid-cols-${mdCols}`,
        lgCols && `lg:grid-cols-${lgCols}`,
        `gap-${gap}`,
        className
      )}
      {...props}
    />
  );
}
```

### `<Section>` — vertical padding + container

```tsx
type SectionProps = ComponentProps<"section"> & {
  size?: "sm" | "md" | "lg" | "hero";
};

const sizeMap = {
  sm:   "py-12 md:py-16",
  md:   "py-16 md:py-24",
  lg:   "py-20 md:py-28 lg:py-32",
  hero: "py-24 md:py-32 lg:py-40",
};

export function Section({ size = "md", className, ...props }: SectionProps) {
  return (
    <section className={cn(sizeMap[size], className)} {...props} />
  );
}
```

### `<Container>` — max-width + horizontal padding

```tsx
type ContainerProps = ComponentProps<"div"> & {
  size?: "sm" | "md" | "lg" | "xl";
};

const containerMap = {
  sm: "max-w-3xl",   // 768px — prose
  md: "max-w-5xl",   // 1024px — standard
  lg: "max-w-7xl",   // 1280px — wide
  xl: "max-w-[1440px]",
};

export function Container({ size = "lg", className, ...props }: ContainerProps) {
  return (
    <div
      className={cn("mx-auto w-full px-6 md:px-8 lg:px-12", containerMap[size], className)}
      {...props}
    />
  );
}
```

## 5. Usage pattern

```tsx
<Section size="lg">
  <Container size="lg">
    <Stack gap={12}>
      <Stack gap={4} align="center">
        <h2>Section title</h2>
        <p>Section subtitle</p>
      </Stack>
      <Grid cols={1} mdCols={2} lgCols={3} gap={8}>
        {items.map(item => <Card key={item.id} {...item} />)}
      </Grid>
    </Stack>
  </Container>
</Section>
```

Notice: **no margin anywhere**. All spacing flows through `gap` on parents.

## 6. Leaf component rules

```tsx
// ❌ Leaf component with external margin
function Card({ className, ...props }) {
  return <div className={cn("mt-6 p-6", className)} {...props} />;
}

// ✅ Leaf owns padding, not margin
function Card({ className, ...props }) {
  return <div className={cn("p-6", className)} {...props} />;
}
// Parent decides spacing:
<Stack gap={6}><Card /><Card /></Stack>
```

**Rule:** A component should be droppable into any layout without rearranging its margins.

## 7. Responsive padding template

```tsx
// Common patterns
"p-4 md:p-6 lg:p-8"          // card padding scaling
"px-4 md:px-6"                // input horizontal padding
"gap-4 md:gap-6 lg:gap-8"     // grid gap scaling
"py-16 md:py-24 lg:py-32"     // section padding
```

## Anti-patterns

```tsx
// ❌ Arbitrary values
<div className="mt-[13px] p-[22px]">

// ❌ Margin between siblings (use gap)
<div>
  <Card className="mb-6" />
  <Card className="mb-6" />
  <Card />
</div>

// ✅ Gap on parent
<Stack gap={6}>
  <Card /><Card /><Card />
</Stack>

// ❌ Per-item margin-top for first-vs-rest
<Card className="first:mt-0 mt-6" />

// ❌ Mixing padding + margin for section rhythm
<section className="mt-20 mb-20 py-16">

// ✅ Section owns its own py, no margin
<Section size="lg">...</Section>
```
