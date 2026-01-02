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

## Pending
- [ ] Phase 4: Test example app on Android emulator
  - Note: Example app CMake config blocked by Java 24 compatibility issue in react-native-test-app

## Notes
- iOS codegen generates: `RNPolygenSpecJSI.h` with class `NativePolygenCxxSpecJSI`
- Android codegen also generates: `RNPolygenSpecJSI.h` with same class name
- The polygen library compiles successfully, but the example app has a separate issue
- Java 24 "restricted method" warnings are treated as errors in Gradle 8.8
- This is an upstream issue with react-native-test-app, not polygen
