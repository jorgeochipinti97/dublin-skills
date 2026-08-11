# Testing on Device

> Nothing about a mobile app is trustworthy until you have held it. The simulator is a development convenience, not evidence.

---

## The four environments, in order of trust

| Environment | Trust | What it catches | What it misses |
|---|---|---|---|
| Expo Go | lowest | Layout, obvious logic | Native modules, config plugins, real perf, deep links, push |
| Simulator / emulator | low | Layout across sizes, navigation | Performance, gestures, camera, haptics, biometrics, real network |
| **Dev build on a real phone** | high | Almost everything | Release-only optimizations |
| Production/preview build on a real phone | highest | Everything | — |

Ship decisions come from the bottom two rows.

---

## Expo Go — the five-minute look

```bash
pnpm start          # scan the QR with the Expo Go app
```

Fine for checking a layout on day 1. Stop using it the moment you add a dependency with native code, a config plugin, push notifications, or deep links. See the **Expo Go Mirage** tell.

---

## Dev build — your actual daily driver

A dev build is *your* app compiled with the dev client attached: fast refresh and the dev menu, but with your real native dependencies and config.

**Cloud (no local toolchain — recommended to start):**
```bash
eas build --profile development --platform ios       # register device UDID first
eas build --profile development --platform android
```
Install from the link, then:
```bash
pnpm start --dev-client
```

**Local (needs Xcode / Android Studio, but no wait in a queue):**
```bash
npx expo run:ios --device
npx expo run:android --device
```

Rebuild a dev build only when **native** dependencies change. JS changes hot-reload as always. A common mistake is rebuilding for every change — unnecessary and slow.

---

## Physical device setup

**iOS:** device and Mac on the same network; scan the QR. If the connection fails (corporate Wi-Fi, client-isolation networks), use `pnpm start --tunnel`.

**Android:** same network, or plug in USB and use `adb reverse tcp:8081 tcp:8081`, which is more reliable than Wi-Fi.

**Test on a cheap Android.** Not the team's flagship. A mid-range device three years old is what a large share of your users hold, and it is where `ScrollView` graveyards and unoptimized images actually hurt. If the app is smooth there, it is smooth everywhere.

---

## What requires a real device, always

- **Performance** — simulators run on your desktop CPU and lie about scroll and animation
- **Push notifications on iOS** — do not work in the simulator, at all
- **Camera, microphone, biometrics, haptics**
- **Real network conditions** — 3G, lossy connections, airplane mode transitions
- **Gestures** — swipe-back, pull-to-refresh, and momentum scroll feel different with a thumb
- **Safe areas** — a notch and a home indicator on real glass
- **Battery and thermals** — a hot phone throttles, and your animation budget disappears

---

## Manual checklist before calling a screen done

Run this on a real phone, both platforms if both ship:

- [ ] Light **and** dark mode (toggle in OS settings while the app is open)
- [ ] Top content clear of the status bar / Dynamic Island; bottom clear of the home indicator
- [ ] Scroll a long list — no stutter, no blank cells
- [ ] Airplane mode: cached content renders, offline state is explicit, no infinite spinner
- [ ] Airplane mode off: data refreshes without a manual restart
- [ ] Every tappable target reachable one-handed and ≥ 44pt, with visible press feedback
- [ ] Keyboard does not cover the focused input; the first tap on a button works
- [ ] Android hardware back does the right thing on every screen, including modals
- [ ] Rotate, or use split screen on Android — nothing overlaps or crashes
- [ ] OS font size at a large accessibility setting — text stays readable, layout survives
- [ ] Kill the app and reopen — it restores sensibly; the splash does not flash the wrong color
- [ ] Deep link opens the right screen: `npx uri-scheme open "miapp://article/1947" --ios`

---

## Automated tests

Keep the pyramid from `testing-strategy`; only the tooling changes.

**Unit / component** — Jest + `@testing-library/react-native`:
```bash
npx expo install -- --dev jest jest-expo @testing-library/react-native
```
```tsx
import { render, screen, fireEvent } from "@testing-library/react-native";

it("navega al detalle al tocar la tarjeta", () => {
  const onPress = jest.fn();
  render(<ArticleCard article={articleFixture} onPress={onPress} />);
  fireEvent.press(screen.getByText("Cómo Despegar rediseñó su checkout"));
  expect(onPress).toHaveBeenCalled();
});
```
Query by accessible text and labels, never by test ids on visible content — it tests what the user perceives and doubles as an accessibility check.

**E2E** — **Maestro** is the pragmatic pick for React Native. YAML flows, no build instrumentation, runs on simulators and real devices:
```yaml
# .maestro/feed.yaml
appId: com.dublin.miapp
---
- launchApp
- assertVisible: "Inicio"
- tapOn: "Cómo Despegar rediseñó su checkout"
- assertVisible: "Camila Pereyra"
- back
- assertVisible: "Inicio"
```
```bash
maestro test .maestro/feed.yaml
```

Keep E2E to the two or three flows whose breakage would be an emergency — launch → feed → detail, and login if there is one. Mobile E2E is slower and flakier than web; a large suite becomes a suite nobody trusts.

**What to skip:** snapshot tests of RN component trees. High churn, near-zero signal.

---

## Debugging

- **Dev menu** — shake the device, or `m` in the terminal
- **React DevTools / debugger** — press `j` in the Expo CLI to open the Hermes debugger
- **Network inspection** — the debugger's network tab, or Reactotron for a richer view
- **Performance** — the dev menu's performance monitor shows JS and UI thread FPS. A UI thread below 60 means the native side is the problem; a JS thread below 60 means your code is
- **Release-only bugs** — build with the `preview` profile and reproduce there. Minification, stripped dev warnings, and Hermes optimizations surface bugs invisible in development

---

## Crash reporting from day 1

You will not see production crashes otherwise — there is no server log and users do not file reports, they uninstall.

```bash
npx expo install @sentry/react-native
```

Configure the EAS build hook so source maps upload automatically; without them a stack trace is minified garbage. Verify by triggering a test crash in a preview build **before** the first store release.
