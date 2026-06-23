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
}
