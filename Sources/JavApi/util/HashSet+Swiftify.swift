/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

// MARK: - HashSet → Swift bridge

extension java.util.HashSet {

  // MARK: Swift → Java

  /// Creates a `HashSet` from an existing Swift `Set`.
  ///
  /// The set is copied once; later mutations of the original do not affect
  /// this `HashSet`.
  ///
  /// ```swift
  /// let set = java.util.HashSet(from: Swift.Set(["a", "b", "c"]))
  /// ```
  public convenience init(from swiftSet: Swift.Set<E>) {
    self.init(initialCapacity: swiftSet.count * 2)
    for element in swiftSet {
      _ = try? add(element)
    }
  }
}

// MARK: - Swift Set → HashSet bridge

extension Swift.Set {
  
  /// Returns a Swift `Set` snapshot of this `HashSet`.
  ///
  /// The returned set is an independent copy; later mutations of this
  /// `HashSet` do not affect it.
  ///
  /// ```swift
  /// let swiftSet: Swift.Set<String> = hashSet.toSwiftSet()
  /// ```
  public init (from: java.util.HashSet<Element>) {
    self.init(from._map.keySet())
  }

  /// - Returns: return a `java.util.HashSet` copy of this set.
  ///
  /// Requires `Element: Hashable` (always true for `Swift.Set`).
  ///
  /// ```swift
  /// let hashSet = Swift.Set(["x", "y"]).toJavaHashSet()
  /// ```
  public func toJavaHashSet() -> java.util.HashSet<Element> {
    java.util.HashSet(from: self)
  }
}
