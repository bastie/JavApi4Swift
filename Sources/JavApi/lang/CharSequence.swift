/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

public protocol CharSequence : CustomStringConvertible {
  associatedtype CharSequence : StringProtocol

  func subSequence (_ start: Int, _ end : Int) -> CharSequence

  func toString () -> String
}

extension CharSequence {
  /// Bridges Java's `toString()` to Swift's `CustomStringConvertible`,
  /// so any `CharSequence` can be used directly in string interpolation,
  /// `print()`, and other Swift APIs expecting `description`.
  public var description: String { toString() }

  /// Returns an `IntStream` of `char` values (UTF-16 code units).
  ///
  /// Default implementation delegating to `toString().chars()` — see
  /// `String.chars()` for the UTF-16/surrogate-pair details.
  ///
  /// Mirrors `java.lang.CharSequence.chars()`.
  /// - Since: Java 8
  public func chars() -> java.util.stream.IntStream {
    toString().chars()
  }

  /// Returns an `IntStream` of Unicode code points.
  ///
  /// Default implementation delegating to `toString().codePoints()`.
  ///
  /// Mirrors `java.lang.CharSequence.codePoints()`.
  /// - Since: Java 8
  public func codePoints() -> java.util.stream.IntStream {
    toString().codePoints()
  }
}
