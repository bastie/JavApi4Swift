/*
 * SPDX-FileCopyrightText: 2024 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

/// Java-like 64-bit long Integer type
public final class Long : Number {
  public static func *= (lhs: inout Long, rhs: Long) {
    lhs.value *= rhs.value
  }
  
  public let magnitude: Int64.Magnitude
  
  public static func - (lhs: Long, rhs: Long) -> Self {
    return .init(exactly: lhs.value - rhs.value)!
  }
  
  public required init(integerLiteral value: Int64) {
    self.value = value
    self.magnitude = Int64.Magnitude(value)
  }
  
  public typealias Magnitude = Int64.Magnitude
  
  internal var value : Int64
  
  public required init?<T>(exactly source: T) where T : BinaryInteger {
    self.value = Int64(exactly: source)!
    self.magnitude = Int64.Magnitude(self.value)
  }
  
  public static func * (lhs: Long, rhs: Long) -> Self {
    return .init(exactly: lhs.value * rhs.value)!
  }
  
  public static func + (lhs: Long, rhs: Long) -> Self {
    return .init(exactly: lhs.value + rhs.value)!
  }
  
  public typealias IntegerLiteralType = Int64
  
  public static func == (lhs: Long, rhs: Long) -> Bool {
    return lhs.value == rhs.value
  }
  
  
  public static let MAX_VALUE = Int64.max
  public static let MIN_VALUE = Int64.min

  /// Returns a string representation of the long value in the given radix.
  ///
  /// Matches Java's `Long.toString(long i, int radix)` behaviour:
  /// - Radix is clamped to 2…36; values outside that range fall back to radix 10.
  /// - Negative values get a leading minus sign.
  ///
  /// - Parameters:
  ///   - i: The long value to convert.
  ///   - radix: The base to use (2–36).
  /// - Returns: String representation in the given radix.
  ///
  /// - Since: JavaApi &gt; 0.19.1 (Java 1.0)
  public static func toString (_ i : Int64, _ radix : Int) -> String {
    let r = (radix < 2 || radix > 36) ? 10 : radix
    return String(i, radix: r, uppercase: false)
  }
  
  public static func numberOfLeadingZeros(_ number : long) -> Int {
    return Int64.numberOfLeadingZeros(long: number)
  }
  
  public static func numberOfTrailingZeros (_ number : long) -> Int {
    return Int64.numberOfTrailingZeros(long: number)
  }
}
