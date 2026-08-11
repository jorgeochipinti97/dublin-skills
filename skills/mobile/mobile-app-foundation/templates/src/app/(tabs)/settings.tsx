import { ScrollView, Text, View } from "react-native";
import { useColorScheme } from "nativewind";

import { Button } from "@/components/ui/Button";
import { Screen } from "@/components/ui/Screen";
import type { ThemePreference } from "@/theme/useTheme";

const OPTIONS: { value: ThemePreference; label: string }[] = [
  { value: "light", label: "Claro" },
  { value: "dark", label: "Oscuro" },
  { value: "system", label: "Sistema" },
];

export default function SettingsScreen() {
  // colorScheme is what is rendering now; setColorScheme accepts the
  // preference, including "system" — which is the default and the right one.
  const { colorScheme, setColorScheme } = useColorScheme();

  return (
    <Screen>
      <ScrollView contentContainerStyle={{ padding: 16 }}>
        <Text className="pb-4 text-[30px] font-bold text-text">Ajustes</Text>

        <View className="rounded-lg bg-surface p-4">
          <Text className="text-[16px] font-semibold text-text">Tema</Text>
          <Text className="mt-1 text-[14px] text-muted">
            Por defecto seguimos el ajuste del sistema.
          </Text>

          <View className="mt-4 gap-2">
            {OPTIONS.map((option) => (
              <Button
                key={option.value}
                label={option.label}
                variant={
                  // "system" has no resolved value to compare against, so it is
                  // shown as secondary rather than falsely marked active.
                  option.value === colorScheme ? "primary" : "secondary"
                }
                onPress={() => setColorScheme(option.value)}
              />
            ))}
          </View>
        </View>

        <Text className="mt-6 text-center text-[12px] text-muted">
          Cambiá el tema del sistema con la app abierta para verificar que ambos temas funcionan.
        </Text>
      </ScrollView>
    </Screen>
  );
}
