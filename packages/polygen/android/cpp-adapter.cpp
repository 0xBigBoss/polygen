#include <ReactCommon/CxxTurboModuleUtils.h>

#include <ReactNativePolygen/ReactNativePolygen.h>

namespace {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wglobal-constructors"
struct PolygenModuleRegister {
  PolygenModuleRegister() {
    facebook::react::registerCxxModuleToGlobalModuleMap(
        facebook::react::ReactNativePolygen::kModuleName,
        [](std::shared_ptr<facebook::react::CallInvoker> jsInvoker) {
          return std::make_shared<facebook::react::ReactNativePolygen>(
              std::move(jsInvoker));
        });
  }
};
static PolygenModuleRegister polygenModuleRegister;
#pragma clang diagnostic pop
} // namespace
