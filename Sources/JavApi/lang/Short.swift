/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

/// Java-like 16-bit signed integer wrapper type.
///
/// Mirrors Java's `java.lang.Short`: a `final` class (reference type) that boxes an `Int16` value.
/// Conforms to ``Number`` (`Numeric`) analogous to `Integer` and `Long`.
///
/// - Since: Java 1.1
public final class Short: Number, @unchecked Sendable {

  internal var value: Int16
  public let magnitude: Int16.Magnitude

  // MARK: - ExpressibleByIntegerLiteral (required by Numeric)
  public typealias IntegerLiteralType = Int16

  /// Required by `ExpressibleByIntegerLiteral` — the label `integerLiteral` is
  /// mandated by the Swift compiler and cannot be replaced with `_`.
  public required init(integerLiteral value: Int16) {
    self.value     = value
    self.magnitude = value.magnitude
  }

  /// Wraps a Swift `Int16` as a Java-like `Short` — mirrors Java autoboxing / `new Short(short)`.
  public init(_ value: Int16) {
    self.value     = value
    self.magnitude = value.magnitude
  }

  /// Creates a `Short` from any `BinaryInteger` type (Int8, Int32, UInt8, UInt16, …).
  ///
  /// Mirrors Java's implicit widening/narrowing conversion to `short`.
  /// Values wider than 16 bits are truncated (`truncatingIfNeeded`), matching
  /// Java's narrowing cast semantics (`(short) value`).
  public init<T: BinaryInteger>(_ source: T) {
    let v          = Int16(truncatingIfNeeded: source)
    self.value     = v
    self.magnitude = v.magnitude
  }

  // MARK: - Numeric requirements
  public typealias Magnitude = Int16.Magnitude

  public required init?<T>(exactly source: T) where T: BinaryInteger {
    guard let v = Int16(exactly: source) else { return nil }
    self.value     = v
    self.magnitude = v.magnitude
  }

  public static func + (lhs: Short, rhs: Short) -> Self {
    return .init(integerLiteral: lhs.value &+ rhs.value)
  }
  public static func - (lhs: Short, rhs: Short) -> Self {
    return .init(integerLiteral: lhs.value &- rhs.value)
  }
  public static func * (lhs: Short, rhs: Short) -> Self {
    return .init(integerLiteral: lhs.value &* rhs.value)
  }
  public static func *= (lhs: inout Short, rhs: Short) {
    lhs.value = lhs.value &* rhs.value
  }
  public static func += (lhs: inout Short, rhs: Short) {
    lhs.value = lhs.value &+ rhs.value
  }
  public static func -= (lhs: inout Short, rhs: Short) {
    lhs.value = lhs.value &- rhs.value
  }
  public static func == (lhs: Short, rhs: Short) -> Bool {
    return lhs.value == rhs.value
  }

  // MARK: - Number methods
  /// - Returns: The wrapped `Int16` value.
  public func shortValue() -> Int16  { value }
  /// - Returns: The value widened to `Int`.
  public func intValue() -> Int      { Int(value) }
  /// - Returns: The value widened to `Int64`.
  public func longValue() -> Int64   { Int64(value) }
  /// - Returns: The value as `Float`.
  public func floatValue() -> Float  { Float(value) }
  /// - Returns: The value as `Double`.
  public func doubleValue() -> Double { Double(value) }

  // MARK: - Static constants
  /// The minimum value a Java `short` can hold: −32768.
  public static let MIN_VALUE: Int16 = Int16.min
  /// The maximum value a Java `short` can hold: 32767.
  public static let MAX_VALUE: Int16 = Int16.max

  // MARK: - Parsing
  /// Parses a signed decimal short (−32768…32767).
  ///
  /// - Throws: `NumberFormatException` if the string cannot be parsed.
  public static func parseShort(_ s: String) throws(NumberFormatException) -> Int16 {
    guard let v = Int16(s) else {
      throw NumberFormatException("For input string: \"\(s)\"")
    }
    return v
  }

  /// - Returns: A `Short` holding the value parsed from the string.
  /// - Throws: `NumberFormatException` if the string cannot be parsed.
  public static func valueOf(_ s: String) throws(NumberFormatException) -> Short {
    return Short(try parseShort(s))
  }

  /// - Returns: A string representation of this `Short` value.
  public func toString() -> String { String(value) }
}
