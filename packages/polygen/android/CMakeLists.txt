cmake_minimum_required(VERSION 3.4.1)
project(Wasm)

set (CMAKE_VERBOSE_MAKEFILE ON)
set (CMAKE_CXX_STANDARD 14)

add_library(react-native-wasm            SHARED
            ../cpp/react-native-wasm.cpp
            cpp-adapter.cpp
)

# Specifies a path to native header files.
include_directories(
            ../cpp
)

# Link against React Native and fbjni (RN 0.76+ merged SO uses separate jsi module).
target_link_libraries(react-native-wasm
            ReactAndroid::jsi
            ReactAndroid::reactnative
            fbjni::fbjni
)

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
