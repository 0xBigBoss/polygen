/**
 * Compile-time and runtime tests for Wasm TurboModule registration.
 *
 * These tests verify the bridgeless mode TurboModule registration API.
 * They are designed to run during module initialization without requiring
 * external test frameworks.
 *
 * Note: Tests that call [Wasm getTurboModule:jsInvoker:] are defined in
 * Wasm.mm since they require Objective-C++ context.
 */

#pragma once

#ifdef __cplusplus

#include "ReactNativePolygen.h"
#include <cassert>
#include <memory>
#include <string>

namespace polygen::tests {

/**
 * Mock CallInvoker for testing without React Native runtime.
 * This allows testing getTurboModule logic in isolation.
 */
class MockCallInvoker : public facebook::react::CallInvoker {
public:
  void invokeAsync(facebook::react::CallFunc&& /*func*/) noexcept override {}
  void invokeSync(facebook::react::CallFunc&& /*func*/) override {}
  void invokeAsync(facebook::react::SchedulerPriority /*priority*/, facebook::react::CallFunc&& /*func*/) noexcept override {}
};

/**
 * Test that the module name constant has the expected value.
 */
inline bool testModuleNameConstant() {
  std::string expectedName = "Polygen";
  std::string actualName = facebook::react::ReactNativePolygen::kModuleName;

  return expectedName == actualName;
}

} // namespace polygen::tests

#endif // __cplusplus
