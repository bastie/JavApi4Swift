/*
 * SPDX-FileCopyrightText: 2023, 2024 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Synchronization

// Da die Property-Umsetzung schnell unübersichtlich wird (vgl. .net Port) Auslagerung in eine eigene Quelldatei
extension System {

  public static func getProperty (_ key : String, _ resultIfMissing : String?) throws -> String? {
    guard !key.isEmpty() else {
      throw IllegalArgumentException("key cannot be empty");
    }
    return _propertiesStorage.withLock { $0[key] } ?? resultIfMissing
  }

  public static func getProperty (_ name : String) throws -> String? {
    return try System.getProperty(name, nil)
  }

  public static func setProperty (_ name : String, _ value : String) throws {
    guard !name.isEmpty() else {
      throw IllegalArgumentException("name cannot be empty")
    }
    // Javadoc tells you cannot change this at runtime
    guard name != "java.locale.useOldISOCodes" else {
      return
    }
    _propertiesStorage.withLock { $0[name] = value }
  }

  /// Remove the property with given name.
  ///
  /// - Since: JavaApi &gt; 0.20.0 (Java 1.5)
  public static func clearProperty (_ name : String) throws {
    guard !name.isEmpty() else {
      throw IllegalArgumentException("name cannot be empty")
    }
    _ = _propertiesStorage.withLock { $0.removeValue(forKey: name) }
  }

  // **not private** : In result of Swiftify
  /// A dictionary snapshot with all supported properties and the default values used in JavApi
  static var SYSTEM_PROPERTIES : [String:String] {
    _propertiesStorage.withLock { $0 }
  }

  /// Returns all system properties as a `java.util.Properties` object.
  ///
  /// The returned object is a snapshot — changes to it do not affect the
  /// underlying property store. Use ``setProperty(_:_:)`` to modify properties.
  ///
  /// - Since: JavaApi (Java 1.0)
  public static func getProperties() -> java.util.Properties {
    let snapshot = _propertiesStorage.withLock { $0 }
    let props = java.util.Properties()
    for (key, value) in snapshot {
      props.setProperty(key, value)
    }
    return props
  }

  /// Thread-safe storage for system properties backed by Synchronization.Mutex
  private static let _propertiesStorage: Mutex<[String:String]> = {
    var result : [String:String] = [
    "path.separator" : _SYSTEM_NAME.contains("Windows") ? ";" : _SYSTEM_NAME.contains("Wasm") ? "[A-Za-z][A-Za-z][A-Za-z][A-Za-z]://" : ":",
    "line.separator" : _SYSTEM_NAME.contains("Windows") ? "\r\n" : _SYSTEM_NAME.contains("Wasm") ? "" : "\n",
    "os.name" : _SYSTEM_NAME,
    "file.separator" : _SYSTEM_NAME.contains("Windows") ? "\\" : _SYSTEM_NAME.contains("Wasm") ? "/" : "/",
    "native.encoding" : "utf-8",
    "stdout.encoding" : "utf-8",
    "stderr.encoding" : "utf-8",
    "java.vendor" : "JavApi⁴Swift",
    "java.expected.version" : "\(Int.max)", // (extension) can be set to special Java version behavior. For example Java 1.0 behavior in Boolean.getBoolean.
    ]
    // see java.util.Locale.getLanguageCode
    if let version = result["java.expected.version"].flatMap(Int.init), version < 17 {
      result["java.locale.useOldISOCodes"] = "true"
    }
    return Mutex(result)
  }()
  
#if os(iOS)
  fileprivate static let _SYSTEM_NAME = "iOS"
#elseif os(macOS)
  fileprivate static let _SYSTEM_NAME = "macOS"
#elseif os(OSX)
  fileprivate static let _SYSTEM_NAME = "macOS"
#elseif os(Linux)
  fileprivate static let _SYSTEM_NAME = "Linux"
#elseif os(Windows)
  fileprivate static let _SYSTEM_NAME = "Windows"
#elseif os(PS4)
  fileprivate static let _SYSTEM_NAME = "PS4"
#elseif os(WASI)
  fileprivate static let _SYSTEM_NAME = "Wasm"
#elseif os(Android)
  fileprivate static let _SYSTEM_NAME = "Android"
#elseif os(FreeBSD)
  fileprivate static let _SYSTEM_NAME = "FreeBSD"
#else
  fileprivate static let _SYSTEM_NAME = "other"
#endif
}

