/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

/// Signed Java-style helpers for `Byte`.
///
/// Java's `byte` is a signed 8-bit type (-128…127). This extension provides
/// the signed constants and a signed parsing method for code ported from Java
/// that relies on signed byte semantics.
///
/// - Since: JavaApi &gt; 0.48.0 (Java 1.1)
extension Byte {

  // MARK: - Signed bounds (Java byte / Int8 semantics)

  /// The minimum value of a signed Java `byte`: -128.
  public static let SMIN_VALUE: Int8 = Int8.min   // -128

  /// The maximum value of a signed Java `byte`: 127.
  public static let SMAX_VALUE: Int8 = Int8.max   //  127

  // MARK: - Signed parsing

  /// Parses the string argument as a signed decimal byte (-128…127).
  ///
  /// Use this when porting Java code that relies on `Byte.parseByte(String)` with
  /// signed semantics. For the unsigned variant use `Byte.parseByte(_:)`.
  ///
  /// - Throws: `NumberFormatException` if the string does not contain a parsable Int8.
  public static func parseSignedByte(_ s: String) throws(NumberFormatException) -> Int8 {
    guard let v = Int8(s) else {
      throw NumberFormatException("For input string: \"\(s)\"")
    }
    return v
  }

  // MARK: - Signed value accessor

  /// Returns the value as a signed `Int8`, reinterpreting the bit pattern.
  ///
  /// Values 0…127 map to 0…127; values 128…255 map to -128…-1.
  public func signedByteValue() -> Int8 {
    return Int8(bitPattern: byteValue())
  }
}
