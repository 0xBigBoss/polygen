cmake_minimum_required(VERSION 3.13)
project(Wasm)

set(CMAKE_VERBOSE_MAKEFILE ON)
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(ReactAndroid REQUIRED CONFIG)
find_package(fbjni REQUIRED CONFIG)

set(REACT_NATIVE_DIR "")
set(_search_dir "${CMAKE_CURRENT_SOURCE_DIR}")
while (NOT REACT_NATIVE_DIR)
  if (EXISTS "${_search_dir}/node_modules/react-native/ReactAndroid/cmake-utils/folly-flags.cmake")
    set(REACT_NATIVE_DIR "${_search_dir}/node_modules/react-native")
    break()
  endif()
  get_filename_component(_parent_dir "${_search_dir}/.." ABSOLUTE)
  if (_parent_dir STREQUAL _search_dir)
    break()
  endif()
  set(_search_dir "${_parent_dir}")
endwhile()
if (REACT_NATIVE_DIR)
  set(REACT_ANDROID_DIR "${REACT_NATIVE_DIR}/ReactAndroid")
  include("${REACT_ANDROID_DIR}/cmake-utils/folly-flags.cmake")
endif()

# Search for polygen-generated host code
# Walk up from polygen module to find app's node_modules/.polygen-out/host
set(POLYGEN_HOST_DIR "")
if (POLYGEN_APP_ROOT)
  set(_host_search_dir "${POLYGEN_APP_ROOT}")
else()
  set(_host_search_dir "${CMAKE_CURRENT_SOURCE_DIR}")
endif()
while (NOT POLYGEN_HOST_DIR)
  # Check common locations relative to current search dir
  foreach(_candidate
    "${_host_search_dir}/node_modules/.polygen-out/host"
    "${_host_search_dir}/.polygen-out/host"
  )
    if (EXISTS "${_candidate}/CMakeLists.txt")
      set(POLYGEN_HOST_DIR "${_candidate}")
      break()
    endif()
  endforeach()

  if (POLYGEN_HOST_DIR)
    break()
  endif()

  get_filename_component(_host_parent_dir "${_host_search_dir}/.." ABSOLUTE)
  if (_host_parent_dir STREQUAL _host_search_dir)
    break()
  endif()
  set(_host_search_dir "${_host_parent_dir}")
endwhile()

set(LIB_ANDROID_DIR ${CMAKE_CURRENT_SOURCE_DIR})
set(LIB_CPP_DIR ${LIB_ANDROID_DIR}/../cpp)
set(LIB_CPP_POLYGEN_DIR ${LIB_CPP_DIR}/ReactNativePolygen)
set(LIB_CPP_WASMRT_DIR ${LIB_CPP_DIR}/wasm-rt)
set(LIB_ANDROID_GENERATED_JNI_DIR ${LIB_ANDROID_DIR}/build/generated/source/codegen/jni)
set(LIB_ANDROID_GENERATED_COMPONENTS_DIR ${LIB_ANDROID_GENERATED_JNI_DIR}/react/renderer/components/RNPolygenSpec)

# Include generated host code if found
if (POLYGEN_HOST_DIR)
  message(STATUS "[Polygen] Found generated host code at: ${POLYGEN_HOST_DIR}")
  set(POLYGEN_INCLUDE_DIR ${LIB_CPP_DIR})
  add_subdirectory(${POLYGEN_HOST_DIR} ${CMAKE_CURRENT_BINARY_DIR}/polygen-generated)
else()
  message(WARNING "[Polygen] No generated host code found. Run 'polygen generate' to precompile WASM modules.")
endif()

file(GLOB_RECURSE POLYGEN_CPP_SRCS CONFIGURE_DEPENDS
  ${LIB_CPP_POLYGEN_DIR}/*.cpp
  ${LIB_CPP_POLYGEN_DIR}/*.c
  ${LIB_CPP_WASMRT_DIR}/*.cpp
  ${LIB_CPP_WASMRT_DIR}/*.c
)

file(GLOB POLYGEN_CODEGEN_SRCS CONFIGURE_DEPENDS
  ${LIB_ANDROID_GENERATED_JNI_DIR}/*.cpp
  ${LIB_ANDROID_GENERATED_COMPONENTS_DIR}/*.cpp
)

add_library(react-native-wasm SHARED
  cpp-adapter.cpp
  ${POLYGEN_CPP_SRCS}
  ${POLYGEN_CODEGEN_SRCS}
  $<$<TARGET_EXISTS:polygen_generated>:$<TARGET_OBJECTS:polygen_generated>>
)

target_include_directories(react-native-wasm
  PUBLIC
  ${LIB_CPP_DIR}
  ${LIB_CPP_POLYGEN_DIR}
  ${LIB_CPP_WASMRT_DIR}
  ${LIB_ANDROID_GENERATED_JNI_DIR}
  ${LIB_ANDROID_GENERATED_COMPONENTS_DIR}
)

if (TARGET ReactAndroid::reactnative)
  target_link_libraries(
    react-native-wasm
    ReactAndroid::reactnative
    ReactAndroid::jsi
    fbjni::fbjni
  )
else()
  target_link_libraries(
    react-native-wasm
    fbjni::fbjni
    ReactAndroid::folly_runtime
    ReactAndroid::glog
    ReactAndroid::jsi
    ReactAndroid::react_codegen_rncore
    ReactAndroid::react_debug
    ReactAndroid::react_nativemodule_core
    ReactAndroid::react_render_componentregistry
    ReactAndroid::react_render_core
    ReactAndroid::react_render_debug
    ReactAndroid::react_render_graphics
    ReactAndroid::react_render_mapbuffer
    ReactAndroid::react_utils
    ReactAndroid::rrc_view
    ReactAndroid::turbomodulejsijni
    ReactAndroid::yoga
  )
endif()

target_compile_options(react-native-wasm PRIVATE
  -Wall
  -fexceptions
  -frtti
  -O2
  -fstack-protector-all
  -DLOG_TAG=\"Polygen\"
  -DFMT_HEADER_ONLY=1
  ${folly_FLAGS}
)

# 16KB page size support for Android 15+
target_link_options(react-native-wasm PRIVATE
  -Wl,-z,max-page-size=16384
)
