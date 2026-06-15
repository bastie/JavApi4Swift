/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

/// Java-like unsigned 8-bit integer type wrapper.
///
/// `byte` in this project is `UInt8` for Swift compatibility.
/// Use `UMIN_VALUE` / `UMAX_VALUE` (or their aliases `MIN_VALUE` / `MAX_VALUE`)
/// for unsigned bounds. For signed Java-style bounds see `Byte+Java.swift`.
///
/// - Since: JavaApi &gt; 0.48.0 (Java 1.1)
public final class Byte : Equatable {

  // MARK: - Unsigned bounds (UInt8 / project-byte semantics)

  /// The minimum value of the unsigned `byte` type used in this project: 0.
  public static let UMIN_VALUE: UInt8 = UInt8.min   // 0

  /// The maximum value of the unsigned `byte` type used in this project: 255.
  public static let UMAX_VALUE: UInt8 = UInt8.max   // 255

  /// Alias for `UMIN_VALUE` — matches the Java name `Byte.MIN_VALUE` for unsigned use.
  public static var MIN_VALUE: UInt8 { UMIN_VALUE }

  /// Alias for `UMAX_VALUE` — matches the Java name `Byte.MAX_VALUE` for unsigned use.
  public static var MAX_VALUE: UInt8 { UMAX_VALUE }

  // MARK: - Storage

  private let value: UInt8

  // MARK: - Init

  /// Wraps a Swift `UInt8` (= project `byte`) as a Java-like `Byte`.
  public init(_ value: UInt8) {
    self.value = value
  }

  // MARK: - Value accessors

  /// Returns the unsigned `byte` (UInt8) value stored in this object.
  public func byteValue() -> UInt8 {
    return value
  }

  // MARK: - Parsing

  /// Parses the string argument as an unsigned decimal byte (0…255).
  ///
  /// - Throws: `NumberFormatException` if the string does not contain a parsable UInt8.
  public static func parseByte(_ s: String) throws(NumberFormatException) -> UInt8 {
    guard let v = UInt8(s) else {
      throw NumberFormatException("For input string: \"\(s)\"")
    }
    return v
  }

  /// Returns a `Byte` object holding the value parsed from the string.
  ///
  /// - Throws: `NumberFormatException` if the string cannot be parsed.
  public static func valueOf(_ s: String) throws(NumberFormatException) -> Byte {
    return Byte(try parseByte(s))
  }

  // MARK: - String conversion

  /// Returns a string representation of this `Byte` value.
  public func toString() -> String {
    return String(value)
  }

  // MARK: - Equatable

  public static func == (lhs: Byte, rhs: Byte) -> Bool {
    return lhs.value == rhs.value
  }
}
