#ifdef __cplusplus
#import "ReactNativePolygen.h"
#import <memory>
#import <string>
#import <ReactCommon/CallInvoker.h>
#import <ReactCommon/TurboModule.h>
#endif

@interface Wasm : NSObject

#ifdef __cplusplus
/**
 * Returns the Polygen TurboModule for registration in bridgeless mode.
 *
 * In React Native 0.81+ bridgeless mode, the +load registration doesn't work.
 * App developers must call this from their AppDelegate's getTurboModule:jsInvoker: method:
 *
 * @code
 * #import <RCTAppDelegate+Protected.h>
 * #import <ReactNativePolygen/Wasm.h>
 *
 * - (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:(const std::string &)name
 *                                                       jsInvoker:(std::shared_ptr<facebook::react::CallInvoker>)jsInvoker
 * {
 *   if (auto module = [Wasm getTurboModule:name jsInvoker:jsInvoker]) {
 *     return module;
 *   }
 *   return [super getTurboModule:name jsInvoker:jsInvoker];
 * }
 * @endcode
 *
 * @param name The module name requested by the TurboModuleManager
 * @param jsInvoker The JavaScript call invoker
 * @return A shared_ptr to the TurboModule if name matches "Polygen", nullptr otherwise
 */
+ (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:(const std::string &)name
                                                      jsInvoker:(std::shared_ptr<facebook::react::CallInvoker>)jsInvoker;
#endif

@end
