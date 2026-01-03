#import "Wasm.h"
#include <ReactCommon/CxxTurboModuleUtils.h>

#if DEBUG
#include "WasmTests.h"
#include <cassert>
#endif

@implementation Wasm

/**
 * Registers the module to the global module map during class load.
 * This works for bridged mode but may not work in bridgeless mode (RN 0.81+).
 * For bridgeless mode, use getTurboModule:jsInvoker: from AppDelegate.
 */
+ (void)load {
#if DEBUG
  // Run unit tests in debug builds to verify getTurboModule logic
  assert(polygen::tests::runAllTests() && "Wasm TurboModule tests failed");
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
