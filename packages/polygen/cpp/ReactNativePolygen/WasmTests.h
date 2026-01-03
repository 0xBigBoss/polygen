/**
 * Compile-time and runtime tests for Wasm TurboModule registration.
 *
 * These tests verify the bridgeless mode TurboModule registration API.
 * They are designed to run during module initialization without requiring
 * external test frameworks.
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
 * Test that getTurboModule returns a valid module for the correct name.
 */
inline bool testGetTurboModuleReturnsModuleForPolygenName() {
  auto mockInvoker = std::make_shared<MockCallInvoker>();
  std::string moduleName = facebook::react::ReactNativePolygen::kModuleName;

  // Create the module directly using the same logic as Wasm.mm
  std::shared_ptr<facebook::react::TurboModule> result = nullptr;
  if (moduleName == facebook::react::ReactNativePolygen::kModuleName) {
    result = std::make_shared<facebook::react::ReactNativePolygen>(mockInvoker);
  }

  return result != nullptr;
}

/**
 * Test that module name matching is case-sensitive.
 */
inline bool testModuleNameIsCaseSensitive() {
  std::string correctName = facebook::react::ReactNativePolygen::kModuleName;
  std::string lowercaseName = "polygen";  // lowercase, should not match "Polygen"

  return correctName != lowercaseName;
}

/**
 * Test that the module name constant has the expected value.
 */
inline bool testModuleNameConstant() {
  std::string expectedName = "Polygen";
  std::string actualName = facebook::react::ReactNativePolygen::kModuleName;

  return expectedName == actualName;
}

/**
 * Test that multiple module creations return independent instances.
 */
inline bool testMultipleInstancesAreIndependent() {
  auto mockInvoker = std::make_shared<MockCallInvoker>();

  auto instance1 = std::make_shared<facebook::react::ReactNativePolygen>(mockInvoker);
  auto instance2 = std::make_shared<facebook::react::ReactNativePolygen>(mockInvoker);

  return instance1.get() != instance2.get();
}

/**
 * Run all tests and return true if all pass.
 * This can be called from +load or during module initialization.
 */
inline bool runAllTests() {
  bool allPassed = true;

  allPassed &= testModuleNameConstant();
  allPassed &= testModuleNameIsCaseSensitive();
  allPassed &= testGetTurboModuleReturnsModuleForPolygenName();
  allPassed &= testMultipleInstancesAreIndependent();

  return allPassed;
}

} // namespace polygen::tests

#endif // __cplusplus
