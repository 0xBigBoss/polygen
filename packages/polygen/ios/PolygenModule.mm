#import "PolygenModule.h"
#import <ReactCommon/CxxTurboModuleUtils.h>
#import <ReactNativePolygen/ReactNativePolygen.h>

// Codegen-generated ObjC spec header
#import <RNPolygenSpec/RNPolygenSpec.h>

// Fail-fast: Polygen requires New Architecture
#if !RCT_NEW_ARCH_ENABLED
#error "Polygen requires React Native New Architecture (bridgeless mode). \
Set RCT_NEW_ARCH_ENABLED=1 in your Podfile or upgrade to Expo SDK 52+."
#endif

@implementation PolygenModule

RCT_EXPORT_MODULE(Polygen)

+ (BOOL)requiresMainQueueSetup
{
  return NO;
}

- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:
    (const facebook::react::ObjCTurboModule::InitParams &)params
{
#if DEBUG
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    NSLog(@"[Polygen] TurboModule registered via bridgeless path");
  });
#endif
  return std::make_shared<facebook::react::ReactNativePolygen>(params.jsInvoker);
}

@end
