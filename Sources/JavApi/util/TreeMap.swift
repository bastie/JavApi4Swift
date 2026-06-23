/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.util {

  /// A Red-Black-tree-equivalent sorted map implementation of `java.util.TreeMap`.
  ///
  /// Keys are maintained in ascending natural order (`Comparable`).
  /// Backed internally by a sorted array of key-value pairs; all structural
  /// operations are O(log n) via binary search for lookup and O(n) for
  /// insertion/deletion (acceptable for the Java-API-compatibility goal of
  /// this library).
  ///
  /// **Supported Java 1.2 API:**
  /// - All `Map` methods: `put`, `get`, `remove`, `containsKey`, `containsValue`,
  ///   `size`, `isEmpty`, `clear`, `keySet`, `values`, `putAll`
  /// - `SortedMap` extensions: `firstKey`, `lastKey`, `headMap`, `tailMap`, `subMap`
  ///
  /// - Since: Java 1.2
  open class TreeMap<K: Hashable & Comparable, V>: java.util.AbstractMap<K, V>,
                                                    java.util.SortedMap {

    // MARK: - Backing store

    // Pairs kept in ascending key order at all times.
    internal var _pairs: [(key: K, value: V)] = []

    // MARK: - Init

    public override init() {}

    /// Creates a `TreeMap` pre-populated from any `java.util.Map`.
    public init(_ map: any java.util.Map<K, V>) {
      super.init()
      putAll(map)
    }

    // MARK: - Internal helpers

    /// Binary search: returns the index of `key` if present, or the insertion
    /// point (as a negative value `-(insertionPoint + 1)`) if absent.
    private func _indexOf(_ key: K) -> Int {
      var lo = 0
      var hi = _pairs.count - 1
      while lo <= hi {
        let mid = (lo + hi) >> 1
        let midKey = _pairs[mid].key
        if midKey < key {
          lo = mid + 1
        } else if midKey > key {
          hi = mid - 1
        } else {
          return mid          // exact match
        }
      }
      return -(lo + 1)        // not found; lo is insertion point
    }

    // MARK: - AbstractMap required override

    open override func entrySet() -> [(key: K, value: V)] {
      _pairs
    }

    // MARK: - Map — Mutation

    @discardableResult
    open override func put(_ key: K, _ value: V) -> V? {
      let idx = _indexOf(key)
      if idx >= 0 {
        let old = _pairs[idx].value
        _pairs[idx] = (key: key, value: value)
        return old
      } else {
        _pairs.insert((key: key, value: value), at: -(idx + 1))
        return nil
      }
    }

    @discardableResult
    open override func remove(_ key: K) -> V? {
      let idx = _indexOf(key)
      guard idx >= 0 else { return nil }
      let old = _pairs[idx].value
      _pairs.remove(at: idx)
      return old
    }

    open override func clear() {
      _pairs.removeAll()
    }

    // MARK: - Map — Query (O(log n))

    open override func size() -> Int { _pairs.count }

    open override func isEmpty() -> Bool { _pairs.isEmpty }

    open override func containsKey(_ key: K) -> Bool {
      _indexOf(key) >= 0
    }

    open override func get(_ key: K) -> V? {
      let idx = _indexOf(key)
      return idx >= 0 ? _pairs[idx].value : nil
    }

    // MARK: - Map — Views

    open override func keySet() -> Swift.Set<K> {
      Swift.Set(_pairs.map { $0.key })
    }

    open override func values() -> [V] {
      _pairs.map { $0.value }
    }

    // MARK: - SortedMap

    open func firstKey() throws -> K {
      guard let first = _pairs.first else {
        throw java.util.NoSuchElementException("TreeMap is empty")
      }
      return first.key
    }

    open func lastKey() throws -> K {
      guard let last = _pairs.last else {
        throw java.util.NoSuchElementException("TreeMap is empty")
      }
      return last.key
    }

    open func headMap(_ toKey: K) -> any java.util.SortedMap<K, V> {
      let sub = _pairs.filter { $0.key < toKey }
      return _SubTreeMap(pairs: sub)
    }

    open func tailMap(_ fromKey: K) -> any java.util.SortedMap<K, V> {
      let sub = _pairs.filter { $0.key >= fromKey }
      return _SubTreeMap(pairs: sub)
    }

    open func subMap(_ fromKey: K, _ toKey: K) -> any java.util.SortedMap<K, V> {
      let sub = _pairs.filter { $0.key >= fromKey && $0.key < toKey }
      return _SubTreeMap(pairs: sub)
    }
  }
}

// MARK: - Internal read-only submap view

extension java.util {

  /// Lightweight read-only view returned by `headMap`, `tailMap`, `subMap`.
  ///
  /// Mutations (`put`, `remove`, `clear`) are not supported on views —
  /// they `fatalError`, matching Java's throw-on-structural-modification semantics
  /// (simplified to fatal for this port).
  final class _SubTreeMap<K: Hashable & Comparable, V>: java.util.AbstractMap<K, V>,
                                                         java.util.SortedMap {

    private let _pairs: [(key: K, value: V)]

    init(pairs: [(key: K, value: V)]) {
      self._pairs = pairs
    }

    override func entrySet() -> [(key: K, value: V)] { _pairs }

    override func put(_ key: K, _ value: V) -> V? {
      fatalError("_SubTreeMap is a read-only view")
    }
    override func remove(_ key: K) -> V? {
      fatalError("_SubTreeMap is a read-only view")
    }

    func firstKey() throws -> K {
      guard let first = _pairs.first else {
        throw java.util.NoSuchElementException("subMap is empty")
      }
      return first.key
    }

    func lastKey() throws -> K {
      guard let last = _pairs.last else {
        throw java.util.NoSuchElementException("subMap is empty")
      }
      return last.key
    }

    func headMap(_ toKey: K) -> any java.util.SortedMap<K, V> {
      _SubTreeMap(pairs: _pairs.filter { $0.key < toKey })
    }

    func tailMap(_ fromKey: K) -> any java.util.SortedMap<K, V> {
      _SubTreeMap(pairs: _pairs.filter { $0.key >= fromKey })
    }

    func subMap(_ fromKey: K, _ toKey: K) -> any java.util.SortedMap<K, V> {
      _SubTreeMap(pairs: _pairs.filter { $0.key >= fromKey && $0.key < toKey })
    }
  }
}
