/*
 * SPDX-FileCopyrightText: 2026 Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

// MARK: - ArrayList → Swift bridge

extension java.util.ArrayList {

  // MARK: Swift → Java

  /// Creates an `ArrayList` from an existing Swift `Array`.
  ///
  /// The array is copied once; later mutations of the original array do not
  /// affect this list.
  ///
  /// ```swift
  /// let list = java.util.ArrayList(from: [1, 2, 3])
  /// ```
  public convenience init(from array: [E]) {
    self.init(initialCapacity: array.count)
    elements = array.map { Optional($0) }
  }

  // MARK: Java → Swift

  /// Returns a Swift `Array` snapshot of this list's non-nil elements.
  ///
  /// `nil` slots (possible via `set(_:nil)`) are dropped. The returned array
  /// is an independent copy.
  ///
  /// ```swift
  /// let arr: [String] = list.toSwiftArray()
  /// ```
  public func toSwiftArray() -> [E] {
    elements.compactMap { $0 }
  }

  // MARK: Subscript (Swift-style index access)

  /// Provides Swift array-style subscript access.
  ///
  /// Reading throws `IndexOutOfBoundsException` for out-of-range indices
  /// (via `get`); writing replaces the element at that index (via `set`).
  ///
  /// ```swift
  /// list[0]      // first element (or nil)
  /// list[0] = 42 // replace first element
  /// ```
  public subscript(index: Int) -> E? {
    get { try? get(index) }
    set { _ = try? set(index, newValue) }
  }
}

// MARK: - Swift Array → ArrayList bridge

extension Array {

  /// Returns a `java.util.ArrayList` copy of this array.
  ///
  /// Requires `Element: Equatable`.
  ///
  /// ```swift
  /// let list = [1, 2, 3].toJavaArrayList()
  /// ```
  public func toJavaArrayList() -> java.util.ArrayList<Element> where Element: Equatable {
    java.util.ArrayList(from: self)
  }
}
