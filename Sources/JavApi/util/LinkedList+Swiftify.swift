/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

// MARK: - LinkedList → Swift bridge

extension java.util.LinkedList {

  // MARK: Swift → Java

  /// Creates a `LinkedList` from an existing Swift `Array`.
  ///
  /// The array is copied once; later mutations of the original do not affect
  /// this list.
  ///
  /// ```swift
  /// let list = java.util.LinkedList(from: [1, 2, 3])
  /// ```
  public convenience init(from array: [E]) {
    self.init()
    for element in array {
      linkLast(element)
    }
  }

  // MARK: Java → Swift

  /// Returns a Swift `Array` snapshot of this list's elements in order.
  ///
  /// The returned array is an independent copy; later mutations of this list
  /// do not affect it.
  ///
  /// ```swift
  /// let arr: [Int] = linkedList.toSwiftArray()
  /// ```
  public func toSwiftArray() -> [E] {
    var result: [E] = []
    result.reserveCapacity(count)
    var node = head
    while let current = node {
      if let element = current.element {
        result.append(element)
      }
      node = current.next
    }
    return result
  }

  // MARK: Subscript (Swift-style index access)

  /// Provides Swift array-style subscript access.
  ///
  /// Reading returns `nil` for out-of-range indices or `nil` elements.
  /// Writing replaces the element at that index.
  ///
  /// ```swift
  /// list[0]      // first element
  /// list[0] = 42 // replace first element
  /// ```
  public subscript(index: Int) -> E? {
    get { try? get(index) }
    set {
      if let v = newValue {
        _ = try? set(index, v)
      }
    }
  }
}

// MARK: - Swift Array → LinkedList bridge

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
