import { Tabs } from "expo-router";
import { Bookmark, House, Settings } from "lucide-react-native";

import { useThemeColors } from "@/theme/useTheme";

/**
 * Icon budget (Dublin): 5 tabs maximum. A sixth tab means the information
 * architecture is wrong — a "More" tab is a symptom, not a solution.
 *
 * The tab bar handles its own bottom safe-area inset. Screens do not — that is
 * what <Screen edges={["top"]}> is for.
 */
export default function TabsLayout() {
  const colors = useThemeColors();

  return (
    <Tabs
      screenOptions={{
        headerShown: false,
        tabBarActiveTintColor: colors.accent,
        tabBarInactiveTintColor: colors.textMuted,
        tabBarStyle: {
          backgroundColor: colors.surface,
          borderTopColor: colors.border,
        },
      }}
    >
      <Tabs.Screen
        name="index"
        options={{
          title: "Inicio",
          tabBarIcon: ({ color, size }) => <House color={color} size={size} />,
        }}
      />
      <Tabs.Screen
        name="saved"
        options={{
          title: "Guardados",
          tabBarIcon: ({ color, size }) => <Bookmark color={color} size={size} />,
        }}
      />
      <Tabs.Screen
        name="settings"
        options={{
          title: "Ajustes",
          tabBarIcon: ({ color, size }) => <Settings color={color} size={size} />,
        }}
      />
    </Tabs>
  );
}
