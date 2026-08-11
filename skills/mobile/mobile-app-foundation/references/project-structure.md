# Project Structure (expo-router)

## Mental model

expo-router is file-based routing, like the Next.js App Router. If you know `app/page.tsx`, you know this. The differences that matter:

| Next.js App Router | expo-router |
|---|---|
| `app/page.tsx` | `app/index.tsx` |
| `app/layout.tsx` | `app/_layout.tsx` |
| `app/blog/[slug]/page.tsx` | `app/blog/[slug].tsx` |
| `app/(marketing)/` route group | `app/(tabs)/` — same idea, and it also drives the navigator |
| `not-found.tsx` | `app/+not-found.tsx` |
| `<Link href>` | `<Link href>` from `expo-router` |
| `useRouter()` / `useParams()` | `useRouter()` / `useLocalSearchParams()` |
| Server Components | **none** — everything is client-side |

The last row is the big one. There is no server in a mobile app. Every route is a client component, every fetch happens on the device, and there is no `"use server"`. Data fetching lives in TanStack Query, not in the route.

---

## Recommended tree (content app)

expo-router accepts routes at either `app/` or `src/app/`. **Use `src/app/`** — it is what `create-expo-app` generates on current SDKs, and the generated `tsconfig.json` maps `@/*` → `./src/*`, so every import below is alias-based and survives moving a route between folders.

```
src/
├── app/                     # routes ONLY
│   ├── _layout.tsx          # root: providers, theme, splash, fonts
│   ├── (tabs)/
│   │   ├── _layout.tsx      # bottom tab navigator
│   │   ├── index.tsx        # Feed
│   │   ├── saved.tsx        # Saved articles
│   │   └── settings.tsx     # Theme, account
│   ├── article/
│   │   └── [id].tsx         # Detail — pushed on the stack, full screen
│   └── +not-found.tsx
├── api/                     # fetchers only — no React in here
│   └── articles.ts
├── components/
│   └── ui/                  # Screen, Button, Skeleton
├── lib/
│   ├── query.ts             # QueryClient + persister
│   └── saved.ts             # AsyncStorage-backed saved-article ids
├── theme/
│   ├── tokens.ts            # single source of colors/spacing/radius
│   └── useTheme.ts
└── global.css               # Tailwind directives + CSS variables
```

**Rule:** `src/app/` holds routes and nothing else. A file there becomes a URL — a helper module dropped in becomes an accidental route. Everything shared lives in a sibling folder under `src/` and is imported as `@/lib/query`, `@/theme/useTheme`, and so on.

Two config files must agree with this layout, and both fail silently if they do not: `metro.config.js` (`withNativeWind(config, { input: "./src/global.css" })`) and `tailwind.config.js` (`content: ["./src/**/*.{js,jsx,ts,tsx}"]`).

---

## Root layout

The root layout is where anything app-wide is mounted, in this order:

```tsx
// src/app/_layout.tsx
import "@/global.css";
import { Stack } from "expo-router";
import { SafeAreaProvider } from "react-native-safe-area-context";
import { StatusBar } from "expo-status-bar";
import { PersistQueryClientProvider } from "@tanstack/react-query-persist-client";
import { queryClient, persistOptions } from "@/lib/query";
import { useColorScheme } from "nativewind";

export default function RootLayout() {
  const { colorScheme } = useColorScheme();

  return (
    <PersistQueryClientProvider client={queryClient} persistOptions={persistOptions}>
      <SafeAreaProvider>
        <StatusBar style={colorScheme === "dark" ? "light" : "dark"} />
        <Stack screenOptions={{ headerShown: false }}>
          <Stack.Screen name="(tabs)" />
          <Stack.Screen name="article/[id]" options={{ headerShown: true, title: "" }} />
        </Stack>
      </SafeAreaProvider>
    </PersistQueryClientProvider>
  );
}
```

`SafeAreaProvider` must wrap everything, or `useSafeAreaInsets()` returns zeros and every screen quietly goes **Notch Blind**.

---

## Tabs

```tsx
// src/app/(tabs)/_layout.tsx
import { Tabs } from "expo-router";
import { House, Bookmark, Settings } from "lucide-react-native";
import { useThemeColors } from "@/theme/useTheme";

export default function TabsLayout() {
  const c = useThemeColors();

  return (
    <Tabs
      screenOptions={{
        headerShown: false,
        tabBarActiveTintColor: c.accent,
        tabBarInactiveTintColor: c.muted,
        tabBarStyle: { backgroundColor: c.surface, borderTopColor: c.border },
      }}
    >
      <Tabs.Screen name="index" options={{ title: "Inicio", tabBarIcon: ({ color, size }) => <House color={color} size={size} /> }} />
      <Tabs.Screen name="saved" options={{ title: "Guardados", tabBarIcon: ({ color, size }) => <Bookmark color={color} size={size} /> }} />
      <Tabs.Screen name="settings" options={{ title: "Ajustes", tabBarIcon: ({ color, size }) => <Settings color={color} size={size} /> }} />
    </Tabs>
  );
}
```

The tab bar handles its own bottom safe-area inset. Your **screens** do not — that is your job, which is why the boilerplate has a `Screen` primitive.

Icon budget (Dublin): **≤ 5 tabs**. Six tabs means the information architecture is wrong, not that you need a "More" tab.

---

## Navigating

```tsx
import { Link, useRouter, useLocalSearchParams } from "expo-router";

// Declarative — preferred; gets correct press states and accessibility
<Link href={`/article/${article.id}`} asChild>
  <Pressable>{/* ... */}</Pressable>
</Link>

// Imperative
const router = useRouter();
router.push(`/article/${id}`);   // add to stack
router.replace("/(tabs)");        // no back
router.back();

// Reading params — ALWAYS strings, even for numeric ids
const { id } = useLocalSearchParams<{ id: string }>();
```

`useLocalSearchParams` returns `string | string[]`. Parse and validate — a route param is untrusted input exactly like a URL query on web.

---

## Modals

A modal is a route with a presentation option, not a state flag:

```tsx
// app/_layout.tsx
<Stack.Screen name="compose" options={{ presentation: "modal" }} />
```

Why this beats `useState(showModal)`: the hardware back button, the swipe-down gesture, and deep linking all work for free. On mobile the back button is a real, physical contract — breaking it is a bug users notice immediately.

---

## Deep links

Set the scheme once, in `app.json`:

```json
{ "expo": { "scheme": "miapp" } }
```

Every route is now reachable: `miapp://article/1947`. Test without a build:

```bash
npx uri-scheme open "miapp://article/1947" --ios
npx uri-scheme open "miapp://article/1947" --android
```

**Universal links** (`https://midominio.com/article/1947` opening the app instead of Safari) need more: an `apple-app-site-association` file served from your domain plus `associatedDomains` in `app.json` for iOS, and `assetlinks.json` plus `intentFilters` for Android. Plan this at day 0 if the content is ever shared — retrofitting it means re-issuing builds.

---

## Where things go — decision table

| Thing | Location | Why |
|---|---|---|
| A screen | `src/app/**` | Only routes belong here |
| A screen-only subcomponent | `src/components/<screen>/` | Keeps `src/app/` free of accidental routes |
| Shared primitive | `src/components/ui/` | Reused everywhere |
| Fetcher | `src/api/` | Testable without React |
| Query hooks | `src/api/` next to the fetcher | Query key and fetcher stay together |
| Colors / spacing | `src/theme/tokens.ts` | Single source of truth; `DESIGN.md` documents it |
| Native config | `app.json` | Config plugins, permissions, bundle ids |
| Build config | `eas.json` | Profiles, not secrets |

---

## What does NOT exist on native

Things web developers reach for that are absent — the **Web Brain** trap:

- `localStorage` → `AsyncStorage` (async!) or `expo-secure-store` for anything sensitive
- `window` / `document` → nothing; use `Dimensions` or `useWindowDimensions`
- `fetch` — this one **does** exist and works normally
- CSS files, `:hover`, `position: fixed` → NativeWind utilities, `Pressable` states, absolute positioning
- `<img>`, `<div>`, `<button>` → `expo-image`, `View`, `Pressable`
- `alert()` → `Alert.alert()` from `react-native`
- Route-level code splitting — the whole JS bundle ships at once, so bundle size affects startup, not navigation
