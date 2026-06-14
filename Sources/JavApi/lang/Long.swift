/*
 * SPDX-FileCopyrightText: 2024 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

/// Java-like 64-bit long Integer type
public final class Long : Number {
  // Java long arithmetic wraps on overflow (two's complement) — use &+/&-/&*
  public static func *= (lhs: inout Long, rhs: Long) {
    lhs.value = lhs.value &* rhs.value
  }
  public static func += (lhs: inout Long, rhs: Long) {
    lhs.value = lhs.value &+ rhs.value
  }
  public static func -= (lhs: inout Long, rhs: Long) {
    lhs.value = lhs.value &- rhs.value
  }
  
  public let magnitude: Int64.Magnitude
  
  public static func - (lhs: Long, rhs: Long) -> Self {
    return .init(integerLiteral: lhs.value &- rhs.value)
  }
  
  public required init(integerLiteral value: Int64) {
    self.value = value
    self.magnitude = Int64.Magnitude(value)
  }

  /// Creates a `Long` wrapping the given value — mirrors Java autoboxing / `new Long(long)`.
  public convenience init(_ value: Int64) {
    self.init(integerLiteral: value)
  }

  /// Creates a `Long` from any `BinaryInteger` type (Int8, Int16, Int32, UInt8, UInt32, …).
  ///
  /// Mirrors Java's implicit widening conversion to `long`. For types wider than `Int64`
  /// the value is truncated, matching Java's narrowing cast semantics (`(long) value`).
  public convenience init<T: BinaryInteger>(_ source: T) {
    self.init(integerLiteral: Int64(truncatingIfNeeded: source))
  }

  /// - Returns: The wrapped `Int64` value.
  public func longValue() -> Int64 { value }

  public typealias Magnitude = Int64.Magnitude

  internal var value : Int64

  public required init?<T>(exactly source: T) where T : BinaryInteger {
    guard let v = Int64(exactly: source) else { return nil }
    self.value     = v
    self.magnitude = Int64.Magnitude(v)
  }
  
  public static func * (lhs: Long, rhs: Long) -> Self {
    return .init(integerLiteral: lhs.value &* rhs.value)
  }

  public static func + (lhs: Long, rhs: Long) -> Self {
    return .init(integerLiteral: lhs.value &+ rhs.value)
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
