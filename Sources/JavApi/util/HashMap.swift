/*
 * SPDX-FileCopyrightText: 2025 - 2026 Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.util {

  /// A hash table based implementation of `java.util.Map`.
  ///
  /// Backed internally by a Swift `Dictionary` for O(1) average-case get/put/remove.
  /// Permits `nil` values but not `nil` keys (matching Java semantics).
  ///
  /// Inherits default implementations of `size()`, `isEmpty()`, `containsKey()`,
  /// `get()`, `putAll()`, `clear()`, `keySet()`, `values()`, `equals()`, and
  /// `toString()` from `AbstractMap`. Performance-sensitive paths override where
  /// the Swift Dictionary allows O(1) instead of O(n) via `entrySet()`.
  ///
  /// - Since: Java 1.2
  open class HashMap<K: Hashable, V>: java.util.AbstractMap<K, V> {

    // MARK: - Backing store

    /// The Swift Dictionary backing this map.
    internal var _store: [K: V]

    // MARK: - Init

    /// Creates an empty map.
    public override init() {
      _store = [:]
    }

    /// Creates an empty map with a capacity hint.
    public init(initialCapacity: Int) {
      _store = Dictionary(minimumCapacity: initialCapacity)
    }

    // MARK: - AbstractMap — required override

    /// Returns a snapshot of all key-value pairs as an array of named tuples.
    ///
    /// `AbstractMap` derives `size()`, `keySet()`, `values()`, `containsKey()`,
    /// `get()`, `clear()`, `putAll()`, `equals()`, and `toString()` from this.
    /// `HashMap` overrides the hot paths below for O(1) behaviour.
    open override func entrySet() -> [(key: K, value: V)] {
      _store.map { (key: $0.key, value: $0.value) }
    }

    // MARK: - java.util.Map — Mutation (O(1) overrides)

    @discardableResult
    open override func put(_ key: K, _ value: V) -> V? {
      let old = _store[key]
      _store[key] = value
      return old
    }

    @discardableResult
    open override func remove(_ key: K) -> V? {
      _store.removeValue(forKey: key)
    }

    open override func clear() {
      _store.removeAll()
    }

    // MARK: - java.util.Map — Query (O(1) overrides)

    open override func size() -> Int {
      _store.count
    }

    open override func isEmpty() -> Bool {
      _store.isEmpty
    }

    open override func containsKey(_ key: K) -> Bool {
      _store[key] != nil
    }

    open override func get(_ key: K) -> V? {
      _store[key]
    }

    // MARK: - java.util.Map — Views (O(n) but direct, no intermediate array)

    open override func keySet() -> Swift.Set<K> {
      Swift.Set(_store.keys)
    }

    open override func values() -> [V] {
      Array(_store.values)
    }

    // MARK: - containsValue

    /// Returns `true` if this map maps one or more keys to `value`.
    ///
    /// O(n) — scans all values.
    open func containsValue(_ value: V) -> Bool where V: Equatable {
      _store.values.contains(value)
    }

    // MARK: - putAll (O(n) direct store copy)

    open override func putAll(_ map: any java.util.Map<K, V>) {
      for key in map.keySet() {
        if let v = map.get(key) {
          _store[key] = v
        }
      }
    }
  }
}
