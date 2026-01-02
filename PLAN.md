# Polygen Android Full Implementation Plan

This document outlines the steps needed to complete full Android support for Polygen. The current fix (PR #132) makes the Android build succeed, but the module throws `UnsupportedOperationException` at runtime because the C++ WASM runtime isn't wired up yet.

## Current State

### What Works
- Android new architecture build compiles successfully
- Codegen generates correct `NativePolygenSpec` in `com.callstack.polygen`
- `PolygenModule.kt` implements all abstract methods from the spec
- Module registers correctly with React Native's TurboModule system

### What Doesn't Work
- All methods throw `UnsupportedOperationException` at runtime
- No JNI bridge to the C++ `ReactNativePolygen` implementation
- CMake native build is disabled

## Architecture Options

### Option A: Pure C++ TurboModule (Recommended)

Register the C++ `ReactNativePolygen` class directly, matching how iOS works.

**Pros:**
- Consistent with iOS implementation
- No duplicate code in Kotlin
- Direct JSI access, better performance
- The C++ implementation already exists and works

**Cons:**
- Requires understanding React Native's C++ TurboModule registration on Android
- More complex CMake setup

### Option B: Kotlin Bridge with JNI

Keep the Kotlin `PolygenModule` and add JNI methods that call into C++.

**Pros:**
- Standard Android pattern
- Easier to debug Kotlin layer

**Cons:**
- Duplicates method definitions in Kotlin and C++
- Additional JNI marshalling overhead
- More code to maintain

## Implementation Steps (Option A - Recommended)

### Phase 1: CMake Setup

1. **Update `android/CMakeLists.txt`** to compile the C++ ReactNativePolygen module:
   ```cmake
   cmake_minimum_required(VERSION 3.13)
   project(Polygen)

   set(CMAKE_CXX_STANDARD 17)

   # Find React Native packages
   find_package(ReactAndroid REQUIRED CONFIG)
   find_package(fbjni REQUIRED CONFIG)

   # Collect all C++ sources
   file(GLOB_RECURSE POLYGEN_SOURCES
     "../cpp/ReactNativePolygen/*.cpp"
     "../cpp/ReactNativePolygen/*.c"
     "../cpp/wasm-rt/*.c"
     "src/main/jni/OnLoad.cpp"
   )

   # Create shared library
   add_library(polygen SHARED ${POLYGEN_SOURCES})

   target_include_directories(polygen PRIVATE
     ../cpp
     ../cpp/ReactNativePolygen
     ../cpp/wasm-rt
   )

   target_link_libraries(polygen
     ReactAndroid::jsi
     ReactAndroid::react_nativemodule_core
     ReactAndroid::turbomodulejsijni
     fbjni::fbjni
   )
   ```

2. **Re-enable native build in `build.gradle`**:
   ```gradle
   externalNativeBuild {
     cmake {
       path "CMakeLists.txt"
     }
   }
   ```

### Phase 2: C++ Module Registration

3. **Create `android/src/main/jni/OnLoad.cpp`**:
   ```cpp
   #include <fbjni/fbjni.h>
   #include <ReactCommon/CxxTurboModuleUtils.h>
   #include <ReactNativePolygen/ReactNativePolygen.h>

   JNIEXPORT jint JNICALL JNI_OnLoad(JavaVM *vm, void *) {
     return facebook::jni::initialize(vm, [] {
       facebook::react::registerCxxModuleToGlobalModuleMap(
         std::string(facebook::react::ReactNativePolygen::kModuleName),
         [](std::shared_ptr<facebook::react::CallInvoker> jsInvoker) {
           return std::make_shared<facebook::react::ReactNativePolygen>(jsInvoker);
         }
       );
     });
   }
   ```

4. **Update `PolygenPackage.kt`** to mark as CxxModule:
   ```kotlin
   moduleInfos[PolygenModule.NAME] = ReactModuleInfo(
     PolygenModule.NAME,
     PolygenModule.NAME,
     false,  // canOverrideExistingModule
     false,  // needsEagerInit
     false,  // hasConstants
     true,   // isCxxModule  <-- Change to true
     isTurboModule
   )
   ```

5. **Load native library to trigger `JNI_OnLoad`** in `PolygenPackage.kt`:
   ```kotlin
   import com.facebook.soloader.SoLoader

   class PolygenPackage : TurboReactPackage() {
     companion object {
       init {
         SoLoader.loadLibrary("polygen")
       }
     }
     // ... rest of package
   }
   ```
   This ensures the native library is loaded when the package class is initialized,
   which triggers `JNI_OnLoad` and registers the C++ TurboModule.

6. **Remove or simplify `PolygenModule.kt`** since the C++ module handles everything.

### Phase 3: Codegen Integration

7. **Update `react-native.config.js`** to point to the CMake file:
   ```js
   android: {
     cmakeListsPath: 'android/CMakeLists.txt',
   }
   ```

8. **Ensure codegen header paths are correct** in CMakeLists.txt:
   ```cmake
   target_include_directories(polygen PRIVATE
     ${CMAKE_CURRENT_BINARY_DIR}/generated/source/codegen/jni
   )
   ```

### Phase 4: Testing & Validation

9. **Test with example app**:
   ```bash
   cd apps/example
   yarn android
   ```

10. **Verify all WASM operations work**:
    - Module loading
    - Memory allocation
    - Global variables
    - Table operations
    - Function calls

### Phase 5: Documentation

11. **Update README.md** with Android setup instructions
12. **Add Android-specific troubleshooting** to docs

## Files to Modify

| File | Action |
|------|--------|
| `android/CMakeLists.txt` | Rewrite with proper C++ compilation |
| `android/build.gradle` | Re-enable externalNativeBuild |
| `android/src/main/jni/OnLoad.cpp` | Create for C++ module registration |
| `android/src/main/java/.../PolygenPackage.kt` | Set isCxxModule=true, add SoLoader.loadLibrary("polygen") |
| `android/src/main/java/.../PolygenModule.kt` | Remove or simplify |
| `react-native.config.js` | Add cmakeListsPath back |
| `cpp/ReactNativePolygen/ReactNativePolygen.h` | Ensure Android compatibility |

## Dependencies

- React Native 0.75+ (for proper new architecture support)
- NDK 21+ (already configured)
- CMake 3.13+

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| C++ code may have iOS-specific assumptions | Review and test all code paths on Android |
| CMake configuration complexity | Start with minimal config, add features incrementally |
| Memory management differences | Use shared_ptr consistently, test for leaks |
| Build time increase | Consider prebuilt binaries for release |

## Timeline Estimate

Not provided - depends on developer availability and familiarity with React Native internals.

## References

- [React Native TurboModules](https://reactnative.dev/docs/the-new-architecture/pillars-turbomodules)
- [C++ TurboModules](https://reactnative.dev/docs/the-new-architecture/cxx-cxxturbomodules)
- [Polygen Issue #132](https://github.com/callstackincubator/polygen/issues/132)
- [Polygen Issue #73](https://github.com/callstackincubator/polygen/issues/73)
