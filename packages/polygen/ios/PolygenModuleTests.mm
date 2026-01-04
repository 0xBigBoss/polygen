#import <XCTest/XCTest.h>
#import <React/RCTBridge.h>
#import <ReactCommon/RCTTurboModule.h>
#import "PolygenModule.h"
#import <ReactNativePolygen/WasmTests.h>  // For polygen::tests::MockCallInvoker

@interface PolygenModuleTests : XCTestCase
@end

@implementation PolygenModuleTests

- (void)testModuleName {
  XCTAssertEqualObjects([PolygenModule moduleName], @"Polygen");
}

- (void)testRequiresMainQueueSetup {
  XCTAssertFalse([PolygenModule requiresMainQueueSetup]);
}

- (void)testGetTurboModuleReturnsNonNull {
  // Use the existing MockCallInvoker from WasmTests.h
  auto callInvoker = std::make_shared<polygen::tests::MockCallInvoker>();

  // Initialize all InitParams fields to safe defaults (C++17-compatible)
  facebook::react::ObjCTurboModule::InitParams params;
  params.moduleName = "Polygen";
  params.instance = nil;
  params.jsInvoker = callInvoker;
  params.nativeMethodCallInvoker = nullptr;
  params.isSyncModule = false;
  params.shouldVoidMethodsExecuteSync = false;

  PolygenModule *module = [[PolygenModule alloc] init];
  auto turboModule = [module getTurboModule:params];

  XCTAssertTrue(turboModule != nullptr, @"getTurboModule should return a valid C++ module");
}

@end
