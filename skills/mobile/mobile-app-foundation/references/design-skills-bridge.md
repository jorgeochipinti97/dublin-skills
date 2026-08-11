# Design-Skills Bridge — web output → React Native

Every frontend skill in this library (`frontend-foundation`, `premium-frontend-design`, `mobile-design`, `forms-and-validation`, `product-tour`, `data-viz-architect`, `react-performance`) was written for the DOM. Their **judgment** is correct for a native app; their **code** is not.

> **This translation is the agent's job, never the user's.** Someone asking for a mobile app should never be handed `backdrop-filter` and told to convert it. If a design skill emits web code inside a React Native project, translate it through this file *before writing anything*, and say which substitutions were made.

**Project detection** — treat a project as React Native when either holds:
- `app.json` / `app.config.{js,ts}` contains an `expo` key
- `package.json` lists `react-native` in dependencies

---

## Skill-by-skill: what to keep, what to drop

| Skill | Keep | Drop |
|---|---|---|
| `product-ux-advisor` | Everything — it is diagnosis, not code | Web-only patterns (hover menus, breadcrumbs) |
| `brand-identity`, `brand-guidelines` | Everything — specification, not implementation | — |
| `mobile-design` | Every pattern **decision**: bottom sheet vs modal, FAB, thumb zones, touch targets, safe areas | Every snippet: Tailwind classes, Vaul, `100dvh`, `env(safe-area-inset-*)`, media queries |
| `premium-frontend-design` | The taste layer and the content AI Tells: LILA BAN, Jane Doe Effect, Acme Slop, Filler Word Index, 99.99% Problem, Pure Black Tell | `backdrop-filter`, CSS gradients, Framer Motion, `:hover`, `useMotionValue` magnetic buttons |
| `frontend-foundation` | Token discipline, spacing scale, dual theme, icon budget, the DESIGN.md contract idea | Base UI / Radix (no DOM), CLS rules (not a native metric), `font-display`, viewport meta |
| `forms-and-validation` | React Hook Form + Zod — the whole logic layer runs unchanged | `<input>`, `<label htmlFor>`, `aria-live`, Server Actions |
| `react-performance` | Render discipline, useEffect elimination, memo rules | RSC / Server Components, route code-splitting, `next/dynamic` |
| `data-viz-architect` | Chart selection and the WHY behind it | Recharts, D3, SVG-in-DOM |
| `product-tour` | The onboarding concept and step sequencing | Driver.js, NextStep — both DOM-only |
| **`frontend-output-validator`** | **Nothing — do not run it on native output** | Lighthouse cannot profile a binary; its greps look for `className`, `<img>`, viewport meta, and will report green without measuring anything |

The last row matters most: that skill produces **false confidence** on a native app. Use `references/testing-on-device.md` instead — the equivalent check is manual, because there is no Lighthouse for a native binary.

---

## Technique translation

Package names verified to exist on 2026-08-10. **Never pin a version from this table** — always `npx expo install <pkg>`, which resolves what matches the installed SDK (mandate #1).

| Web technique | React Native | Notes |
|---|---|---|
| `backdrop-filter: blur()` (glass) | `expo-blur` → `<BlurView intensity tint>` | Real native blur. Cheaper than the web equivalent |
| CSS gradient | `expo-linear-gradient` | For mesh/aurora, compose several, or use Skia |
| Complex generative visuals | `@shopify/react-native-skia` | Heavy dependency — only when a gradient stack genuinely cannot do it |
| Framer Motion | `react-native-reanimated` | Runs on the UI thread. `moti` gives a Framer-like declarative API on top |
| `useMotionValue` magnetic button | `useSharedValue` + `useAnimatedStyle` | Same idea, different names — never drive it from `useState` |
| Vaul / Radix Dialog as sheet | `@gorhom/bottom-sheet` | The native gesture and snap-point behavior |
| Radix / Base UI primitives | Own primitives on `Pressable` + `react-native-gesture-handler` | No DOM, so no headless DOM library applies |
| `:hover` | `active:` / `onPressIn` | Hover does not exist on a phone; on web it may add affordance, never carry information |
| `position: fixed` header | `position: "absolute"` in a root view | |
| `100dvh` | `flex: 1` | |
| `env(safe-area-inset-*)` | `useSafeAreaInsets()` — already inside the `Screen` primitive | |
| CSS `@media` | `useWindowDimensions()` | No container queries |
| `text-overflow: ellipsis` | `numberOfLines={2}` | |
| `<img>` + `loading="lazy"` | `expo-image` + `cachePolicy="memory-disk"` | Always declare `aspectRatio` |
| Lucide icons (web) | `lucide-react-native` (needs `react-native-svg`) | Same icon set, same names |
| SF Symbols look | `expo-symbols` | iOS-native symbols; needs a fallback on Android |
| Recharts / D3 | `victory-native`, or `react-native-svg` by hand | Chart *choice* still comes from `data-viz-architect` |
| Driver.js / NextStep tour | `react-native-copilot` | Or build it: overlay + measured target rect |
| `KeyboardAvoidingView` beyond one input | `react-native-keyboard-controller` | Needs a dev build |
| Native context menu | `@react-native-menu/menu` | |
| CLS (Cumulative Layout Shift) | No equivalent metric | Same discipline though: fixed `aspectRatio` so lists never jump under the thumb |
| Lighthouse | No equivalent | Dev-menu performance monitor (JS vs UI thread FPS) + the device checklist |

---

## Worked example — a premium skill's output, translated

`premium-frontend-design` asked for a glass card with a magnetic hover and a gradient edge. Here is what it emits, and what actually ships.

### What the skill produces (web)
```tsx
<motion.div
  className="rounded-2xl bg-white/10 backdrop-blur-xl border border-white/20
             hover:scale-[1.02] transition-transform"
  style={{ backgroundImage: "linear-gradient(135deg, #0F766E, #2DD4BF)" }}
  onMouseMove={handleMagnetic}
>
  <h3 className="text-2xl font-semibold">Resumen</h3>
</motion.div>
```

### What ships (native)
```tsx
import { BlurView } from "expo-blur";
import { LinearGradient } from "expo-linear-gradient";
import Animated, { useAnimatedStyle, useSharedValue, withSpring } from "react-native-reanimated";
import { Pressable, Text } from "react-native";

const AnimatedPressable = Animated.createAnimatedComponent(Pressable);

export function GlassCard() {
  // hover does not exist — the press is the interaction
  const scale = useSharedValue(1);
  const style = useAnimatedStyle(() => ({ transform: [{ scale: scale.value }] }));

  return (
    <AnimatedPressable
      onPressIn={() => (scale.value = withSpring(0.98))}
      onPressOut={() => (scale.value = withSpring(1))}
      style={style}
      className="overflow-hidden rounded-2xl border border-border"
    >
      <LinearGradient colors={["#0F766E", "#2DD4BF"]} start={{ x: 0, y: 0 }} end={{ x: 1, y: 1 }}>
        <BlurView intensity={40} tint="dark" className="p-5">
          <Text className="text-[22px] font-semibold text-text">Resumen</Text>
        </BlurView>
      </LinearGradient>
    </AnimatedPressable>
  );
}
```

Four substitutions, each with a reason:
1. `backdrop-blur-xl` → `BlurView` — CSS filters do not exist
2. `linear-gradient` → `LinearGradient` — no CSS backgrounds
3. `hover:scale` → `onPressIn/onPressOut` + Reanimated — **no hover on a phone**, and the animation must live on the UI thread
4. `<div>`/`<h3>` → `Pressable`/`Text` — text outside `<Text>` crashes at runtime

---

## What has no web equivalent — add it, do not just translate

Translation is only half the job. These exist on native and a web-derived design will simply omit them:

- **Haptics** on every confirmation and destructive action (`expo-haptics`) — safe on web too, it degrades to nothing
- **Native gestures**: swipe-to-delete, pull-to-refresh, swipe-back
- **Momentum scrolling** feel — never intercept or fight it
- **App lifecycle**: background/foreground transitions, cold start, state restoration
- **Offline** as a first-class state, not an error case
- **Push notifications** and deep links into specific screens
- **The Android hardware back button** — a real navigation contract

A design that translates cleanly but adds none of these still feels like a website in a shell.
