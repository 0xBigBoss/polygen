#import "Wasm.h"
#include <ReactCommon/CxxTurboModuleUtils.h>
#import <objc/runtime.h>

#if DEBUG
#include "WasmTests.h"
#include <cassert>
#endif

// Original implementation pointer for swizzled method
static IMP _original_getTurboModule_jsInvoker = nil;

// Swizzled implementation that checks for Polygen first
static std::shared_ptr<facebook::react::TurboModule>
_swizzled_getTurboModule_jsInvoker(id self, SEL _cmd,
                                    const std::string &name,
                                    std::shared_ptr<facebook::react::CallInvoker> jsInvoker) {
  // Check if this is the Polygen module
  if (name == facebook::react::ReactNativePolygen::kModuleName) {
    return std::make_shared<facebook::react::ReactNativePolygen>(jsInvoker);
  }

  // Call original implementation for other modules
  if (_original_getTurboModule_jsInvoker) {
    typedef std::shared_ptr<facebook::react::TurboModule> (*OriginalFunc)(id, SEL, const std::string &, std::shared_ptr<facebook::react::CallInvoker>);
    return ((OriginalFunc)_original_getTurboModule_jsInvoker)(self, _cmd, name, jsInvoker);
  }

  return nullptr;
}

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
 * Swizzles a class's getTurboModule:jsInvoker: method to intercept Polygen requests.
 */
+ (void)swizzleTurboModuleDelegateClass:(Class)cls {
  SEL selector = @selector(getTurboModule:jsInvoker:);
  Method method = class_getInstanceMethod(cls, selector);

  if (!method) {
    return;
  }

  // Store original implementation
  _original_getTurboModule_jsInvoker = method_getImplementation(method);

  // Replace with our swizzled implementation
  method_setImplementation(method, (IMP)_swizzled_getTurboModule_jsInvoker);
}

/**
 * Registers the module to the global module map during class load.
 * Also swizzles known TurboModule delegate classes for bridgeless mode support.
 */
+ (void)load {
#if DEBUG
  // Run unit tests in debug builds to verify getTurboModule logic
  assert([Wasm runAllTests] && "Wasm TurboModule tests failed");
#endif

  // Register to global module map (works for bridged mode and some bridgeless configurations)
  facebook::react::registerCxxModuleToGlobalModuleMap(
    std::string(facebook::react::ReactNativePolygen::kModuleName),
    [](std::shared_ptr<facebook::react::CallInvoker> jsInvoker) {
      return std::make_shared<facebook::react::ReactNativePolygen>(jsInvoker);
    }
  );

  // Swizzle known TurboModule delegate classes for bridgeless mode support
  // This handles cases where the global module map isn't shared between frameworks

  // RNXTurboModuleAdapter - used by react-native-test-app via @rnx-kit/react-native-host
  Class rnxAdapter = NSClassFromString(@"RNXTurboModuleAdapter");
  if (rnxAdapter) {
    [self swizzleTurboModuleDelegateClass:rnxAdapter];
  }

  // RCTAppDelegate - used by standard React Native apps
  Class appDelegate = NSClassFromString(@"RCTAppDelegate");
  if (appDelegate && !rnxAdapter) {  // Only if RNX adapter isn't present
    [self swizzleTurboModuleDelegateClass:appDelegate];
  }
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
