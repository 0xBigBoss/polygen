# Spec: iOS Bridgeless Mode TurboModule Registration

## Problem Statement

In React Native 0.76+ bridgeless mode, C++ TurboModules registered via `registerCxxModuleToGlobalModuleMap()` in `+load` are not found at runtime:

```
TurboModuleRegistry.getEnforcing(...): 'Polygen' could not be found.
Bridgeless mode: true. TurboModule interop: false.
```

## Root Cause

1. C++ TurboModules bypass the ObjC delegate path (`getTurboModule:jsInvoker:`)
2. They go directly to `globalExportedCxxTurboModuleMap()` - a static variable
3. Due to C++ ODR/inline function behavior, each framework gets its own copy of this static map
4. Polygen registers to its copy; React Native's TurboModuleManager checks a different copy

## Selected Solution: ObjC TurboModule Wrapper

Wrap `ReactNativePolygen` in an Objective-C class conforming to `RCTTurboModule`. This uses the official ObjC TurboModule registration path which works correctly in bridgeless mode.

### Why This Approach

- **Stability:** Uses official React Native APIs
- **Maintainability:** Less likely to break with RN updates than swizzling
- **Simplicity:** No runtime symbol lookup or method interception

### Implementation Details

1. Create `PolygenModule.mm` - ObjC class conforming to `RCTTurboModule`
2. Implement codegen spec for the module interface
3. The ObjC module's `getTurboModule:` returns the C++ `ReactNativePolygen` instance
4. Remove the `+load` registration (bridgeless only, no backwards compat)

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

## Success Criteria

- [ ] `polygen generate` works with new example structure
- [ ] iOS app loads Polygen TurboModule in bridgeless mode
- [ ] All existing WASM demos function correctly
- [ ] Android continues to work (no regression)
- [ ] `yarn typecheck`, `yarn lint`, `yarn test` pass
- [ ] Example app builds on iOS simulator
- [ ] Example app builds on Android emulator

## Migration Path

For existing Polygen users upgrading:

1. Update to Polygen version with this fix
2. Ensure React Native 0.76+ with bridgeless mode
3. Run `pod install` to pick up new native code
4. No JS API changes required

## Files to Modify

### New Files

- `packages/polygen/ios/PolygenModule.h` - ObjC TurboModule interface
- `packages/polygen/ios/PolygenModule.mm` - ObjC TurboModule implementation
- `apps/example/` - New Expo bare workflow project (replacing existing)

### Modified Files

- `packages/polygen/ReactNativePolygen.podspec` - Add ObjC sources
- `packages/polygen/src/NativePolygen.ts` - Update codegen spec if needed

### Deleted Files

- `packages/polygen/cpp/ReactNativePolygen/Wasm.h` - No longer needed
- `packages/polygen/cpp/ReactNativePolygen/Wasm.mm` - No longer needed
- `packages/polygen/cpp/ReactNativePolygen/WasmTests.h` - Tests move to new structure

## Open Questions

None - all decisions made during spec interview.

## References

- [React Native TurboModules](https://reactnative.dev/docs/turbo-native-modules-introduction)
- [Expo Bare Workflow](https://docs.expo.dev/bare/overview/)
- GitHub Issue: https://github.com/0xBigBoss/polygen/issues/1
