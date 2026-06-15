/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

/// Java-like 32-bit integer wrapper type.
///
/// Mirrors Java's `java.lang.Integer`: a class (reference type) that boxes an `Int` value.
/// Conforms to ``Number`` (`Numeric`) analogous to `Long`.
///
/// - Since: JavaApi (Java 1.0)
public final class Integer: Number, @unchecked Sendable {

  internal var value: Int
  public let magnitude: Int.Magnitude

  // MARK: - ExpressibleByIntegerLiteral (required by Numeric)
  public typealias IntegerLiteralType = Int

  /// Required by `ExpressibleByIntegerLiteral` — the label `integerLiteral` is
  /// mandated by the Swift compiler and cannot be replaced with `_`.
  public required init(integerLiteral value: Int) {
    self.value     = value
    self.magnitude = Int.Magnitude(bitPattern: value)
  }

  /// Creates an `Integer` wrapping the given value — mirrors Java autoboxing / `new Integer(int)`.
  public init(_ value: Int) {
    self.value     = value
    self.magnitude = Int.Magnitude(bitPattern: value)
  }

  /// Creates an `Integer` from any `BinaryInteger` type (Int8, Int16, UInt8, UInt16, …).
  ///
  /// Mirrors Java's implicit widening conversion: `byte` → `int`, `short` → `int`, etc.
  /// For types wider than `Int` (e.g. `UInt64`) the value is truncated to `Int` bit width,
  /// matching Java's narrowing cast semantics (`(int) longValue`).
  public init<T: BinaryInteger>(_ source: T) {
    let v          = Int(truncatingIfNeeded: source)
    self.value     = v
    self.magnitude = Int.Magnitude(bitPattern: v)
  }

  // MARK: - BinaryInteger / Numeric requirements
  public typealias Magnitude = Int.Magnitude

  public required init?<T>(exactly source: T) where T: BinaryInteger {
    guard let v = Int(exactly: source) else { return nil }
    self.value     = v
    self.magnitude = Int.Magnitude(bitPattern: v)
  }

  // Java int arithmetic wraps on overflow (two's complement) — use &+/&-/&*
  public static func + (lhs: Integer, rhs: Integer) -> Self {
    return .init(integerLiteral: lhs.value &+ rhs.value)
  }
  public static func - (lhs: Integer, rhs: Integer) -> Self {
    return .init(integerLiteral: lhs.value &- rhs.value)
  }
  public static func * (lhs: Integer, rhs: Integer) -> Self {
    return .init(integerLiteral: lhs.value &* rhs.value)
  }
  public static func *= (lhs: inout Integer, rhs: Integer) {
    lhs.value = lhs.value &* rhs.value
  }
  public static func += (lhs: inout Integer, rhs: Integer) {
    lhs.value = lhs.value &+ rhs.value
  }
  public static func -= (lhs: inout Integer, rhs: Integer) {
    lhs.value = lhs.value &- rhs.value
  }
  public static func == (lhs: Integer, rhs: Integer) -> Bool {
    return lhs.value == rhs.value
  }

  // MARK: - Number methods (override extension defaults with exact types)
  /// - Returns: The wrapped `Int` value.
  public func intValue() -> Int     { value }
  /// - Returns: The wrapped value as `Int32`.
  public func intValue32() -> Int32 { Int32(value) }
  /// - Returns: The wrapped value as `Int64`.
  public func longValue() -> Int64  { Int64(value) }
  /// - Returns: The wrapped value as `Float`.
  public func floatValue() -> Float { Float(value) }
  /// - Returns: The wrapped value as `Double`.
  public func doubleValue() -> Double { Double(value) }

  /// https://stackoverflow.com/questions/56222323/what-is-the-equivelent-to-javas-integer-reversebytes-in-swift?rq=3 :
  
  /// Reverse the bytes of Int32 in result of Java int is 32-bits long
  ///
  /// <strong>The method is Java-like only for 32-bit implemented. </strong> Use `Int.byteSwapped` for Swift and of course 64-bit Int types.
  ///
  /// A Java int is always 32 bits, so Integer.reverseBytes turns 0x00801600 into 0x00168000.
  ///
  /// A Swift Int is 32 bits on 32-bit platforms and 64 bits on 64-bit platforms (which is most current platforms). So on a 32-bit platform, i.byteSwapped turns 0x00801600 into 0x00168000, but on a 64-bit platform, i.byteSwapped turns 0x0000000000801600 into 0x0016800000000000.
  ///
  /// - Parameters value to reverse
  /// - Returns reverse byte of given Int (as Int32)
  ///
  public static func reverseBytes (_ value : Int) -> Int {
    return Int (Int32(value).byteSwapped)
  }

  /// The maximum value of `Int` type
  ///
  /// ## Sample for port Java to Swift without [JavApi⁴Swift](https://github.com/bastie/JavApi4Swift)
  ///
  /// Java code
  /// ```Java
  /// int maximum = Integer.MAX_VALUE;
  /// ```
  /// Swift code
  /// ```Swift
  /// var maximum = Int32.max
  /// ```
  ///
  /// ⚔️
  ///
  /// - Since: Java 1.0
  public static let MAX_VALUE : Int = Int(Int32.max)

  /// The minimum value of `Int` type
  ///
  /// ## Sample for port Java to Swift without [JavApi⁴Swift](https://github.com/bastie/JavApi4Swift)
  ///
  /// Java code
  /// ```Java
  /// int minimum = Integer.MIX_VALUE;
  /// ```
  /// Swift code
  /// ```Swift
  /// var minimum = Int32.min
  /// ```
  ///
  /// ⚔️
  ///
  /// - Since: Java 1.0
  public static let MIN_VALUE : Int = Int(Int32.min)
  
  
  public static func parseInt (_ string : String) throws (NumberFormatException) -> Int {
    if let value = Int(string) {
      return value
    }
    throw NumberFormatException("\(string) is not a number")
  }
  
  public static func valueOf (_ string : String, _ radix : Int) throws -> Int {
    return try parseInt(string)
  }
  
  public static func toHexString (_ decimalNumber : any BinaryInteger) -> String {
    let hexString = String(decimalNumber, radix: 16)
    return hexString
  }

  /// Returns a string representation of the integer in the given radix.
  ///
  /// Matches Java's `Integer.toString(int i, int radix)` behaviour:
  /// - Radix is clamped to 2…36; values outside that range fall back to radix 10.
  /// - Negative values get a leading minus sign.
  ///
  /// - Parameters:
  ///   - i: The integer value to convert.
  ///   - radix: The base to use (2–36).
  /// - Returns: String representation in the given radix.
  ///
  /// - Since: Java 1.0
  public static func toString (_ i : Int, _ radix : Int) -> String {
    let r = (radix < 2 || radix > 36) ? 10 : radix
    return String(i, radix: r, uppercase: false)
  }
}
