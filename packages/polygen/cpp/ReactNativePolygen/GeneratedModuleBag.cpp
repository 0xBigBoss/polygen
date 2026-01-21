/*
 * Copyright (c) callstack.io.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#include <ReactNativePolygen/ModuleBag.h>

namespace callstack::polygen::generated {

__attribute__((weak)) const ModuleBag& getModuleBag() {
  static const ModuleBag empty({});
  return empty;
}

} // namespace callstack::polygen::generated
