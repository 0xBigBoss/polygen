# TODO - iOS Bridgeless TurboModule Implementation

## Completed
- [x] Create packages/polygen/ios/PolygenModule.h (iteration 1)
- [x] Create packages/polygen/ios/PolygenModule.mm with RCT_EXPORT_MODULE, requiresMainQueueSetup, getTurboModule (iteration 1)
- [x] Create packages/polygen/ios/PolygenModuleTests.mm with unit tests (iteration 1)
- [x] Update packages/polygen/ReactNativePolygen.podspec with ios sources, exclude_files, test_spec (iteration 1)
- [x] Update packages/polygen/package.json to React 18.2.0 and RN 0.76.0 (iteration 1)
- [x] Delete legacy Wasm.h and Wasm.mm files (iteration 1)
- [x] Create new Expo bare workflow example app with SDK 54 (iteration 1)
- [x] Fix example app TypeScript errors (iteration 1)
- [x] yarn typecheck passes (iteration 1)
- [x] yarn lint passes (iteration 1)
- [x] iOS pod install works (iteration 1)
- [x] Fix iOS dependency versions (react-native-safe-area-context 5.6.2, react-native-screens 4.19.0, react-native-gesture-handler 2.30.0) (iteration 2)
- [x] Add ReactNativeWebAssemblyHost pod to Podfile for polygen-generated code (iteration 2)
- [x] Run polygen generate to create getModuleBag() (iteration 2)
- [x] iOS xcodebuild passes (iteration 2)

## In Progress
- [ ] Android build fixes

## Pending
- [ ] None

## Blocked
- [ ] Android build requires CMake refactoring for RN 0.76+ autolinking (see notes)

## Notes
- Example app uses RN 0.81.5 and Expo SDK 54 (newer than spec minimum of 0.76)
- iOS build is fully working
- Android build has several issues:
  1. Created new JNI CMakeLists.txt at packages/polygen/android/src/main/jni/CMakeLists.txt for RN 0.76+ autolinking
  2. Updated react-native.config.js to point to new CMakeLists.txt
  3. Disabled standalone CMake build in library's build.gradle (AAR build doesn't have prefab)
  4. Need to pass POLYGEN_APP_ROOT from app's CMake to polygen CMake for getModuleBag()
  5. Missing computeSHA256 and fmt library linking
- iOS verification: `xcodebuild -workspace example.xcworkspace -scheme example -sdk iphonesimulator -configuration Debug build` succeeds
