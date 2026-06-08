/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension Double {
  public static let MAX_VALUE = Double.greatestFiniteMagnitude
  public static let MIN_VALUE = Double.leastNonzeroMagnitude
  public static let POSITIVE_INFINITY = Double.infinity
  public static let NEGATIVE_INFINITY = -Double.infinity
  public static let NaN = Double.nan

  /// Returns a string representation of the given double value
  ///
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  public static func toString(_ d: Double) -> String {
    return "\(d)"
  }

  /// Returns a Double instance representing the specified String value
  ///
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  public static func valueOf(_ s: String) throws -> Double {
    return try parseDouble(s)
  }

  /// Returns a Double instance representing the specified double value
  ///
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  public static func valueOf(_ d: Double) -> Double {
    return d
  }

  /// Returns true if the specified double value is NaN (static version)
  ///
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  public static func isNaN(_ v: Double) -> Bool {
    return v.isNaN
  }

  /// Returns true if this Double value is NaN
  ///
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  public func isNaN() -> Bool {
    return self.isNaN
  }

  /// Returns true if this Double value is infinite
  ///
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  public func isInfinite() -> Bool {
    return self.isInfinite
  }

  /// Returns the double value of this Double
  ///
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  public func doubleValue() -> Double {
    return self
  }

  /// Returns the float value of this Double
  ///
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  public func floatValue() -> Float {
    return Float(self)
  }

  /// Returns the int value of this Double (truncated toward zero)
  ///
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  public func intValue() -> Int {
    return Int(self)
  }

  /// Returns the long value of this Double (truncated toward zero)
  ///
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  public func longValue() -> Int64 {
    return Int64(self)
  }

  public static func parseDouble (_ s : String?) throws /*(RuntimeException) <- CompilerError */ -> Double {
    if let s {
      return try parseDouble(s)
    }
    throw NullPointerException("In result of String is nil cannot parse as Double.")
  }
  /// Parse the fiven String to a Double
  ///
  /// - Parameters:
  ///   - s Double as String
  public static func parseDouble (_ s : String) throws (NumberFormatException) -> Double {
    let trimmed = s.trim()
    guard trimmed.components(separatedBy: ".").count == 2 else {
      throw NumberFormatException("In result of String contains multiple points cannot parse as Double.")
    }
    let result = Double(trimmed)
    if let result {
      return result
    }
    throw NumberFormatException ("NumberFormatException for input String \(s)")
  }
} // EOT
