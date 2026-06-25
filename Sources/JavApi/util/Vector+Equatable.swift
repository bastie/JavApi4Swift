/*
 * SPDX-FileCopyrightText: 2026 Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.util.Vector: Equatable where E: Equatable {
  /// Returns `true` if both vectors have the same size and equal elements at each position.
  ///
  /// Matches Java's `AbstractList.equals()` semantics.
  public static func == (lhs: java.util.Vector<E>, rhs: java.util.Vector<E>) -> Bool {
    guard lhs.elementCount == rhs.elementCount else { return false }
    for i in 0..<lhs.elementCount {
      if lhs.elementData[i] != rhs.elementData[i] { return false }
    }
    return true
  }
}
