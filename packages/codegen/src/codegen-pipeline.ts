import { androidCmake } from './pipeline/react-native/android-cmake.js';
import { cocoapods } from './pipeline/react-native/cocoapods.js';
import { metroResolver } from './pipeline/react-native/metro.js';
import { reactNativeTurboModule } from './pipeline/react-native/turbomodule.js';
import { embedWasmRuntime } from './pipeline/wasm2c-runtime.js';
import type { Plugin } from './plugin.js';

export const DEFAULT_PLUGINS: Plugin[] = [
  androidCmake(),
  cocoapods(),
  metroResolver(),
  reactNativeTurboModule(),
  embedWasmRuntime(),
];
