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

    /// Insertion-order key list — the single source of truth for iteration order.
    internal var sortedKeyCollection: Array<KeyType>

    // MARK: - Constructors

    public required init() {
      delegateDictionary = [:]
      sortedKeyCollection = []
    }

    public init(_ initialCapacity: Int) {
      delegateDictionary = Dictionary<KeyType, ValueType>(minimumCapacity: initialCapacity)
      sortedKeyCollection = Array<KeyType>()
    }

    public init(_ m: LinkedHashMap<KeyType, ValueType>) {
      self.delegateDictionary = m.delegateDictionary
      self.sortedKeyCollection = m.sortedKeyCollection
    }

    // MARK: - Map — Query

    open func size() -> Int { delegateDictionary.count }

    open func isEmpty() -> Bool { sortedKeyCollection.isEmpty }

    open func containsKey(_ key: KeyType) -> Bool { sortedKeyCollection.contains(key) }

    open func containsValue(_ value: ValueType) -> Bool {
      delegateDictionary.values.contains(value)
    }

    open func get(_ key: KeyType) -> ValueType? { delegateDictionary[key] }

    // MARK: - Map — Mutation

    @discardableResult
    open func put(_ key: KeyType, _ newValue: ValueType) -> ValueType? {
      let oldValue = delegateDictionary.updateValue(newValue, forKey: key)
      if oldValue == nil { sortedKeyCollection.append(key) }
      return oldValue
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
