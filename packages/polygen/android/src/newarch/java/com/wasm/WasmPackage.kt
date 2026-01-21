package com.wasm

import com.facebook.react.TurboReactPackage
import com.facebook.react.bridge.NativeModule
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.module.model.ReactModuleInfo
import com.facebook.react.module.model.ReactModuleInfoProvider
import com.facebook.soloader.SoLoader

class WasmPackage : TurboReactPackage() {
  companion object {
    init {
      SoLoader.loadLibrary("react-native-wasm")
    }
  }

  override fun getModule(name: String, reactContext: ReactApplicationContext): NativeModule? {
    return null
  }

  override fun getReactModuleInfoProvider(): ReactModuleInfoProvider {
    return ReactModuleInfoProvider {
      val moduleName = "Polygen"
      mapOf(
        moduleName to ReactModuleInfo(
          moduleName,
          moduleName,
          false, // canOverrideExistingModule
          false, // needsEagerInit
          false, // hasConstants
          true, // isCxxModule
          true // isTurboModule
        )
      )
    }
  }
}
