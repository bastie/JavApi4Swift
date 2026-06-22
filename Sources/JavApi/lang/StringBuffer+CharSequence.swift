/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

/// Conformance of `StringBuffer` to `CharSequence`, matching Java's
/// `java.lang.StringBuffer implements CharSequence`.
extension StringBuffer : CharSequence {
  public typealias CharSequence = String

  /// Returns the substring in range [start, end).
  public func subSequence(_ start: Int, _ end: Int) -> String {
    return substring(start, end)
  }
}
