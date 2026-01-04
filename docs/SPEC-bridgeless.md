# Spec: iOS Bridgeless Mode TurboModule Registration

## Problem Statement

In React Native 0.76+ bridgeless mode, C++ TurboModules registered via `registerCxxModuleToGlobalModuleMap()` in `+load` are not found at runtime:

```
TurboModuleRegistry.getEnforcing(...): 'Polygen' could not be found.
Bridgeless mode: true. TurboModule interop: false.
```

## Root Cause

1. `RCTTurboModuleManager` checks `getTurboModule:jsInvoker:` first, then falls back to `globalExportedCxxTurboModuleMap()`
2. Pure C++ TurboModules like Polygen have no ObjC class, so the delegate returns nil and the manager checks the global map
3. `globalExportedCxxTurboModuleMap()` is defined in `CxxTurboModuleUtils.cpp` with a function-local static; each framework that links ReactCommon gets its own object file copy, creating isolated static maps
4. Polygen registers to its framework's copy; React Native's TurboModuleManager checks the main app's copy, finds nothing

## Selected Solution: ObjC TurboModule Wrapper

Wrap `ReactNativePolygen` in an Objective-C class conforming to `RCTTurboModule`. This uses the official ObjC TurboModule registration path which works correctly in bridgeless mode.

### Why This Approach

- **Stability:** Uses official React Native APIs
- **Maintainability:** Less likely to break with RN updates than swizzling
- **Simplicity:** No runtime symbol lookup or method interception

### Implementation Details

#### 1. ObjC Module Interface (`packages/polygen/ios/PolygenModule.h`)

```objc
#import <React/RCTBridgeModule.h>
#import <ReactCommon/RCTTurboModule.h>

@interface PolygenModule : NSObject <RCTBridgeModule, RCTTurboModule>
@end
```

#### 2. ObjC Module Implementation (`packages/polygen/ios/PolygenModule.mm`)

```objc
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
```

#### 3. Registration Mechanism

The `RCT_EXPORT_MODULE(Polygen)` macro:
- Registers the module with React Native's module registry via `+load`
- Makes the module discoverable by `RCTTurboModuleManager`
- Uses the ObjC path which works correctly in bridgeless mode

When JS calls `TurboModuleRegistry.getEnforcing('Polygen')`:
1. `RCTTurboModuleManager` finds `PolygenModule` via the module registry
2. Calls `[PolygenModule getTurboModule:]`
3. Returns the C++ `ReactNativePolygen` instance

#### 4. Codegen Wiring

The existing codegen spec (`packages/polygen/src/NativePolygen.ts`) generates:
- `RNPolygenSpecJSI.h` - C++ JSI bindings with `NativePolygenCxxSpecJSI` base class
- `RNPolygenSpec.h` - ObjC protocol `NativePolygenSpec` (for type checking)

The C++ class `ReactNativePolygen` in `packages/polygen/cpp/ReactNativePolygen/ReactNativePolygen.h`:
- Extends `NativePolygenCxxSpecJSI` (line 51)
- Uses `constexpr static auto kModuleName = "Polygen"` (line 53)
- Implements all methods from the codegen spec

The ObjC wrapper doesn't implement the protocol methods directly—it delegates to the C++ implementation via `getTurboModule:`.

#### 5. Remove Legacy Registration

Delete the `+load` method in `Wasm.mm` that calls `registerCxxModuleToGlobalModuleMap`. This registration path doesn't work in bridgeless mode and is superseded by the ObjC wrapper.

#### 6. Fail-Fast for Unsupported Configurations

Since this version drops bridged mode support, add compile-time and runtime guards to fail explicitly rather than silently:

**Compile-time guard** (`packages/polygen/ios/PolygenModule.mm`):

```objc
#if !RCT_NEW_ARCH_ENABLED
#error "Polygen requires React Native New Architecture (bridgeless mode). \
Set RCT_NEW_ARCH_ENABLED=1 in your Podfile or upgrade to Expo SDK 52+."
#endif
```

**Runtime guard** (in `getTurboModule:` method):

```objc
- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:
    (const facebook::react::ObjCTurboModule::InitParams &)params
{
#if DEBUG
  // Log confirmation that bridgeless registration is working
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    NSLog(@"[Polygen] TurboModule registered via bridgeless path");
  });
#endif
  return std::make_shared<facebook::react::ReactNativePolygen>(params.jsInvoker);
}
```

This ensures:
- Build fails immediately if someone tries to use Polygen with `RCT_NEW_ARCH_ENABLED=0`
- Clear error message guides users to the solution
- Debug builds log successful registration for verification

### Architecture Preserved

- Generated WASM host code (`ReactNativeWebAssemblyHost`) remains internal to Polygen
- No changes to how user's compiled WASM modules are loaded
- Only the registration mechanism changes

## Example App Modernization

Replace `apps/example` (react-native-test-app) with a modern Expo bare workflow project.

### Requirements

- Expo SDK 52+
- React Native 0.76+
- Bridgeless mode enabled by default
- Expo bare workflow (full native access)

### Bridgeless Mode Configuration

New Architecture (bridgeless) is enabled by default for new Expo SDK 52+ projects and all SDK 53+ projects. For existing SDK 52 projects, explicit configuration may be required.

#### Expo Config (`apps/example/app.json`)

Use the top-level `newArchEnabled` field (preferred) or platform-specific fields:

```json
{
  "expo": {
    "newArchEnabled": true
  }
}
```

Or for platform-specific control:

```json
{
  "expo": {
    "ios": { "newArchEnabled": true },
    "android": { "newArchEnabled": true }
  }
}
```

**Note:** The `expo-build-properties` plugin's `newArchEnabled` option is deprecated. Use the Expo config fields above instead.

#### iOS (`apps/example/ios/Podfile`)

For manual verification, check that the environment variable is set:

```ruby
# New Architecture is configured via app.json, but can verify:
# ENV['RCT_NEW_ARCH_ENABLED'] should be '1' after prebuild

use_expo_modules!
```

#### Android (`apps/example/android/gradle.properties`)

For manual verification:

```properties
# Set automatically by Expo prebuild when newArchEnabled: true
newArchEnabled=true
```

### Verification

After setup, the app should show in Metro console:
```
Running "PolygenExample" with {"fabric":true,"initialProps":{},"concurrentRoot":true}
```

And `TurboModuleRegistry.getEnforcing('Polygen')` should succeed without errors.

### Demo Content

Keep existing WASM demos:
- `example.wasm` - Basic example
- `table_test.wasm` - Table/global tests
- `simple_sha256_wasm_bg.wasm` - SHA256 hashing

## Scope

### In Scope

- [ ] ObjC TurboModule wrapper for `ReactNativePolygen`
- [ ] Codegen spec for module interface
- [ ] New Expo bare workflow example app
- [ ] iOS bridgeless mode support
- [ ] Android bridgeless mode (already works)
- [ ] Update documentation

### Out of Scope

- Bridged mode backwards compatibility (RN < 0.76)
- react-native-test-app support
- New WASM demo content

## Dependency Updates

Update `packages/polygen/package.json` to require React Native 0.76+ and React 18+:

```json
{
  "peerDependencies": {
    "react": ">=18.0.0",
    "react-native": ">=0.76.0"
  },
  "devDependencies": {
    "react": "18.2.0",
    "react-native": "0.76.0"
  }
}
```

**Why React 18:** React Native 0.76+ requires React 18 for concurrent features used in bridgeless mode. The current `react: 17.0.2` devDependency and permissive `react: *` peerDependency must be updated to avoid version mismatches.

This aligns local development with the bridgeless-only support decision.

## Test Coverage

### Unit Tests for ObjC Registration

Add tests in `packages/polygen/ios/PolygenModuleTests.mm`:

```objc
#import <XCTest/XCTest.h>
#import <React/RCTBridge.h>
#import <ReactCommon/RCTTurboModule.h>
#import "PolygenModule.h"
#import <ReactNativePolygen/WasmTests.h>  // For polygen::tests::MockCallInvoker

@interface PolygenModuleTests : XCTestCase
@end

@implementation PolygenModuleTests

- (void)testModuleName {
  XCTAssertEqualObjects([PolygenModule moduleName], @"Polygen");
}

- (void)testRequiresMainQueueSetup {
  XCTAssertFalse([PolygenModule requiresMainQueueSetup]);
}

- (void)testGetTurboModuleReturnsNonNull {
  // Use the existing MockCallInvoker from WasmTests.h
  auto callInvoker = std::make_shared<polygen::tests::MockCallInvoker>();

  // Initialize all InitParams fields to safe defaults (C++17-compatible)
  facebook::react::ObjCTurboModule::InitParams params;
  params.moduleName = "Polygen";
  params.instance = nil;
  params.jsInvoker = callInvoker;
  params.nativeMethodCallInvoker = nullptr;
  params.isSyncModule = false;
  params.shouldVoidMethodsExecuteSync = false;

  PolygenModule *module = [[PolygenModule alloc] init];
  auto turboModule = [module getTurboModule:params];

  XCTAssertTrue(turboModule != nullptr, @"getTurboModule should return a valid C++ module");
}

@end
```

### Runtime Verification (Example App)

Jest tests mock `TurboModuleRegistry` and won't validate native bridgeless registration. Instead, the example app includes runtime verification that runs on device/simulator:

#### App Startup Check (`apps/example/src/App.tsx`)

```typescript
import { useEffect, useState } from 'react';
import { TurboModuleRegistry, Text, View } from 'react-native';

function App() {
  const [moduleStatus, setModuleStatus] = useState<'loading' | 'success' | 'error'>('loading');

  useEffect(() => {
    try {
      // This call will throw if the module isn't registered in bridgeless mode
      const polygen = TurboModuleRegistry.getEnforcing('Polygen');

      // Verify the module has expected methods
      if (typeof polygen.loadModule === 'function') {
        setModuleStatus('success');
        console.log('[Polygen] TurboModule loaded successfully in bridgeless mode');
      } else {
        throw new Error('Module missing expected methods');
      }
    } catch (error) {
      setModuleStatus('error');
      console.error('[Polygen] TurboModule registration failed:', error);
    }
  }, []);

  return (
    <View>
      <Text testID="polygen-status">{moduleStatus}</Text>
      {/* Rest of app */}
    </View>
  );
}
```

#### E2E Verification (Optional Detox Test)

For CI automation, add a Detox test in `apps/example/e2e/polygen.e2e.ts`:

```typescript
describe('Polygen Bridgeless Mode', () => {
  beforeAll(async () => {
    await device.launchApp();
  });

  it('loads TurboModule successfully', async () => {
    await expect(element(by.id('polygen-status'))).toHaveText('success');
  });
});
```

### Test Matrix

| Test Type | Coverage | Location | Notes |
|-----------|----------|----------|-------|
| Unit | ObjC module name and setup | `ios/PolygenModuleTests.mm` | Runs in Xcode |
| Unit | getTurboModule returns valid C++ module | `ios/PolygenModuleTests.mm` | Runs in Xcode |
| Runtime | TurboModuleRegistry.getEnforcing works | Example app on device | Validates bridgeless |
| E2E | Automated module load check | Detox (optional) | CI integration |
| Regression | Android still works | Example app on Android | Manual verification |

## Success Criteria

- [ ] `polygen generate` works with new example structure
- [ ] iOS app loads Polygen TurboModule in bridgeless mode
- [ ] All existing WASM demos function correctly
- [ ] Android continues to work (no regression)
- [ ] `yarn typecheck`, `yarn lint`, `yarn test` pass
- [ ] Example app builds on iOS simulator
- [ ] Example app builds on Android emulator
- [ ] ObjC module registration tests pass

## Migration Path

For existing Polygen users upgrading:

1. Update to Polygen version with this fix
2. Ensure React Native 0.76+ with bridgeless mode
3. **Remove AppDelegate TurboModule override** (breaking change - see below)
4. Run `pod install` to pick up new native code
5. No JS API changes required

### Breaking Change: Remove AppDelegate Override

Previous versions of Polygen documented a workaround requiring users to override `getTurboModule:jsInvoker:` in their AppDelegate:

```objc
// ❌ REMOVE THIS CODE - no longer needed
#import <ReactNativePolygen/Wasm.h>

- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:(const std::string &)name
                                                      jsInvoker:(std::shared_ptr<facebook::react::CallInvoker>)jsInvoker
{
  if (auto module = [Wasm getTurboModule:name jsInvoker:jsInvoker]) {
    return module;
  }
  return [super getTurboModule:name jsInvoker:jsInvoker];
}
```

**Action required:**
1. Remove the `#import <ReactNativePolygen/Wasm.h>` import from your AppDelegate
2. Remove the `getTurboModule:jsInvoker:` override method entirely
3. Remove `#import <RCTAppDelegate+Protected.h>` if only used for this override

The new ObjC wrapper (`PolygenModule`) handles registration automatically via `RCT_EXPORT_MODULE`. No AppDelegate changes are needed.

**Build errors if not removed:**
- `'ReactNativePolygen/Wasm.h' file not found` - the header is deleted in this version
- Undefined symbol errors for `[Wasm getTurboModule:jsInvoker:]`

## Files to Modify

### New Files

- `packages/polygen/ios/PolygenModule.h` - ObjC TurboModule interface
- `packages/polygen/ios/PolygenModule.mm` - ObjC TurboModule implementation
- `packages/polygen/ios/PolygenModuleTests.mm` - Unit tests for ObjC registration
- `apps/example/` - New Expo bare workflow project (replacing existing)

### Modified Files

- `packages/polygen/ReactNativePolygen.podspec` - Add ObjC sources while preserving subspec separation
  ```ruby
  # In the main spec (not subspecs):
  s.source_files = [
    "cpp/ReactNativePolygen/**/*.{h,hpp,c,cpp,mm}",  # Preserve existing path
    "ios/**/*.{h,m,mm}"  # Add ObjC wrapper
  ]

  # Exclude test files from production build
  s.exclude_files = [
    "ios/**/*Tests.mm"
  ]

  # Optional: Add test spec for running unit tests
  s.test_spec 'Tests' do |test_spec|
    test_spec.source_files = 'ios/**/*Tests.mm'
    test_spec.frameworks = 'XCTest'
  end

  # Note: cpp/wasm-rt remains in Runtime subspec only
  ```
- `packages/polygen/package.json` - Update react-native to 0.76+
- `packages/polygen/src/NativePolygen.ts` - No changes needed (existing spec is correct)

### Deleted Files

- `packages/polygen/cpp/ReactNativePolygen/Wasm.h` - No longer needed (legacy registration)
- `packages/polygen/cpp/ReactNativePolygen/Wasm.mm` - No longer needed (legacy registration)

## Open Questions

None - all decisions made during spec interview.

## References

- [React Native TurboModules](https://reactnative.dev/docs/turbo-native-modules-introduction)
- [Expo Bare Workflow](https://docs.expo.dev/bare/overview/)
- GitHub Issue: https://github.com/0xBigBoss/polygen/issues/1
