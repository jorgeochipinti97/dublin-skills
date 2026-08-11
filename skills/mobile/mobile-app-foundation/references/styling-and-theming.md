# Styling & Theming (NativeWind + dual theme)

## Setup (NativeWind 4)

Four files have to agree. Miss one and styles silently do nothing — the most common "why is nothing styled" bug.

```js
// babel.config.js
module.exports = function (api) {
  api.cache(true);
  return {
    presets: [
      ["babel-preset-expo", { jsxImportSource: "nativewind" }],
      "nativewind/babel",
    ],
  };
};
```

```js
// metro.config.js
const { getDefaultConfig } = require("expo/metro-config");
const { withNativeWind } = require("nativewind/metro");

const config = getDefaultConfig(__dirname);
module.exports = withNativeWind(config, { input: "./global.css" });
```

```js
// tailwind.config.js
module.exports = {
  content: ["./app/**/*.{js,jsx,ts,tsx}", "./src/**/*.{js,jsx,ts,tsx}"],
  presets: [require("nativewind/preset")],
  darkMode: "class",
  theme: { extend: { colors: { /* tokens — see below */ } } },
  plugins: [],
};
```

```css
/* global.css — imported once, in app/_layout.tsx */
@tailwind base;
@tailwind components;
@tailwind utilities;
```

Plus `nativewind-env.d.ts` with `/// <reference types="nativewind/types" />` so TypeScript accepts `className` on RN components.

**After changing any of these four, restart Metro with `pnpm start --clear`.** Metro caches aggressively and will keep serving the old transform.

---

## Tokens

One source of truth, consumed two ways — by Tailwind classes and by imperative APIs (navigators, status bar, native components that do not take `className`).

```ts
// src/theme/tokens.ts
export const tokens = {
  light: {
    bg: "#FAFAF9",
    surface: "#FFFFFF",
    surfaceAlt: "#F5F5F4",
    border: "#E7E5E4",
    text: "#1C1917",
    textMuted: "#57534E",
    accent: "#0F766E",
    accentText: "#FFFFFF",
    danger: "#B91C1C",
  },
  dark: {
    bg: "#0C0A09",       // NOT #000000 — see Pure Black Tell
    surface: "#1C1917",
    surfaceAlt: "#292524",
    border: "#292524",
    text: "#FAFAF9",
    textMuted: "#A8A29E",
    accent: "#2DD4BF",
    accentText: "#0C0A09",
    danger: "#F87171",
  },
} as const;

export const spacing = { xs: 4, sm: 8, md: 16, lg: 24, xl: 32, "2xl": 48 } as const;
export const radius = { sm: 6, md: 10, lg: 16, full: 9999 } as const;
```

**Pure Black Tell applies on mobile too, with a caveat.** `#000000` on an OLED screen makes edges disappear and smearing visible during scroll. Use a near-black (`#0C0A09`). The one legitimate exception is a deliberate OLED power-saving mode the user opts into.

Wire tokens into Tailwind with CSS variables so `dark:` works without duplicating every class:

```js
// tailwind.config.js — theme.extend.colors
colors: {
  bg: "rgb(var(--color-bg) / <alpha-value>)",
  surface: "rgb(var(--color-surface) / <alpha-value>)",
  border: "rgb(var(--color-border) / <alpha-value>)",
  text: "rgb(var(--color-text) / <alpha-value>)",
  muted: "rgb(var(--color-text-muted) / <alpha-value>)",
  accent: "rgb(var(--color-accent) / <alpha-value>)",
}
```

```css
/* global.css */
:root {
  --color-bg: 250 250 249;
  --color-surface: 255 255 255;
  --color-border: 231 229 228;
  --color-text: 28 25 23;
  --color-text-muted: 87 83 78;
  --color-accent: 15 118 110;
}
.dark:root {
  --color-bg: 12 10 9;
  --color-surface: 28 25 23;
  --color-border: 41 37 36;
  --color-text: 250 250 249;
  --color-text-muted: 168 162 158;
  --color-accent: 45 212 191;
}
```

Now `className="bg-bg text-text"` is theme-correct everywhere, and `dark:` variants are only needed for genuine exceptions.

---

## Dual theme (Dublin hard rule)

Mobile makes this easier than web: the OS already has a system-wide setting, and `nativewind` reads it.

```tsx
// src/theme/useTheme.ts
import { useColorScheme } from "nativewind";
import { tokens } from "./tokens";

export function useThemeColors() {
  const { colorScheme } = useColorScheme();
  return tokens[colorScheme === "dark" ? "dark" : "light"];
}
```

Manual override, for the settings screen:

```tsx
import { useColorScheme } from "nativewind";

const { colorScheme, setColorScheme } = useColorScheme();
// "light" | "dark" | "system"
setColorScheme("system");
```

Three requirements, all mandatory:

1. **`app.json` must declare `"userInterfaceStyle": "automatic"`.** Without it the OS pins your app to light and no amount of JS will change it. This is the single most common "dark mode does not work" cause.
2. **`StatusBar` follows the theme** — `<StatusBar style={colorScheme === "dark" ? "light" : "dark"} />`. Otherwise dark text on a dark bar: invisible.
3. **The native splash screen needs its own dark variant** in `app.json`, or the app flashes white before mounting. Users read that flash as "slow app".

There is no View Transitions API on native. For a theme cross-fade, animate an overlay with Reanimated — but honestly, an instant switch is what iOS and Android do natively, and matching the platform beats matching the web here.

---

## Type scale

No `rem`, no `clamp()`. Units are density-independent pixels; the framework handles device scaling.

```ts
export const type = {
  display: { fontSize: 32, lineHeight: 38, fontWeight: "700" },
  title:   { fontSize: 22, lineHeight: 28, fontWeight: "600" },
  body:    { fontSize: 16, lineHeight: 24, fontWeight: "400" },
  small:   { fontSize: 14, lineHeight: 20, fontWeight: "400" },
  caption: { fontSize: 12, lineHeight: 16, fontWeight: "500" },
} as const;
```

**16 is the floor for body text.** Not for the iOS-zoom reason from web (there is no zoom-on-focus here) but because a phone is held at arm's length in bad light.

**Respect OS font scaling.** Users who enlarge system text expect your app to follow. Do not blanket-disable it — that is an accessibility failure. Cap it where layout genuinely breaks:

```tsx
<Text maxFontSizeMultiplier={1.6}>{title}</Text>
```

Custom fonts load through `expo-font` and must finish loading before the splash hides, or text pops mid-render.

---

## Safe areas

The rule: **the navigator handles its own insets; your screen content does not.** Encode it once in a primitive so no screen can forget:

```tsx
// src/components/ui/Screen.tsx
import { View, type ViewProps } from "react-native";
import { useSafeAreaInsets } from "react-native-safe-area-context";

type Props = ViewProps & { edges?: Array<"top" | "bottom"> };

export function Screen({ edges = ["top"], style, children, ...rest }: Props) {
  const insets = useSafeAreaInsets();
  return (
    <View
      className="flex-1 bg-bg"
      style={[
        {
          paddingTop: edges.includes("top") ? insets.top : 0,
          paddingBottom: edges.includes("bottom") ? insets.bottom : 0,
        },
        style,
      ]}
      {...rest}
    >
      {children}
    </View>
  );
}
```

- Screen inside tabs → `edges={["top"]}` (the tab bar owns the bottom)
- Full-screen / modal → `edges={["top", "bottom"]}`
- A scrolling list → put the inset in `contentContainerStyle`, not on the list container, or the scroll indicator ends up inset too

---

## Platform differences worth encoding

| Concern | iOS | Android |
|---|---|---|
| Shadow | `shadowColor/Offset/Opacity/Radius` | `elevation` |
| Back gesture | swipe from left edge | hardware/gesture back button |
| Font | SF Pro | Roboto |
| Ripple on press | none — use opacity | `android_ripple` on `Pressable` |
| Status bar | translucent by default | needs explicit config |

```tsx
import { Platform } from "react-native";

const shadow = Platform.select({
  ios: { shadowColor: "#000", shadowOpacity: 0.08, shadowRadius: 12, shadowOffset: { width: 0, height: 4 } },
  android: { elevation: 3 },
});
```

`Platform.select` beats `Platform.OS === "ios" ? ... : ...` chains — it stays readable when a third case (web, via react-native-web) appears.

---

## Press states are mandatory

There is no `:hover` on a phone. Press feedback is the **only** signal that something is interactive. Every tappable element gets it:

```tsx
<Pressable
  className="rounded-lg bg-accent px-4 py-3 active:opacity-80"
  android_ripple={{ color: "rgba(255,255,255,0.15)" }}
  hitSlop={8}
  accessibilityRole="button"
>
  <Text className="text-center font-semibold text-accentText">Guardar</Text>
</Pressable>
```

`hitSlop` expands the touch area without changing layout — the correct fix for a small icon button, and it satisfies the 44pt minimum without visual bloat.
