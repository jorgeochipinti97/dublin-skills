import { Pressable, Text, type PressableProps } from "react-native";

import { TOUCH_TARGET } from "../../theme/tokens";

type Variant = "primary" | "secondary" | "ghost";

type Props = PressableProps & {
  label: string;
  variant?: Variant;
};

const container: Record<Variant, string> = {
  primary: "bg-accent active:opacity-80",
  secondary: "bg-surfaceAlt border border-border active:opacity-80",
  ghost: "active:opacity-60",
};

const labelStyle: Record<Variant, string> = {
  primary: "text-accentText",
  secondary: "text-text",
  ghost: "text-accent",
};

/**
 * There is no :hover on a phone — the press state is the ONLY signal that
 * something is interactive. Every variant here has one, plus a 44pt floor.
 */
export function Button({ label, variant = "primary", disabled, ...rest }: Props) {
  return (
    <Pressable
      accessibilityRole="button"
      accessibilityLabel={label}
      accessibilityState={{ disabled: Boolean(disabled) }}
      disabled={disabled}
      android_ripple={{ color: "rgba(128,128,128,0.2)" }}
      style={{ minHeight: TOUCH_TARGET }}
      className={`items-center justify-center rounded-md px-5 ${container[variant]} ${
        disabled ? "opacity-40" : ""
      }`}
      {...rest}
    >
      <Text className={`text-[16px] font-semibold ${labelStyle[variant]}`}>{label}</Text>
    </Pressable>
  );
}
