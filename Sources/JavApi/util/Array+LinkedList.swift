/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension Array {

  /// Creates a Swift `Array` from a `java.util.LinkedList`.
  ///
  /// ```swift
  /// let arr = Array(from: linkedList)
  /// ```
  public init(from list: java.util.LinkedList<Element>) where Element: Equatable {
    self.init()
    var node = list.head
    while let current = node {
      if let element = current.element {
        self.append(element)
      }
      node = current.next
    }
  }

  /// Returns a `java.util.LinkedList` copy of this array.
  ///
  /// Requires `Element: Equatable`.
  ///
  /// ```swift
  /// let list = [1, 2, 3].toJavaLinkedList()
  /// ```
  public func toJavaLinkedList() -> java.util.LinkedList<Element> where Element: Equatable {
    java.util.LinkedList(from: self)
  }
}
