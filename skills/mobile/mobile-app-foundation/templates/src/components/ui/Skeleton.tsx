import { useEffect } from "react";
import { View } from "react-native";
import Animated, {
  useAnimatedStyle,
  useSharedValue,
  withRepeat,
  withTiming,
} from "react-native-reanimated";

/**
 * Pulse runs on the UI thread via Reanimated. Driving this with useState at
 * frame rate would stall every time JS is busy parsing a response — which is
 * exactly when the skeleton is on screen (JS Thread Jam).
 */
function Pulse({ className, style }: { className?: string; style?: object }) {
  const opacity = useSharedValue(0.4);

  useEffect(() => {
    opacity.value = withRepeat(withTiming(0.9, { duration: 800 }), -1, true);
  }, [opacity]);

  const animated = useAnimatedStyle(() => ({ opacity: opacity.value }));

  return <Animated.View className={`bg-surfaceAlt ${className ?? ""}`} style={[style, animated]} />;
}

/** Matches the real ArticleCard layout, so nothing shifts when data lands. */
export function ArticleCardSkeleton() {
  return (
    <View className="mb-4 overflow-hidden rounded-lg bg-surface">
      <Pulse style={{ width: "100%", aspectRatio: 16 / 9 }} />
      <View className="p-4">
        <Pulse className="rounded-sm" style={{ height: 22, width: "90%" }} />
        <Pulse className="mt-2 rounded-sm" style={{ height: 22, width: "60%" }} />
        <Pulse className="mt-3 rounded-sm" style={{ height: 14, width: "40%" }} />
      </View>
    </View>
  );
}

export function FeedSkeleton() {
  return (
    <View className="p-4">
      <ArticleCardSkeleton />
      <ArticleCardSkeleton />
      <ArticleCardSkeleton />
    </View>
  );
}
