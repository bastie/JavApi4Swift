/*
 * SPDX-FileCopyrightText: 2024 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

///
/// ## Sample for port Java to Swift without [JavApi⁴Swift](https://github.com/bastie/JavApi4Swift)
///
/// Replace ``Boolean`` type of Java with ``Bool`` of Swift
///
/// - Since: JavaApi &gt; 0.16.0 (Java 1.0)
/// - Note: In different to Java implementation of ``Bool`` is as struct a value (like) type
typealias Boolean = Bool

extension Boolean {
  
  /// true value
  /// - Since: JavaApi &gt; 0.16.0 (Java 1.0)
  public static let TRUE = Bool.init (true)
  /// false value
  /// - Since: JavaApi &gt; 0.16.0 (Java 1.0)
  public static let FALSE = Bool.init (false)

  /// Create a new `true` Boolean value if parameter in lowercase equals to `true` otherwise `false` Boolean value
  /// - Parameter value true or not true
  /// - Since: JavaApi &gt; 0.16.0 (Java 1.0)
  public init (_ value : String?) {
    self.init (value?.lowercased () == "true")
  }
  
  /// The value itself
  /// - Since: JavaApi &gt; 0.16.0 (Java 1.0)
  public func boolValue () -> Bool {
    return self
  }
  
  /// Returns if values of self and the other are same if parameter is not ``nil``
  /// - Parameter other the value to compare with self
  /// - Returns true if `other` not nil, is ``Bool`` and have same value
  /// - Since: JavaApi &gt; 0.16.0 (Java 1.0)
  public func equals (_ other: Any?) -> Bool {
    if let other = other as? Bool {
      return self == other
    }
    return false
  }
  
  /// Returns true if the system property called with `systemPropertyName` parameter is true.
  /// If parameter `JavaVersion` is not set, system property `java.expected.version`is check agains value `1.0`.
  /// - Parameter systemPropertyName to check content
  /// - Parameter for JavaVersion with value `1.0` make check case sensitive.
  /// - Note: Java 1.0 is case sensitive. Java 1.1 and higher are case insensitive. By default Java 1.1 algorithm is used.
  public static func getBoolean (_ systemPropertyName: String?, for JavaVersion : String = "undefined") -> Bool {
    if let systemPropertyName {
      let systemPropertyValue = System.getProperty(systemPropertyName, "false")
#if Java10Compiler // compiler or runtime check of case sensitive system property value
      return "true" == systemPropertyValue
#elseif JavaOtherCompiler
      return "true" == systemPropertyValue
#else // at runtime check
      switch JavaVersion {
      case "1.0":
        return "true" == systemPropertyValue
      case "undefined":
        let isJava10 = System.getProperty("java.expected.version","undefined") == "1.0"
        return isJava10 ? "true" == systemPropertyValue : "true" == systemPropertyValue.lowercased ()
      default:
        return "true" == systemPropertyValue.lowercased ()
      }
#endif // EO compiler or runtime check of case sensitive system property value
    }
    return false
  }

  /// Returns the hashcode value
  /// - Returns hash value
  /// - Since: JavaApi &gt; 0.16.0 (Java 1.0)
  public func hashcode () -> Int {
    return self.hashValue
  }
  
  /// Returns the value as String
  /// - Returns `true` only if true otherwise `false`
  public func toString () -> String {
    return self ? "true" : "false"
  }
  
  /// Creates new value in dependency of given value
  /// - Parameter value with case insensitive true or other
  /// - Returns `true` if given case insensitive value is not nil and equals to `true` otherwise `false`
  public static func valueOf (_ value: String?) -> Bool {
    return value?.lowercased () == "true"
  }
}
