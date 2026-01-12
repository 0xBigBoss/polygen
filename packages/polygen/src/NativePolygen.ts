import type { TurboModule } from 'react-native';
import { TurboModuleRegistry } from 'react-native';
import type { UnsafeObject } from 'react-native/Libraries/Types/CodegenTypes';

export type NativeImportObject = UnsafeObject;
export type UnsafeArrayBuffer = UnsafeObject;

/**
 * WebAssembly type
 */
export enum NativeType {
  I32 = 0,
  U32 = 1,
  I64 = 2,
  U64 = 3,
  F32 = 4,
  F64 = 5,
}

/**
 * WebAssembly Table element type
 */
export enum NativeTableElementType {
  AnyFunc = 0,
  ExternRef = 1,
}

/**
 * @spec https://webassembly.github.io/spec/js-api/index.html#modules
 */
export enum NativeSymbolKind {
  Function = 'function',
  Table = 'table',
  Memory = 'memory',
  Global = 'global',
}

/**
 * Describes a single export from a module.
 *
 * Returned from the call to `WebAssembly.Module.exports()`.
 *
 * @spec https://webassembly.github.io/spec/js-api/index.html#modules
 */
export interface ModuleExportDescriptor {
  /**
   * Name of the exported symbol.
   */
  readonly name: string;

  /**
   * Exported symbol kind.
   */
  readonly kind: NativeSymbolKind;
}

/**
 * Describes a single import from a module.
 *
 * Returned from the call to `WebAssembly.Module.imports()`.
 *
 * @spec https://webassembly.github.io/spec/js-api/index.html#modules
 */
export interface ModuleImportDescriptor {
  /**
   * Name of the module to import from.
   */
  readonly module: string;

  /**
   * Name of the imported symbol.
   */
  readonly name: string;

  /**
   * Imported symbol kind.
   */
  readonly kind: NativeSymbolKind;
}

/**
 * Representation of internal precomputed module metadata.
 */
export interface InternalModuleMetadata {
  /**
   * All module imports.
   */
  readonly imports: ModuleImportDescriptor[];

  /**
   * All module exports.
   */
  readonly exports: ModuleExportDescriptor[];
}

export interface NativeGlobalDescriptor {
  readonly type: NativeType;
  readonly isMutable: boolean;
}

export interface NativeTableDescriptor {
  readonly initialSize: number;
  readonly maxSize?: number;
  readonly element: NativeTableElementType;
}

/**
 * Opaque handle representing WebAssembly Module.
 */
export type OpaqueModuleNativeHandle = UnsafeObject;

/**
 * Opaque handle representing WebAssembly Module instance.
 */
export type OpaqueModuleInstanceNativeHandle = UnsafeObject;

/**
 * Opaque handle representing WebAssembly memory instance.
 */
export type OpaqueMemoryNativeHandle = UnsafeObject;

/**
 * Opaque handle representing WebAssembly global instance.
 */
export type OpaqueGlobalNativeHandle = UnsafeObject;

/**
 * Opaque handle representing WebAssembly Table instance.
 */
export type OpaqueTableNativeHandle = UnsafeObject;

export interface Spec extends TurboModule {
  copyNativeHandle(holder: UnsafeObject, from: UnsafeObject): boolean;

  // Modules
  loadModule(
    holder: OpaqueModuleNativeHandle,
    moduleData: UnsafeArrayBuffer
  ): InternalModuleMetadata;
  unloadModule(module: OpaqueModuleNativeHandle): void;
  getModuleMetadata(module: OpaqueModuleNativeHandle): InternalModuleMetadata;

  // Module instances
  createModuleInstance(
    holder: OpaqueModuleInstanceNativeHandle,
    mod: OpaqueModuleNativeHandle,
    importObject: NativeImportObject
  ): void;
  destroyModuleInstance(instance: OpaqueModuleInstanceNativeHandle): void;

  // Memory
  createMemory(
    holder: OpaqueMemoryNativeHandle,
    initial: number,
    maximum?: number
  ): void;
  getMemoryBuffer(instance: OpaqueMemoryNativeHandle): UnsafeArrayBuffer;
  growMemory(instance: OpaqueMemoryNativeHandle, delta: number): void;

  // Globals
  createGlobal(
    holder: OpaqueGlobalNativeHandle,
    descriptor: NativeGlobalDescriptor,
    initialValue: number
  ): void;
  getGlobalValue(instance: OpaqueGlobalNativeHandle): number;
  setGlobalValue(instance: OpaqueGlobalNativeHandle, newValue: number): void;

  // Tables
  createTable(
    holder: OpaqueTableNativeHandle,
    descriptor: NativeTableDescriptor,
    initial?: unknown
  ): void;
  growTable(instance: OpaqueTableNativeHandle, delta: number): void;
  getTableElement(instance: OpaqueTableNativeHandle, index: number): unknown;
  setTableElement(
    instance: OpaqueTableNativeHandle,
    index: number,
    value: unknown
  ): void;
  getTableSize(instance: OpaqueTableNativeHandle): number;
}

// Lazy loading wrapper to avoid module-level getEnforcing call
// This prevents errors when the module is imported but TurboModules aren't ready
let _nativeModule: Spec | null = null;
let _loadAttempted = false;

// Single call site for TurboModuleRegistry.get to satisfy RN codegen
// (codegen requires exactly one module load per spec file)
function loadModule(): void {
  if (!_loadAttempted) {
    _loadAttempted = true;
    _nativeModule = TurboModuleRegistry.get<Spec>('Polygen');
  }
}

function getNativeModule(): Spec {
  loadModule();
  if (!_nativeModule) {
    throw new Error(
      '[Polygen] TurboModule not available. ' +
        'Ensure the native module is properly linked and the app was rebuilt.'
    );
  }
  return _nativeModule;
}

/**
 * Check if the Polygen TurboModule is available.
 * Use this to conditionally enable WebAssembly features.
 */
export function isPolygenAvailable(): boolean {
  loadModule();
  return _nativeModule !== null;
}

// Export a proxy that lazily loads the native module on first property access
const lazyProxy = new Proxy({} as Spec, {
  get(_target, prop) {
    const module = getNativeModule();
    const value = module[prop as keyof Spec];
    if (typeof value === 'function') {
      return value.bind(module);
    }
    return value;
  },
});

export default lazyProxy;
