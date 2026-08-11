/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: 0BSD
 */

extension java.util.logging {

  /// - Since: Java 1.4
  open class Level {

    nonisolated(unsafe) public static let OFF     : Level = Level("OFF",     Int.max, register: false)
    nonisolated(unsafe) public static let SEVERE  : Level = Level("SEVERE",  1000,    register: false)
    nonisolated(unsafe) public static let WARNING : Level = Level("WARNING", 900,     register: false)
    nonisolated(unsafe) public static let INFO    : Level = Level("INFO",    800,     register: false)
    nonisolated(unsafe) public static let CONFIG  : Level = Level("CONFIG",  700,     register: false)
    nonisolated(unsafe) public static let FINE    : Level = Level("FINE",    500,     register: false)
    nonisolated(unsafe) public static let FINER   : Level = Level("FINER",   400,     register: false)
    nonisolated(unsafe) public static let FINEST  : Level = Level("FINEST",  300,     register: false)
    nonisolated(unsafe) public static let ALL     : Level = Level("ALL",     Int.min, register: false)

    // Registry for user-defined levels, keyed by name and integer value string.
    // Protected by CrossPlatformMutex for thread safety.
    private static let _registryLock = CrossPlatformMutex(0)
    nonisolated(unsafe) private static var _registry: [String: Level] = [:]

    private var resourceBundleName : String?
    private var name : String
    private var value: Int

    /// Designated initialiser.  When `register` is `true` (the default for
    /// user-created levels) the level is added to the global registry so that
    /// `parse(_:)` can look it up by name or integer value.
    public init(_ theName: String, _ intValue: Int, register: Bool = true) {
      self.name  = theName
      self.value = intValue
      if register {
        Level._registryLock.withLock { _ in
          Level._registry[theName]          = self
          Level._registry[String(intValue)] = self
        }
      }
    }

    public convenience init(_ name: String, _ value: Int, _ resourceBundleName: String?) {
      self.init(name, value)
      self.resourceBundleName = resourceBundleName
    }

    open func getResourceBundleName() -> String? {
      return self.resourceBundleName
    }

    open func getName () -> String {
      return self.name
    }

    public func intValue() -> Int {
      return self.value
    }

    /// Parses a level name or integer string.
    ///
    /// Standard names (`OFF`, `SEVERE`, …) are matched first, then the
    /// user-defined level registry, and finally numeric values for which a
    /// standard level exists.  Throws `IllegalArgumentException` if the name
    /// is not recognised.
    ///
    /// - Since: Java 1.4
    public static func parse(_ name: String) throws -> Level {
      // 1. Standard names
      switch name {
      case "OFF":     return .OFF
      case "SEVERE":  return .SEVERE
      case "WARNING": return .WARNING
      case "INFO":    return .INFO
      case "CONFIG":  return .CONFIG
      case "FINE":    return .FINE
      case "FINER":   return .FINER
      case "FINEST":  return .FINEST
      case "ALL":     return .ALL
      default: break
      }

      // 2. User-defined levels by name
      var registered: Level? = nil
      _registryLock.withLock { _ in registered = _registry[name] }
      if let level = registered { return level }

      // 3. Numeric value — standard levels first, then registry, then synthetic
      if let intValue = Int(name) {
        switch intValue {
        case Int.max: return .OFF
        case Int.min: return .ALL
        case 1000:    return .SEVERE
        case 900:     return .WARNING
        case 800:     return .INFO
        case 700:     return .CONFIG
        case 500:     return .FINE
        case 400:     return .FINER
        case 300:     return .FINEST
        default:
          // Check registry by numeric string key
          var byValue: Level? = nil
          _registryLock.withLock { _ in byValue = _registry[name] }
          if let level = byValue { return level }
          // Return a synthetic level with the given value
          return Level(name, intValue, register: false)
        }
      }

      throw IllegalArgumentException("\(name) is not a valid Level")
    }
  }

}

extension java.util.logging.Level: Equatable {
  public static func == (_ lhs: java.util.logging.Level, _ rhs: java.util.logging.Level) -> Bool {
    lhs.intValue() == rhs.intValue()
  }
}
