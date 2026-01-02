/*
 * Copyright (c) callstack.io.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#include <fbjni/fbjni.h>
#include <ReactCommon/CxxTurboModuleUtils.h>
#include <ReactNativePolygen/ReactNativePolygen.h>

JNIEXPORT jint JNICALL JNI_OnLoad(JavaVM *vm, void *) {
  return facebook::jni::initialize(vm, [] {
    facebook::react::registerCxxModuleToGlobalModuleMap(
      std::string(facebook::react::ReactNativePolygen::kModuleName),
      [](std::shared_ptr<facebook::react::CallInvoker> jsInvoker) {
        return std::make_shared<facebook::react::ReactNativePolygen>(jsInvoker);
      }
    );
  });
}
