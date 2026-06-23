/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

// MARK: - TreeSet → Swift bridge

extension java.util.TreeSet {

  // MARK: Swift → Java

  /// Creates a `TreeSet` from an existing Swift `Array`.
  ///
  /// Duplicates are silently dropped; elements are stored in ascending
  /// natural order. The array is copied once.
  ///
  /// ```swift
  /// let set = java.util.TreeSet(from: [3, 1, 2, 1])
  /// // contains: 1, 2, 3
  /// ```
  public convenience init(from array: [E]) {
    self.init()
    for element in array {
      _ = try? add(element)
    }
  }

  /// Creates a `TreeSet` from an existing Swift `Set`.
  ///
  /// Elements are stored in ascending natural order. The set is copied once.
  ///
  /// ```swift
  /// let set = java.util.TreeSet(from: Swift.Set([3, 1, 2]))
  /// ```
  public convenience init(from swiftSet: Swift.Set<E>) {
    self.init(from: Array(swiftSet))
  }

  // MARK: Java → Swift

  /// Returns a Swift `Array` snapshot of this set's elements in ascending order.
  ///
  /// The returned array is an independent copy.
  ///
  /// ```swift
  /// let arr: [Int] = treeSet.toSwiftArray()
  /// ```
  public func toSwiftArray() -> [E] {
    _elements
  }

  /// Returns a Swift `Set` snapshot of this set's elements.
  ///
  /// The returned set is an independent copy. Note that `Swift.Set` has no
  /// defined iteration order; use `toSwiftArray()` to preserve sorted order.
  ///
  /// ```swift
  /// let swiftSet: Swift.Set<Int> = treeSet.toSwiftSet()
  /// ```
  public func toSwiftSet() -> Swift.Set<E> {
    Swift.Set(_elements)
  }
}

// MARK: - Swift Array → TreeSet bridge

extension Array {

  /// Creates a Swift `Array` from a `java.util.TreeSet`, preserving ascending order.
  ///
  /// ```swift
  /// let arr = Array(from: treeSet)
  /// ```
  public init(from set: java.util.TreeSet<Element>)
    where Element: Hashable & Comparable & Equatable
  {
    self = set._elements
  }

  /// Returns a `java.util.TreeSet` copy of this array, sorted and deduplicated.
  ///
  /// Requires `Element: Hashable & Comparable & Equatable`.
  ///
  /// ```swift
  /// let set = [3, 1, 2, 1].toJavaTreeSet()
  /// ```
  public func toJavaTreeSet() -> java.util.TreeSet<Element>
    where Element: Hashable & Comparable & Equatable
  {
    java.util.TreeSet(from: self)
  }
}

// MARK: - Swift Set → TreeSet bridge

extension Swift.Set {

  /// Creates a Swift `Set` from a `java.util.TreeSet`.
  ///
  /// ```swift
  /// let swiftSet = Swift.Set(from: treeSet)
  /// ```
  public init(from set: java.util.TreeSet<Element>) where Element: Comparable & Equatable {
    self = Swift.Set(set._elements)
  }

  /// Returns a `java.util.TreeSet` copy of this set, sorted in ascending order.
  ///
  /// Requires `Element: Comparable & Equatable`.
  ///
  /// ```swift
  /// let treeSet = Swift.Set([3, 1, 2]).toJavaTreeSet()
  /// ```
  public func toJavaTreeSet() -> java.util.TreeSet<Element> where Element: Comparable & Equatable {
    java.util.TreeSet(from: self)
  }
}
