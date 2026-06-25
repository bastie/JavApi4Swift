/*
 * SPDX-FileCopyrightText: 2026 Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.util.HashSet: Equatable {
  /// Returns `true` if both sets contain exactly the same elements (order-independent).
  ///
  /// Matches Java's `AbstractSet.equals()` semantics.
  public static func == (lhs: java.util.HashSet<E>, rhs: java.util.HashSet<E>) -> Bool {
    return lhs._map.keySet() == rhs._map.keySet()
  }
}
