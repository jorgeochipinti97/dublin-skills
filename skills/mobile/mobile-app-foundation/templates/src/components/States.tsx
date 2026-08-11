import { Text, View } from "react-native";

import { Button } from "./ui/Button";

/**
 * The offline contract, in components.
 *
 * Rule: an error path NEVER ends in a spinner, and cached content always
 * beats an error screen. See references/data-and-offline.md.
 */

export function OfflineBar() {
  return (
    <View className="bg-surfaceAlt px-4 py-2">
      <Text className="text-center text-[14px] text-muted">
        Sin conexión — mostrando lo último guardado
      </Text>
    </View>
  );
}

export function ErrorState({ onRetry }: { onRetry: () => void }) {
  return (
    <View className="flex-1 items-center justify-center px-8">
      <Text className="text-center text-[22px] font-semibold text-text">
        No pudimos cargar el contenido
      </Text>
      <Text className="mt-2 text-center text-[16px] leading-6 text-muted">
        Revisá tu conexión e intentá de nuevo.
      </Text>
      <View className="mt-6 w-full">
        <Button label="Reintentar" onPress={onRetry} />
      </View>
    </View>
  );
}

export function EmptyState({
  title,
  description,
}: {
  title: string;
  description: string;
}) {
  return (
    <View className="items-center justify-center px-8 py-16">
      <Text className="text-center text-[22px] font-semibold text-text">{title}</Text>
      <Text className="mt-2 text-center text-[16px] leading-6 text-muted">{description}</Text>
    </View>
  );
}
