# TODO - Polygen Android C++ Integration

## Completed
- [x] Review existing C++ implementation structure (iteration 1)
- [x] Review iOS TurboModule registration pattern (iteration 1)
- [x] Phase 1: Rewrite CMakeLists.txt for C++ compilation (iteration 1)
- [x] Phase 1: Re-enable externalNativeBuild in build.gradle (iteration 1)
- [x] Phase 2: Create OnLoad.cpp for JNI_OnLoad registration (iteration 1)
- [x] Phase 2: Update PolygenPackage.kt with SoLoader.loadLibrary (iteration 1)
- [x] Phase 2: Set isCxxModule=true in ReactModuleInfo (iteration 1)
- [x] Phase 3: Add cmakeListsPath to react-native.config.js (iteration 1)
- [x] Fix C++ code to support Android codegen headers (iteration 2)
  - Added #include <string> to w2c.h
  - Created ModuleBagStub.cpp for getModuleBag() function
  - Added RNPolygenSpecJSI-generated.cpp to JNI sources
  - Fixed GLOB to GLOB_RECURSE to include utils/*.cpp
  - Added ReactAndroid::folly_runtime to link libraries
- [x] Phase 4: Verify Android build succeeds (iteration 2)
  - libpolygen.so successfully built for arm64-v8a
  - JNI_OnLoad symbol present
- [x] Phase 4: Test example app on Android emulator (iteration 3)
  - App launches successfully via ADB
  - UI visible and interactive (BottomTabs Example screen)
  - Navigation works (Import Validation screen)
  - C++ TurboModule registration working (no UnsatisfiedLinkError)
  - "Bridgeless mode is enabled" confirms new architecture active

## Pending
- [ ] Phase 5: Android integration for polygen-generated code
  - iOS uses `ReactNativeWebAssemblyHost.podspec` to link generated native code
  - Android needs equivalent mechanism (CMake include or separate AAR)
  - Until implemented, modules return "not precompiled" errors as expected

## Blocked
None

## Notes
- App package: `com.callstack.polygen.example`
- Main activity: `com.microsoft.reacttestapp.MainActivity`
- libpolygen.so loaded successfully (verified in logcat)
- No UnsatisfiedLinkError or TurboModule registration errors
- iOS codegen generates: `RNPolygenSpecJSI.h` with class `NativePolygenCxxSpecJSI`
- Android codegen also generates: `RNPolygenSpecJSI.h` with same class name

## Module Loading Architecture

### How It Works
1. `polygen generate` creates native C/C++ code in `node_modules/.polygen-out/host/`
2. It generates a `loader.cpp` with `getModuleBag()` containing all precompiled modules
3. The polygen library has `ModuleBagStub.cpp` returning an empty bag (fallback)
4. For modules to load, the app must link generated code instead of the stub

### iOS vs Android
- **iOS**: `ReactNativeWebAssemblyHost.podspec` auto-links generated code via CocoaPods
- **Android**: No equivalent mechanism yet - requires manual CMake integration

### Current Behavior
- C++ TurboModule registration: ✅ Working
- Module compile errors (expected): "module was not precompiled"
- This is correct behavior when generated code isn't linked

## Verification Summary
PR scope (C++ TurboModule wiring) verified:
1. ✅ Android example app launches successfully on emulator
2. ✅ App UI is visible and interactive
3. ✅ libpolygen.so loads without UnsatisfiedLinkError
4. ✅ C++ TurboModule registered via JNI_OnLoad
5. ✅ Module API accessible from JavaScript (returns expected errors for unlinked modules)

Future work needed:
- Android equivalent of ReactNativeWebAssemblyHost.podspec for linking generated code
