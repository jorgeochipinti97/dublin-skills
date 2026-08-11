import { Platform, View, type ViewProps } from "react-native";
import { useSafeAreaInsets } from "react-native-safe-area-context";

type Edge = "top" | "bottom";

type Props = ViewProps & {
  /**
   * Which edges this screen pads for itself.
   * Inside the tab navigator the tab bar owns the bottom, so "top" is correct.
   * Full-screen and modal routes want both.
   */
  edges?: Edge[];
  /** Opt out of the web reading-width cap (full-bleed screens). */
  fullWidth?: boolean;
};

/** A phone never has a 1400px viewport; a browser does. Uncapped, lines get
 *  unreadably long on desktop — the web half of Shrunk Desktop. */
const WEB_MAX_WIDTH = 720;

/**
 * Every screen renders through this. Encoding safe areas in one primitive is
 * what makes Notch Blind impossible to ship by accident, and encoding the web
 * width cap here means no screen has to remember the third target exists.
 */
export function Screen({ edges = ["top"], fullWidth, style, children, ...rest }: Props) {
  const insets = useSafeAreaInsets();

  const content =
    Platform.OS === "web" && !fullWidth ? (
      <View className="w-full flex-1" style={{ maxWidth: WEB_MAX_WIDTH, marginHorizontal: "auto" }}>
        {children}
      </View>
    ) : (
      children
    );

  return (
    <View
      className="flex-1 bg-bg"
      style={[
        {
          // Insets resolve to 0 on web, so this is a no-op there rather than
          // a branch to maintain.
          paddingTop: edges.includes("top") ? insets.top : 0,
          paddingBottom: edges.includes("bottom") ? insets.bottom : 0,
        },
        style,
      ]}
      {...rest}
    >
      {content}
    </View>
  );
}
