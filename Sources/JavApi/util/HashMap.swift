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

    /// Copy constructor — creates a new map containing all entries of `map`.
    ///
    /// Matches `java.util.HashMap(Map<? extends K, ? extends V>)` (Java 1.2).
    public init(_ map: any java.util.Map<K, V>) {
      _store = Dictionary(minimumCapacity: Swift.max(16, map.size() * 2))
      super.init()
      let it = map.keySet().iterator()
      while it.hasNext() {
        if let key = try? it.next(), let value = map.get(key) {
          _store[key] = value
        }
      }
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

    // MARK: - Java 8 compute / merge

    /// Returns a shallow copy of this map.
    ///
    /// Matches `java.util.HashMap.clone()` (Java 1.2).
    open func clone() -> HashMap<K, V> {
      let copy = HashMap<K, V>(initialCapacity: Swift.max(16, _store.count * 2))
      copy._store = _store
      return copy
    }

    /// Computes a new value for `key` using `remappingFunction(key, oldValue)`.
    ///
    /// If the function returns `nil`, the key is removed; otherwise the result
    /// is stored and returned.
    ///
    /// Matches `java.util.Map.compute(K, BiFunction)` (Java 8).
    @discardableResult
    open func compute(_ key: K, _ remappingFunction: (K, V?) -> V?) -> V? {
      let oldValue = _store[key]
      if let newValue = remappingFunction(key, oldValue) {
        _store[key] = newValue
        return newValue
      } else {
        _store.removeValue(forKey: key)
        return nil
      }
    }

    /// If `key` is already present, recomputes its value using
    /// `remappingFunction(key, oldValue)`. If the function returns `nil`, the
    /// key is removed; otherwise the result is stored and returned.
    ///
    /// Matches `java.util.Map.computeIfPresent(K, BiFunction)` (Java 8).
    @discardableResult
    open func computeIfPresent(_ key: K, _ remappingFunction: (K, V) -> V?) -> V? {
      guard let oldValue = _store[key] else { return nil }
      if let newValue = remappingFunction(key, oldValue) {
        _store[key] = newValue
        return newValue
      } else {
        _store.removeValue(forKey: key)
        return nil
      }
    }

    /// If `key` is absent (or maps to `nil`), stores `value` and returns it.
    /// Otherwise merges old and new values using `remappingFunction(oldValue, value)`.
    /// If the function returns `nil`, the key is removed.
    ///
    /// Matches `java.util.Map.merge(K, V, BiFunction)` (Java 8).
    @discardableResult
    open func merge(_ key: K, _ value: V, _ remappingFunction: (V, V) -> V?) -> V? {
      if let oldValue = _store[key] {
        if let newValue = remappingFunction(oldValue, value) {
          _store[key] = newValue
          return newValue
        } else {
          _store.removeValue(forKey: key)
          return nil
        }
      } else {
        _store[key] = value
        return value
      }
    }

    // MARK: - Java 9 factory: Map.of(…)
    //
    // Mirrors the 11 Java overloads (0–10 key-value pairs) with identical
    // alternating-parameter call syntax: HashMap.of("a", 1, "b", 2).
    // Each public overload delegates to the private helper _ofPairs.

    private static func _ofPairs(
      _ pairs: [(K, V)]
    ) throws(java.lang.IllegalArgumentException) -> any java.util.Map<K, V> {
      let map = HashMap<K, V>(initialCapacity: Swift.max(16, pairs.count * 2))
      for (k, v) in pairs {
        if map.containsKey(k) {
          throw java.lang.IllegalArgumentException("duplicate key: \(k)")
        }
        _ = map.put(k, v)
      }
      return java.util.Collections.unmodifiableMap(map)
    }

    /// Returns an empty unmodifiable map.
    ///
    /// Mirrors `java.util.Map.of()` (Java 9).
    /// - Since: Java 9
    public static func of() -> any java.util.Map<K, V> {
      java.util.Collections.unmodifiableMap(HashMap<K, V>())
    }

    /// Returns an unmodifiable map containing 1 mapping.
    ///
    /// Mirrors `java.util.Map.of(K,V)` (Java 9).
    /// - Since: Java 9
    public static func of(
      _ k1: K, _ v1: V
    ) -> any java.util.Map<K, V> {
      // No duplicates possible with a single pair.
      let map = HashMap<K, V>(initialCapacity: 16)
      _ = map.put(k1, v1)
      return java.util.Collections.unmodifiableMap(map)
    }

    /// Returns an unmodifiable map containing 2 mappings.
    ///
    /// Mirrors `java.util.Map.of(K,V,K,V)` (Java 9).
    /// - Throws: `IllegalArgumentException` on duplicate keys.
    /// - Since: Java 9
    public static func of(
      _ k1: K, _ v1: V,
      _ k2: K, _ v2: V
    ) throws(java.lang.IllegalArgumentException) -> any java.util.Map<K, V> {
      try _ofPairs([(k1,v1),(k2,v2)])
    }

    /// Returns an unmodifiable map containing 3 mappings.
    ///
    /// Mirrors `java.util.Map.of(K,V,K,V,K,V)` (Java 9).
    /// - Throws: `IllegalArgumentException` on duplicate keys.
    /// - Since: Java 9
    public static func of(
      _ k1: K, _ v1: V,
      _ k2: K, _ v2: V,
      _ k3: K, _ v3: V
    ) throws(java.lang.IllegalArgumentException) -> any java.util.Map<K, V> {
      try _ofPairs([(k1,v1),(k2,v2),(k3,v3)])
    }

    /// Returns an unmodifiable map containing 4 mappings.
    ///
    /// Mirrors `java.util.Map.of(K,V,…)` (Java 9).
    /// - Throws: `IllegalArgumentException` on duplicate keys.
    /// - Since: Java 9
    public static func of(
      _ k1: K, _ v1: V,
      _ k2: K, _ v2: V,
      _ k3: K, _ v3: V,
      _ k4: K, _ v4: V
    ) throws(java.lang.IllegalArgumentException) -> any java.util.Map<K, V> {
      try _ofPairs([(k1,v1),(k2,v2),(k3,v3),(k4,v4)])
    }

    /// Returns an unmodifiable map containing 5 mappings.
    ///
    /// Mirrors `java.util.Map.of(K,V,…)` (Java 9).
    /// - Throws: `IllegalArgumentException` on duplicate keys.
    /// - Since: Java 9
    public static func of(
      _ k1: K, _ v1: V,
      _ k2: K, _ v2: V,
      _ k3: K, _ v3: V,
      _ k4: K, _ v4: V,
      _ k5: K, _ v5: V
    ) throws(java.lang.IllegalArgumentException) -> any java.util.Map<K, V> {
      try _ofPairs([(k1,v1),(k2,v2),(k3,v3),(k4,v4),(k5,v5)])
    }

    /// Returns an unmodifiable map containing 6 mappings.
    ///
    /// Mirrors `java.util.Map.of(K,V,…)` (Java 9).
    /// - Throws: `IllegalArgumentException` on duplicate keys.
    /// - Since: Java 9
    public static func of(
      _ k1: K, _ v1: V,
      _ k2: K, _ v2: V,
      _ k3: K, _ v3: V,
      _ k4: K, _ v4: V,
      _ k5: K, _ v5: V,
      _ k6: K, _ v6: V
    ) throws(java.lang.IllegalArgumentException) -> any java.util.Map<K, V> {
      try _ofPairs([(k1,v1),(k2,v2),(k3,v3),(k4,v4),(k5,v5),(k6,v6)])
    }

    /// Returns an unmodifiable map containing 7 mappings.
    ///
    /// Mirrors `java.util.Map.of(K,V,…)` (Java 9).
    /// - Throws: `IllegalArgumentException` on duplicate keys.
    /// - Since: Java 9
    public static func of(
      _ k1: K, _ v1: V,
      _ k2: K, _ v2: V,
      _ k3: K, _ v3: V,
      _ k4: K, _ v4: V,
      _ k5: K, _ v5: V,
      _ k6: K, _ v6: V,
      _ k7: K, _ v7: V
    ) throws(java.lang.IllegalArgumentException) -> any java.util.Map<K, V> {
      try _ofPairs([(k1,v1),(k2,v2),(k3,v3),(k4,v4),(k5,v5),(k6,v6),(k7,v7)])
    }

    /// Returns an unmodifiable map containing 8 mappings.
    ///
    /// Mirrors `java.util.Map.of(K,V,…)` (Java 9).
    /// - Throws: `IllegalArgumentException` on duplicate keys.
    /// - Since: Java 9
    public static func of(
      _ k1: K, _ v1: V,
      _ k2: K, _ v2: V,
      _ k3: K, _ v3: V,
      _ k4: K, _ v4: V,
      _ k5: K, _ v5: V,
      _ k6: K, _ v6: V,
      _ k7: K, _ v7: V,
      _ k8: K, _ v8: V
    ) throws(java.lang.IllegalArgumentException) -> any java.util.Map<K, V> {
      try _ofPairs([(k1,v1),(k2,v2),(k3,v3),(k4,v4),(k5,v5),(k6,v6),(k7,v7),(k8,v8)])
    }

    /// Returns an unmodifiable map containing 9 mappings.
    ///
    /// Mirrors `java.util.Map.of(K,V,…)` (Java 9).
    /// - Throws: `IllegalArgumentException` on duplicate keys.
    /// - Since: Java 9
    public static func of(
      _ k1: K, _ v1: V,
      _ k2: K, _ v2: V,
      _ k3: K, _ v3: V,
      _ k4: K, _ v4: V,
      _ k5: K, _ v5: V,
      _ k6: K, _ v6: V,
      _ k7: K, _ v7: V,
      _ k8: K, _ v8: V,
      _ k9: K, _ v9: V
    ) throws(java.lang.IllegalArgumentException) -> any java.util.Map<K, V> {
      try _ofPairs([(k1,v1),(k2,v2),(k3,v3),(k4,v4),(k5,v5),(k6,v6),(k7,v7),(k8,v8),(k9,v9)])
    }

    /// Returns an unmodifiable map containing 10 mappings.
    ///
    /// Mirrors `java.util.Map.of(K,V,…)` (Java 9).
    /// - Throws: `IllegalArgumentException` on duplicate keys.
    /// - Since: Java 9
    public static func of(
      _ k1: K,  _ v1: V,
      _ k2: K,  _ v2: V,
      _ k3: K,  _ v3: V,
      _ k4: K,  _ v4: V,
      _ k5: K,  _ v5: V,
      _ k6: K,  _ v6: V,
      _ k7: K,  _ v7: V,
      _ k8: K,  _ v8: V,
      _ k9: K,  _ v9: V,
      _ k10: K, _ v10: V
    ) throws(java.lang.IllegalArgumentException) -> any java.util.Map<K, V> {
      try _ofPairs([(k1,v1),(k2,v2),(k3,v3),(k4,v4),(k5,v5),(k6,v6),(k7,v7),(k8,v8),(k9,v9),(k10,v10)])
    }

    // MARK: - Java 10 factory: Map.copyOf(…)

    /// Returns an unmodifiable map containing the same mappings as `map`.
    ///
    /// Null keys and values cause a `NullPointerException` (null-hostile).
    ///
    /// Mirrors `java.util.Map.copyOf(Map)` (Java 10).
    ///
    /// - Parameter source: The map whose mappings to copy.
    /// - Returns: An unmodifiable `Map` containing the same mappings.
    /// - Since: Java 10
    public static func copyOf(_ source: any java.util.Map<K, V>) -> any java.util.Map<K, V> {
      let copy = HashMap<K, V>(initialCapacity: Swift.max(16, source.size() * 2))
      let it = source.keySet().iterator()
      while it.hasNext() {
        guard let key = try? it.next() else {
          fatalError("NullPointerException: Map.copyOf does not allow null keys")
        }
        guard let value = source.get(key) else {
          fatalError("NullPointerException: Map.copyOf does not allow null values")
        }
        _ = copy.put(key, value)
      }
      return java.util.Collections.unmodifiableMap(copy)
    }

    // MARK: - Java 9 factory: Map.entry + Map.ofEntries

    /// Returns an unmodifiable map entry containing the given key and value.
    ///
    /// The returned entry is null-hostile: both key and value must be non-nil.
    /// Because `MapEntry` is a Swift value type, the entry is inherently immutable
    /// once stored in a `let` binding.
    ///
    /// Mirrors `java.util.Map.entry(K, V)` (Java 9).
    ///
    /// - Parameters:
    ///   - key: The key (non-nil).
    ///   - value: The value (non-nil).
    /// - Returns: A `MapEntry<K, V>` holding the given key-value pair.
    /// - Since: Java 9
    public static func entry(_ key: K, _ value: V) -> java.util.MapEntry<K, V> {
      java.util.MapEntry<K, V>(key, value)
    }

    /// Returns an unmodifiable map containing the given entries.
    ///
    /// Throws `IllegalArgumentException` if any two entries share an equal key.
    ///
    /// Mirrors `java.util.Map.ofEntries(Map.Entry...)` (Java 9).
    ///
    /// - Parameter entries: Zero or more `MapEntry<K, V>` values.
    /// - Returns: An unmodifiable `Map` containing all given entries.
    /// - Throws: `IllegalArgumentException` on duplicate keys.
    /// - Since: Java 9
    public static func ofEntries(
      _ entries: java.util.MapEntry<K, V>...
    ) throws(java.lang.IllegalArgumentException) -> any java.util.Map<K, V> {
      try _ofPairs(entries.map { ($0.getKey(), $0.getValue()) })
    }
  }
}
