/*
 * SPDX-FileCopyrightText: 2026 Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.util.TreeSet: Equatable {
  /// Returns `true` if both sets contain exactly the same elements in the same sorted order.
  ///
  /// Matches Java's `AbstractSet.equals()` semantics. Since `TreeSet` is always sorted,
  /// element-wise comparison is equivalent to set equality.
  public static func == (lhs: java.util.TreeSet<E>, rhs: java.util.TreeSet<E>) -> Bool {
    guard lhs._elements.count == rhs._elements.count else { return false }
    for i in lhs._elements.indices {
      if lhs._elements[i] != rhs._elements[i] { return false }
    }
    return true
  }
}
