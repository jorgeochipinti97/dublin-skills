import { FlashList } from "@shopify/flash-list";
import { Text, View } from "react-native";

import { ArticleCard } from "@/components/ArticleCard";
import { EmptyState } from "@/components/States";
import { Screen } from "@/components/ui/Screen";
import { useSavedArticles } from "@/lib/saved";

/**
 * Reads entirely from the persisted query cache — this screen works with the
 * phone in airplane mode, which is the whole point of a "saved" tab.
 */
export default function SavedScreen() {
  const { articles } = useSavedArticles();

  return (
    <Screen>
      <View className="px-4 pb-2 pt-2">
        <Text className="text-[30px] font-bold text-text">Guardados</Text>
      </View>

      <FlashList
        data={articles}
        keyExtractor={(article) => article.id}
        renderItem={({ item }) => <ArticleCard article={item} />}
        ListEmptyComponent={
          <EmptyState
            title="No guardaste nada todavía"
            description="Tocá el marcador en cualquier nota para leerla después, incluso sin conexión."
          />
        }
        contentContainerStyle={{ padding: 16 }}
      />
    </Screen>
  );
}
