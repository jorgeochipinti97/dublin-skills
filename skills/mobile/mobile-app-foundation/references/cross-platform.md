# Cross-Platform: iOS + Android + Web

Dublin mandate: **every app ships to all three.** One codebase, three targets. Expo supports this through `react-native-web`, and `expo-router` exports the web build as static HTML — which lands on a VPS with nginx, matching Dublin's VPS-first convention.

```bash
npx expo export --platform web --output-dir dist   # static site, deploy anywhere
```

Web is not a consolation prize here: static routes mean real URLs, shareable links, and SEO — things a store binary cannot give you.

---

## Verified support matrix

Checked by reading each package's web implementation in `node_modules`, on Expo SDK 57. **Re-verify after any SDK upgrade** — this table is a snapshot, not a guarantee.

| Package | Web | What actually happens |
|---|---|---|
| `expo-router` | ✅ | Static rendering; each route becomes an HTML file with a real URL |
| `nativewind` | ✅ | Compiles to real CSS |
| `@shopify/flash-list` v2 | ✅ | Ships `PlatformHelper.web.js` and `measureLayout.web.js` |
| `expo-image` | ✅ | Maps to `<img>` with caching handled by the browser |
| `@react-native-async-storage/async-storage` | ✅ | Backed by `localStorage` |
| `@react-native-community/netinfo` | ✅ | Backed by `navigator.onLine` |
| `react-native-safe-area-context` | ✅ | Insets resolve to 0 — harmless |
| `react-native-reanimated` | ✅ | Runs, though without a separate UI thread |
| `expo-haptics` | ✅ | `navigator.vibrate`, with a switch-element trick for iOS Safari; silently no-ops on desktop, which is correct |
| **`expo-secure-store`** | ❌ | Its web build is literally `export default {}`. Any call throws |
| **`Alert.alert`** | ⚠️ | `react-native-web` defines it as `static alert() {}` — a **silent no-op**. Your error message simply never appears |
| `expo-notifications` (push) | ⚠️ | Different mechanism entirely (Web Push); do not assume parity |
| Camera, biometrics, background tasks | ❌ | Native-only. Branch or hide the feature |

The two rows in bold are the dangerous ones: they fail **silently or at runtime**, never at build time. The bundle succeeds, TypeScript is happy, and the bug ships.

---

## The two traps in detail

### `expo-secure-store` does not exist on web

There is no Keychain in a browser. The honest cross-platform answer is not "use localStorage instead" — it is that **web sessions belong in an httpOnly cookie set by your backend**, which JavaScript cannot read and therefore cannot leak through XSS.

```ts
// src/lib/session-storage.ts
import { Platform } from "react-native";
import * as SecureStore from "expo-secure-store";

/**
 * Native: token in the Keychain / Keystore.
 * Web: no client-side token at all — the backend sets an httpOnly cookie and
 *      the browser attaches it automatically. Never mirror a token into
 *      localStorage "so the code is symmetric"; that is an XSS-readable token.
 */
export const sessionStorage = {
  async setToken(token: string) {
    if (Platform.OS === "web") return; // cookie already set by the server
    await SecureStore.setItemAsync("session-token", token);
  },

  async getToken(): Promise<string | null> {
    if (Platform.OS === "web") return null; // fetch sends the cookie itself
    return SecureStore.getItemAsync("session-token");
  },

  async clear() {
    if (Platform.OS === "web") {
      await fetch("/auth/logout", { method: "POST", credentials: "include" });
      return;
    }
    await SecureStore.deleteItemAsync("session-token");
  },
};
```

Web requests then use `credentials: "include"`; native requests attach the `Authorization` header. Pair with `auth-architect`, which already treats httpOnly cookies as the correct web default.

### `Alert.alert` is a silent no-op on web

```tsx
// BAD — on web the user sees absolutely nothing
onError: () => Alert.alert("No se pudo guardar", "Revisá tu conexión.")
```

Use one notify function with a real web path. In-app UI (a toast) is better than `window.alert` on both platforms anyway — `Alert` on native blocks, and `window.alert` on web blocks the whole tab.

```ts
// src/lib/notify.ts
import { Alert, Platform } from "react-native";

export function notify(title: string, message?: string) {
  if (Platform.OS === "web") {
    // Replace with your toast component once there is one — this is the floor,
    // not the goal. What matters is that web is never left silent.
    window.alert(message ? `${title}\n\n${message}` : title);
    return;
  }
  Alert.alert(title, message);
}
```

**Generalization:** any `react-native` API that "does nothing" on web is more dangerous than one that throws. Grep for `Alert.alert`, `Vibration`, `BackHandler`, `PermissionsAndroid`, and `Linking.canOpenURL` before shipping a web build.

---

## How to write platform differences

**Preferred — platform-specific files.** Metro picks the right one automatically; nothing platform-specific ends up in the other bundle:

```
src/components/DatePicker.tsx        # native
src/components/DatePicker.web.tsx    # web
```

**For small branches — `Platform.select`:**

```ts
const shadow = Platform.select({
  web: { boxShadow: "0 4px 12px rgba(0,0,0,0.08)" },
  ios: { shadowColor: "#000", shadowOpacity: 0.08, shadowRadius: 12 },
  android: { elevation: 3 },
});
```

**For capabilities — feature-detect, do not platform-detect:**

```ts
// GOOD — survives a future platform gaining the capability
const canShare = typeof navigator !== "undefined" && "share" in navigator;

// WORSE — a guess baked into a conditional
const canShare = Platform.OS !== "web";
```

**Never** put a platform check inside a hot render path. Resolve it once at module scope.

---

## Layout: three targets, not two

Mobile-first still holds — 360px first — but web adds a real desktop viewport that phones never have.

- Cap content width on web (`maxWidth: 720` for reading) or you get 1400px-wide lines nobody reads
- The bottom tab bar is a **mobile** pattern. On a wide web viewport, switch to a top nav or a sidebar — a tab bar pinned to the bottom of a desktop browser is the Shrunk Desktop tell in reverse
- `useWindowDimensions()` drives this; container queries and CSS media queries are not available to native
- Hover exists on web and nowhere else. It may **add** affordance, never carry required information

```tsx
const { width } = useWindowDimensions();
const isWide = width >= 768;   // one breakpoint is usually enough
```

---

## Verification: three commands, not one

A change is not done until all three pass. Add this to CI:

```bash
npx tsc --noEmit
npx expo export --platform ios --output-dir /tmp/x-ios
npx expo export --platform android --output-dir /tmp/x-android
npx expo export --platform web --output-dir /tmp/x-web
```

Bundling all three catches import-level breakage. It does **not** catch the silent no-ops above — those need the manual pass:

- [ ] Web build opened in a browser; console clean
- [ ] Every error path produces visible feedback **on web** (the `Alert` trap)
- [ ] Anything touching secure storage, camera, biometrics, or push branches correctly or is hidden
- [ ] Wide viewport: content width capped, navigation is not a bottom tab bar
- [ ] Deep link and a direct URL load both resolve to the right screen
- [ ] Browser back button behaves like the Android hardware back button

---

## Deploying the web build

`output: "static"` in `app.json` produces plain HTML/JS/CSS — no Node server needed, which is exactly what Dublin's VPS-first convention wants:

```nginx
location / {
    root /var/www/mi-app;
    try_files $uri $uri.html $uri/index.html /index.html;
}
```

`try_files` with the `.html` fallback matters: expo-router emits `/settings.html`, and without it a refresh on a deep route 404s.
