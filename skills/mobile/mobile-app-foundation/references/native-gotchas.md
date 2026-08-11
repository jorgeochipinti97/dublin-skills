# Native Gotchas — the AI Tells with fixes

Every entry is a real failure a web developer hits in their first weeks. BAD is what gets written; GOOD is what ships.

---

## 1. Web Brain

Writing React Native as if it were React DOM.

### BAD
```tsx
export function Card({ article }) {
  return (
    <div className="card" onClick={() => open(article.id)} style={{ position: "fixed" }}>
      <img src={article.imageUrl} />
      <h2>{article.title}</h2>
      <p>{article.excerpt}</p>
    </div>
  );
}
```
`<div>`, `<img>`, `<h2>`, `<p>` do not exist. `onClick` does nothing. `position: fixed` is not a thing.

### GOOD
```tsx
import { View, Text, Pressable } from "react-native";
import { Image } from "expo-image";

export function Card({ article, onPress }: { article: Article; onPress: () => void }) {
  return (
    <Pressable onPress={onPress} className="rounded-xl bg-surface p-4 active:opacity-90">
      <Image source={{ uri: article.imageUrl }} style={{ width: "100%", aspectRatio: 16 / 9 }} contentFit="cover" />
      <Text className="mt-3 text-[22px] font-semibold text-text">{article.title}</Text>
      <Text className="mt-1 text-[14px] text-muted" numberOfLines={2}>{article.excerpt}</Text>
    </Pressable>
  );
}
```

### Translation table

| Web | Native |
|---|---|
| `<div>` | `<View>` |
| `<span>` `<p>` `<h1>` | `<Text>` — **all** text must be inside `<Text>` or it crashes |
| `<button>` | `<Pressable>` |
| `<img>` | `<Image>` from `expo-image` |
| `<input>` | `<TextInput>` |
| `<a href>` | `<Link href>` from `expo-router` |
| `onClick` | `onPress` |
| `:hover` | `active:` / `onPressIn` — there is no hover |
| `position: fixed` | `position: "absolute"` on a root-level view |
| `overflow: scroll` | `<ScrollView>` or `<FlashList>` |
| `100vh` | `flex: 1` |
| `text-overflow: ellipsis` | `numberOfLines={2}` on `<Text>` |
| `localStorage` | `AsyncStorage` (async) / `expo-secure-store` |
| `z-index` | `zIndex` — works, but sibling order wins on Android; prefer ordering |

**Flexbox differs in one key way:** `flexDirection` defaults to `column`, not `row`. Most "why is everything stacked" confusion is this.

---

## 2. ScrollView Graveyard

### BAD
```tsx
<ScrollView>
  {articles.map((a) => <ArticleCard key={a.id} article={a} />)}
</ScrollView>
```
All 500 cards mount immediately, each with an image. Memory spikes, scroll stutters, low-end Android crashes.

### GOOD
```tsx
<FlashList data={articles} keyExtractor={(a) => a.id} renderItem={({ item }) => <ArticleCard article={item} />} />
```

**Rule:** `ScrollView` is for a bounded set of heterogeneous content (a settings screen, an article body). Any homogeneous list that can grow uses `FlashList`.

Corollary: **never nest a virtualized list inside a `ScrollView`.** It loses bounded height, gives up virtualization, and logs a warning most people ignore. Use `ListHeaderComponent` / `ListFooterComponent` instead.

---

## 3. Notch Blind

### BAD
```tsx
<View className="flex-1 bg-bg">
  <Text className="text-display">Inicio</Text>   {/* under the status bar */}
</View>
```

### GOOD
```tsx
<Screen edges={["top"]}>
  <Text className="text-display">Inicio</Text>
</Screen>
```
With the `Screen` primitive from `styling-and-theming.md`. Two failure modes to check on a real device: content under the **status bar / Dynamic Island** at the top, and content under the **home indicator** at the bottom.

`SafeAreaProvider` must be mounted at the root, or `useSafeAreaInsets()` silently returns zeros and everything looks fine in the simulator you happened to pick.

---

## 4. Keyboard Eater

### BAD
```tsx
<View className="flex-1 justify-end p-4">
  <TextInput placeholder="Escribí un comentario" />   {/* keyboard covers it */}
</View>
```

### GOOD
```tsx
import { KeyboardAvoidingView, Platform, ScrollView } from "react-native";

<KeyboardAvoidingView
  behavior={Platform.OS === "ios" ? "padding" : "height"}
  keyboardVerticalOffset={headerHeight}
  className="flex-1"
>
  <ScrollView keyboardShouldPersistTaps="handled" contentContainerClassName="p-4">
    <TextInput placeholder="Escribí un comentario" className="rounded-lg border border-border p-3 text-text" />
  </ScrollView>
</KeyboardAvoidingView>
```

- `behavior` genuinely differs per platform; there is no single correct value.
- `keyboardShouldPersistTaps="handled"` — without it the first tap only dismisses the keyboard and your button appears broken.
- `keyboardVerticalOffset` must account for any header, or you get a gap or an overlap.

For anything beyond a single input, `react-native-keyboard-controller` handles this far better than `KeyboardAvoidingView`. It needs a dev build.

---

## 5. JS Thread Jam

### BAD
```tsx
const [progress, setProgress] = useState(0);
useEffect(() => {
  const t = setInterval(() => setProgress((p) => p + 0.01), 16);
  return () => clearInterval(t);
}, []);
<View style={{ width: `${progress * 100}%` }} />
```
Every frame is a React render on the JS thread. Any data parse or navigation stalls the animation.

### GOOD
```tsx
import Animated, { useSharedValue, useAnimatedStyle, withTiming } from "react-native-reanimated";

const progress = useSharedValue(0);
useEffect(() => { progress.value = withTiming(1, { duration: 1000 }); }, []);
const style = useAnimatedStyle(() => ({ width: `${progress.value * 100}%` }));
<Animated.View style={style} />
```
Runs on the UI thread. Stays smooth while JS is busy.

**Rule:** any animation driven by `useState` at frame rate is a bug. Use Reanimated, or `LayoutAnimation` for simple layout changes.

---

## 6. Expo Go Mirage

Expo Go is a **pre-built host app** containing a fixed set of native modules. Your app is not that app.

Works in Expo Go but not in your build, or vice versa:
- Any library with custom native code (MMKV, keyboard-controller, most SDKs)
- Config plugins that modify native project files
- Push notification tokens (Expo Go uses its own credentials)
- Deep links (Expo Go owns the scheme)
- Release-only crashes — different JS engine settings, minification, no dev warnings

**Rule:** Expo Go is for a five-minute look at a layout. The moment you add a dependency or touch config, move to a **dev build** (`references/testing-on-device.md`). Anything you would tell a client is "done" must have been seen in a real build.

---

## 7. Ghost Tap

### BAD
```tsx
<Text onPress={onSave}>Guardar</Text>   {/* no feedback, tiny target */}
<Pressable onPress={onClose}><X size={16} /></Pressable>  {/* ~16pt target */}
```

### GOOD
```tsx
<Pressable
  onPress={onSave}
  className="min-h-[44px] justify-center rounded-lg px-4 active:opacity-70"
  android_ripple={{ color: "rgba(0,0,0,0.08)" }}
  accessibilityRole="button"
  accessibilityLabel="Guardar artículo"
>
  <Text className="font-semibold text-accent">Guardar</Text>
</Pressable>

<Pressable onPress={onClose} hitSlop={14} accessibilityRole="button" accessibilityLabel="Cerrar">
  <X size={16} />
</Pressable>
```
44×44pt minimum (Apple HIG; Android asks 48dp). `hitSlop` gets you there without visual bulk. Every interactive element needs a press state and an `accessibilityLabel` when its content is an icon.

---

## 8. Version Roulette

### BAD
```jsonc
// package.json, edited by hand
"react-native": "0.79.0",
"react-native-reanimated": "^3.16.0"
```
JS version and the compiled native version disagree. Symptom: red screen, or worse, a crash that only appears in a release build.

### GOOD
```bash
npx expo install react-native-reanimated
npx expo install --check     # report packages that mismatch the SDK
npx expo install --fix       # fix them
```
`expo install` resolves the version compatible with your installed SDK. Run `--check` before every build; it takes seconds and prevents the worst class of mobile bug.

Upgrading SDKs: one major at a time, `npx expo install --fix` after each, read the changelog. Skipping versions is how a two-hour upgrade becomes two days.

---

## 9. Store Surprise

Everything below blocks submission and is invisible during development. Handle it on **day 0**, in `app.json`:

```jsonc
{
  "expo": {
    "name": "Mi App",
    "slug": "mi-app",
    "scheme": "miapp",
    "version": "1.0.0",
    "userInterfaceStyle": "automatic",
    "icon": "./assets/icon.png",              // 1024×1024, no transparency, no rounded corners
    "ios": {
      "bundleIdentifier": "com.dublin.miapp", // immutable after first submission
      "infoPlist": {
        "NSPhotoLibraryUsageDescription": "Para elegir una foto de perfil.",
        "NSCameraUsageDescription": "Para sacar una foto de perfil."
      }
    },
    "android": {
      "package": "com.dublin.miapp",          // immutable after first submission
      "adaptiveIcon": { "foregroundImage": "./assets/adaptive-icon.png", "backgroundColor": "#0C0A09" }
    }
  }
}
```

- **Missing permission usage strings are an automatic iOS rejection.** They must say *why*, specifically. "Necesitamos acceso a tu cámara" gets rejected; the example above does not.
- **`bundleIdentifier` and `package` cannot be changed after the first store submission.** Choose deliberately.
- Apple Developer Program: **USD 99/year**. Google Play Console: **USD 25, one time**. Neither can be skipped, and the Apple account can take a day or more to approve. Start it before you need it.
- Also required at submission: privacy policy URL, data-collection disclosure, age rating, screenshots per device class.

---

## 10. Offline Amnesia

### BAD
```tsx
const { data, isLoading } = useFeed();
if (isLoading) return <ActivityIndicator />;
return <FlashList data={data} ... />;
```
No network → `isLoading` stays true → spinner forever. On a subway, this is your app.

### GOOD
See `data-and-offline.md` §Offline states. The short version: render cached data when it exists, show an explicit offline bar, and never let an error path end in a spinner.

---

## 11. The pnpm Trap (Dublin-specific)

Dublin mandates `pnpm` everywhere. React Native is the one place it needs a setting, because Metro's resolver does not follow pnpm's symlinked, strictly-isolated `node_modules`. A package that expects a transitive dependency to be hoisted cannot find it.

### Symptom
```
Error: Unable to resolve module react-native-css-interop/jsx-runtime
  from src/app/(tabs)/index.tsx
```
`react-native-css-interop` is a dependency of `nativewind`, and with `jsxImportSource: "nativewind"` every JSX file imports it. Under npm it is hoisted to the root and resolves; under default pnpm it does not.

The nasty part: **`tsc --noEmit` passes clean.** TypeScript resolves through the symlinks fine. The failure only appears at bundle time, so a typecheck-only CI gate will not catch it.

### GOOD
```
# .npmrc, at the project root, BEFORE the first install
node-linker=hoisted
```
Expo's documented setting for pnpm. The scaffold script writes it automatically. If you hit an unresolvable-module error in an existing pnpm React Native project, check this file first.

**Generalization:** for any "module X could not be found" that names a package you never installed directly, suspect hoisting before suspecting your code.

---

## Bonus traps

**Text must be inside `<Text>`.** `<View>hola</View>` crashes at runtime, not at compile time.

**`console.log` in a release build costs real performance.** Strip logs in production builds.

**Android back button** is a real navigation contract. expo-router handles it for routes; if you implement a custom overlay with state, you must handle `BackHandler` yourself or the button exits the app.

**`Dimensions.get("window")` is captured once.** It does not update on rotation or split screen. Use `useWindowDimensions()`.

**Absolute `zIndex` behaves differently on Android** — later siblings paint on top regardless. Reorder rather than fight it.

**Large `require` trees hurt startup, not navigation.** The whole JS bundle loads at launch; there is no route-level code splitting. Watch what you import at module scope.
