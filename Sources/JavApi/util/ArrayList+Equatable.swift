/*
 * SPDX-FileCopyrightText: 2026 Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.util.ArrayList: Equatable {
  /// Returns `true` if both lists have the same size and equal elements at each position.
  ///
  /// This matches Java's `AbstractList.equals()` semantics: two lists are equal if they
  /// contain the same elements in the same order.
  public static func == (lhs: java.util.ArrayList<E>, rhs: java.util.ArrayList<E>) -> Bool {
    guard lhs.elements.count == rhs.elements.count else { return false }
    for i in lhs.elements.indices {
      if lhs.elements[i] != rhs.elements[i] { return false }
    }
    return true
  }
}
