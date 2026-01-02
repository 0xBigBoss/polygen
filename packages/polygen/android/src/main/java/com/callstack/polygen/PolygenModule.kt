package com.callstack.polygen

import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReadableMap
import com.facebook.react.bridge.WritableMap
import com.facebook.react.bridge.WritableNativeMap
import com.facebook.react.module.annotations.ReactModule

@ReactModule(name = PolygenModule.NAME)
class PolygenModule internal constructor(context: ReactApplicationContext) :
  PolygenSpec(context) {

  override fun getName(): String {
    return NAME
  }

  override fun copyNativeHandle(holder: ReadableMap, from: ReadableMap): Boolean {
    throw UnsupportedOperationException("Polygen Android implementation is not yet complete. See https://github.com/callstackincubator/polygen/issues/132")
  }

  override fun loadModule(holder: ReadableMap, moduleData: ReadableMap): WritableMap {
    throw UnsupportedOperationException("Polygen Android implementation is not yet complete. See https://github.com/callstackincubator/polygen/issues/132")
  }

  override fun unloadModule(module: ReadableMap) {
    throw UnsupportedOperationException("Polygen Android implementation is not yet complete. See https://github.com/callstackincubator/polygen/issues/132")
  }

  override fun getModuleMetadata(module: ReadableMap): WritableMap {
    throw UnsupportedOperationException("Polygen Android implementation is not yet complete. See https://github.com/callstackincubator/polygen/issues/132")
  }

  override fun createModuleInstance(holder: ReadableMap, mod: ReadableMap, importObject: ReadableMap) {
    throw UnsupportedOperationException("Polygen Android implementation is not yet complete. See https://github.com/callstackincubator/polygen/issues/132")
  }

  override fun destroyModuleInstance(instance: ReadableMap) {
    throw UnsupportedOperationException("Polygen Android implementation is not yet complete. See https://github.com/callstackincubator/polygen/issues/132")
  }

  override fun createMemory(holder: ReadableMap, initial: Double, maximum: Double?) {
    throw UnsupportedOperationException("Polygen Android implementation is not yet complete. See https://github.com/callstackincubator/polygen/issues/132")
  }

  override fun getMemoryBuffer(instance: ReadableMap): WritableMap {
    throw UnsupportedOperationException("Polygen Android implementation is not yet complete. See https://github.com/callstackincubator/polygen/issues/132")
  }

  override fun growMemory(instance: ReadableMap, delta: Double) {
    throw UnsupportedOperationException("Polygen Android implementation is not yet complete. See https://github.com/callstackincubator/polygen/issues/132")
  }

  override fun createGlobal(holder: ReadableMap, descriptor: ReadableMap, initialValue: Double) {
    throw UnsupportedOperationException("Polygen Android implementation is not yet complete. See https://github.com/callstackincubator/polygen/issues/132")
  }

  override fun getGlobalValue(instance: ReadableMap): Double {
    throw UnsupportedOperationException("Polygen Android implementation is not yet complete. See https://github.com/callstackincubator/polygen/issues/132")
  }

  override fun setGlobalValue(instance: ReadableMap, newValue: Double) {
    throw UnsupportedOperationException("Polygen Android implementation is not yet complete. See https://github.com/callstackincubator/polygen/issues/132")
  }

  override fun createTable(holder: ReadableMap, descriptor: ReadableMap, initial: ReadableMap?) {
    throw UnsupportedOperationException("Polygen Android implementation is not yet complete. See https://github.com/callstackincubator/polygen/issues/132")
  }

  override fun growTable(instance: ReadableMap, delta: Double) {
    throw UnsupportedOperationException("Polygen Android implementation is not yet complete. See https://github.com/callstackincubator/polygen/issues/132")
  }

  override fun getTableElement(instance: ReadableMap, index: Double): WritableMap {
    throw UnsupportedOperationException("Polygen Android implementation is not yet complete. See https://github.com/callstackincubator/polygen/issues/132")
  }

  override fun setTableElement(instance: ReadableMap, index: Double, value: ReadableMap) {
    throw UnsupportedOperationException("Polygen Android implementation is not yet complete. See https://github.com/callstackincubator/polygen/issues/132")
  }

  override fun getTableSize(instance: ReadableMap): Double {
    throw UnsupportedOperationException("Polygen Android implementation is not yet complete. See https://github.com/callstackincubator/polygen/issues/132")
  }

  companion object {
    const val NAME = "Polygen"
  }
}
