/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension Float {

  /// The maximum value of `Float` type (Java Float.MAX_VALUE)
  ///
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  public static let MAX_VALUE = Float.greatestFiniteMagnitude

  /// Positive infinity (Java Float.POSITIVE_INFINITY)
  ///
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  public static let POSITIVE_INFINITY = Float.infinity

  /// Negative infinity (Java Float.NEGATIVE_INFINITY)
  ///
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  public static let NEGATIVE_INFINITY = -Float.infinity

  /// Not a Number (Java Float.NaN)
  ///
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  public static let NaN = Float.nan

  /// The smallest positive nonzero value of `Float` type (Java Float.MIN_VALUE)
  ///
  /// Note: Java's Float.MIN_VALUE is the smallest *positive* nonzero value, not the most negative.
  ///
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  public static let MIN_VALUE = Float.leastNonzeroMagnitude

  /// Maximum exponent for a finite float (Java Float.MAX_EXPONENT = 127)
  ///
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  public static let MAX_EXPONENT : Int = 127

  /// Minimum exponent for a normalized float (Java Float.MIN_EXPONENT = -126)
  ///
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  public static let MIN_EXPONENT : Int = -126

  /// The minimum normal value (Java Float.MIN_NORMAL)
  ///
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  public static let MIN_NORMAL = Float.leastNormalMagnitude

  /// Number of bits used to represent a float (Java Float.SIZE = 32)
  ///
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  public static let SIZE : Int = 32

  /// Number of bytes used to represent a float (Java Float.BYTES = 4)
  ///
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  public static let BYTES : Int = 4

  /// Parse the given String to a Float
  ///
  /// - Parameters:
  ///   - s: Float as String
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  public static func parseFloat(_ s: String?) throws -> Float {
    guard let s else {
      throw NullPointerException("In result of String is nil cannot parse as Float.")
    }
    return try parseFloat(s)
  }

  /// Parse the given String to a Float
  ///
  /// - Parameters:
  ///   - s: Float as String
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  public static func parseFloat(_ s: String) throws (NumberFormatException) -> Float {
    let trimmed = s.trim()
    if let result = Float(trimmed) {
      return result
    }
    throw NumberFormatException("NumberFormatException for input String \(s)")
  }

  /// Returns true if this Float value is NaN
  ///
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  public func isNaN() -> Bool {
    return self.isNaN
  }

  /// Returns true if this Float value is infinite
  ///
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  public func isInfinite() -> Bool {
    return self.isInfinite
  }

  /// Returns a Float instance representing the specified float value
  ///
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  public static func valueOf(_ s: String) throws -> Float {
    return try parseFloat(s)
  }

  /// Returns a Float instance representing the specified float value
  ///
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  public static func valueOf(_ f: Float) -> Float {
    return f
  }

  /// Returns the float value of this Float
  ///
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  public func floatValue() -> Float {
    return self
  }

  /// Returns the double value of this Float
  ///
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  public func doubleValue() -> Double {
    return Double(self)
  }

  /// Returns the int value of this Float (truncated toward zero)
  ///
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  public func intValue() -> Int {
    return Int(self)
  }

  /// Returns the long value of this Float (truncated toward zero)
  ///
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  public func longValue() -> Int64 {
    return Int64(self)
  }

  /// Returns a string representation of this Float
  ///
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  public static func toString(_ f: Float) -> String {
    return "\(f)"
  }

  /// Returns the bit representation of this float as an Int32 (Java Float.floatToIntBits)
  ///
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  public func floatToIntBits() -> Int32 {
    return self.bitPattern.toInt32()
  }

  /// Returns the float corresponding to the given Int32 bit pattern (Java Float.intBitsToFloat)
  ///
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  public static func intBitsToFloat(_ bits: Int32) -> Float {
    return Float(bitPattern: UInt32(bitPattern: bits))
  }

  /// Compare two float values
  ///
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  public static func compare(_ f1: Float, _ f2: Float) -> Int {
    if f1 < f2 { return -1 }
    if f1 > f2 { return 1 }
    return 0
  }
}

extension UInt32 {
  fileprivate func toInt32() -> Int32 {
    return Int32(bitPattern: self)
  }
}
