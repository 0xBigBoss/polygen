package com.callstack.polygen

import com.facebook.react.TurboReactPackage
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.NativeModule
import com.facebook.react.module.model.ReactModuleInfoProvider
import com.facebook.react.module.model.ReactModuleInfo
import com.facebook.soloader.SoLoader

class PolygenPackage : TurboReactPackage() {
  companion object {
    init {
      // Only load native library when new architecture is enabled
      // Old architecture uses Java/Kotlin stub and no native library is built
      if (BuildConfig.IS_NEW_ARCHITECTURE_ENABLED) {
        SoLoader.loadLibrary("polygen")
      }
    }
  }
  override fun getModule(name: String, reactContext: ReactApplicationContext): NativeModule? {
    // For new architecture with C++ TurboModule, return null to let the system
    // use the C++ module registered via JNI_OnLoad in OnLoad.cpp
    if (BuildConfig.IS_NEW_ARCHITECTURE_ENABLED) {
      return null
    }
    // Old architecture fallback (throws UnsupportedOperationException)
    return if (name == PolygenModule.NAME) {
      PolygenModule(reactContext)
    } else {
      null
    }
  }

  override fun getReactModuleInfoProvider(): ReactModuleInfoProvider {
    return ReactModuleInfoProvider {
      val moduleInfos: MutableMap<String, ReactModuleInfo> = HashMap()
      val isNewArch: Boolean = BuildConfig.IS_NEW_ARCHITECTURE_ENABLED
      moduleInfos[PolygenModule.NAME] = ReactModuleInfo(
        PolygenModule.NAME,
        PolygenModule.NAME,
        false,    // canOverrideExistingModule
        false,    // needsEagerInit
        false,    // hasConstants
        isNewArch, // isCxxModule - only true for new arch C++ TurboModule
        isNewArch  // isTurboModule
      )
      moduleInfos
    }
  }
}
