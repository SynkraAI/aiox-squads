# Task: native-module-setup

```yaml
id: native-module-setup
version: "1.0.0"
title: "Native Module Setup (Turbo Module / Fabric)"
description: >
  Sets up a native module using the New Architecture (Turbo Modules
  and Fabric Components). Defines the native API interface with
  codegen specs, implements iOS (Swift) and Android (Kotlin) modules,
  bridges to the JavaScript layer, and tests on both platforms.
elicit: false
owner: mobile-eng
executor: mobile-eng
outputs:
  - Codegen spec (TypeScript interface)
  - iOS native module implementation (Swift)
  - Android native module implementation (Kotlin)
  - JavaScript bridge layer
  - Cross-platform test verification
```

---

## When This Task Runs

This task runs when:
- A feature requires access to native platform APIs not available in React Native core
- An existing Bridge Module needs to be migrated to the New Architecture (Turbo Module)
- Performance-critical native code needs direct JS ↔ native communication
- A third-party native SDK needs to be wrapped for React Native usage
- `*native-module` or `*turbo-module` is invoked

This task does NOT run when:
- The feature can be accomplished with existing React Native APIs or Expo modules
- Only JavaScript code is needed (no native bridge)
- The task is about native UI components (Fabric Component, different task)

---

## Execution Steps

### Step 1: Define Native API Interface

Design the TypeScript interface that will serve as the contract between JavaScript and native code.

```typescript
// NativeDeviceSensors.ts
import type { TurboModule } from 'react-native';
import { TurboModuleRegistry } from 'react-native';

export interface Spec extends TurboModule {
  // Synchronous methods (fast, blocking)
  getDeviceId(): string;
  isFeatureSupported(feature: string): boolean;

  // Asynchronous methods (non-blocking, returns Promise)
  getCurrentLocation(): Promise<{
    latitude: number;
    longitude: number;
    accuracy: number;
  }>;

  // Methods with callbacks
  startMonitoring(interval: number): void;
  stopMonitoring(): void;

  // Event emitter support
  addListener(eventName: string): void;
  removeListeners(count: number): void;
}

export default TurboModuleRegistry.getEnforcing<Spec>(
  'DeviceSensors'
);
```

Design principles for the interface:
- Keep the API surface minimal — only expose what JS actually needs
- Use primitive types where possible (string, number, boolean) for codegen compatibility
- Use `Object` type for complex structures (codegen will generate native equivalents)
- Distinguish sync vs async methods intentionally (sync blocks the JS thread)
- Include event emitter methods if the module sends events to JS

**Output:** TypeScript spec file for codegen.

### Step 2: Create Codegen Spec

Configure the codegen to generate native interfaces from the TypeScript spec.

In `package.json`:
```json
{
  "codegenConfig": {
    "name": "DeviceSensorsSpec",
    "type": "modules",
    "jsSrcsDir": "src",
    "android": {
      "javaPackageName": "com.app.devicesensors"
    }
  }
}
```

Run codegen to generate:
- **iOS:** `DeviceSensorsSpec.h` — Objective-C++ protocol
- **Android:** `DeviceSensorsSpec.java` — Java abstract class

Verify generated files:
- Check that all methods from the TypeScript spec appear in the generated native interfaces
- Verify type mappings (string → NSString/String, number → double/Double, boolean → BOOL/Boolean)
- Check that Promise-based methods generate correct callback signatures

**Output:** Codegen configuration and generated native interfaces.

### Step 3: Implement iOS Module (Swift)

Implement the native module for iOS using Swift with an Objective-C++ bridge.

```swift
// DeviceSensorsModule.swift
import Foundation
import CoreLocation

@objc(DeviceSensors)
class DeviceSensorsModule: NSObject {

  @objc static func requiresMainQueueSetup() -> Bool {
    return false // Set true only if initialization must happen on main thread
  }

  @objc func getDeviceId() -> String {
    return UIDevice.current.identifierForVendor?.uuidString ?? ""
  }

  @objc func isFeatureSupported(_ feature: String) -> Bool {
    switch feature {
    case "location":
      return CLLocationManager.locationServicesEnabled()
    default:
      return false
    }
  }

  @objc func getCurrentLocation(
    _ resolve: @escaping RCTPromiseResolveBlock,
    rejecter reject: @escaping RCTPromiseRejectBlock
  ) {
    // Implement location fetching with CLLocationManager
    // Resolve with dictionary matching the TypeScript return type
  }

  @objc func startMonitoring(_ interval: Double) {
    // Start native monitoring with specified interval
  }

  @objc func stopMonitoring() {
    // Stop native monitoring
  }
}
```

The Objective-C++ bridge file (`DeviceSensorsModule.mm`):
```objc
#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(DeviceSensors, NSObject)
RCT_EXTERN_METHOD(getDeviceId)
RCT_EXTERN_METHOD(isFeatureSupported:(NSString *)feature)
RCT_EXTERN_METHOD(getCurrentLocation:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(startMonitoring:(double)interval)
RCT_EXTERN_METHOD(stopMonitoring)
@end
```

iOS-specific considerations:
- Handle permissions (Info.plist entries, runtime permission requests)
- Thread safety — use `DispatchQueue` for background work
- Memory management — weak references to avoid retain cycles
- Lifecycle handling — respond to app backgrounding/foregrounding

**Output:** Swift module implementation with Objective-C++ bridge.

### Step 4: Implement Android Module (Kotlin)

Implement the native module for Android using Kotlin.

```kotlin
// DeviceSensorsModule.kt
package com.app.devicesensors

import com.facebook.react.bridge.*
import com.facebook.react.module.annotations.ReactModule

@ReactModule(name = DeviceSensorsModule.NAME)
class DeviceSensorsModule(
  reactContext: ReactApplicationContext
) : ReactContextBaseJavaModule(reactContext) {

  companion object {
    const val NAME = "DeviceSensors"
  }

  override fun getName(): String = NAME

  @ReactMethod(isBlockingSynchronousMethod = true)
  fun getDeviceId(): String {
    return android.provider.Settings.Secure.getString(
      reactApplicationContext.contentResolver,
      android.provider.Settings.Secure.ANDROID_ID
    )
  }

  @ReactMethod(isBlockingSynchronousMethod = true)
  fun isFeatureSupported(feature: String): Boolean {
    return when (feature) {
      "location" -> {
        val locationManager = reactApplicationContext
          .getSystemService(Context.LOCATION_SERVICE) as LocationManager
        locationManager.isProviderEnabled(LocationManager.GPS_PROVIDER)
      }
      else -> false
    }
  }

  @ReactMethod
  fun getCurrentLocation(promise: Promise) {
    // Implement location fetching
    // Resolve with WritableMap matching TypeScript return type
    val result = Arguments.createMap().apply {
      putDouble("latitude", 0.0)
      putDouble("longitude", 0.0)
      putDouble("accuracy", 0.0)
    }
    promise.resolve(result)
  }

  @ReactMethod
  fun startMonitoring(interval: Double) {
    // Start native monitoring
  }

  @ReactMethod
  fun stopMonitoring() {
    // Stop native monitoring
  }
}
```

Register the module in a Package:
```kotlin
// DeviceSensorsPackage.kt
class DeviceSensorsPackage : ReactPackage {
  override fun createNativeModules(
    reactContext: ReactApplicationContext
  ): List<NativeModule> {
    return listOf(DeviceSensorsModule(reactContext))
  }

  override fun createViewManagers(
    reactContext: ReactApplicationContext
  ): List<ReactViewManager<*, *>> = emptyList()
}
```

Android-specific considerations:
- Handle runtime permissions (ActivityCompat, permission callbacks)
- Thread management — use coroutines or ExecutorService for background work
- Lifecycle awareness — use `LifecycleEventListener`
- Handle configuration changes and process death

**Output:** Kotlin module implementation with package registration.

### Step 5: Bridge to JS Layer

Create the JavaScript wrapper that provides a clean API to React components.

```typescript
// useDeviceSensors.ts
import { useEffect, useCallback } from 'react';
import { NativeEventEmitter, Platform } from 'react-native';
import NativeDeviceSensors from './NativeDeviceSensors';

const eventEmitter = new NativeEventEmitter(NativeDeviceSensors);

export function useDeviceSensors() {
  const getDeviceId = useCallback(() => {
    return NativeDeviceSensors.getDeviceId();
  }, []);

  const getCurrentLocation = useCallback(async () => {
    return NativeDeviceSensors.getCurrentLocation();
  }, []);

  const startMonitoring = useCallback((interval: number) => {
    NativeDeviceSensors.startMonitoring(interval);
  }, []);

  const stopMonitoring = useCallback(() => {
    NativeDeviceSensors.stopMonitoring();
  }, []);

  return { getDeviceId, getCurrentLocation, startMonitoring, stopMonitoring };
}
```

Bridge layer responsibilities:
- Provide TypeScript types for all return values
- Handle platform differences transparently
- Add error handling and fallback behavior
- Manage event subscriptions and cleanup
- Provide React hooks for easy consumption

**Output:** JavaScript bridge with TypeScript types and React hooks.

### Step 6: Test on Both Platforms

Verify the native module works correctly on iOS and Android.

**Functional testing:**
- Call each method from JavaScript and verify return values
- Test async methods resolve/reject correctly
- Test event emission from native to JavaScript
- Test edge cases (null values, empty strings, out-of-range numbers)

**Platform-specific testing:**
- iOS: Test in Simulator and on physical device
- Android: Test in Emulator and on physical device
- Verify permissions flow works on both platforms
- Test background/foreground transitions

**Integration testing:**
- Use the module from a real React component
- Verify no memory leaks (start/stop monitoring cycles)
- Test rapid successive calls
- Test concurrent calls from multiple components

**Output:** Test results for both platforms with pass/fail for each method.

---

## Quality Criteria

- The codegen spec must exactly match the native implementations
- Both iOS and Android must implement all methods from the spec
- Synchronous methods must only be used for fast, non-blocking operations
- Error handling must be present for all async operations
- The module must be testable on both platforms from a single JavaScript API

---

*Squad Apex — Native Module Setup Task v1.0.0*

---

## Quality Gate

```yaml
gate:
  id: QG-native-module-setup
  blocker: true
  criteria:
    - "All outputs listed in YAML header must be produced"
    - "Codegen spec must exactly match the native implementations on both platforms"
    - "Both iOS (Swift) and Android (Kotlin) must implement all methods from the spec"
    - "Error handling must be present for all async operations"
    - "Module must be tested on both platforms with pass/fail for each method"
  on_fail: "BLOCK — return to executor with specific gaps listed"
  on_pass: "Mark task complete, deliver outputs to handoff target"
```

---

## Handoff

| Field | Value |
|-------|-------|
| Delivers to | `@qa-xplatform` or `@apex-lead` |
| Artifact | Native module with codegen spec, iOS/Android implementations, JS bridge, and test results |
| Next action | Validate cross-platform behavior via `cross-platform-test-setup` or integrate into the application |
