import AsyncStorage from "@react-native-async-storage/async-storage";
import { Image } from "expo-image";
import { useMutation, useQuery } from "@tanstack/react-query";

import { articleKeys, type Article } from "../api/articles";
import { notify } from "./notify";
import { queryClient } from "./query";

const KEY = "saved-article-ids";

/**
 * We persist only the ids. The article bodies already live in the persisted
 * query cache, and the images in expo-image's disk cache — so "save for
 * offline" is nearly free once the cache layer exists.
 */

async function readIds(): Promise<string[]> {
  const raw = await AsyncStorage.getItem(KEY);
  if (!raw) return [];
  try {
    const parsed = JSON.parse(raw);
    return Array.isArray(parsed) ? (parsed as string[]) : [];
  } catch {
    // Corrupt entry — drop it rather than crash on every launch.
    await AsyncStorage.removeItem(KEY);
    return [];
  }
}

export const savedKeys = { ids: ["saved", "ids"] as const };

export function useSavedIds() {
  return useQuery({ queryKey: savedKeys.ids, queryFn: readIds });
}

export function useSavedArticles() {
  const { data: ids = [], isPending } = useSavedIds();

  const articles = ids
    .map((id) => queryClient.getQueryData<Article>(articleKeys.detail(id)))
    .filter((a): a is Article => Boolean(a));

  return { articles, isPending };
}

export function useToggleSave(article: Article) {
  const { data: ids = [] } = useSavedIds();
  const isSaved = ids.includes(article.id);

  const mutation = useMutation({
    mutationFn: async () => {
      const current = await readIds();
      const next = current.includes(article.id)
        ? current.filter((id) => id !== article.id)
        : [...current, article.id];

      await AsyncStorage.setItem(KEY, JSON.stringify(next));

      if (!current.includes(article.id)) {
        // Seed the detail cache and warm the image so it reads offline.
        queryClient.setQueryData(articleKeys.detail(article.id), article);
        await Image.prefetch(article.imageUrl);
      }

      return next;
    },
    // Optimistic: the toggle must feel instant even on a bad connection.
    onMutate: async () => {
      await queryClient.cancelQueries({ queryKey: savedKeys.ids });
      const previous = queryClient.getQueryData<string[]>(savedKeys.ids) ?? [];
      const next = previous.includes(article.id)
        ? previous.filter((id) => id !== article.id)
        : [...previous, article.id];
      queryClient.setQueryData(savedKeys.ids, next);
      return { previous };
    },
    onError: (_error, _vars, context) => {
      queryClient.setQueryData(savedKeys.ids, context?.previous ?? []);
      // notify(), not Alert.alert() — Alert is a silent no-op on web, so the
      // rollback would happen with zero explanation on one of three targets.
      notify("No se pudo guardar", "Intentá de nuevo en un momento.");
    },
    onSettled: () => queryClient.invalidateQueries({ queryKey: savedKeys.ids }),
  });

  return { isSaved, toggle: mutation.mutate };
}
