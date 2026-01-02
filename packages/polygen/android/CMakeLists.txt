cmake_minimum_required(VERSION 3.13)
project(Polygen)

set(CMAKE_VERBOSE_MAKEFILE ON)
set(CMAKE_CXX_STANDARD 20)

# Find react-native directory
# When building as part of an app, this will find the react-native installation
if(NOT DEFINED REACT_ANDROID_DIR)
  # Search upward for node_modules/react-native
  set(SEARCH_DIR ${CMAKE_SOURCE_DIR})
  while(NOT EXISTS "${SEARCH_DIR}/node_modules/react-native/ReactAndroid")
    get_filename_component(PARENT_DIR ${SEARCH_DIR} DIRECTORY)
    if(PARENT_DIR STREQUAL SEARCH_DIR)
      message(FATAL_ERROR "Could not find react-native in node_modules")
    endif()
    set(SEARCH_DIR ${PARENT_DIR})
  endwhile()
  set(REACT_ANDROID_DIR "${SEARCH_DIR}/node_modules/react-native/ReactAndroid")
endif()

# Include folly flags for proper compilation
include(${REACT_ANDROID_DIR}/cmake-utils/folly-flags.cmake)

# Find React Native packages via prefab
find_package(ReactAndroid REQUIRED CONFIG)
find_package(fbjni REQUIRED CONFIG)

# Collect all C++ sources from ReactNativePolygen (including subdirectories)
file(GLOB_RECURSE POLYGEN_CPP_SOURCES
  "../cpp/ReactNativePolygen/*.cpp"
)

# Collect all C sources from wasm-rt runtime
file(GLOB WASM_RT_C_SOURCES
  "../cpp/wasm-rt/*.c"
)

# JNI registration, stubs, and codegen-generated sources
set(JNI_SOURCES
  "src/main/jni/OnLoad.cpp"
  "src/main/jni/ModuleBagStub.cpp"
  "${CMAKE_SOURCE_DIR}/build/generated/source/codegen/jni/react/renderer/components/RNPolygenSpec/RNPolygenSpecJSI-generated.cpp"
)

# Create shared library
add_library(polygen SHARED
  ${POLYGEN_CPP_SOURCES}
  ${WASM_RT_C_SOURCES}
  ${JNI_SOURCES}
)

# Include directories for our sources
target_include_directories(polygen PRIVATE
  ../cpp
  ../cpp/ReactNativePolygen
  ../cpp/wasm-rt
)

# Include directories for codegen-generated headers
# These are set by the React Native Gradle plugin
# The path is relative to the library's build directory
target_include_directories(polygen PRIVATE
  ${CMAKE_SOURCE_DIR}/build/generated/source/codegen/jni
  ${CMAKE_SOURCE_DIR}/build/generated/source/codegen/jni/react/renderer/components/RNPolygenSpec
)

# Link against React Native and fbjni
target_link_libraries(polygen
  ReactAndroid::jsi
  ReactAndroid::react_nativemodule_core
  ReactAndroid::turbomodulejsijni
  ReactAndroid::reactnativejni
  ReactAndroid::folly_runtime
  fbjni::fbjni
)

# Compiler flags
target_compile_options(polygen PRIVATE
  -Wall
  -fexceptions
  -frtti
  -O2
  -fstack-protector-all
  -DLOG_TAG=\"Polygen\"
  ${folly_FLAGS}
)
