const { getDefaultConfig } = require("expo/metro-config");
const { withNativeWind } = require("nativewind/metro");

const config = getDefaultConfig(__dirname);

// Routes and source both live under src/ in the Expo default template,
// and so does the stylesheet.
module.exports = withNativeWind(config, { input: "./src/global.css" });
