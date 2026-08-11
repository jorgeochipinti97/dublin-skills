import "@/global.css";

import NetInfo from "@react-native-community/netinfo";
import { focusManager, onlineManager } from "@tanstack/react-query";
import { PersistQueryClientProvider } from "@tanstack/react-query-persist-client";
import { Stack } from "expo-router";
import { StatusBar } from "expo-status-bar";
import { useColorScheme } from "nativewind";
import { useEffect } from "react";
import { AppState, type AppStateStatus } from "react-native";
import { GestureHandlerRootView } from "react-native-gesture-handler";
import { SafeAreaProvider } from "react-native-safe-area-context";

import { persistOptions, queryClient } from "@/lib/query";
import { useThemeColors } from "@/theme/useTheme";

// A phone has no window focus and no permanent connection. These two managers
// are what make queries refetch when signal returns and when the user comes
// back to the app — without them the UI feels stuck after a tunnel.
onlineManager.setEventListener((setOnline) =>
  NetInfo.addEventListener((state) => setOnline(Boolean(state.isConnected)))
);

export default function RootLayout() {
  const { colorScheme } = useColorScheme();
  const colors = useThemeColors();

  useEffect(() => {
    const sub = AppState.addEventListener("change", (status: AppStateStatus) => {
      focusManager.setFocused(status === "active");
    });
    return () => sub.remove();
  }, []);

  return (
    <GestureHandlerRootView style={{ flex: 1 }}>
      <PersistQueryClientProvider client={queryClient} persistOptions={persistOptions}>
        {/* SafeAreaProvider must wrap everything, or useSafeAreaInsets()
            silently returns zeros and every screen goes Notch Blind. */}
        <SafeAreaProvider>
          <StatusBar style={colorScheme === "dark" ? "light" : "dark"} />
          <Stack
            screenOptions={{
              headerShown: false,
              contentStyle: { backgroundColor: colors.bg },
            }}
          >
            <Stack.Screen name="(tabs)" />
            <Stack.Screen
              name="article/[id]"
              options={{
                headerShown: true,
                title: "",
                headerTintColor: colors.accent,
                headerStyle: { backgroundColor: colors.bg },
                headerShadowVisible: false,
              }}
            />
          </Stack>
        </SafeAreaProvider>
      </PersistQueryClientProvider>
    </GestureHandlerRootView>
  );
}
