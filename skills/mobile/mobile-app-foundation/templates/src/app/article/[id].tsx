import { Image } from "expo-image";
import * as Haptics from "expo-haptics";
import { useLocalSearchParams } from "expo-router";
import { Bookmark, BookmarkCheck } from "lucide-react-native";
import { Pressable, ScrollView, Text, View } from "react-native";

import { useArticle } from "@/api/articles";
import { ErrorState } from "@/components/States";
import { Screen } from "@/components/ui/Screen";
import { ArticleCardSkeleton } from "@/components/ui/Skeleton";
import { useToggleSave } from "@/lib/saved";
import { useThemeColors } from "@/theme/useTheme";

export default function ArticleScreen() {
  // Route params are ALWAYS strings and are untrusted input, exactly like a
  // URL query on web. Narrow before use.
  const params = useLocalSearchParams<{ id: string }>();
  const id = typeof params.id === "string" ? params.id : "";

  const { data: article, isPending, isError, refetch } = useArticle(id);

  if (isPending) {
    return (
      <Screen edges={[]}>
        <View className="p-4">
          <ArticleCardSkeleton />
        </View>
      </Screen>
    );
  }

  if (isError || !article) {
    return (
      <Screen edges={[]}>
        <ErrorState onRetry={() => refetch()} />
      </Screen>
    );
  }

  return (
    <Screen edges={["bottom"]}>
      <ScrollView contentContainerStyle={{ paddingBottom: 32 }}>
        <Image
          source={{ uri: article.imageUrl }}
          style={{ width: "100%", aspectRatio: 16 / 9 }}
          contentFit="cover"
          transition={200}
          cachePolicy="memory-disk"
        />

        <View className="px-4 pt-4">
          <Text className="text-[30px] font-bold leading-9 text-text">{article.title}</Text>

          <View className="mt-3 flex-row items-center justify-between">
            <Text className="text-[14px] text-muted">
              {article.author} · {article.readingMinutes} min
            </Text>
            <SaveButton article={article} />
          </View>

          <Text className="mt-6 text-[16px] leading-7 text-text">{article.body}</Text>
        </View>
      </ScrollView>
    </Screen>
  );
}

function SaveButton({ article }: { article: Parameters<typeof useToggleSave>[0] }) {
  const colors = useThemeColors();
  const { isSaved, toggle } = useToggleSave(article);

  return (
    <Pressable
      onPress={() => {
        // Haptics are the touch-screen equivalent of a click sound: users do
        // not name their absence, but they feel it.
        Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
        toggle();
      }}
      hitSlop={14}
      accessibilityRole="button"
      accessibilityLabel={isSaved ? "Quitar de guardados" : "Guardar para leer después"}
      className="active:opacity-60"
    >
      {isSaved ? (
        <BookmarkCheck color={colors.accent} size={24} />
      ) : (
        <Bookmark color={colors.textMuted} size={24} />
      )}
    </Pressable>
  );
}
