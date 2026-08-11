# __PROJECT__

Cross-platform app — **iOS + Android + web from one codebase**. React Native + Expo, scaffolded from the Dublin `mobile-app-foundation` skill.

## Run it

```bash
pnpm start          # Metro; scan the QR with Expo Go for a quick look
pnpm ios            # iOS simulator (macOS only)
pnpm android        # Android emulator
pnpm web            # browser
```

The feed renders from a local fixture, so it works with no backend. Point it at a real API by setting `EXPO_PUBLIC_API_URL` and deleting the fixture block at the bottom of `src/api/articles.ts`.

> `EXPO_PUBLIC_*` values are inlined into the JS bundle and readable by anyone who downloads the app. Never put a secret in one.

## What is already wired

- **expo-router** — file-based routes: tabs, a stack detail route, `+not-found`
- **Dual theme from commit 1** — light + dark, following the OS by default, overridable in Ajustes
- **Design tokens** — `global.css` (CSS variables → NativeWind classes) mirrored in `src/theme/tokens.ts` for imperative consumers
- **Safe areas** — owned by the `Screen` primitive; no route can forget them
- **TanStack Query + AsyncStorage persister** — cold start with no network still renders the last feed
- **Online/focus managers** — queries refetch when signal returns and when the app comes to the foreground
- **FlashList** feed with infinite scroll and pull-to-refresh
- **expo-image** with disk caching and fixed aspect ratios
- **Offline states** — skeleton, stale bar, retry; never a dead spinner
- **Save for offline** — optimistic toggle, image prefetch, reads in airplane mode

## Structure

```
src/
├── app/             # routes ONLY — a file here becomes a URL
│   ├── _layout.tsx  # providers, theme, stack
│   ├── (tabs)/      # bottom tab navigator
│   └── article/[id].tsx
├── api/             # fetchers + query hooks
├── components/      # ui/ primitives + feature components
├── lib/             # query client, saved-articles storage
├── theme/           # tokens + hooks
└── global.css       # Tailwind directives + CSS variables
```

Imports use the `@/` alias (`@/lib/query`, `@/theme/useTheme`) — it maps to `./src/*` in `tsconfig.json`.

`.npmrc` sets `node-linker=hoisted`. **Do not delete it.** Metro does not follow pnpm's symlinked `node_modules`, and without it the bundle fails on transitive dependencies while `tsc` still passes.

## Before you ship

Read the skill's `references/builds-and-distribution.md` and do the day-0 checklist. The short version:

1. Set `ios.bundleIdentifier` and `android.package` in `app.json` — **immutable after the first store submission**
2. Start the Apple Developer (USD 99/yr) and Play Console (USD 25 once) accounts; approval takes time
3. Write permission usage strings for anything you will request
4. Make a dev build and run it on a real phone — Expo Go is not your app

```bash
eas build --profile development --platform ios
eas build --profile development --platform android
```

## Cross-platform

Web is a first-class target, not a bonus. `expo export --platform web` produces a static site (real URLs, SEO) that deploys to a VPS with nginx — no Node server.

```bash
npx expo export --platform web --output-dir dist
```

```nginx
location / {
    root /var/www/dist;
    try_files $uri $uri.html $uri/index.html /index.html;
}
```
The `$uri.html` fallback matters: expo-router emits `/settings.html`, and without it a refresh on a deep route 404s.

**Two modules fail silently on web — a green build proves nothing:**

| Instead of | Use | Why |
|---|---|---|
| `Alert.alert` | `src/lib/notify.ts` | `react-native-web` defines Alert as `static alert() {}` — your message never appears |
| `expo-secure-store` directly | `src/lib/session-storage.ts` | Its web build is `export default {}`; any call throws |

Never mirror a native token into `localStorage` to make the code symmetric — that turns a Keychain-protected secret into an XSS-readable one. On web the session belongs in an httpOnly cookie.

## Rules that are not negotiable

See `DESIGN.md`. The three that break apps most often:

- **Never hand-edit native package versions.** Use `npx expo install <pkg>`, and run `npx expo install --check` before every build.
- **Never ship an OTA update whose JS needs native code the installed binary lacks.** It crashes the app on launch for every user.
- **Never call a change done after checking one platform.** Bundle all three, then open the web build in a browser and run the app on a real phone.
