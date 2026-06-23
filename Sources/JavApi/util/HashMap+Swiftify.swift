/*
 * SPDX-FileCopyrightText: 2026 Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

// MARK: - HashMap → Swift bridge

extension java.util.HashMap {

  // MARK: Swift → Java

  /// Creates a `HashMap` from an existing Swift `Dictionary`.
  ///
  /// The dictionary is copied once; subsequent mutations of the original
  /// dictionary do not affect this map.
  ///
  /// ```swift
  /// let map = java.util.HashMap(from: ["a": 1, "b": 2])
  /// ```
  public convenience init(from dictionary: [K: V]) {
    self.init(initialCapacity: dictionary.count)
    _store = dictionary
  }

  // MARK: Java → Swift

  /// Returns a Swift `Dictionary` snapshot of this map.
  ///
  /// The returned dictionary is an independent copy; later mutations of this
  /// map do not affect it.
  ///
  /// ```swift
  /// let dict: [String: Int] = map.toSwiftDictionary()
  /// ```
  public func toSwiftDictionary() -> [K: V] {
    _store
  }

  // MARK: Subscript (Swift-style key access)

  /// Provides Swift dictionary-style subscript access.
  ///
  /// Reading returns `nil` for absent keys. Writing `nil` removes the key.
  ///
  /// ```swift
  /// map["key"] = 42
  /// let v = map["key"]   // 42
  /// map["key"] = nil     // removes entry
  /// ```
  public subscript(key: K) -> V? {
    get { _store[key] }
    set {
      if let v = newValue {
        _ = put(key, v)
      } else {
        _ = remove(key)
      }
    }
  }
}

// MARK: - Swift Dictionary → HashMap bridge

extension Dictionary {

  /// Returns a `java.util.HashMap` copy of this dictionary.
  ///
  /// ```swift
  /// let map = ["x": 1, "y": 2].toJavaHashMap()
  /// ```
  public func toJavaHashMap() -> java.util.HashMap<Key, Value> {
    java.util.HashMap(from: self)
  }
}
