import { Alert, Platform } from "react-native";

/**
 * Cross-platform user feedback.
 *
 * WHY THIS EXISTS: `Alert.alert` is a **silent no-op** on web —
 * react-native-web defines it as `static alert() {}`. Calling it directly
 * means every error message you write disappears on one of your three
 * targets, with no build error and no console warning.
 *
 * Replace the web branch with a real toast component when you have one.
 * `window.alert` is the floor (it blocks the tab), not the goal. What is
 * non-negotiable is that web is never left silent.
 */
export function notify(title: string, message?: string) {
  if (Platform.OS === "web") {
    window.alert(message ? `${title}\n\n${message}` : title);
    return;
  }

  Alert.alert(title, message);
}
