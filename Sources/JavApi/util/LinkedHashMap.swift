/*
 * SPDX-FileCopyrightText: 2023 - 2026 Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.util {

  /// Swift implementation of `java.util.LinkedHashMap`.
  ///
  /// A hash-map that maintains **insertion order** for its keys.  Backed
  /// internally by a `Dictionary` (O(1) lookup) and an `Array` (order
  /// tracking).
  ///
  /// Conforms to `java.util.SequencedMap` (Java 21), which extends
  /// `java.util.Map`, providing ordered first/last entry access.
  ///
  /// **Supported Java API:**
  /// - All `Map` methods: `put`, `get`, `remove`, `clear`, `size`, `isEmpty`,
  ///   `containsKey`, `containsValue`, `putAll`, `keySet`, `values`, `entrySet`
  /// - `SequencedMap` extensions: `firstEntry`, `lastEntry`,
  ///   `pollFirstEntry`, `pollLastEntry`, `reversedMap`,
  ///   `sequencedKeySet`, `sequencedValues`, `sequencedEntrySet`
  ///
  /// - Since: Java 1.4
  open class LinkedHashMap<KeyType: Hashable, ValueType: Equatable>: java.util.SequencedMap {

    public typealias K = KeyType
    public typealias V = ValueType

    // MARK: - Backing store

    /// O(1) key → value lookup.
    internal var delegateDictionary: Dictionary<KeyType, ValueType>

    /// Insertion-order (or access-order) key list — the single source of truth for iteration order.
    internal var sortedKeyCollection: Array<KeyType>

    /// When `true`, every `get()` and `put()` on an existing key moves the key
    /// to the **end** of `sortedKeyCollection` (LRU / access-order mode).
    ///
    /// Mirrors the Java `accessOrder` constructor parameter.
    private let _accessOrder: Bool

    // MARK: - Constructors

    public required init() {
      delegateDictionary = [:]
      sortedKeyCollection = []
      _accessOrder = false
    }

    public init(_ initialCapacity: Int) {
      delegateDictionary = Dictionary<KeyType, ValueType>(minimumCapacity: initialCapacity)
      sortedKeyCollection = Array<KeyType>()
      _accessOrder = false
    }

    public init(_ m: LinkedHashMap<KeyType, ValueType>) {
      self.delegateDictionary = m.delegateDictionary
      self.sortedKeyCollection = m.sortedKeyCollection
      self._accessOrder = m._accessOrder
    }

    /// Creates a `LinkedHashMap` with the given initial capacity, load factor,
    /// and ordering mode.
    ///
    /// When `accessOrder` is `true`, the map uses **access order**: each
    /// `get()` or `put()` on an existing key moves that entry to the *end* of
    /// the encounter order (most-recently-used last).  This makes the map
    /// suitable as a basis for LRU caches by overriding `removeEldestEntry`.
    ///
    /// When `accessOrder` is `false` (the default), the map uses **insertion
    /// order** — the same as all other constructors.
    ///
    /// - Parameters:
    ///   - initialCapacity: Capacity hint passed to the backing `Dictionary`.
    ///   - loadFactor: Ignored in this Swift implementation (no rehashing);
    ///     present for Java API compatibility.
    ///   - accessOrder: `true` for access-order, `false` for insertion-order.
    /// - Since: Java 1.4
    public init(_ initialCapacity: Int, _ loadFactor: Float, _ accessOrder: Bool) {
      delegateDictionary = Dictionary<KeyType, ValueType>(minimumCapacity: initialCapacity)
      sortedKeyCollection = Array<KeyType>()
      self._accessOrder = accessOrder
    }

    // MARK: - Map — Query

    open func size() -> Int { delegateDictionary.count }

    open func isEmpty() -> Bool { sortedKeyCollection.isEmpty }

    open func containsKey(_ key: KeyType) -> Bool { sortedKeyCollection.contains(key) }

    open func containsValue(_ value: ValueType) -> Bool {
      delegateDictionary.values.contains(value)
    }

    open func get(_ key: KeyType) -> ValueType? {
      guard let value = delegateDictionary[key] else { return nil }
      if _accessOrder {
        sortedKeyCollection.removeAll { $0 == key }
        sortedKeyCollection.append(key)
      }
      return value
    }

    // MARK: - Map — Mutation

    @discardableResult
    open func put(_ key: KeyType, _ newValue: ValueType) -> ValueType? {
      let oldValue = delegateDictionary.updateValue(newValue, forKey: key)
      if oldValue == nil {
        sortedKeyCollection.append(key)
      } else if _accessOrder {
        // Move updated key to end (most-recently-used)
        sortedKeyCollection.removeAll { $0 == key }
        sortedKeyCollection.append(key)
      }
      // LRU eviction hook: subclasses may override removeEldestEntry to
      // trigger eviction after each insertion.
      if let eldest = firstEntry(), removeEldestEntry(eldest) {
        _ = remove(eldest.key)
      }
      return oldValue
    }

    /// Returns `true` if this map should remove its eldest entry after a `put`.
    ///
    /// The default implementation returns `false` (no automatic eviction).
    /// Override this method in a subclass to implement LRU caches:
    ///
    /// ```swift
    /// class LRUCache<K: Hashable, V: Equatable>: java.util.LinkedHashMap<K, V> {
    ///   let maxSize: Int
    ///   init(maxSize: Int) {
    ///     self.maxSize = maxSize
    ///     super.init(maxSize, 0.75, true)
    ///   }
    ///   override func removeEldestEntry(_ eldest: java.util.MapEntry<K, V>) -> Bool {
    ///     size() > maxSize
    ///   }
    /// }
    /// ```
    ///
    /// - Parameter eldest: The least-recently inserted (or least-recently used,
    ///   in access-order mode) entry.
    /// - Returns: `true` if `eldest` should be removed; `false` otherwise.
    /// - Since: Java 1.4
    open func removeEldestEntry(_ eldest: java.util.MapEntry<KeyType, ValueType>) -> Bool {
      false
    }

    @discardableResult
    open func remove(_ key: KeyType) -> ValueType? {
      guard let oldValue = delegateDictionary.removeValue(forKey: key) else { return nil }
      sortedKeyCollection.removeAll { $0 == key }
      return oldValue
    }

    open func putAll(_ map: any java.util.Map<KeyType, ValueType>) {
      let it = map.entrySet().iterator()
      while it.hasNext() {
        if let e = try? it.next() { _ = put(e.key, e.value) }
      }
    }

    open func clear() {
      sortedKeyCollection.removeAll()
      delegateDictionary.removeAll()
    }

    // MARK: - Map — Views

    open func keySet() -> any java.util.Set<KeyType> {
      let set = java.util.HashSet<KeyType>(initialCapacity: sortedKeyCollection.count * 2)
      for k in sortedKeyCollection { _ = try? set.add(k) }
      return set
    }

    open func values() -> any java.util.Collection<ValueType> {
      let list = java.util.ArrayList<ValueType>()
      for k in sortedKeyCollection {
        if let v = delegateDictionary[k] { _ = try? list.add(v) }
      }
      return list
    }

    open func entrySet() -> any java.util.Set<java.util.MapEntry<KeyType, ValueType>> {
      let set = java.util.HashSet<java.util.MapEntry<KeyType, ValueType>>(
        initialCapacity: sortedKeyCollection.count * 2)
      for k in sortedKeyCollection {
        if let v = delegateDictionary[k] { _ = try? set.add(java.util.MapEntry(k, v)) }
      }
      return set
    }

    // MARK: - SequencedMap — ordered first/last access

    open func firstEntry() -> java.util.MapEntry<KeyType, ValueType>? {
      guard let k = sortedKeyCollection.first, let v = delegateDictionary[k] else { return nil }
      return java.util.MapEntry(k, v)
    }

    open func lastEntry() -> java.util.MapEntry<KeyType, ValueType>? {
      guard let k = sortedKeyCollection.last, let v = delegateDictionary[k] else { return nil }
      return java.util.MapEntry(k, v)
    }

    open func pollFirstEntry() -> java.util.MapEntry<KeyType, ValueType>? {
      guard let k = sortedKeyCollection.first, let v = delegateDictionary[k] else { return nil }
      _ = remove(k)
      return java.util.MapEntry(k, v)
    }

    open func pollLastEntry() -> java.util.MapEntry<KeyType, ValueType>? {
      guard let k = sortedKeyCollection.last, let v = delegateDictionary[k] else { return nil }
      _ = remove(k)
      return java.util.MapEntry(k, v)
    }

    /// Inserts or moves `key` to the front of the encounter order.
    open func putFirst(_ key: KeyType, _ value: ValueType) throws -> ValueType? {
      let old = delegateDictionary.updateValue(value, forKey: key)
      if old != nil { sortedKeyCollection.removeAll { $0 == key } }
      sortedKeyCollection.insert(key, at: 0)
      return old
    }

    /// Inserts or moves `key` to the end of the encounter order.
    open func putLast(_ key: KeyType, _ value: ValueType) throws -> ValueType? {
      let old = delegateDictionary.updateValue(value, forKey: key)
      if old != nil { sortedKeyCollection.removeAll { $0 == key } }
      sortedKeyCollection.append(key)
      return old
    }

    open func reversedMap() -> any java.util.SequencedMap<KeyType, ValueType> {
      let rev = LinkedHashMap<KeyType, ValueType>()
      for k in sortedKeyCollection.reversed() {
        if let v = delegateDictionary[k] { _ = rev.put(k, v) }
      }
      return rev
    }

    open func sequencedKeySet() -> any java.util.SequencedSet<KeyType> {
      java.util._OrderedSetSnapshot(sortedKeyCollection)
    }

    open func sequencedValues() -> any java.util.SequencedCollection<ValueType> {
      let list = java.util.ArrayList<ValueType>()
      for k in sortedKeyCollection {
        if let v = delegateDictionary[k] { _ = try? list.add(v) }
      }
      return list
    }

    open func sequencedEntrySet() -> any java.util.SequencedSet<java.util.MapEntry<KeyType, ValueType>> {
      let entries = sortedKeyCollection.compactMap { k -> java.util.MapEntry<KeyType, ValueType>? in
        guard let v = delegateDictionary[k] else { return nil }
        return java.util.MapEntry(k, v)
      }
      return java.util._OrderedSetSnapshot(entries)
    }
  }

  /// The iterator for `LinkedHashMap` — iterates in insertion order.
  ///
  /// Conforms to both `IteratorProtocol` (Swift) and `java.util.Iterator` (JavApi).
  public struct LinkedHashMapIterator<KeyType: Hashable, ValueType>: IteratorProtocol {
    let sequence: Dictionary<KeyType, ValueType>
    let keys: Array<KeyType>
    var current = 0

    mutating public func next() -> (KeyType, ValueType)? {
      guard current < keys.count else { return nil }
      defer { current += 1 }
      let key = keys[current]
      if let value = sequence[key] { return (key, value) }
      return nil
    }
  }
}

extension java.util.LinkedHashMap: Sequence {
  public func makeIterator() -> java.util.LinkedHashMapIterator<KeyType, ValueType> {
    java.util.LinkedHashMapIterator<KeyType, ValueType>(
      sequence: delegateDictionary, keys: sortedKeyCollection, current: 0)
  }
}
