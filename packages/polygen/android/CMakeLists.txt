cmake_minimum_required(VERSION 3.4.1)
project(Polygen)

# Note: The full C++ implementation for Android is not yet complete.
# This CMake file is a placeholder. The actual WASM runtime will be
# integrated via JNI in a future update. Currently the Android module
# provides stub implementations that throw UnsupportedOperationException.
#
# See: https://github.com/callstackincubator/polygen/issues/132

set(CMAKE_VERBOSE_MAKEFILE ON)
set(CMAKE_CXX_STANDARD 17)

# Placeholder - no native sources to compile yet
# The ReactNativePolygen C++ code needs to be properly integrated for Android
