import { useColorScheme } from "nativewind";

import { tokens, type ThemeColors } from "./tokens";

/**
 * Resolved palette for the active theme.
 * Use only where className is not available (navigators, StatusBar, native props).
 */
export function useThemeColors(): ThemeColors {
  const { colorScheme } = useColorScheme();
  return colorScheme === "dark" ? tokens.dark : tokens.light;
}

export type ThemePreference = "light" | "dark" | "system";

/**
 * Theme control for the settings screen.
 * Default is "system" — the OS setting is the one the user already made.
 */
export function useThemePreference() {
  const { colorScheme, setColorScheme } = useColorScheme();

  return {
    /** What is actually rendering right now. */
    resolved: colorScheme === "dark" ? ("dark" as const) : ("light" as const),
    setPreference: (preference: ThemePreference) => setColorScheme(preference),
  };
}
