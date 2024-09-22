/*
 * SPDX-FileCopyrightText: 2023, 2024 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

// Da die Property-Umsetzung schnell unübersichtlich wird (vgl. .net Port) Auslagerung in eine eigene Quelldatei
extension System {
  
  public static func getProperty (_ key : String, _ resultIfMissing : String?) throws -> String? {
    guard !key.isEmpty() else {
      throw Throwable.IllegalArgumentException("key cannot be empty");
    }
    if SYSTEM_PROPERTIES.keys.contains(key) {
      return SYSTEM_PROPERTIES[key]
    }
    return resultIfMissing
  }
  
  public static func getProperty (_ name : String) throws -> String? {
    return try System.getProperty(name, nil)
  }

  // **not private** : In result of Swiftify
  /// An dictionary with all supported properties and the default value used in JavApi
  static let SYSTEM_PROPERTIES : [String:String] = [
    "path.separator" : _SYSTEM_NAME.contains("Windows") ? ";" : _SYSTEM_NAME.contains("Wasm") ? "[A-Za-z][A-Za-z][A-Za-z][A-Za-z]://" : ":",
    "line.separator" : _SYSTEM_NAME.contains("Windows") ? "\n\r" : _SYSTEM_NAME.contains("Wasm") ? "" : "\n",
    "os.name" : _SYSTEM_NAME,
    "file.separator" : _SYSTEM_NAME.contains("Windows") ? "\\" : _SYSTEM_NAME.contains("Wasm") ? "/" : "/",
    "native.encoding" : "utf-8",
    "stdout.encoding" : "utf-8",
    "stderr.encoding" : "utf-8",
    "java.vendor" : "JavApi⁴Swift",
    "java.expected.version" : "\(UInt64.max)" // (extension) can be set to special Java version behavior. For example Java 1.0 behavior in Boolean.getBoolean.
  ]
  
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
#else
  fileprivate static let _SYSTEM_NAME = "other"
#endif
}

