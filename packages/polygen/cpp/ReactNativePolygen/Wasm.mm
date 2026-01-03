#import "Wasm.h"
#include <ReactCommon/CxxTurboModuleUtils.h>

#if DEBUG
#include "WasmTests.h"
#include <cassert>
#endif

@implementation Wasm

#if DEBUG
/**
 * Test that getTurboModule returns a valid module for the correct name.
 * This calls the actual Objective-C method to verify the bridgeless entry point.
 */
+ (bool)testGetTurboModuleReturnsModuleForCorrectName {
  auto mockInvoker = std::make_shared<polygen::tests::MockCallInvoker>();
  std::string moduleName = facebook::react::ReactNativePolygen::kModuleName;

  auto result = [Wasm getTurboModule:moduleName jsInvoker:mockInvoker];

  return result != nullptr;
}

/**
 * Test that getTurboModule returns nullptr for incorrect name.
 */
+ (bool)testGetTurboModuleReturnsNullForWrongName {
  auto mockInvoker = std::make_shared<polygen::tests::MockCallInvoker>();
  std::string wrongName = "WrongModuleName";

  auto result = [Wasm getTurboModule:wrongName jsInvoker:mockInvoker];

  return result == nullptr;
}

/**
 * Test that getTurboModule is case-sensitive.
 */
+ (bool)testGetTurboModuleIsCaseSensitive {
  auto mockInvoker = std::make_shared<polygen::tests::MockCallInvoker>();
  std::string lowercaseName = "polygen";  // lowercase, should not match "Polygen"

  auto result = [Wasm getTurboModule:lowercaseName jsInvoker:mockInvoker];

  return result == nullptr;
}

/**
 * Test that multiple calls return independent instances.
 */
+ (bool)testGetTurboModuleReturnsIndependentInstances {
  auto mockInvoker = std::make_shared<polygen::tests::MockCallInvoker>();
  std::string moduleName = facebook::react::ReactNativePolygen::kModuleName;

  auto instance1 = [Wasm getTurboModule:moduleName jsInvoker:mockInvoker];
  auto instance2 = [Wasm getTurboModule:moduleName jsInvoker:mockInvoker];

  return instance1 != nullptr && instance2 != nullptr && instance1.get() != instance2.get();
}

/**
 * Run all tests and return true if all pass.
 */
+ (bool)runAllTests {
  bool allPassed = true;

  // C++ tests from WasmTests.h
  allPassed &= polygen::tests::testModuleNameConstant();

  // Objective-C++ tests that call the actual method
  allPassed &= [Wasm testGetTurboModuleReturnsModuleForCorrectName];
  allPassed &= [Wasm testGetTurboModuleReturnsNullForWrongName];
  allPassed &= [Wasm testGetTurboModuleIsCaseSensitive];
  allPassed &= [Wasm testGetTurboModuleReturnsIndependentInstances];

  return allPassed;
}
#endif

/**
 * Registers the module to the global module map during class load.
 * This works for bridged mode but may not work in bridgeless mode (RN 0.81+).
 * For bridgeless mode, use getTurboModule:jsInvoker: from AppDelegate.
 */
+ (void)load {
#if DEBUG
  // Run unit tests in debug builds to verify getTurboModule logic
  assert([Wasm runAllTests] && "Wasm TurboModule tests failed");
#endif

  facebook::react::registerCxxModuleToGlobalModuleMap(
    std::string(facebook::react::ReactNativePolygen::kModuleName),
    [](std::shared_ptr<facebook::react::CallInvoker> jsInvoker) {
      return std::make_shared<facebook::react::ReactNativePolygen>(jsInvoker);
    }
  );
}

+ (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:(const std::string &)name
                                                      jsInvoker:(std::shared_ptr<facebook::react::CallInvoker>)jsInvoker
{
  if (name == facebook::react::ReactNativePolygen::kModuleName) {
    return std::make_shared<facebook::react::ReactNativePolygen>(jsInvoker);
  }
  return nullptr;
}

@end
