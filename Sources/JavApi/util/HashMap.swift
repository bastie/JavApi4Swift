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
  open class HashMap<K: Hashable, V: Equatable>: java.util.AbstractMap<K, V> {

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

    /// Returns a `Set` view of all key-value pairs.
    ///
    /// `AbstractMap` derives `size()`, `keySet()`, `values()`, `containsKey()`,
    /// `get()`, `clear()`, `putAll()`, `equals()`, and `toString()` from this.
    /// `HashMap` overrides the hot paths below for O(1) behaviour.
    open override func entrySet() -> any java.util.Set<java.util.MapEntry<K, V>> {
      let set = HashSet<java.util.MapEntry<K, V>>(initialCapacity: Swift.max(16, _store.count * 2))
      for (k, v) in _store { _ = try? set.add(Entry(k, v)) }
      return set
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

    open override func keySet() -> any java.util.Set<K> {
      let set = HashSet<K>(initialCapacity: Swift.max(16, _store.count * 2))
      for key in _store.keys { _ = try? set.add(key) }
      return set
    }

    open override func values() -> any java.util.Collection<V> {
      let list = java.util.ArrayList<V>()
      for v in _store.values { _ = try? list.add(v) }
      return list
    }

    // MARK: - containsValue

    /// Returns `true` if this map maps one or more keys to `value`.
    ///
    /// O(n) — scans all values.
    open override func containsValue(_ value: V) -> Bool {
      _store.values.contains(value)
    }

    // MARK: - putAll (O(n) direct store copy)

    open override func putAll(_ map: any java.util.Map<K, V>) {
      let it = map.keySet().iterator()
      while it.hasNext() {
        if let key = try? it.next(), let v = map.get(key) {
          _store[key] = v
        }
      }
    }

    // MARK: - Java 8 methods (O(1) overrides of Map extension defaults)

    /// Returns the value for `key`, or `defaultValue` if the key is absent.
    open override func getOrDefault(_ key: K, _ defaultValue: V) -> V {
      _store[key] ?? defaultValue
    }

    /// Associates `key` with `value` only if `key` is not already present.
    /// Returns the existing value if present, or `nil` after inserting.
    @discardableResult
    open override func putIfAbsent(_ key: K, _ value: V) -> V? {
      if let existing = _store[key] { return existing }
      _store[key] = value
      return nil
    }

    /// Replaces the value for `key` if it is present. Returns the old value,
    /// or `nil` if the key was absent.
    @discardableResult
    open override func replace(_ key: K, _ value: V) -> V? {
      guard _store[key] != nil else { return nil }
      let old = _store[key]
      _store[key] = value
      return old
    }

    /// Replaces the value for `key` only if it currently equals `oldValue`.
    /// Returns `true` on success, `false` otherwise.
    @discardableResult
    open override func replace(_ key: K, _ oldValue: V, _ newValue: V) -> Bool {
      guard _store[key] == oldValue else { return false }
      _store[key] = newValue
      return true
    }

    /// Removes the mapping for `key` only if it currently maps to `value`.
    /// Returns `true` if the mapping was removed.
    @discardableResult
    open override func remove(_ key: K, _ value: V) -> Bool {
      guard _store[key] == value else { return false }
      _store.removeValue(forKey: key)
      return true
    }
  }
}
