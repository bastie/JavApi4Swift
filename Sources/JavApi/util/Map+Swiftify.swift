/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

// MARK: - MapEntry → Swift tuple bridge

extension java.util.MapEntry {

  /// Returns this entry as a Swift named tuple `(key: K, value: V)`.
  ///
  /// This is a Swift-idiomatic convenience — Java code would call
  /// `getKey()` and `getValue()` directly.  Swift callers can destructure
  /// the result:
  ///
  /// ```swift
  /// let entry: java.util.MapEntry<String, Int> = ...
  /// let (k, v) = entry.asTuple
  /// // or
  /// print(entry.asTuple.key, entry.asTuple.value)
  /// ```
  public var asTuple: (key: K, value: V) {
    (key: key, value: value)
  }
}

// MARK: - Swift tuple → MapEntry bridge

extension java.util.MapEntry {

  /// Creates a `MapEntry` from a Swift named tuple.
  ///
  /// ```swift
  /// let entry = java.util.MapEntry(tuple: ("hello", 42))
  /// ```
  public init(tuple: (key: K, value: V)) {
    self.init(tuple.key, tuple.value)
  }
}

// MARK: - Map view as Swift sequence of tuples

extension java.util.Map {

  /// Returns the contents of this map as an array of Swift tuples.
  ///
  /// The order of elements is undefined (matches Java semantics for
  /// unordered maps; `TreeMap` returns pairs in key-ascending order).
  ///
  /// ```swift
  /// let map = java.util.HashMap<String, Int>()
  /// map.put("a", 1); map.put("b", 2)
  /// for (key, value) in map.asTuples() {
  ///   print(key, value)
  /// }
  /// ```
  public func asTuples() -> [(key: K, value: V)] {
    var result: [(key: K, value: V)] = []
    let it = entrySet().iterator()
    while it.hasNext() {
      if let e = try? it.next() {
        result.append(e.asTuple)
      }
    }
    return result
  }
}
