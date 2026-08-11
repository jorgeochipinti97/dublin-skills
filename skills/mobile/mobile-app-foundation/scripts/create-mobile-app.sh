#!/usr/bin/env bash
#
# Scaffold a Dublin-flavored Expo app.
#
#   create-mobile-app.sh <target-path> [app-name]
#
# Strategy: let create-expo-app pick the SDK and all native package versions
# (never a hand-written package.json — that is Version Roulette), then overlay
# the Dublin layer: tokens + dual theme, safe-area Screen primitive, persisted
# query cache, FlashList feed, offline states, DESIGN.md, eas.json.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATES="$SCRIPT_DIR/../templates"

bold() { printf "\033[1m%s\033[0m\n" "$1"; }
info() { printf "  %s\n" "$1"; }
fail() { printf "\033[31merror:\033[0m %s\n" "$1" >&2; exit 1; }

# ---------------------------------------------------------------- arguments

[[ $# -ge 1 ]] || fail "usage: create-mobile-app.sh <target-path> [app-name]"

TARGET="$1"
APP_NAME="${2:-$(basename "$TARGET")}"

[[ -d "$TEMPLATES" ]] || fail "templates not found at $TEMPLATES"

if [[ -e "$TARGET" ]] && [[ -n "$(ls -A "$TARGET" 2>/dev/null)" ]]; then
    fail "$TARGET exists and is not empty — refusing to overwrite"
fi

command -v node >/dev/null 2>&1 || fail "node is required"

PKG=pnpm
command -v pnpm >/dev/null 2>&1 || {
    printf "  pnpm not found, falling back to npm\n"
    PKG=npm
}

# ------------------------------------------------------- 1. base Expo app

bold "1/6  create-expo-app (Expo resolves the SDK and all native versions)"
npx --yes create-expo-app@latest "$TARGET" --template default --no-install

cd "$TARGET"

# ------------------------------------------------------- 2. Dublin overlay

bold "2/6  Overlaying the Dublin layer"

# The default template ships an example app; routes live in src/app/ and the
# rest of its source in src/. Replace src/ wholesale rather than merging —
# a merge leaves orphan example routes and dangling imports behind. (Copying
# onto an existing src/ would also nest it as src/src/.)
rm -rf src app
cp -R "$TEMPLATES/src" ./src

for f in babel.config.js metro.config.js tailwind.config.js nativewind-env.d.ts eas.json; do
    cp "$TEMPLATES/$f" "./$f"
done

TODAY="$(date +%Y-%m-%d)"
sed "s/__PROJECT__/$APP_NAME/g" "$TEMPLATES/DESIGN.md" > ./DESIGN.md
sed "s/__PROJECT__/$APP_NAME/g" "$TEMPLATES/README.md" > ./README.md

# Dublin operating model: every project carries its own context files.
sed -e "s/__PROJECT__/$APP_NAME/g" -e "s/__DATE__/$TODAY/g" \
    "$TEMPLATES/SESSION.md" > ./SESSION.md
sed "s/__PROJECT__/$APP_NAME/g" "$TEMPLATES/TASKS.md" > ./TASKS.md

# Private per-person task files must never be committed.
grep -q '^\*\.local\.md' .gitignore 2>/dev/null || \
    printf '\n# Private personal tasks — never commit\n*.local.md\n' >> .gitignore

info "routes, src/, config, DESIGN.md, eas.json, SESSION.md, TASKS.md"

# ------------------------------------------------------- 3. app.json patch

bold "3/6  Patching app.json"

node - "$APP_NAME" <<'NODE'
const fs = require("fs");
const appName = process.argv[2];
const slug = appName.toLowerCase().replace(/[^a-z0-9]+/g, "-").replace(/^-|-$/g, "");
const scheme = slug.replace(/-/g, "");

const config = JSON.parse(fs.readFileSync("app.json", "utf8"));
const expo = config.expo ?? (config.expo = {});

expo.name = appName;
expo.slug = slug;
expo.scheme = scheme;

// Without this the OS pins the app to light and no JS can change it —
// the single most common "dark mode does not work" cause.
expo.userInterfaceStyle = "automatic";

// FlashList v2 is new-architecture only.
expo.newArchEnabled = true;

expo.ios = { ...(expo.ios ?? {}), supportsTablet: true };
expo.android = { ...(expo.android ?? {}) };

// Runtime version gate: OTA updates only reach binaries built from the same
// app version, so a native change cannot land on an old binary and crash it.
expo.runtimeVersion = { policy: "appVersion" };

fs.writeFileSync("app.json", JSON.stringify(config, null, 2) + "\n");
console.log(`  name=${appName} slug=${slug} scheme=${scheme}://`);
NODE

# ------------------------------------------------------- 4. base install

if [[ "$PKG" == "pnpm" ]]; then
    # React Native's Metro resolver does not follow pnpm's symlinked, strictly
    # isolated node_modules. Transitive native deps that a package expects to
    # be hoisted (nativewind -> react-native-css-interop, for one) fail to
    # resolve at BUNDLE time while tsc stays perfectly happy.
    # Hoisted linking is Expo's documented setting for pnpm. Do not remove it.
    printf "node-linker=hoisted\n" > .npmrc
    info "wrote .npmrc (node-linker=hoisted) — required for React Native + pnpm"
fi

bold "4/6  Installing base dependencies ($PKG)"
$PKG install --silent

# ------------------------------------------------------- 5. Dublin deps

bold "5/6  Adding dependencies via 'expo install' (SDK-compatible versions)"

npx expo install \
    nativewind \
    react-native-reanimated \
    react-native-safe-area-context \
    react-native-screens \
    react-native-gesture-handler \
    react-native-svg \
    expo-image \
    expo-haptics \
    expo-secure-store \
    expo-status-bar \
    @shopify/flash-list \
    @react-native-async-storage/async-storage \
    @react-native-community/netinfo \
    @tanstack/react-query \
    @tanstack/react-query-persist-client \
    @tanstack/query-async-storage-persister \
    lucide-react-native \
    react-dom \
    react-native-web

# tailwindcss is a build-time JS tool with no native side, so pinning it is not
# Version Roulette. NativeWind 4 is developed against Tailwind 3.x; v4 support
# should be confirmed in the NativeWind docs before bumping this.
bold "     Pinning tailwindcss (NativeWind 4 peer)"
if [[ "$PKG" == "pnpm" ]]; then
    pnpm add -D "tailwindcss@^3.4" --silent
else
    npm install -D "tailwindcss@^3.4" --silent
fi

# ------------------------------------------------------- 6. sanity check

bold "6/6  Generating expo-env.d.ts and checking SDK compatibility"
# expo-env.d.ts declares the CSS side-effect import and typed routes. Expo
# generates it on first start; doing it here means `tsc --noEmit` is clean
# immediately instead of failing on a fresh clone.
npx expo customize tsconfig.json >/dev/null 2>&1 || true
npx expo install --check || true

printf "\n"
bold "Ready — three targets from one codebase."
info "cd $TARGET"
info "$PKG start          # Metro + QR for Expo Go (quick look only)"
info "$PKG ios            # simulator, macOS"
info "$PKG android        # emulator"
info "$PKG web            # browser"
printf "\n"
bold "Next, in order:"
info "1. Open Ajustes and switch theme — verify light AND dark"
info "2. Set ios.bundleIdentifier and android.package in app.json (immutable after first submission)"
info "3. Make a dev build and run it on a REAL phone:"
info "     eas build --profile development --platform ios"
info "   Expo Go is a preview host app, not your app."
printf "\n"
bold "Verify all three before calling anything done:"
info "npx tsc --noEmit"
info "npx expo export --platform ios     --output-dir /tmp/x-ios"
info "npx expo export --platform android --output-dir /tmp/x-android"
info "npx expo export --platform web     --output-dir /tmp/x-web"
info "A green build does NOT prove web works: expo-secure-store has no web"
info "implementation and Alert.alert is a silent no-op there. See"
info "references/cross-platform.md."
printf "\n"
info "If styles do not apply, restart Metro with --clear: Metro caches the transform."
