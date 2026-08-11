import { Image } from "expo-image";
import { Link } from "expo-router";
import { memo } from "react";
import { Pressable, Text, View } from "react-native";

import type { Article } from "../api/articles";

/**
 * memo matters here: FlashList recycles rows, so this re-renders constantly
 * during scroll. An inline arrow in renderItem would rebuild the whole subtree
 * every frame and undo the virtualization.
 */
export const ArticleCard = memo(function ArticleCard({ article }: { article: Article }) {
  return (
    <Link href={`/article/${article.id}`} asChild>
      <Pressable
        accessibilityRole="link"
        accessibilityLabel={`Abrir: ${article.title}`}
        className="mb-4 overflow-hidden rounded-lg bg-surface active:opacity-90"
      >
        {/* aspectRatio is fixed so the card never resizes when the image lands —
            a list that jumps under the thumb mid-scroll is the native CLS. */}
        <Image
          source={{ uri: article.imageUrl }}
          style={{ width: "100%", aspectRatio: 16 / 9 }}
          contentFit="cover"
          transition={200}
          cachePolicy="memory-disk"
        />

        <View className="p-4">
          <Text className="text-[22px] font-semibold leading-7 text-text" numberOfLines={3}>
            {article.title}
          </Text>

          <Text className="mt-2 text-[14px] leading-5 text-muted" numberOfLines={2}>
            {article.excerpt}
          </Text>

          <Text className="mt-3 text-[12px] text-muted">
            {article.author} · {article.readingMinutes} min de lectura
          </Text>
        </View>
      </Pressable>
    </Link>
  );
});
