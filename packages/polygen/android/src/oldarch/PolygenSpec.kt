package com.callstack.polygen

import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.ReadableMap
import com.facebook.react.bridge.WritableMap

abstract class PolygenSpec internal constructor(context: ReactApplicationContext) :
  ReactContextBaseJavaModule(context) {

  @ReactMethod(isBlockingSynchronousMethod = true)
  abstract fun copyNativeHandle(holder: ReadableMap, from: ReadableMap): Boolean

  @ReactMethod(isBlockingSynchronousMethod = true)
  abstract fun loadModule(holder: ReadableMap, moduleData: ReadableMap): WritableMap

  @ReactMethod
  abstract fun unloadModule(module: ReadableMap)

  @ReactMethod(isBlockingSynchronousMethod = true)
  abstract fun getModuleMetadata(module: ReadableMap): WritableMap

  @ReactMethod
  abstract fun createModuleInstance(holder: ReadableMap, mod: ReadableMap, importObject: ReadableMap)

  @ReactMethod
  abstract fun destroyModuleInstance(instance: ReadableMap)

  @ReactMethod
  abstract fun createMemory(holder: ReadableMap, initial: Double, maximum: Double?)

  @ReactMethod(isBlockingSynchronousMethod = true)
  abstract fun getMemoryBuffer(instance: ReadableMap): WritableMap

  @ReactMethod
  abstract fun growMemory(instance: ReadableMap, delta: Double)

  @ReactMethod
  abstract fun createGlobal(holder: ReadableMap, descriptor: ReadableMap, initialValue: Double)

  @ReactMethod(isBlockingSynchronousMethod = true)
  abstract fun getGlobalValue(instance: ReadableMap): Double

  @ReactMethod
  abstract fun setGlobalValue(instance: ReadableMap, newValue: Double)

  @ReactMethod
  abstract fun createTable(holder: ReadableMap, descriptor: ReadableMap, initial: ReadableMap?)

  @ReactMethod
  abstract fun growTable(instance: ReadableMap, delta: Double)

  @ReactMethod(isBlockingSynchronousMethod = true)
  abstract fun getTableElement(instance: ReadableMap, index: Double): WritableMap

  @ReactMethod
  abstract fun setTableElement(instance: ReadableMap, index: Double, value: ReadableMap)

  @ReactMethod(isBlockingSynchronousMethod = true)
  abstract fun getTableSize(instance: ReadableMap): Double
}
