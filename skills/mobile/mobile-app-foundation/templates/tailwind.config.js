/** @type {import('tailwindcss').Config} */
module.exports = {
  // Routes live in src/app/, everything else in src/ — one glob covers both.
  content: ["./src/**/*.{js,jsx,ts,tsx}"],
  presets: [require("nativewind/preset")],
  darkMode: "class",
  theme: {
    extend: {
      // Colors resolve from CSS variables declared in global.css so a single
      // token change updates both themes. Never hardcode a hex in a component.
      colors: {
        bg: "rgb(var(--color-bg) / <alpha-value>)",
        surface: "rgb(var(--color-surface) / <alpha-value>)",
        surfaceAlt: "rgb(var(--color-surface-alt) / <alpha-value>)",
        border: "rgb(var(--color-border) / <alpha-value>)",
        text: "rgb(var(--color-text) / <alpha-value>)",
        muted: "rgb(var(--color-text-muted) / <alpha-value>)",
        accent: "rgb(var(--color-accent) / <alpha-value>)",
        accentText: "rgb(var(--color-accent-text) / <alpha-value>)",
        danger: "rgb(var(--color-danger) / <alpha-value>)",
      },
      borderRadius: {
        sm: "6px",
        md: "10px",
        lg: "16px",
      },
    },
  },
  plugins: [],
};
