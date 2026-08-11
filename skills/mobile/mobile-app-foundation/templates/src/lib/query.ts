import AsyncStorage from "@react-native-async-storage/async-storage";
import { createAsyncStoragePersister } from "@tanstack/query-async-storage-persister";
import { QueryClient } from "@tanstack/react-query";

const WEEK = 1000 * 60 * 60 * 24 * 7;

export const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 1000 * 60 * 5,
      // Must be >= the persister maxAge below, or entries are collected
      // before they can ever be restored on a cold start.
      gcTime: WEEK,
      retry: 2,
      // There is no window on a phone. AppState drives this instead —
      // see the focusManager wiring in app/_layout.tsx.
      refetchOnWindowFocus: false,
    },
  },
});

const persister = createAsyncStoragePersister({
  storage: AsyncStorage,
  throttleTime: 1000,
});

export const persistOptions = {
  persister,
  maxAge: WEEK,
  // Bump this on any release that changes an API response shape. Old cached
  // objects rendering against new code is a crash you only see in production.
  buster: "v1",
};
