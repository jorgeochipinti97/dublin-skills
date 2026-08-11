/**
 * Imperative mirror of the CSS variables in global.css.
 *
 * NativeWind classes cover components. These values cover everything that
 * cannot take a className: the tab navigator, StatusBar, RefreshControl,
 * ActivityIndicator, and native modal chrome.
 *
 * If you change a color here, change it in global.css too.
 */

export const tokens = {
  light: {
    bg: "#FAFAF9",
    surface: "#FFFFFF",
    surfaceAlt: "#F5F5F4",
    border: "#E7E5E4",
    text: "#1C1917",
    textMuted: "#57534E",
    accent: "#0F766E",
    accentText: "#FFFFFF",
    danger: "#B91C1C",
  },
  dark: {
    bg: "#0C0A09",
    surface: "#1C1917",
    surfaceAlt: "#292524",
    border: "#292524",
    text: "#FAFAF9",
    textMuted: "#A8A29E",
    accent: "#2DD4BF",
    accentText: "#0C0A09",
    danger: "#F87171",
  },
} as const;

/** Widened so light and dark share one type — `as const` above would make
 *  each palette its own literal type and they would not be interchangeable. */
export type ThemeColors = { [K in keyof (typeof tokens)["light"]]: string };

/** Density-independent pixels. No rem, no clamp — the platform scales for you. */
export const spacing = { xs: 4, sm: 8, md: 16, lg: 24, xl: 32, xxl: 48 } as const;

export const radius = { sm: 6, md: 10, lg: 16, full: 9999 } as const;

/** 16 is the floor for body text: a phone is read at arm's length. */
export const type = {
  display: { fontSize: 30, lineHeight: 36 },
  title: { fontSize: 22, lineHeight: 28 },
  body: { fontSize: 16, lineHeight: 24 },
  small: { fontSize: 14, lineHeight: 20 },
  caption: { fontSize: 12, lineHeight: 16 },
} as const;

/** Minimum touch target (Apple HIG 44pt / Android 48dp). Never go below. */
export const TOUCH_TARGET = 44;
