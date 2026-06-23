/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

// MARK: - TreeMap → Swift bridge

extension java.util.TreeMap {

  // MARK: Swift → Java

  /// Creates a `TreeMap` from an existing Swift `Dictionary`.
  ///
  /// Keys are sorted in ascending natural order. The dictionary is copied
  /// once; later mutations of the original do not affect this map.
  ///
  /// ```swift
  /// let map = java.util.TreeMap(from: ["b": 2, "a": 1])
  /// // iteration order: a, b
  /// ```
  public convenience init(from dictionary: [K: V]) {
    self.init()
    for (k, v) in dictionary {
      put(k, v)
    }
  }

  // MARK: Java → Swift

  /// Returns a Swift `Dictionary` snapshot of this map.
  ///
  /// The returned dictionary is an independent copy; later mutations of this
  /// map do not affect it. Note that `Dictionary` has no defined iteration
  /// order; use `entrySet()` if you need sorted order.
  ///
  /// ```swift
  /// let dict: [String: Int] = treeMap.toSwiftDictionary()
  /// ```
  public func toSwiftDictionary() -> [K: V] {
    var result: [K: V] = Dictionary(minimumCapacity: _pairs.count)
    for pair in _pairs {
      result[pair.key] = pair.value
    }
    return result
  }

  // MARK: Subscript (Swift-style key access)

  /// Provides Swift dictionary-style subscript access in sorted-key order.
  ///
  /// Reading returns `nil` for absent keys. Writing `nil` removes the key.
  ///
  /// ```swift
  /// map["key"] = 42
  /// let v = map["key"]   // 42
  /// map["key"] = nil     // removes entry
  /// ```
  public subscript(key: K) -> V? {
    get { get(key) }
    set {
      if let v = newValue {
        put(key, v)
      } else {
        remove(key)
      }
    }
  }
}

// MARK: - Swift Dictionary → TreeMap bridge

extension Dictionary {

  /// Creates a Swift `Dictionary` from a `java.util.TreeMap`.
  ///
  /// ```swift
  /// let dict = Dictionary(from: treeMap)
  /// ```
  public init(from map: java.util.TreeMap<Key, Value>) where Key: Comparable {
    self.init(minimumCapacity: map.size())
    for pair in map._pairs {
      self[pair.key] = pair.value
    }
  }

  /// Returns a `java.util.TreeMap` copy of this dictionary, sorted by key.
  ///
  /// Requires `Key: Comparable`.
  ///
  /// ```swift
  /// let map = ["b": 2, "a": 1].toJavaTreeMap()
  /// ```
  public func toJavaTreeMap() -> java.util.TreeMap<Key, Value>
    where Key: Comparable {
    java.util.TreeMap(from: self)
  }
}
