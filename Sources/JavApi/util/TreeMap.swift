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
  /// insertion/deletion.
  ///
  /// **Supported API:**
  /// - All `Map` methods
  /// - `SortedMap` extensions: `firstKey`, `lastKey`, `headMap`, `tailMap`, `subMap`
  /// - `NavigableMap` extensions: navigation, polling, descending views,
  ///   inclusive range views
  /// - `SequencedMap` via protocol hierarchy (firstEntry, lastEntry, etc.)
  ///
  /// - Since: Java 1.2
  open class TreeMap<K: Hashable & Comparable, V: Equatable>: java.util.AbstractMap<K, V>,
                                                    java.util.NavigableMap {

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
    /// point (as `-(insertionPoint + 1)`) if absent.
    internal func _indexOf(_ key: K) -> Int {
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
          return mid
        }
      }
      return -(lo + 1)
    }

    // MARK: - AbstractMap required override

    open override func entrySet() -> any java.util.Set<java.util.MapEntry<K, V>> {
      let set = HashSet<java.util.MapEntry<K, V>>(initialCapacity: Swift.max(16, _pairs.count * 2))
      for pair in _pairs { _ = try? set.add(Entry(pair.key, pair.value)) }
      return set
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

    open override func containsKey(_ key: K) -> Bool { _indexOf(key) >= 0 }

    open override func get(_ key: K) -> V? {
      let idx = _indexOf(key)
      return idx >= 0 ? _pairs[idx].value : nil
    }

    // MARK: - Map — Views

    open override func keySet() -> any java.util.Set<K> {
      let set = HashSet<K>(initialCapacity: Swift.max(16, _pairs.count * 2))
      for pair in _pairs { _ = try? set.add(pair.key) }
      return set
    }

    open override func values() -> any java.util.Collection<V> {
      let list = java.util.ArrayList<V>()
      for pair in _pairs { _ = try? list.add(pair.value) }
      return list
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
      _SubTreeMap(pairs: _pairs.filter { $0.key < toKey })
    }

    open func tailMap(_ fromKey: K) -> any java.util.SortedMap<K, V> {
      _SubTreeMap(pairs: _pairs.filter { $0.key >= fromKey })
    }

    open func subMap(_ fromKey: K, _ toKey: K) -> any java.util.SortedMap<K, V> {
      _SubTreeMap(pairs: _pairs.filter { $0.key >= fromKey && $0.key < toKey })
    }

    // MARK: - NavigableMap — closest-match entry navigation

    open func lowerEntry(_ key: K) -> java.util.MapEntry<K, V>? {
      // greatest entry with key strictly less than `key`
      let idx = _indexOf(key)
      let pos = idx >= 0 ? idx - 1 : -(idx + 1) - 1
      guard pos >= 0 else { return nil }
      return Entry(_pairs[pos].key, _pairs[pos].value)
    }

    open func floorEntry(_ key: K) -> java.util.MapEntry<K, V>? {
      // greatest entry with key ≤ `key`
      let idx = _indexOf(key)
      if idx >= 0 { return Entry(_pairs[idx].key, _pairs[idx].value) }
      let pos = -(idx + 1) - 1
      guard pos >= 0 else { return nil }
      return Entry(_pairs[pos].key, _pairs[pos].value)
    }

    open func ceilingEntry(_ key: K) -> java.util.MapEntry<K, V>? {
      // least entry with key ≥ `key`
      let idx = _indexOf(key)
      if idx >= 0 { return Entry(_pairs[idx].key, _pairs[idx].value) }
      let pos = -(idx + 1)
      guard pos < _pairs.count else { return nil }
      return Entry(_pairs[pos].key, _pairs[pos].value)
    }

    open func higherEntry(_ key: K) -> java.util.MapEntry<K, V>? {
      // least entry with key strictly greater than `key`
      let idx = _indexOf(key)
      let pos = idx >= 0 ? idx + 1 : -(idx + 1)
      guard pos < _pairs.count else { return nil }
      return Entry(_pairs[pos].key, _pairs[pos].value)
    }

    // MARK: - NavigableMap — endpoint entries

    open func firstEntry() -> java.util.MapEntry<K, V>? {
      guard let p = _pairs.first else { return nil }
      return Entry(p.key, p.value)
    }

    open func lastEntry() -> java.util.MapEntry<K, V>? {
      guard let p = _pairs.last else { return nil }
      return Entry(p.key, p.value)
    }

    // MARK: - NavigableMap — polling

    open func pollFirstEntry() -> java.util.MapEntry<K, V>? {
      guard !_pairs.isEmpty else { return nil }
      let p = _pairs.removeFirst()
      return Entry(p.key, p.value)
    }

    open func pollLastEntry() -> java.util.MapEntry<K, V>? {
      guard !_pairs.isEmpty else { return nil }
      let p = _pairs.removeLast()
      return Entry(p.key, p.value)
    }

    // MARK: - NavigableMap — descending views

    open func descendingMap() -> any java.util.NavigableMap<K, V> {
      _DescendingTreeMap(ascending: _pairs)
    }

    open func descendingKeySet() -> any java.util.NavigableSet<K> {
      let keys = _pairs.map { $0.key }.reversed()
      return java.util._DescendingTreeSet(ascending: Array(keys))
    }

    open func navigableKeySet() -> any java.util.NavigableSet<K> {
      let keys = _pairs.map { $0.key }
      return java.util._SubTreeSet(elements: keys)
    }

    // MARK: - NavigableMap — inclusive range views

    open func subMap(_ fromKey: K, _ fromInclusive: Bool,
                     _ toKey: K, _ toInclusive: Bool) -> any java.util.NavigableMap<K, V> {
      let filtered = _pairs.filter { p in
        let lo = fromInclusive ? p.key >= fromKey : p.key > fromKey
        let hi = toInclusive   ? p.key <= toKey   : p.key < toKey
        return lo && hi
      }
      return _SubTreeMap(pairs: filtered)
    }

    open func headMap(_ toKey: K, _ inclusive: Bool) -> any java.util.NavigableMap<K, V> {
      _SubTreeMap(pairs: _pairs.filter { inclusive ? $0.key <= toKey : $0.key < toKey })
    }

    open func tailMap(_ fromKey: K, _ inclusive: Bool) -> any java.util.NavigableMap<K, V> {
      _SubTreeMap(pairs: _pairs.filter { inclusive ? $0.key >= fromKey : $0.key > fromKey })
    }

    // MARK: - SequencedMap overrides (concrete, O(1))

    open func reversedMap() -> any java.util.SequencedMap<K, V> { descendingMap() }

    open func sequencedKeySet() -> any java.util.SequencedSet<K> { navigableKeySet() }

    open func sequencedValues() -> any java.util.SequencedCollection<V> {
      let list = java.util.ArrayList<V>()
      for p in _pairs { _ = try? list.add(p.value) }
      return list
    }

    open func sequencedEntrySet() -> any java.util.SequencedSet<java.util.MapEntry<K, V>> {
      let entries = _pairs.map { java.util.MapEntry($0.key, $0.value) }
      return java.util._OrderedSetSnapshot(entries)
    }
  }
}

// MARK: - Lightweight ordered SequencedSet snapshot for entrySet views

extension java.util {

  /// A read-only ordered snapshot of elements that conforms to `SequencedSet`.
  ///
  /// Used by `TreeMap.sequencedEntrySet()` and similar methods to return
  /// a `SequencedSet` view without requiring elements to be `Comparable`
  /// (as `TreeSet` would demand).
  final class _OrderedSetSnapshot<E: Equatable & Hashable>: java.util.AbstractCollection<E>,
                                                             java.util.SequencedSet {

    private let _elements: [E]

    init(_ elements: [E]) { self._elements = elements; super.init() }

    override func size() -> Int { _elements.count }

    override func iterator() -> any java.util.Iterator<E> {
      _SnapshotIter(_elements)
    }

    override func contains(_ e: E?) -> Bool {
      guard let e else { return false }; return _elements.contains(e)
    }

    override func add(_ e: E?) throws -> Bool { fatalError("_OrderedSetSnapshot is read-only") }

    // SequencedCollection
    func getFirst() throws -> E {
      guard let f = _elements.first else { throw java.util.NoSuchElementException() }
      return f
    }
    func getLast() throws -> E {
      guard let l = _elements.last else { throw java.util.NoSuchElementException() }
      return l
    }
    func reversed() -> any java.util.SequencedCollection<E> {
      _OrderedSetSnapshot(_elements.reversed())
    }

    // SequencedSet
    func reversedSet() -> any java.util.SequencedSet<E> {
      _OrderedSetSnapshot(_elements.reversed())
    }
  }
}

// Simple snapshot iterator used by _OrderedSetSnapshot
private final class _SnapshotIter<E>: java.util.Iterator, IteratorProtocol {
  public typealias Element = E
  private let _elements: [E]
  private var _index: Int = 0
  init(_ elements: [E]) { _elements = elements }
  public func hasNext() -> Bool { _index < _elements.count }
  public func next() throws(java.util.NoSuchElementException) -> E {
    guard _index < _elements.count else { throw java.util.NoSuchElementException() }
    defer { _index += 1 }
    return _elements[_index]
  }
  public func next() -> E? {
    guard _index < _elements.count else { return nil }
    defer { _index += 1 }
    return _elements[_index]
  }
  public func remove() throws(java.lang.IllegalStateException) {
    throw java.lang.IllegalStateException()
  }
  public func makeIterator() -> _SnapshotIter<E> { self }
}

// MARK: - Internal read-only submap view (NavigableMap)

extension java.util {

  /// Lightweight read-only view returned by `headMap`, `tailMap`, `subMap`.
  ///
  /// Conforms to `NavigableMap` so that sub-views support the full Java 6
  /// navigation API.  Mutation methods (`put`, `remove`) are not supported.
  final class _SubTreeMap<K: Hashable & Comparable, V: Equatable>: java.util.AbstractMap<K, V>,
                                                         java.util.NavigableMap {

    private let _pairs: [(key: K, value: V)]

    init(pairs: [(key: K, value: V)]) {
      self._pairs = pairs
    }

    // MARK: AbstractMap

    override func entrySet() -> any java.util.Set<java.util.MapEntry<K, V>> {
      let set = HashSet<java.util.MapEntry<K, V>>(initialCapacity: Swift.max(16, _pairs.count * 2))
      for pair in _pairs { _ = try? set.add(Entry(pair.key, pair.value)) }
      return set
    }

    override func put(_ key: K, _ value: V) -> V? { fatalError("_SubTreeMap is a read-only view") }
    override func remove(_ key: K) -> V?           { fatalError("_SubTreeMap is a read-only view") }

    // MARK: SortedMap

    func firstKey() throws -> K {
      guard let first = _pairs.first else { throw java.util.NoSuchElementException("subMap is empty") }
      return first.key
    }

    func lastKey() throws -> K {
      guard let last = _pairs.last else { throw java.util.NoSuchElementException("subMap is empty") }
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

    // MARK: NavigableMap — navigation (linear search; views are small)

    func lowerEntry(_ key: K) -> java.util.MapEntry<K, V>? {
      guard let p = _pairs.last(where: { $0.key < key }) else { return nil }
      return Entry(p.key, p.value)
    }

    func floorEntry(_ key: K) -> java.util.MapEntry<K, V>? {
      guard let p = _pairs.last(where: { $0.key <= key }) else { return nil }
      return Entry(p.key, p.value)
    }

    func ceilingEntry(_ key: K) -> java.util.MapEntry<K, V>? {
      guard let p = _pairs.first(where: { $0.key >= key }) else { return nil }
      return Entry(p.key, p.value)
    }

    func higherEntry(_ key: K) -> java.util.MapEntry<K, V>? {
      guard let p = _pairs.first(where: { $0.key > key }) else { return nil }
      return Entry(p.key, p.value)
    }

    func firstEntry() -> java.util.MapEntry<K, V>? {
      guard let p = _pairs.first else { return nil }
      return Entry(p.key, p.value)
    }

    func lastEntry() -> java.util.MapEntry<K, V>? {
      guard let p = _pairs.last else { return nil }
      return Entry(p.key, p.value)
    }

    func pollFirstEntry() -> java.util.MapEntry<K, V>? { fatalError("_SubTreeMap is a read-only view") }
    func pollLastEntry() -> java.util.MapEntry<K, V>?  { fatalError("_SubTreeMap is a read-only view") }

    // MARK: NavigableMap — descending views

    func descendingMap() -> any java.util.NavigableMap<K, V> {
      _DescendingTreeMap(ascending: _pairs)
    }

    func descendingKeySet() -> any java.util.NavigableSet<K> {
      _DescendingTreeSet(ascending: _pairs.map { $0.key })
    }

    func navigableKeySet() -> any java.util.NavigableSet<K> {
      _SubTreeSet(elements: _pairs.map { $0.key })
    }

    // MARK: NavigableMap — inclusive range views

    func subMap(_ fromKey: K, _ fromInclusive: Bool,
                _ toKey: K, _ toInclusive: Bool) -> any java.util.NavigableMap<K, V> {
      let filtered = _pairs.filter { p in
        let lo = fromInclusive ? p.key >= fromKey : p.key > fromKey
        let hi = toInclusive   ? p.key <= toKey   : p.key < toKey
        return lo && hi
      }
      return _SubTreeMap(pairs: filtered)
    }

    func headMap(_ toKey: K, _ inclusive: Bool) -> any java.util.NavigableMap<K, V> {
      _SubTreeMap(pairs: _pairs.filter { inclusive ? $0.key <= toKey : $0.key < toKey })
    }

    func tailMap(_ fromKey: K, _ inclusive: Bool) -> any java.util.NavigableMap<K, V> {
      _SubTreeMap(pairs: _pairs.filter { inclusive ? $0.key >= fromKey : $0.key > fromKey })
    }

    // MARK: SequencedMap overrides

    func reversedMap() -> any java.util.SequencedMap<K, V> { descendingMap() }

    func sequencedKeySet() -> any java.util.SequencedSet<K> { navigableKeySet() }

    func sequencedValues() -> any java.util.SequencedCollection<V> {
      let list = java.util.ArrayList<V>()
      for p in _pairs { _ = try? list.add(p.value) }
      return list
    }

    func sequencedEntrySet() -> any java.util.SequencedSet<java.util.MapEntry<K, V>> {
      let entries = _pairs.map { java.util.MapEntry($0.key, $0.value) }
      return java.util._OrderedSetSnapshot(entries)
    }
  }
}

// MARK: - Read-only descending map snapshot (NavigableMap)

extension java.util {

  /// Lightweight read-only snapshot in **descending** key order.
  ///
  /// Returned by `TreeMap.descendingMap()`.  Navigation methods use inverted
  /// semantics (the entry with the largest key appears first).
  final class _DescendingTreeMap<K: Hashable & Comparable, V: Equatable>: java.util.AbstractMap<K, V>,
                                                               java.util.NavigableMap {

    internal let _pairs: [(key: K, value: V)]   // descending order

    init(ascending: [(key: K, value: V)]) {
      self._pairs = ascending.reversed()
    }

    // MARK: AbstractMap

    override func entrySet() -> any java.util.Set<java.util.MapEntry<K, V>> {
      let set = HashSet<java.util.MapEntry<K, V>>(initialCapacity: Swift.max(16, _pairs.count * 2))
      for p in _pairs { _ = try? set.add(Entry(p.key, p.value)) }
      return set
    }

    override func put(_ key: K, _ value: V) -> V? { fatalError("_DescendingTreeMap is a read-only snapshot") }
    override func remove(_ key: K) -> V?           { fatalError("_DescendingTreeMap is a read-only snapshot") }

    // MARK: SortedMap — inverted semantics

    func firstKey() throws -> K {
      guard let p = _pairs.first else { throw java.util.NoSuchElementException() }
      return p.key  // largest key
    }

    func lastKey() throws -> K {
      guard let p = _pairs.last else { throw java.util.NoSuchElementException() }
      return p.key  // smallest key
    }

    func headMap(_ toKey: K) -> any java.util.SortedMap<K, V> {
      _DescendingTreeMap(ascending: _pairs.filter { $0.key > toKey })
    }

    func tailMap(_ fromKey: K) -> any java.util.SortedMap<K, V> {
      _DescendingTreeMap(ascending: _pairs.filter { $0.key <= fromKey })
    }

    func subMap(_ fromKey: K, _ toKey: K) -> any java.util.SortedMap<K, V> {
      _DescendingTreeMap(ascending: _pairs.filter { $0.key > toKey && $0.key <= fromKey })
    }

    // MARK: NavigableMap — inverted navigation

    func lowerEntry(_ key: K) -> java.util.MapEntry<K, V>? {
      guard let p = _pairs.first(where: { $0.key > key }) else { return nil }
      return Entry(p.key, p.value)
    }

    func floorEntry(_ key: K) -> java.util.MapEntry<K, V>? {
      guard let p = _pairs.first(where: { $0.key >= key }) else { return nil }
      return Entry(p.key, p.value)
    }

    func ceilingEntry(_ key: K) -> java.util.MapEntry<K, V>? {
      guard let p = _pairs.first(where: { $0.key <= key }) else { return nil }
      return Entry(p.key, p.value)
    }

    func higherEntry(_ key: K) -> java.util.MapEntry<K, V>? {
      guard let p = _pairs.first(where: { $0.key < key }) else { return nil }
      return Entry(p.key, p.value)
    }

    func firstEntry() -> java.util.MapEntry<K, V>? {
      guard let p = _pairs.first else { return nil }
      return Entry(p.key, p.value)
    }

    func lastEntry() -> java.util.MapEntry<K, V>? {
      guard let p = _pairs.last else { return nil }
      return Entry(p.key, p.value)
    }

    func pollFirstEntry() -> java.util.MapEntry<K, V>? { fatalError("_DescendingTreeMap is a read-only snapshot") }
    func pollLastEntry() -> java.util.MapEntry<K, V>?  { fatalError("_DescendingTreeMap is a read-only snapshot") }

    // MARK: NavigableMap — descending of descending = ascending

    func descendingMap() -> any java.util.NavigableMap<K, V> {
      _SubTreeMap(pairs: _pairs.reversed())
    }

    func descendingKeySet() -> any java.util.NavigableSet<K> {
      _SubTreeSet(elements: _pairs.reversed().map { $0.key })
    }

    func navigableKeySet() -> any java.util.NavigableSet<K> {
      _DescendingTreeSet(ascending: _pairs.reversed().map { $0.key })
    }

    // MARK: NavigableMap — inclusive range views (inverted)

    func subMap(_ fromKey: K, _ fromInclusive: Bool,
                _ toKey: K, _ toInclusive: Bool) -> any java.util.NavigableMap<K, V> {
      let filtered = _pairs.filter { p in
        let lo = fromInclusive ? p.key <= fromKey : p.key < fromKey
        let hi = toInclusive   ? p.key >= toKey   : p.key > toKey
        return lo && hi
      }
      return _DescendingTreeMap(ascending: filtered)
    }

    func headMap(_ toKey: K, _ inclusive: Bool) -> any java.util.NavigableMap<K, V> {
      _DescendingTreeMap(ascending: _pairs.filter { inclusive ? $0.key >= toKey : $0.key > toKey })
    }

    func tailMap(_ fromKey: K, _ inclusive: Bool) -> any java.util.NavigableMap<K, V> {
      _DescendingTreeMap(ascending: _pairs.filter { inclusive ? $0.key <= fromKey : $0.key < fromKey })
    }

    // MARK: SequencedMap

    func reversedMap() -> any java.util.SequencedMap<K, V> { descendingMap() }

    func sequencedKeySet() -> any java.util.SequencedSet<K> {
      _DescendingTreeSet(ascending: _pairs.reversed().map { $0.key })
    }

    func sequencedValues() -> any java.util.SequencedCollection<V> {
      let list = java.util.ArrayList<V>()
      for p in _pairs { _ = try? list.add(p.value) }
      return list
    }

    func sequencedEntrySet() -> any java.util.SequencedSet<java.util.MapEntry<K, V>> {
      let entries = _pairs.map { java.util.MapEntry($0.key, $0.value) }
      return java.util._OrderedSetSnapshot(entries)
    }
  }
}
