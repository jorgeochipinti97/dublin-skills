# DESIGN.md — __PROJECT__ (mobile)

Design contract for this app. The agent reads it at the start of every session; it is the source of truth when code and intent disagree.

```yaml
platform: react-native
target: [ios, android, web]   # Dublin mandate: one codebase, three targets
webMaxContentWidth: 720       # a browser has no 360px ceiling; cap reading width
minTouchTarget: 44        # pt — Apple HIG floor, Android asks 48dp
theme:
  default: system         # never hardcode light; the OS setting is a real user choice
  modes: [light, dark]
colors:
  light:
    bg: "#FAFAF9"
    surface: "#FFFFFF"
    surfaceAlt: "#F5F5F4"
    border: "#E7E5E4"
    text: "#1C1917"
    textMuted: "#57534E"
    accent: "#0F766E"
    accentText: "#FFFFFF"
    danger: "#B91C1C"
  dark:
    bg: "#0C0A09"         # near-black, NOT #000000 — see Pure Black Tell
    surface: "#1C1917"
    surfaceAlt: "#292524"
    border: "#292524"
    text: "#FAFAF9"
    textMuted: "#A8A29E"
    accent: "#2DD4BF"
    accentText: "#0C0A09"
    danger: "#F87171"
typography:
  bodyMin: 16             # floor — a phone is read at arm's length
  scale: { display: 30, title: 22, body: 16, small: 14, caption: 12 }
  respectOsFontScale: true
  maxFontSizeMultiplier: 1.6
spacing: [4, 8, 16, 24, 32, 48]
radius: { sm: 6, md: 10, lg: 16 }
iconBudget:
  tabBar: 5
  screenHeader: 2
  card: 2
listStrategy:
  threshold: 20           # more than this many items -> FlashList, never ScrollView
  component: "@shopify/flash-list"
images:
  component: expo-image
  requireFixedRatio: true # every image declares aspectRatio or explicit size
  cachePolicy: memory-disk
aiTellsEnforced:
  - Web Brain
  - ScrollView Graveyard
  - Notch Blind
  - Keyboard Eater
  - JS Thread Jam
  - Expo Go Mirage
  - Ghost Tap
  - Version Roulette
  - Store Surprise
  - Offline Amnesia
  - Pure Black Tell
  - One-Target Tell
  - Symmetric Storage Trap
```

---

## Rationale

**Colors are declared once** in `global.css` (CSS variables, consumed by NativeWind classes) and mirrored in `src/theme/tokens.ts` (for navigators, `StatusBar`, and native props that take no `className`). Changing a color means changing both. No component ever contains a hex literal.

**Dark is near-black, not `#000000`.** Pure black smears on OLED during scroll and makes surface edges vanish.

**`Screen` is the only way to render a screen.** It owns safe-area insets, so no route can go Notch Blind. Inside tabs use `edges={["top"]}` — the tab bar owns the bottom.

**Every list over ~20 items uses `FlashList`.** `ScrollView` + `.map()` mounts everything at once and is the single most common performance failure in a content app.

**Every image declares an aspect ratio.** Same discipline as CLS on web: a card that resizes when the image lands makes the list jump under the user's thumb mid-scroll.

**Every interactive element has a press state.** There is no `:hover` on a phone — press feedback is the only affordance signal available.

---

## Offline contract

Every data screen answers all four before it is considered done:

| State | What renders |
|---|---|
| First load, no cache | Skeleton matching the real layout |
| Cached + refetching | Cached content immediately, subtle refresh indicator |
| Error + cache exists | Cached content + "Sin conexión — mostrando lo último guardado" |
| Error + no cache | Explicit message + Retry button — never a dead spinner |

---

## Cross-platform contract

**One codebase, three targets.** Dropping web is an explicit decision, never a default.

Two modules fail *silently* on web — a green build proves nothing:

| Module | Web reality | What to use instead |
|---|---|---|
| `expo-secure-store` | web build is `export default {}` — any call throws | `src/lib/session-storage.ts`: Keychain natively, httpOnly cookie on web |
| `Alert.alert` | `react-native-web` defines it as `static alert() {}` — silent no-op | `src/lib/notify.ts` |

Never mirror a native token into `localStorage` to make the code symmetric — that converts a Keychain-protected secret into an XSS-readable one.

The `Screen` primitive caps content at `webMaxContentWidth` on web, so no screen has to remember the third target exists.

---

## Device verification

No screen is done until it has been checked on a physical phone **and** in a browser: both themes, safe areas top and bottom, airplane mode, Android hardware back, large OS font size, and — on web — that every error path still produces visible feedback. Full checklists in the skill's `references/testing-on-device.md` and `references/cross-platform.md`.
