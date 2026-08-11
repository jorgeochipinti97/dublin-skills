# Builds & Distribution (EAS)

The part web developers underestimate. On web, deploy is `git push` and it is live in a minute. Here, a release is a compiled binary reviewed by a corporation. Plan for it on day 0.

---

## The three build types

| Type | What it is | When |
|---|---|---|
| **Development build** | Your app + the dev client (fast refresh, dev menu) | Daily work, once you have any dependency Expo Go lacks |
| **Preview** | Release-mode build, distributed internally (link / QR / TestFlight) | Sharing with clients and testers |
| **Production** | Store-signed release build | App Store / Play Store submission |

**Expo Go is not on this list.** It is a preview host app, not your app. See the Expo Go Mirage tell.

---

## eas.json

```jsonc
{
  "cli": { "version": ">= 12.0.0", "appVersionSource": "remote" },
  "build": {
    "development": {
      "developmentClient": true,
      "distribution": "internal",
      "env": { "EXPO_PUBLIC_API_URL": "https://api-dev.ejemplo.com" }
    },
    "preview": {
      "distribution": "internal",
      "ios": { "simulator": false },
      "env": { "EXPO_PUBLIC_API_URL": "https://api-staging.ejemplo.com" }
    },
    "production": {
      "autoIncrement": true,
      "env": { "EXPO_PUBLIC_API_URL": "https://api.ejemplo.com" }
    }
  },
  "submit": {
    "production": {
      "ios": { "appleId": "vos@ejemplo.com", "ascAppId": "1234567890" },
      "android": { "serviceAccountKeyPath": "./play-service-account.json" }
    }
  }
}
```

`env` here is **build-time** and `EXPO_PUBLIC_*` values are inlined into the JS bundle — readable by anyone with the app. Secrets go in EAS secrets (`eas secret:create`) and only reach the build environment, never the bundle. Better: keep secrets on your own backend and never ship them at all.

`"appVersionSource": "remote"` with `autoIncrement` lets EAS manage build numbers, which removes an entire category of "this build number was already used" rejections.

---

## First build

```bash
pnpm add -g eas-cli        # or npx eas-cli@latest
eas login
eas build:configure        # creates/updates eas.json, links the project

eas build --profile development --platform ios
eas build --profile development --platform android
```

Builds run in Expo's cloud. No Xcode, no Android Studio. First iOS build asks about credentials — let EAS manage them unless your organization already owns certificates. EAS-managed is the right default; it stores and rotates them for you.

Install: Android gives an `.apk` you can install directly from the link. iOS needs the device UDID registered first:

```bash
eas device:create      # register a device, then rebuild
```

That UDID step catches everyone once. iOS internal distribution only installs on registered devices.

---

## Store submission

```bash
eas build --profile production --platform ios
eas submit --profile production --platform ios
```

What you need before the first submission — none of it is optional:

**iOS**
- Apple Developer Program membership (USD 99/year, approval can take a day or more)
- An app record in App Store Connect with the exact `bundleIdentifier`
- Icon 1024×1024, no alpha channel, no pre-rounded corners
- Screenshots for the required device sizes
- Privacy policy URL
- App Privacy answers (what data you collect, whether it is linked to the user, whether used for tracking)
- Usage strings in `infoPlist` for every permission, each explaining the specific why
- A privacy manifest for tracking-relevant APIs — Expo generates this for its own modules; third-party SDKs must supply theirs

**Android**
- Play Console account (USD 25, one time)
- App signing — let Play manage the signing key
- Feature graphic 1024×500 plus screenshots
- Data safety form (mirrors Apple's, filled separately)
- Target API level requirement, which Google raises annually — an old SDK eventually blocks updates

**Review time** is usually well under 48 hours for both, but plan for at least one rejection round on a first submission. Rejections most often cite: a missing/vague permission string, a broken demo account, a privacy policy that does not match the disclosure, or a login wall with no way for the reviewer in. **Give the reviewer working test credentials in the review notes** — the single highest-yield line you will write.

---

## Internal distribution before the stores

Faster loops, no review:

- **TestFlight** (iOS) — `eas submit` to TestFlight; internal testers get builds in minutes, external testers need a light review
- **Play internal testing** (Android) — same idea, near-instant for the internal track
- **EAS internal distribution** — an install link/QR, no store involved at all; ideal for a client demo on Friday

---

## OTA updates (expo-updates)

Ship JS and asset changes without a store review.

```bash
npx expo install expo-updates
eas update:configure
eas update --branch production --message "fix: corregir fecha en el detalle"
```

**The hard limit:** OTA updates deliver **JavaScript and assets only**. Anything that changes native code — adding a library with native modules, changing a config plugin, bumping the SDK, editing `app.json` native config — requires a new store build. Pushing an OTA update whose JS expects native code the installed binary lacks **crashes the app on launch for every user**. That is the one genuinely dangerous mistake in this document.

The guard is the runtime version:

```jsonc
// app.json
{ "expo": { "runtimeVersion": { "policy": "appVersion" } } }
```

Updates only reach binaries with a matching runtime version. With the `appVersion` policy, bumping `version` for a native change automatically prevents the new JS from landing on old binaries. Newer Expo versions also offer a `fingerprint` policy that derives the runtime version from the actual native dependency set — more precise, and worth checking the current Expo docs for before adopting.

**Treat every OTA push as a production write.** Dublin's `change-safety` skill applies: you are shipping directly to installed devices with no review gate between you and every user. Roll out on a `preview` branch first, verify on a real device, then promote.

Rollback:
```bash
eas update:republish --branch production --group <previous-group-id>
```

---

## Versioning

| Field | Meaning | Who bumps it |
|---|---|---|
| `version` (`1.4.0`) | User-visible, shown in the store | You, per release |
| `ios.buildNumber` / `android.versionCode` | Internal, must strictly increase | EAS, via `autoIncrement` |

Bump `version` whenever native code changes, so the `appVersion` runtime policy does its job.

---

## Day-0 checklist

Thirty minutes now, a week saved later:

- [ ] `bundleIdentifier` and `package` chosen — permanent after first submission
- [ ] Apple Developer + Play Console accounts started (approval lag is real)
- [ ] `app.json`: `scheme`, `userInterfaceStyle: "automatic"`, icon, adaptive icon, splash with a dark variant
- [ ] Permission usage strings written for every permission you will plausibly need
- [ ] `eas.json` with all three profiles
- [ ] A dev build installed on one real iPhone and one real Android
- [ ] Privacy policy URL exists (even a simple page)
- [ ] Runtime version policy chosen and understood
- [ ] Store credentials owned by the **client's** account, not a personal one — moving an app between Apple accounts later is genuinely painful
