/*
 * SPDX-FileCopyrightText: 2026 Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.util.LinkedList: Equatable {
  /// Returns `true` if both lists have the same size and equal elements at each position.
  ///
  /// This matches Java's `AbstractList.equals()` semantics: two lists are equal if they
  /// contain the same elements in the same order.
  public static func == (lhs: java.util.LinkedList<E>, rhs: java.util.LinkedList<E>) -> Bool {
    guard lhs.count == rhs.count else { return false }
    var lNode = lhs.head
    var rNode = rhs.head
    while let l = lNode, let r = rNode {
      if l.element != r.element { return false }
      lNode = l.next
      rNode = r.next
    }
    return true
  }
}
