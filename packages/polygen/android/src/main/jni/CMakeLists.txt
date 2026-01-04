cmake_minimum_required(VERSION 3.13)
set(CMAKE_VERBOSE_MAKEFILE ON)

set(LIB_LITERAL RNPolygenSpec)
set(LIB_TARGET_NAME react_codegen_${LIB_LITERAL})

set(LIB_ANDROID_DIR ${CMAKE_CURRENT_SOURCE_DIR}/../../..)
set(LIB_CPP_DIR ${LIB_ANDROID_DIR}/../cpp)
set(LIB_ANDROID_GENERATED_JNI_DIR ${LIB_ANDROID_DIR}/build/generated/source/codegen/jni)

# Polygen source files
file(GLOB POLYGEN_SRCS CONFIGURE_DEPENDS
  ${LIB_CPP_DIR}/ReactNativePolygen/*.cpp
  ${LIB_CPP_DIR}/wasm-rt/*.c
)

# Codegen source files
file(GLOB LIB_CODEGEN_SRCS CONFIGURE_DEPENDS
  ${LIB_ANDROID_GENERATED_JNI_DIR}/*.cpp
  ${LIB_ANDROID_GENERATED_JNI_DIR}/react/renderer/components/${LIB_LITERAL}/*.cpp
)

# Include polygen-generated code from app's node_modules/.polygen-out/host/ if available
set(POLYGEN_GENERATED_SRCS "")
# Try to find polygen-generated code via POLYGEN_APP_ROOT (passed from app's gradle)
if(DEFINED POLYGEN_APP_ROOT AND EXISTS "${POLYGEN_APP_ROOT}/node_modules/.polygen-out/host/loader.cpp")
  file(GLOB POLYGEN_GENERATED_SRCS CONFIGURE_DEPENDS
    ${POLYGEN_APP_ROOT}/node_modules/.polygen-out/host/*.cpp
    ${POLYGEN_APP_ROOT}/node_modules/.polygen-out/host/*.c
    ${POLYGEN_APP_ROOT}/node_modules/.polygen-out/host/**/*.cpp
    ${POLYGEN_APP_ROOT}/node_modules/.polygen-out/host/**/*.c
  )
  message(STATUS "Found polygen-generated code at ${POLYGEN_APP_ROOT}/node_modules/.polygen-out/host/")
endif()

add_library(
  ${LIB_TARGET_NAME}
  SHARED
  ${POLYGEN_SRCS}
  ${LIB_CODEGEN_SRCS}
  ${POLYGEN_GENERATED_SRCS}
)

target_include_directories(
  ${LIB_TARGET_NAME}
  PUBLIC
  ${LIB_CPP_DIR}
  ${LIB_CPP_DIR}/ReactNativePolygen
  ${LIB_CPP_DIR}/wasm-rt
  ${LIB_ANDROID_GENERATED_JNI_DIR}
  ${LIB_ANDROID_GENERATED_JNI_DIR}/react/renderer/components/RNPolygenSpec
)

# Include polygen-generated code headers if available
if(DEFINED POLYGEN_APP_ROOT AND EXISTS "${POLYGEN_APP_ROOT}/node_modules/.polygen-out/host/")
  target_include_directories(
    ${LIB_TARGET_NAME}
    PUBLIC
    ${POLYGEN_APP_ROOT}/node_modules/.polygen-out/host
  )
endif()

# Link against RN 0.76+ merged SO or legacy targets
# https://github.com/react-native-community/discussions-and-proposals/discussions/816
if (REACTNATIVE_MERGED_SO)
  target_link_libraries(
    ${LIB_TARGET_NAME}
    fbjni
    jsi
    reactnative
  )
else()
  target_link_libraries(
    ${LIB_TARGET_NAME}
    fbjni
    folly_runtime
    jsi
    react_codegen_rncore
    react_nativemodule_core
    turbomodulejsijni
  )
endif()

# Compile options
target_compile_options(
  ${LIB_TARGET_NAME}
  PRIVATE
  -fexceptions
  -frtti
)

# Set C++ standard for CXX files only
set_target_properties(${LIB_TARGET_NAME} PROPERTIES
  CXX_STANDARD 20
  CXX_STANDARD_REQUIRED ON
)

# Suppress warnings that break build (these should be fixed in the source code)
target_compile_options(
  ${LIB_TARGET_NAME}
  PRIVATE
  -Wno-error=macro-redefined
  -Wno-error=reorder-ctor
  -Wno-error=missing-braces
  -Wno-error=unused-variable
)
