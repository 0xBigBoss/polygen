// Learn more https://docs.expo.io/guides/customizing-metro
const path = require('path');
const { getDefaultConfig } = require('expo/metro-config');
const { withPolygenConfig } = require('@callstack/polygen-metro-config');

const root = path.resolve(__dirname, '..', '..');

/** @type {import('expo/metro-config').MetroConfig} */
const config = getDefaultConfig(__dirname);

// Add monorepo root to watch folders
config.watchFolders = [root];

// Enable transformer options
config.transformer = {
  ...config.transformer,
  getTransformOptions: async () => ({
    transform: {
      experimentalImportSupport: false,
      inlineRequires: true,
    },
  }),
};

module.exports = withPolygenConfig(config);
