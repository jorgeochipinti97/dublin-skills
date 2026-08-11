import { FlashList } from "@shopify/flash-list";
import { ActivityIndicator, RefreshControl, Text, View } from "react-native";

import { useFeed } from "@/api/articles";
import { ArticleCard } from "@/components/ArticleCard";
import { EmptyState, ErrorState, OfflineBar } from "@/components/States";
import { FeedSkeleton } from "@/components/ui/Skeleton";
import { Screen } from "@/components/ui/Screen";
import { useThemeColors } from "@/theme/useTheme";

export default function FeedScreen() {
  const colors = useThemeColors();
  const {
    data,
    isPending,
    isError,
    isPaused,
    refetch,
    isRefetching,
    fetchNextPage,
    hasNextPage,
    isFetchingNextPage,
  } = useFeed();

  const items = data?.pages.flatMap((page) => page.items) ?? [];
  const isOffline = isPaused || isError;

  // No cache at all — the only case where a skeleton is the right answer.
  if (isPending && items.length === 0) {
    return (
      <Screen>
        <Header />
        <FeedSkeleton />
      </Screen>
    );
  }

  // Error AND nothing cached. If there were cached items we would render them
  // instead — stale content always beats an error screen.
  if (isError && items.length === 0) {
    return (
      <Screen>
        <Header />
        <ErrorState onRetry={() => refetch()} />
      </Screen>
    );
  }

  return (
    <Screen>
      <Header />
      {isOffline && items.length > 0 ? <OfflineBar /> : null}

      <FlashList
        data={items}
        keyExtractor={(article) => article.id}
        renderItem={({ item }) => <ArticleCard article={item} />}
        onEndReached={() => {
          if (hasNextPage && !isFetchingNextPage) fetchNextPage();
        }}
        onEndReachedThreshold={0.6}
        refreshControl={
          <RefreshControl
            refreshing={isRefetching}
            onRefresh={refetch}
            tintColor={colors.textMuted}
          />
        }
        ListEmptyComponent={
          <EmptyState
            title="Todavía no hay notas"
            description="Cuando se publique algo nuevo, va a aparecer acá."
          />
        }
        ListFooterComponent={
          isFetchingNextPage ? (
            <View className="py-6">
              <ActivityIndicator color={colors.accent} />
            </View>
          ) : null
        }
        contentContainerStyle={{ padding: 16 }}
      />
    </Screen>
  );
}

function Header() {
  return (
    <View className="px-4 pb-2 pt-2">
      <Text className="text-[30px] font-bold text-text">Inicio</Text>
    </View>
  );
}
