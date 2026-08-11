import * as SecureStore from "expo-secure-store";
import { Platform } from "react-native";

/**
 * Platform-correct session storage.
 *
 * WHY THIS EXISTS: `expo-secure-store` has no web implementation — its web
 * build is literally `export default {}`, so any call throws at runtime while
 * the bundle builds clean.
 *
 * The fix is NOT "use localStorage on web so the code is symmetric". A token
 * in localStorage is readable by any XSS. On web the session belongs in an
 * httpOnly cookie set by the backend, which JavaScript cannot read and the
 * browser attaches automatically.
 *
 *   native -> token in Keychain / Keystore, sent as an Authorization header
 *   web    -> no client-side token at all, cookie sent via credentials:"include"
 *
 * Pairs with the auth-architect skill, which treats httpOnly cookies as the
 * correct web default for exactly this reason.
 */

const KEY = "session-token";

export const sessionStorage = {
  async setToken(token: string): Promise<void> {
    if (Platform.OS === "web") return; // the server already set the cookie
    await SecureStore.setItemAsync(KEY, token);
  },

  async getToken(): Promise<string | null> {
    if (Platform.OS === "web") return null; // fetch sends the cookie itself
    return SecureStore.getItemAsync(KEY);
  },

  async clear(): Promise<void> {
    if (Platform.OS === "web") {
      await fetch("/auth/logout", { method: "POST", credentials: "include" });
      return;
    }
    await SecureStore.deleteItemAsync(KEY);
  },
};

/** Auth headers/credentials for a fetch call, correct per platform. */
export async function authFetchInit(init: RequestInit = {}): Promise<RequestInit> {
  if (Platform.OS === "web") {
    return { ...init, credentials: "include" };
  }

  const token = await sessionStorage.getToken();
  if (!token) return init;

  return {
    ...init,
    headers: { ...(init.headers ?? {}), Authorization: `Bearer ${token}` },
  };
}
