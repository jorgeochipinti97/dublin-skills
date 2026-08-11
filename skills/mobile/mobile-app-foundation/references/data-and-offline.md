# Data & Offline (content app)

A content app is a list, a detail screen, and a cache. Get these three right and the app is good. Get the cache wrong and you ship **Offline Amnesia** — an infinite spinner on the subway, which is where a lot of reading actually happens.

---

## Query client with persistence

The goal: **cold start with no network still renders yesterday's feed.** TanStack Query gives this almost for free.

```ts
// src/lib/query.ts
import AsyncStorage from "@react-native-async-storage/async-storage";
import { QueryClient } from "@tanstack/react-query";
import { createAsyncStoragePersister } from "@tanstack/query-async-storage-persister";
import type { PersistQueryClientProviderProps } from "@tanstack/react-query-persist-client";

export const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 1000 * 60 * 5,        // 5 min fresh
      gcTime: 1000 * 60 * 60 * 24 * 7, // keep 7 days on disk
      retry: 2,
      refetchOnWindowFocus: false,     // no window; use AppState instead
    },
  },
});

const persister = createAsyncStoragePersister({
  storage: AsyncStorage,
  throttleTime: 1000,
});

export const persistOptions: PersistQueryClientProviderProps["persistOptions"] = {
  persister,
  maxAge: 1000 * 60 * 60 * 24 * 7,
  buster: "v1", // bump to invalidate every cached query after a shape change
};
```

`gcTime` must be ≥ the persist `maxAge`, or entries get collected before they are ever restored. This is the most common misconfiguration.

**`buster` matters.** If you change an API response shape, old cached objects will render against new code and crash. Bumping `buster` throws the whole persisted cache away — cheap insurance on every release that touches a response type.

---

## Online status and refetching

There is no window focus on mobile. Wire the two real signals:

```ts
// app/_layout.tsx (once, at startup)
import NetInfo from "@react-native-community/netinfo";
import { AppState, Platform } from "react-native";
import { onlineManager, focusManager } from "@tanstack/react-query";

onlineManager.setEventListener((setOnline) =>
  NetInfo.addEventListener((state) => setOnline(!!state.isConnected))
);

AppState.addEventListener("change", (status) => {
  if (Platform.OS !== "web") focusManager.setFocused(status === "active");
});
```

Without this, queries do not refetch when the phone regains signal, and the app feels stuck.

---

## Fetchers stay plain

```ts
// src/api/articles.ts
import { useInfiniteQuery, useQuery } from "@tanstack/react-query";

export type Article = {
  id: string;
  title: string;
  excerpt: string;
  imageUrl: string;
  author: string;
  publishedAt: string;
  readingMinutes: number;
};

const API = process.env.EXPO_PUBLIC_API_URL ?? "https://api.ejemplo.com";

async function getArticles(cursor?: string): Promise<{ items: Article[]; nextCursor?: string }> {
  const url = new URL("/articles", API);
  if (cursor) url.searchParams.set("cursor", cursor);

  const res = await fetch(url.toString());
  if (!res.ok) throw new Error(`GET /articles failed: ${res.status}`);
  return res.json();
}

export const articleKeys = {
  all: ["articles"] as const,
  feed: () => [...articleKeys.all, "feed"] as const,
  detail: (id: string) => [...articleKeys.all, "detail", id] as const,
};

export function useFeed() {
  return useInfiniteQuery({
    queryKey: articleKeys.feed(),
    queryFn: ({ pageParam }) => getArticles(pageParam),
    initialPageParam: undefined as string | undefined,
    getNextPageParam: (last) => last.nextCursor,
  });
}

export function useArticle(id: string) {
  return useQuery({
    queryKey: articleKeys.detail(id),
    queryFn: () => getArticleById(id),
  });
}
```

`EXPO_PUBLIC_*` env vars are **inlined into the JS bundle at build time**. They are readable by anyone who downloads the app. Never put a secret there — API keys that must stay private belong behind your own backend.

---

## The feed (FlashList 2)

```tsx
import { FlashList } from "@shopify/flash-list";
import { RefreshControl } from "react-native";

export default function Feed() {
  const { data, isPending, isError, refetch, isRefetching, fetchNextPage, hasNextPage, isFetchingNextPage } = useFeed();
  const items = data?.pages.flatMap((p) => p.items) ?? [];

  if (isPending) return <FeedSkeleton />;
  if (isError && items.length === 0) return <ErrorState onRetry={refetch} />;

  return (
    <FlashList
      data={items}
      keyExtractor={(a) => a.id}
      renderItem={({ item }) => <ArticleCard article={item} />}
      onEndReached={() => hasNextPage && !isFetchingNextPage && fetchNextPage()}
      onEndReachedThreshold={0.6}
      refreshControl={<RefreshControl refreshing={isRefetching} onRefresh={refetch} />}
      ListEmptyComponent={<EmptyState />}
      ListFooterComponent={isFetchingNextPage ? <Spinner /> : null}
      contentContainerStyle={{ padding: 16 }}
    />
  );
}
```

Notes that matter:

- **FlashList 2 requires the New Architecture** and needs no size estimates — v1's `estimatedItemSize` is gone. On old architecture, use v1 or `FlatList`.
- `isError && items.length === 0` — if there is cached data, show it. A stale feed beats an error screen every time.
- `renderItem` must render a **stable, memoized** component. Recycling means it re-renders constantly; an inline arrow that rebuilds children defeats the whole point.
- Never nest a `FlashList` inside a `ScrollView`. It needs bounded height to virtualize; nesting silently makes it render everything.

---

## Images

```tsx
import { Image } from "expo-image";

<Image
  source={{ uri: article.imageUrl }}
  style={{ width: "100%", aspectRatio: 16 / 9, borderRadius: 12 }}
  contentFit="cover"
  transition={200}
  placeholder={{ blurhash: article.blurhash }}
  cachePolicy="memory-disk"
/>
```

- **Always give dimensions or an `aspectRatio`.** Same CLS discipline as web: a card that resizes when the image lands makes the list jump under the user's thumb mid-scroll.
- `cachePolicy="memory-disk"` is what makes a re-opened article instant and offline-readable.
- Ask the backend for a blurhash. It is the difference between "loading" and "premium".

---

## Offline states — the contract

Every data screen answers four questions before it is done:

| State | What the user sees |
|---|---|
| First load, no cache | Skeleton matching the real layout — never a bare centered spinner |
| Cached + refetching | Cached content immediately, subtle refresh indicator |
| Error + cache exists | Cached content + a dismissible "Sin conexión — mostrando lo último guardado" bar |
| Error + no cache | Explicit message + a Retry button. Never a dead spinner |

```tsx
const { isError, isPaused } = useFeed();
const isOffline = isPaused || isError;

{isOffline && items.length > 0 && (
  <View className="bg-surfaceAlt px-4 py-2">
    <Text className="text-center text-small text-muted">
      Sin conexión — mostrando lo último guardado
    </Text>
  </View>
)}
```

`isPaused` is true when a query cannot run because `onlineManager` reports offline — that is the precise signal, better than inferring from an error.

---

## Saved / offline reading

For a content app, "save for offline" is the killer feature and it is nearly free once the cache is persisted:

```ts
export async function saveForOffline(article: Article) {
  queryClient.setQueryData(articleKeys.detail(article.id), article);
  await Image.prefetch(article.imageUrl);          // expo-image disk cache
  const saved = await getSavedIds();
  await AsyncStorage.setItem("saved-ids", JSON.stringify([...saved, article.id]));
}
```

The article body is already in the persisted query cache; prefetching the image is the only extra step. Store the id list, not the content — the cache owns content.

---

## Storage: what goes where

| Data | Store | Why |
|---|---|---|
| Server responses | TanStack Query + AsyncStorage persister | Handles staleness, refetch, and eviction for you |
| Auth tokens | **`expo-secure-store`** natively, **httpOnly cookie** on web | Keychain / Keystore. Never AsyncStorage — plain readable text on a rooted device. `expo-secure-store` has no web build (`export default {}`), so web must branch; see `cross-platform.md` |
| Preferences (theme, font size) | AsyncStorage, or MMKV once you have a dev build | Small, frequently read |
| Large structured data, full-text search | `expo-sqlite` | Real queries; do not simulate a database in AsyncStorage |

`AsyncStorage` is **async and unencrypted**. Both words matter. Treat it as a disk cache, not a database and not a vault.

---

## Mutations and optimistic updates

Assume a slow, flaky network — because it is:

```ts
const toggleSave = useMutation({
  mutationFn: (id: string) => api.toggleSave(id),
  onMutate: async (id) => {
    await queryClient.cancelQueries({ queryKey: articleKeys.detail(id) });
    const previous = queryClient.getQueryData<Article>(articleKeys.detail(id));
    queryClient.setQueryData(articleKeys.detail(id), (old: Article) => ({ ...old, saved: !old.saved }));
    return { previous };
  },
  onError: (_err, id, ctx) => {
    queryClient.setQueryData(articleKeys.detail(id), ctx?.previous);
    // notify(), NOT Alert.alert — Alert is a silent no-op on web
    // (react-native-web defines it as `static alert() {}`), so the optimistic
    // update would roll back with zero explanation on one of three targets.
    notify("No se pudo guardar", "Revisá tu conexión e intentá de nuevo.");
  },
  onSettled: (_d, _e, id) => queryClient.invalidateQueries({ queryKey: articleKeys.detail(id) }),
});
```

Pair every optimistic update with **haptic feedback** (`expo-haptics`). On a touch screen, haptics are the confirmation that a click sound gives on desktop — cheap to add, and their absence is felt even when users cannot name it.
