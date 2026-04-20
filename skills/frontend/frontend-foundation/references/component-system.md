# Component System on Headless Primitives

Own a branded `ui/` layer over headless primitives. Save tokens, inherit accessibility.

## 1. Why headless primitives

| Metric | Hand-rolled Dialog | Base UI Dialog wrapped |
|--------|-------------------|------------------------|
| LoC (component) | ~120 | ~30 |
| Focus trap | Manual | Built-in |
| Escape to close | Manual | Built-in |
| Scroll lock | Manual | Built-in |
| ARIA labels/roles | Manual, error-prone | Built-in |
| Portal | Manual | Built-in |
| Tokens to generate in Claude | High | Low |

The branded layer is **styling + branding only**. Behavior is delegated.

## 2. Library comparison

| Feature | Base UI | Radix UI | React Aria Components |
|---------|---------|----------|-----------------------|
| Maintainer | MUI team | WorkOS | Adobe |
| API style | Render/asChild | asChild/compound | Compound |
| Styling | Unstyled | Unstyled | Unstyled |
| Bundle | Small | Small (tree-shakeable) | Medium |
| Ecosystem | Growing | Mature (shadcn, Vercel) | Growing |
| Complex widgets | Growing | Has most | Richest (DatePicker, Calendar, DnD, Virtualizer) |
| Accessibility | Excellent | Excellent | Gold standard |

**Default recommendation:** **Base UI**. If shadcn ecosystem matters → **Radix**. If complex widgets (date range picker, virtualized lists, drag-drop reorder) → **React Aria**.

**Do not mix** in the same project.

## 3. Install (Base UI example)

```bash
pnpm add @base-ui-components/react class-variance-authority clsx tailwind-merge lucide-react
```

```ts
// lib/utils.ts
import { clsx, type ClassValue } from "clsx";
import { twMerge } from "tailwind-merge";

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}
```

## 4. Folder structure

```
components/
├── layout/              # Stack, Row, Grid, Section, Container
├── ui/                  # Branded primitives
│   ├── button.tsx
│   ├── input.tsx
│   ├── dialog.tsx
│   ├── dropdown-menu.tsx
│   ├── select.tsx
│   ├── tooltip.tsx
│   └── ...
└── patterns/            # Composed business components
    ├── pricing-card.tsx
    ├── user-menu.tsx
    └── ...
```

**Rule:** `ui/` knows nothing about your business. `patterns/` composes `ui/` into product-specific pieces.

## 5. Button template (CVA + semantic tokens)

```tsx
// components/ui/button.tsx
import { cva, type VariantProps } from "class-variance-authority";
import { forwardRef, type ComponentProps } from "react";
import { cn } from "@/lib/utils";

const buttonVariants = cva(
  "inline-flex items-center justify-center gap-2 rounded-lg font-medium transition-colors " +
  "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 " +
  "focus-visible:ring-offset-background disabled:pointer-events-none disabled:opacity-50",
  {
    variants: {
      variant: {
        primary:     "bg-primary text-primary-foreground hover:bg-primary/90",
        secondary:   "bg-secondary text-secondary-foreground hover:bg-secondary/80",
        outline:     "border border-border bg-background hover:bg-accent hover:text-accent-foreground",
        ghost:       "hover:bg-accent hover:text-accent-foreground",
        destructive: "bg-destructive text-destructive-foreground hover:bg-destructive/90",
        link:        "text-primary underline-offset-4 hover:underline",
      },
      size: {
        sm:   "h-8  px-3  text-sm",
        md:   "h-10 px-4  text-sm",
        lg:   "h-12 px-6  text-base",
        icon: "size-10",
      },
    },
    defaultVariants: { variant: "primary", size: "md" },
  }
);

type ButtonProps = ComponentProps<"button"> & VariantProps<typeof buttonVariants>;

export const Button = forwardRef<HTMLButtonElement, ButtonProps>(
  ({ className, variant, size, ...props }, ref) => (
    <button
      ref={ref}
      className={cn(buttonVariants({ variant, size, className }))}
      {...props}
    />
  )
);
Button.displayName = "Button";
```

## 6. Dialog template (Base UI)

```tsx
// components/ui/dialog.tsx
"use client";
import { Dialog as BaseDialog } from "@base-ui-components/react/dialog";
import { cn } from "@/lib/utils";
import type { ComponentProps } from "react";

export const Dialog = BaseDialog.Root;
export const DialogTrigger = BaseDialog.Trigger;
export const DialogClose = BaseDialog.Close;

export function DialogContent({
  className,
  children,
  ...props
}: ComponentProps<typeof BaseDialog.Popup>) {
  return (
    <BaseDialog.Portal>
      <BaseDialog.Backdrop className="fixed inset-0 z-50 bg-black/50 backdrop-blur-sm data-[ending-style]:opacity-0 data-[starting-style]:opacity-0 transition-opacity duration-200" />
      <BaseDialog.Popup
        className={cn(
          "fixed left-1/2 top-1/2 z-50 -translate-x-1/2 -translate-y-1/2",
          "w-full max-w-lg rounded-xl border border-border bg-card p-6 shadow-lg",
          "data-[ending-style]:opacity-0 data-[starting-style]:opacity-0",
          "data-[ending-style]:scale-95 data-[starting-style]:scale-95",
          "transition-all duration-200",
          className
        )}
        {...props}
      >
        {children}
      </BaseDialog.Popup>
    </BaseDialog.Portal>
  );
}

export function DialogTitle({ className, ...props }: ComponentProps<typeof BaseDialog.Title>) {
  return (
    <BaseDialog.Title
      className={cn("text-lg font-semibold text-foreground", className)}
      {...props}
    />
  );
}

export function DialogDescription({ className, ...props }: ComponentProps<typeof BaseDialog.Description>) {
  return (
    <BaseDialog.Description
      className={cn("text-sm text-muted-foreground", className)}
      {...props}
    />
  );
}
```

Usage:

```tsx
<Dialog>
  <DialogTrigger render={<Button variant="outline">Open</Button>} />
  <DialogContent>
    <Stack gap={4}>
      <DialogTitle>Confirm action</DialogTitle>
      <DialogDescription>This cannot be undone.</DialogDescription>
      <Row justify="end" gap={2}>
        <DialogClose render={<Button variant="ghost">Cancel</Button>} />
        <Button variant="destructive">Delete</Button>
      </Row>
    </Stack>
  </DialogContent>
</Dialog>
```

## 7. Input template

```tsx
// components/ui/input.tsx
import { forwardRef, type ComponentProps } from "react";
import { cn } from "@/lib/utils";

export const Input = forwardRef<HTMLInputElement, ComponentProps<"input">>(
  ({ className, type = "text", ...props }, ref) => (
    <input
      ref={ref}
      type={type}
      className={cn(
        "flex h-10 w-full rounded-lg border border-input bg-background px-3 py-2 text-sm",
        "placeholder:text-muted-foreground",
        "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 focus-visible:ring-offset-background",
        "disabled:cursor-not-allowed disabled:opacity-50",
        "file:border-0 file:bg-transparent file:text-sm file:font-medium",
        className
      )}
      {...props}
    />
  )
);
Input.displayName = "Input";
```

## 8. Minimum primitive set (day-0 roster)

Build these before anything else. Everything else composes from them:

- **Buttons:** Button, IconButton
- **Inputs:** Input, Textarea, Select, Checkbox, Radio, Switch, Slider
- **Overlays:** Dialog, Popover, Tooltip, DropdownMenu, Toast
- **Navigation:** Tabs, Accordion, **Sidebar** (see §9)
- **Display:** Card, Avatar, Badge, Separator, Skeleton

## 9. Sidebar (mandatory pattern)

**Rule:** If the product has a sidebar, it **must** be collapsible with an icon-rail when collapsed. The trigger must be visually polished — pill-shaped, never a generic square button.

### Behavior

- Two widths: **expanded** `240–280px`, **collapsed** `56–64px` (icon rail only)
- Transition: `transition-[width] duration-300 ease-[cubic-bezier(0.16,1,0.3,1)]`
- **Collapsed state shows icons** with tooltips on hover — never fully hide the sidebar
- Persist state in `localStorage` (`sidebar-collapsed`)
- Keyboard shortcut: `Cmd+B` / `Ctrl+B`
- Accessibility: `aria-expanded`, `aria-label="Toggle sidebar"`, focus visible ring

### Trigger style

- `rounded-full` or `rounded-[14px]` — subtly oval/pill, **never** `rounded-md`
- Size: 32–40px square
- Hover: `bg-accent/60` sutil, no harsh state
- Position: floating on the outer edge of the sidebar, or in a header bar

### Template

```tsx
// components/ui/sidebar.tsx
"use client";
import { useEffect, useState } from "react";
import { PanelLeftClose, PanelLeftOpen } from "lucide-react";
import { cn } from "@/lib/utils";

export function Sidebar({ children, className }: { children: React.ReactNode; className?: string }) {
  const [collapsed, setCollapsed] = useState<boolean>(() => {
    if (typeof window === "undefined") return false;
    return localStorage.getItem("sidebar-collapsed") === "true";
  });

  useEffect(() => {
    localStorage.setItem("sidebar-collapsed", String(collapsed));
  }, [collapsed]);

  useEffect(() => {
    const onKey = (e: KeyboardEvent) => {
      if ((e.metaKey || e.ctrlKey) && e.key.toLowerCase() === "b") {
        e.preventDefault();
        setCollapsed(v => !v);
      }
    };
    window.addEventListener("keydown", onKey);
    return () => window.removeEventListener("keydown", onKey);
  }, []);

  return (
    <aside
      data-collapsed={collapsed}
      className={cn(
        "relative flex h-screen shrink-0 flex-col border-r border-border bg-card",
        "transition-[width] duration-300 ease-[cubic-bezier(0.16,1,0.3,1)]",
        collapsed ? "w-16" : "w-64",
        className
      )}
    >
      {children}
      <button
        type="button"
        aria-label="Toggle sidebar"
        aria-expanded={!collapsed}
        onClick={() => setCollapsed(v => !v)}
        className={cn(
          "absolute -right-3 top-6 z-10",
          "grid size-7 place-items-center rounded-full",
          "border border-border bg-card shadow-sm",
          "text-muted-foreground hover:text-foreground hover:bg-accent/60",
          "transition-colors",
          "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 focus-visible:ring-offset-background"
        )}
      >
        {collapsed ? <PanelLeftOpen className="size-3.5" /> : <PanelLeftClose className="size-3.5" />}
      </button>
    </aside>
  );
}

export function SidebarItem({
  icon: Icon, label, active, href,
}: { icon: React.ComponentType<{ className?: string }>; label: string; active?: boolean; href: string }) {
  return (
    <a
      href={href}
      title={label}
      className={cn(
        "group/item relative flex items-center gap-3 rounded-lg px-3 py-2",
        "text-sm text-muted-foreground hover:text-foreground hover:bg-accent/50",
        "transition-colors",
        active && "bg-accent text-foreground"
      )}
    >
      <Icon className="size-4 shrink-0" />
      <span className="truncate group-data-[collapsed=true]/sidebar:hidden">
        {label}
      </span>
    </a>
  );
}
```

Usage:

```tsx
<Sidebar className="group/sidebar">
  <div className="p-3">
    <SidebarItem icon={Home} label="Home" href="/" active />
    <SidebarItem icon={Inbox} label="Inbox" href="/inbox" />
    <SidebarItem icon={Settings} label="Settings" href="/settings" />
  </div>
</Sidebar>
```

For collapsed-state tooltips, wrap each `SidebarItem` with the branded `Tooltip` component (built from Base UI/Radix). Tooltips should **only** render when the sidebar is collapsed — skip them in expanded mode.

### Anti-patterns for sidebar

```tsx
// ❌ Square trigger
<button className="rounded-md border p-2">☰</button>

// ❌ Sidebar that disappears fully when "collapsed"
{open && <aside>...</aside>}  // breaks muscle memory, no icon rail

// ❌ Linear/instant toggle
className={collapsed ? "w-0" : "w-64"}  // add transition-[width]

// ❌ Forgetting persistence
// Every reload the user re-toggles — basura UX

// ❌ No keyboard shortcut
// Linear/Cursor set the expectation: Cmd+B
```

## 9. CVA variant discipline

```tsx
// ❌ Boolean prop explosion
<Button primary large loading rounded leftIcon={...} rightIcon={...} />

// ✅ CVA variants + semantic props
<Button variant="primary" size="lg" disabled>
  <Spinner /> Saving
</Button>
```

Max 2-3 variant dimensions (variant, size, maybe tone). Beyond that, it's a different component.

## 10. Pattern composition

```tsx
// components/patterns/user-menu.tsx
import { DropdownMenu, DropdownMenuTrigger, DropdownMenuContent, DropdownMenuItem } from "@/components/ui/dropdown-menu";
import { Avatar } from "@/components/ui/avatar";

export function UserMenu({ user }: { user: User }) {
  return (
    <DropdownMenu>
      <DropdownMenuTrigger render={<Avatar src={user.avatar} name={user.name} />} />
      <DropdownMenuContent>
        <DropdownMenuItem>Profile</DropdownMenuItem>
        <DropdownMenuItem>Settings</DropdownMenuItem>
        <DropdownMenuItem>Sign out</DropdownMenuItem>
      </DropdownMenuContent>
    </DropdownMenu>
  );
}
```

Business logic lives in `patterns/`. `ui/` stays pristine.

## Anti-patterns

```tsx
// ❌ Hand-rolled accessible component
function Dialog() {
  const [open, setOpen] = useState(false);
  useEffect(() => {
    if (!open) return;
    const handleEsc = (e) => e.key === "Escape" && setOpen(false);
    document.addEventListener("keydown", handleEsc);
    // ... focus trap logic, scroll lock, portal, aria attributes ...
  }, [open]);
  // 100+ more lines
}

// ❌ Shadcn copy-paste in every project, no brand abstraction
// (drift, inconsistency, no shared tokens)

// ❌ Mixing primitive libraries
import * as Dialog from "@radix-ui/react-dialog";
import { Select } from "@base-ui-components/react/select"; // don't mix

// ❌ Hardcoded colors inside ui/
"bg-[#18181b] text-white"

// ✅ Semantic tokens
"bg-card text-card-foreground"
```
