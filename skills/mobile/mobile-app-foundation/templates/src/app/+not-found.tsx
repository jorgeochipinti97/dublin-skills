import { Link, Stack } from "expo-router";
import { Text, View } from "react-native";

import { Screen } from "@/components/ui/Screen";

export default function NotFoundScreen() {
  return (
    <>
      <Stack.Screen options={{ title: "No encontrado" }} />
      <Screen>
        <View className="flex-1 items-center justify-center px-8">
          <Text className="text-center text-[22px] font-semibold text-text">
            Esta pantalla no existe
          </Text>
          <Link href="/" className="mt-6 text-[16px] font-semibold text-accent">
            Volver al inicio
          </Link>
        </View>
      </Screen>
    </>
  );
}
