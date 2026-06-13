/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

/// Java-like 16-bit signed integer type wrapper.
///
/// - Since: JavaApi &gt; 0.48.0 (Java 1.1)
public final class Short : Equatable {

  /// The minimum value a Java `short` can hold: -32768.
  public static let MIN_VALUE: Int16 = Int16.min   // -32768

  /// The maximum value a Java `short` can hold: 32767.
  public static let MAX_VALUE: Int16 = Int16.max   //  32767

  private let value: Int16

  /// Wraps a Swift `Int16` as a Java-like `Short`.
  public init(_ value: Int16) {
    self.value = value
  }

  /// Returns the `short` value stored in this object.
  public func shortValue() -> Int16 {
    return value
  }

  /// Parses the string argument as a signed decimal short (-32768…32767).
  ///
  /// - Throws: `NumberFormatException` if the string does not contain a parsable Int16.
  public static func parseShort(_ s: String) throws(NumberFormatException) -> Int16 {
    guard let v = Int16(s) else {
      throw NumberFormatException("For input string: \"\(s)\"")
    }
    return v
  }

  /// Returns a `Short` object holding the value parsed from the string.
  ///
  /// - Throws: `NumberFormatException` if the string cannot be parsed.
  public static func valueOf(_ s: String) throws(NumberFormatException) -> Short {
    return Short(try parseShort(s))
  }

  /// Returns a string representation of this `Short` value.
  public func toString() -> String {
    return String(value)
  }

  // MARK: Equatable
  public static func == (lhs: Short, rhs: Short) -> Bool {
    return lhs.value == rhs.value
  }
}
