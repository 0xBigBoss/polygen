package com.callstack.polygen

import com.facebook.react.TurboReactPackage
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.NativeModule
import com.facebook.react.module.model.ReactModuleInfoProvider
import com.facebook.react.module.model.ReactModuleInfo

class PolygenPackage : TurboReactPackage() {
  override fun getModule(name: String, reactContext: ReactApplicationContext): NativeModule? {
    return if (name == PolygenModule.NAME) {
      PolygenModule(reactContext)
    } else {
      null
    }
  }

  override fun getReactModuleInfoProvider(): ReactModuleInfoProvider {
    return ReactModuleInfoProvider {
      val moduleInfos: MutableMap<String, ReactModuleInfo> = HashMap()
      val isTurboModule: Boolean = BuildConfig.IS_NEW_ARCHITECTURE_ENABLED
      moduleInfos[PolygenModule.NAME] = ReactModuleInfo(
        PolygenModule.NAME,
        PolygenModule.NAME,
        false,  // canOverrideExistingModule
        false,  // needsEagerInit
        false,  // hasConstants
        false,  // isCxxModule
        isTurboModule // isTurboModule
      )
      moduleInfos
    }
  }
}
