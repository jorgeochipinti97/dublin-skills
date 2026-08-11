---
name: mobile-app-foundation
description: Day-0 architecture for cross-platform apps with React Native + Expo — one codebase shipping to iOS, Android AND web. Use when the user wants to build a mobile app, says "app mobile", "app nativa", "multiplataforma", "React Native", "Expo", "quiero subirla a la App Store / Play Store", "TestFlight", "APK", "boilerplate mobile", or is a web developer touching mobile for the first time. Covers project structure (expo-router), styling + dual theme (NativeWind), lists and offline data (FlashList + TanStack Query), navigation, safe areas, cross-platform parity (the modules that fail silently on web), dev builds vs Expo Go, EAS Build, store submission, static web export, and OTA updates. Names the native AI Tells (Web Brain, ScrollView Graveyard, Notch Blind, Keyboard Eater, Expo Go Mirage, Version Roulette, Store Surprise, Offline Amnesia, One-Target Tell). Distinct from mobile-design, which is responsive CSS for a website. Ships a runnable boilerplate via scripts/create-mobile-app.sh.
---

# Mobile App Foundation (React Native + Expo)

This skill is for **apps that ship to the App Store and Play Store** — and, per Dublin mandate, **to the web from the same codebase**. If the deliverable is only a website that has to look good on a phone, this is the wrong skill — use `mobile-design`.

| | `mobile-design` | `mobile-app-foundation` (this) |
|---|---|---|
| Medium | Web page in a mobile browser | Native binary **+** a static web build |
| Tech | CSS, Tailwind, media queries | React Native, Expo, native modules, react-native-web |
| Ships via | `git push` | EAS Build → TestFlight / Play Console, **and** `expo export --platform web` → VPS |
| "Deploy" takes | seconds | seconds on web, hours to days on the stores (review) |
| Overflow bug | horizontal scroll | no horizontal scroll on native; different failure modes per target |

**Three targets, one codebase.** That is the Dublin default, not an upsell: the same routes become a native app *and* a static site with real URLs. It also means every API you reach for has to work on all three — and two of them fail *silently* on web. See `references/cross-platform.md`.

---

## Philosophy

> **React Native is not React with different tags. The primitives, the threading model, and the release cycle are all different.**

Three principles:

1. **The build is the product.** On web, the code you wrote is what runs. On mobile, a binary compiled weeks ago is what runs, on an OS version you did not choose, on a device you do not own. Design for that gap from day 0 — that is what OTA updates, runtime versions, and dev builds exist for.
2. **The device is hostile.** Intermittent network, a keyboard that eats half the screen, a notch, a gesture bar, background eviction, and a user holding it one-handed on a moving train. None of these exist in your simulator by default.
3. **Ship the boring path first.** A content app is a list, a detail screen, and a cache. Get that running on a real phone in your hand before adding anything else.

---

## Non-Negotiable Mandates

Break these and the app is broken, not merely imperfect.

1. **Never hand-pin native package versions.** Always `npx expo install <pkg>` — it resolves the version compatible with the installed SDK. Editing `package.json` by hand is the #1 cause of red screens. (**Version Roulette**)
2. **Any list that can exceed ~20 items uses `FlashList`.** Never `<ScrollView>{items.map(...)}</ScrollView>`. (**ScrollView Graveyard**)
3. **Safe areas on every screen edge.** `useSafeAreaInsets()` or `SafeAreaView` — the notch and the home indicator are not optional. (**Notch Blind**)
4. **Dark + light theme from day 0.** Dublin hard rule, and on mobile it is worse than on web: the OS ships a system-wide setting your users already have on. Following it is table stakes.
5. **Every data screen defines its offline behavior** before it is called done: cached render, stale indicator, and an error state that is not an infinite spinner. (**Offline Amnesia**)
6. **Test on a physical device with a dev build** before calling anything done. Expo Go is a preview, not your app. (**Expo Go Mirage**)
7. **`.npmrc` with `node-linker=hoisted`** in any pnpm React Native project. Metro does not follow pnpm's symlinked `node_modules`; without it the bundle fails on modules you never imported directly — and `tsc` passes clean, so a typecheck-only CI gate misses it. (**The pnpm Trap**)
8. **Translate design-skill output yourself — never hand the user web code to convert.** Every frontend skill in this library targets the DOM. When one of them runs inside a React Native project (detected by an `expo` key in `app.json`/`app.config.*`, or `react-native` in `package.json`), convert its output through `references/design-skills-bridge.md` **before writing a line**, and state which substitutions were made. Emitting `backdrop-filter`, Framer Motion, Radix, or `:hover` into an RN codebase is a defect, not a starting point — the person asking for a mobile app is the least equipped to do that conversion. **Never run `frontend-output-validator` against native output**: Lighthouse cannot profile a binary and its greps report green without measuring anything. (**Web Code Handoff**)
9. **All three targets, always: iOS + Android + web.** Dublin apps are multiplatform by default, not iOS-and-maybe-Android. Every change bundles for all three before it is done, and every API is checked against the support matrix in `references/cross-platform.md`. Two modules fail *silently* on web — `expo-secure-store` (its web build is `export default {}`) and `Alert.alert` (react-native-web defines it as `static alert() {}`) — so a green build proves nothing on its own. (**One-Target Tell**)

---

## The AI Tells — native edition

Named anti-patterns, siblings to the web ones in `premium-frontend-design`. These are what "a web dev's first React Native app" looks like.

| Tell | What it looks like | Why it hurts |
|---|---|---|
| **Web Brain** | `<div>`, `onClick`, `position: fixed`, `hover:` variants, `100vh`, CSS files | Silently no-ops or crashes; there is no DOM |
| **ScrollView Graveyard** | Feed of 500 items inside a `ScrollView` with `.map()` | Every row mounts at once; memory spike, stutter, eventual crash |
| **Notch Blind** | Header under the status bar, tab bar under the home indicator | Looks broken on every phone made after 2017 |
| **Keyboard Eater** | Focused input hidden behind the soft keyboard | User cannot see what they type; no `KeyboardAvoidingView` |
| **JS Thread Jam** | Animation driven by `useState` + `setInterval` | Animation stalls whenever JS is busy; use Reanimated on the UI thread |
| **Expo Go Mirage** | "It works on my phone" — in Expo Go | Native modules, config plugins, and OTA behavior differ in a real build |
| **Ghost Tap** | `<Text onPress>` with no feedback, targets < 44pt, no `hitSlop` | Users tap and nothing appears to happen; feels dead |
| **Version Roulette** | Hand-edited RN/Expo versions in `package.json` | Native/JS mismatch → red screen, often only in release builds |
| **Store Surprise** | Discovering permission strings, privacy manifest, icons, and age rating at submission | Ships one to two weeks late for reasons that took 20 minutes to fix |
| **Offline Amnesia** | Spinner forever on the subway | For a content app this is the single most common one-star review |
| **The pnpm Trap** | pnpm project with no `node-linker=hoisted` | Bundle fails on transitive deps; typecheck passes, so CI says green |
| **One-Target Tell** | Built and checked on iOS only | Web silently loses every `Alert`, and any secure-store call throws at runtime |
| **Symmetric Storage Trap** | Mirroring the native token into `localStorage` "so web matches" | Turns a Keychain-protected token into an XSS-readable one |
| **Web Code Handoff** | Emitting `backdrop-filter` / Framer Motion / Radix into an RN project, or telling the user to convert it | It does not run, and the person who asked for a mobile app is the least able to translate it |
| **False Green** | Running `frontend-output-validator` (Lighthouse) on a native app | Reports pass without measuring anything — worse than no check |

---

## When This Skill Fires

Triggers (any of these in user input):
- "app mobile", "app nativa", "aplicación para celular", "quiero hacer una app"
- "React Native", "Expo", "expo-router", "EAS", "eas build"
- "App Store", "Play Store", "TestFlight", "APK", "AAB", "store review"
- "boilerplate mobile", "arrancar una app", "nunca hice mobile"
- "dev build", "Expo Go", "simulador", "probar en el celular"
- "OTA", "over the air", "expo-updates"
- Audit flags: any Tell in the table above

---

## Workflow

When invoked:

1. **Confirm it is actually a native app.** If the answer to "does this need to be in an app store, use push notifications, or work offline?" is no, stop and route to a web stack — a native app costs an order of magnitude more to ship and maintain. If it *is* a native app, all three targets are in scope by default; dropping web is a decision to state explicitly, not a default.
2. **Scaffold or read.** New project → run `scripts/create-mobile-app.sh <path>` (see below). Existing project → read `app/`, `package.json`, `app.json`, and any `eas.json` before proposing anything.
3. **Lock the structure** — routes, tab layout, and the shared layer. See `references/project-structure.md`.
4. **Lock the theme** — tokens, dark + light, safe areas, type scale. See `references/styling-and-theming.md`. Write the project's `DESIGN.md` (mobile flavor) at this step, not later.
5. **Lock the data layer** — query client, cache persistence, list strategy, image caching, offline states. See `references/data-and-offline.md`.
6. **Verify all three targets.** Bundle for iOS, Android, and web (`npx expo export --platform <t>`) — that catches import-level breakage. Then get it **on a real phone** with a dev build, and **open the web build in a browser**: the two silent-failure modules produce green builds and broken behavior. See `references/testing-on-device.md` and `references/cross-platform.md`. Nothing after this point is trustworthy without it.
7. **Plan the release path before writing features** — bundle identifiers, credentials, permission strings, icons, OTA runtime versions. See `references/builds-and-distribution.md`. Doing this on day 0 costs 30 minutes; doing it at launch costs a week.
8. **Hand off** — screens go to `mobile-design` for pattern picks (bottom sheet, FAB, thumb zones translate directly), `forms-and-validation` for forms (React Hook Form + Zod work unchanged in RN), `auth-architect` for sessions (with `expo-secure-store` as the token store).

---

## The Boilerplate

```bash
skills/mobile/mobile-app-foundation/scripts/create-mobile-app.sh ~/Desktop/main/proyectos/mi-app
```

It runs `create-expo-app` (so Expo itself picks correct, current versions — never a hand-written `package.json`), then overlays the Dublin layer from `templates/`:

- **expo-router** tabs + stack + detail route + not-found
- **NativeWind** with design tokens and **dark + light from the first commit**, system-following with a manual override
- **TanStack Query** with an AsyncStorage persister → the feed renders from cache on cold start with no network
- **FlashList** feed, **expo-image** with disk caching
- **Safe areas** wired into a `Screen` primitive so no screen can forget them
- A small component layer (`Screen`, `Text`, `Card`, `Button`, `Skeleton`) on top of RN primitives
- `DESIGN.md` (Dublin contract, mobile tokens) and `eas.json` with `development` / `preview` / `production` profiles

Then:

```bash
cd mi-app
pnpm start            # Expo Go — quick preview only
pnpm ios / pnpm android   # simulator
```

To run it as your real app on a physical device (required before shipping), follow `references/testing-on-device.md` §Dev Build.

---

## Stack Decisions (with the WHY)

| Concern | Pick | Why this and not the alternative |
|---|---|---|
| Framework | **Expo (managed)** | EAS builds in the cloud; no Xcode/Android Studio to start. Bare RN buys native control you do not need yet and costs a local toolchain forever. `expo prebuild` is the exit ramp if you ever need it — you are not locked in. |
| Routing | **expo-router** | File-based like Next.js, so the mental model transfers. Deep links and universal links come nearly free — they are painful to retrofit. |
| Styling | **NativeWind 4** | Tailwind syntax on native. Reuses your existing muscle memory, which is the whole point for a first app. Unistyles 3 is faster but adds concepts and needs the new architecture; revisit only if you measure a styling bottleneck. |
| Lists | **FlashList 2** | Recycles views. `FlatList` is acceptable; `ScrollView` + `map` is not. |
| Server state | **TanStack Query** | Same API you already know on web, plus a persister that gives offline-first almost for free. |
| Local storage | **AsyncStorage** to start, **MMKV** later | AsyncStorage runs in Expo Go. MMKV is much faster but wants a dev build — a fine upgrade once you already have one. |
| Secrets | **expo-secure-store** on native, **httpOnly cookie** on web | Keychain / Keystore natively. Never a token in AsyncStorage — and never mirrored into `localStorage` on web to make the code symmetric; that hands it to any XSS. `expo-secure-store` has no web build at all. |
| Web target | **react-native-web + `output: "static"`** | Same routes become a static site with real URLs — deployable to a VPS with nginx, no Node server. |
| Images | **expo-image** | Disk + memory cache, blurhash placeholders, correct `contentFit`. `<Image>` from RN caches poorly. |
| Animation | **react-native-reanimated** | Runs on the UI thread, so animation survives a busy JS thread. |

Verify every version with `npx expo install` at scaffold time. Do not trust a version written in any document, including this one.

---

## Outputs

- **Structure plan** — route tree, layout nesting, where shared code lives
- **Theme spec** — token table, dark + light values, type scale, safe-area strategy, written into `DESIGN.md`
- **Data plan** — per screen: query key, cache time, offline behavior, error state, list strategy
- **Release plan** — bundle IDs, permission strings, credential ownership, build profiles, OTA runtime version policy
- **Device test checklist** — what to verify on a physical phone before calling it done

---

## Reference Files (load on demand)

- `references/design-skills-bridge.md` — **translation table for every other frontend skill in this library**: what to keep vs drop per skill, web technique → native package (`backdrop-filter` → `expo-blur`, Framer Motion → Reanimated, Vaul → `@gorhom/bottom-sheet`, Recharts → `victory-native`…), a worked before/after example, and the native-only affordances a translated web design always omits (haptics, gestures, lifecycle, offline, hardware back)
- `references/cross-platform.md` — **the iOS + Android + web mandate**: verified support matrix, the two silent-failure modules, platform-specific files vs `Platform.select` vs feature detection, wide-viewport layout, three-target verification, static web export to a VPS
- `references/project-structure.md` — expo-router routes, groups, layouts, modals, deep links, where code lives
- `references/styling-and-theming.md` — NativeWind setup, tokens, dark + light, safe areas, type scale, platform differences
- `references/data-and-offline.md` — TanStack Query + persistence, FlashList, expo-image, offline states, pull-to-refresh, infinite feed
- `references/native-gotchas.md` — every AI Tell above with BAD/GOOD pairs, plus the web-to-native translation table
- `references/builds-and-distribution.md` — EAS Build profiles, credentials, TestFlight, Play internal testing, store assets, OTA updates and runtime versions
- `references/testing-on-device.md` — Expo Go vs dev build vs production build, simulators, physical devices, Maestro E2E

---

## Output Standards

- Complete, runnable code — no `// TODO: implement`
- TypeScript throughout, `strict` on
- Every dependency verified via `npx expo install` before it is imported
- Voseo in prose, technical English in code identifiers
- Names and data in examples are real Latin contexts (Camila Pereyra, Tomás Arias), real businesses (Despegar, Mercado Libre), realistic numbers (`$ 14.760,50`) — never `John Doe` / `Acme` / `99.99%`
- State plainly when something requires a dev build, a paid Apple Developer account, or a store review — those are the surprises that sink first-time mobile projects
