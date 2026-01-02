/*
 * Copyright (c) callstack.io.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

/**
 * Stub implementation of getModuleBag for runtime-only usage.
 *
 * When using Polygen with AOT-compiled WASM modules, the bundler
 * will generate this function with the actual module registry.
 * For runtime-only usage (no pre-compiled modules), we provide
 * an empty registry.
 */

#include <ReactNativePolygen/ModuleBag.h>

namespace callstack::polygen::generated {

const ModuleBag& getModuleBag() {
  static ModuleBag emptyBag{};
  return emptyBag;
}

} // namespace callstack::polygen::generated
