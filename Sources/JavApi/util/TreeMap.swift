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

    /// Optional custom key comparator; `nil` means natural ordering.
    private var _comparator: (any java.util.Comparator<K>)? = nil

    // MARK: - Init

    public override init() {}

    /// Creates a `TreeMap` ordered by a custom key comparator.
    ///
    /// - Parameter comparator: A `java.util.Comparator` defining the key order.
    /// - Since: Java 1.2
    public init(comparator: any java.util.Comparator<K>) {
      _comparator = comparator
      super.init()
    }

    /// Creates a `TreeMap` pre-populated from any `java.util.Map`.
    public init(_ map: any java.util.Map<K, V>) {
      super.init()
      putAll(map)
    }

    /// Creates a `TreeMap` containing the same mappings and using the same
    /// ordering as the given `SortedMap`.
    ///
    /// - Since: Java 1.2
    public init(sortedMap: any java.util.SortedMap<K, V>) {
      _comparator = sortedMap.comparator()   // Java-konform: Ordering der Quelle übernehmen
      super.init()
      let entries = sortedMap.entrySet()
      let it = entries.iterator()
      while it.hasNext() {
        if let entry = try? it.next() {
          put(entry.key, entry.value)   // put() maintains sorted order via _indexOf
        }
      }
    }

    // MARK: - Internal helpers

    /// Compares two keys using the custom comparator or natural ordering.
    internal func _compareKeys(_ a: K, _ b: K) -> Int {
      if let cmp = _comparator { return cmp.compare(a, b) }
      return a < b ? -1 : a > b ? 1 : 0
    }

    /// Returns the effective key-comparison closure for passing to subview constructors.
    /// Captures the comparator by value — no retain cycle with `self`.
    private func _cmpKeyFn() -> (K, K) -> Int {
      if let c = _comparator { return { a, b in c.compare(a, b) } }
      return { a, b in a < b ? -1 : a > b ? 1 : 0 }
    }

    /// Binary search: returns the index of `key` if present, or the insertion
    /// point (as `-(insertionPoint + 1)`) if absent.
    internal func _indexOf(_ key: K) -> Int {
      var lo = 0
      var hi = _pairs.count - 1
      while lo <= hi {
        let mid = (lo + hi) >> 1
        let c = _compareKeys(_pairs[mid].key, key)
        if c < 0 {
          lo = mid + 1
        } else if c > 0 {
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

    /// Returns the comparator used for key ordering, or `nil` if natural ordering.
    ///
    /// - Since: Java 1.2
    open func comparator() -> (any java.util.Comparator<K>)? { _comparator }

    /// Returns a shallow copy of this `TreeMap` with the same comparator.
    ///
    /// - Since: Java 1.2
    open func clone() -> TreeMap<K, V> {
      let copy: TreeMap<K, V>
      if let cmp = _comparator {
        copy = TreeMap<K, V>(comparator: cmp)
      } else {
        copy = TreeMap<K, V>()
      }
      copy._pairs = self._pairs
      return copy
    }

    // MARK: - NavigableMap — key-only navigation (Java 6)

    /// Returns the greatest key strictly less than `key`, or `nil` if none.
    ///
    /// - Since: Java 6
    open func lowerKey(_ key: K) -> K? { lowerEntry(key)?.key }

    /// Returns the greatest key less than or equal to `key`, or `nil` if none.
    ///
    /// - Since: Java 6
    open func floorKey(_ key: K) -> K? { floorEntry(key)?.key }

    /// Returns the least key greater than or equal to `key`, or `nil` if none.
    ///
    /// - Since: Java 6
    open func ceilingKey(_ key: K) -> K? { ceilingEntry(key)?.key }

    /// Returns the least key strictly greater than `key`, or `nil` if none.
    ///
    /// - Since: Java 6
    open func higherKey(_ key: K) -> K? { higherEntry(key)?.key }

    open func headMap(_ toKey: K) -> any java.util.SortedMap<K, V> {
      _SubTreeMap(pairs: _pairs.filter { _compareKeys($0.key, toKey) < 0 }, cmp: _cmpKeyFn())
    }

    open func tailMap(_ fromKey: K) -> any java.util.SortedMap<K, V> {
      _SubTreeMap(pairs: _pairs.filter { _compareKeys($0.key, fromKey) >= 0 }, cmp: _cmpKeyFn())
    }

    open func subMap(_ fromKey: K, _ toKey: K) -> any java.util.SortedMap<K, V> {
      _SubTreeMap(
        pairs: _pairs.filter { _compareKeys($0.key, fromKey) >= 0 && _compareKeys($0.key, toKey) < 0 },
        cmp: _cmpKeyFn()
      )
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
      _DescendingTreeMap(ascending: _pairs, cmp: _cmpKeyFn())
    }

    open func descendingKeySet() -> any java.util.NavigableSet<K> {
      let keys = _pairs.map { $0.key }
      return java.util._DescendingTreeSet(ascending: keys, cmp: _cmpKeyFn())
    }

    open func navigableKeySet() -> any java.util.NavigableSet<K> {
      let keys = _pairs.map { $0.key }
      return java.util._SubTreeSet(elements: keys, cmp: _cmpKeyFn())
    }

    // MARK: - NavigableMap — inclusive range views

    open func subMap(_ fromKey: K, _ fromInclusive: Bool,
                     _ toKey: K, _ toInclusive: Bool) -> any java.util.NavigableMap<K, V> {
      let cmp = _cmpKeyFn()
      let filtered = _pairs.filter { p in
        let lo = fromInclusive ? _compareKeys(p.key, fromKey) >= 0 : _compareKeys(p.key, fromKey) > 0
        let hi = toInclusive   ? _compareKeys(p.key, toKey) <= 0   : _compareKeys(p.key, toKey) < 0
        return lo && hi
      }
      return _SubTreeMap(pairs: filtered, cmp: cmp)
    }

    open func headMap(_ toKey: K, _ inclusive: Bool) -> any java.util.NavigableMap<K, V> {
      let cmp = _cmpKeyFn()
      return _SubTreeMap(
        pairs: _pairs.filter { inclusive ? _compareKeys($0.key, toKey) <= 0 : _compareKeys($0.key, toKey) < 0 },
        cmp: cmp
      )
    }

    open func tailMap(_ fromKey: K, _ inclusive: Bool) -> any java.util.NavigableMap<K, V> {
      let cmp = _cmpKeyFn()
      return _SubTreeMap(
        pairs: _pairs.filter { inclusive ? _compareKeys($0.key, fromKey) >= 0 : _compareKeys($0.key, fromKey) > 0 },
        cmp: cmp
      )
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

    /// Effective key-comparison function — matches the parent TreeMap's ordering.
    private let _cmp: (K, K) -> Int

    init(pairs: [(key: K, value: V)],
         cmp: @escaping (K, K) -> Int = { a, b in a < b ? -1 : a > b ? 1 : 0 }) {
      self._pairs = pairs
      self._cmp = cmp
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
      _SubTreeMap(pairs: _pairs.filter { _cmp($0.key, toKey) < 0 }, cmp: _cmp)
    }

    func tailMap(_ fromKey: K) -> any java.util.SortedMap<K, V> {
      _SubTreeMap(pairs: _pairs.filter { _cmp($0.key, fromKey) >= 0 }, cmp: _cmp)
    }

    func subMap(_ fromKey: K, _ toKey: K) -> any java.util.SortedMap<K, V> {
      _SubTreeMap(pairs: _pairs.filter { _cmp($0.key, fromKey) >= 0 && _cmp($0.key, toKey) < 0 }, cmp: _cmp)
    }

    // MARK: NavigableMap — navigation (linear search; views are small)

    func lowerEntry(_ key: K) -> java.util.MapEntry<K, V>? {
      guard let p = _pairs.last(where: { _cmp($0.key, key) < 0 }) else { return nil }
      return Entry(p.key, p.value)
    }

    func floorEntry(_ key: K) -> java.util.MapEntry<K, V>? {
      guard let p = _pairs.last(where: { _cmp($0.key, key) <= 0 }) else { return nil }
      return Entry(p.key, p.value)
    }

    func ceilingEntry(_ key: K) -> java.util.MapEntry<K, V>? {
      guard let p = _pairs.first(where: { _cmp($0.key, key) >= 0 }) else { return nil }
      return Entry(p.key, p.value)
    }

    func higherEntry(_ key: K) -> java.util.MapEntry<K, V>? {
      guard let p = _pairs.first(where: { _cmp($0.key, key) > 0 }) else { return nil }
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
      _DescendingTreeMap(ascending: _pairs, cmp: _cmp)
    }

    func descendingKeySet() -> any java.util.NavigableSet<K> {
      _DescendingTreeSet(ascending: _pairs.map { $0.key }, cmp: _cmp)
    }

    func navigableKeySet() -> any java.util.NavigableSet<K> {
      _SubTreeSet(elements: _pairs.map { $0.key }, cmp: _cmp)
    }

    // MARK: NavigableMap — inclusive range views

    func subMap(_ fromKey: K, _ fromInclusive: Bool,
                _ toKey: K, _ toInclusive: Bool) -> any java.util.NavigableMap<K, V> {
      let filtered = _pairs.filter { p in
        let lo = fromInclusive ? _cmp(p.key, fromKey) >= 0 : _cmp(p.key, fromKey) > 0
        let hi = toInclusive   ? _cmp(p.key, toKey) <= 0   : _cmp(p.key, toKey) < 0
        return lo && hi
      }
      return _SubTreeMap(pairs: filtered, cmp: _cmp)
    }

    func headMap(_ toKey: K, _ inclusive: Bool) -> any java.util.NavigableMap<K, V> {
      _SubTreeMap(
        pairs: _pairs.filter { inclusive ? _cmp($0.key, toKey) <= 0 : _cmp($0.key, toKey) < 0 },
        cmp: _cmp
      )
    }

    func tailMap(_ fromKey: K, _ inclusive: Bool) -> any java.util.NavigableMap<K, V> {
      _SubTreeMap(
        pairs: _pairs.filter { inclusive ? _cmp($0.key, fromKey) >= 0 : _cmp($0.key, fromKey) > 0 },
        cmp: _cmp
      )
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

    internal let _pairs: [(key: K, value: V)]   // descending order (relative to _ascCmp)

    /// The **ascending** key-comparator from the parent TreeMap (or natural ordering).
    private let _ascCmp: (K, K) -> Int

    init(ascending: [(key: K, value: V)],
         cmp: @escaping (K, K) -> Int = { a, b in a < b ? -1 : a > b ? 1 : 0 }) {
      self._pairs = Array(ascending.reversed())
      self._ascCmp = cmp
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
      return p.key  // largest key in ascending ordering
    }

    func lastKey() throws -> K {
      guard let p = _pairs.last else { throw java.util.NoSuchElementException() }
      return p.key  // smallest key in ascending ordering
    }

    // headMap in descending view: keys before toKey in descending = keys > toKey in ascending.
    // _pairs is descending; filter preserves descending order → reverse before init(ascending:).
    func headMap(_ toKey: K) -> any java.util.SortedMap<K, V> {
      let filtered = _pairs.filter { _ascCmp($0.key, toKey) > 0 }
      return _DescendingTreeMap(ascending: Array(filtered.reversed()), cmp: _ascCmp)
    }

    func tailMap(_ fromKey: K) -> any java.util.SortedMap<K, V> {
      let filtered = _pairs.filter { _ascCmp($0.key, fromKey) <= 0 }
      return _DescendingTreeMap(ascending: Array(filtered.reversed()), cmp: _ascCmp)
    }

    func subMap(_ fromKey: K, _ toKey: K) -> any java.util.SortedMap<K, V> {
      // fromKey >= toKey in descending ordering; ascending range: (toKey, fromKey]
      let filtered = _pairs.filter { _ascCmp($0.key, toKey) > 0 && _ascCmp($0.key, fromKey) <= 0 }
      return _DescendingTreeMap(ascending: Array(filtered.reversed()), cmp: _ascCmp)
    }

    // MARK: NavigableMap — inverted navigation
    // _pairs is in descending _ascCmp order (largest-in-asc first).
    // The descending map's ordering is the INVERSE of _ascCmp.
    //
    // lowerEntry(k) = greatest entry with key < k IN THE DESCENDING MAP'S ORDERING
    //               = entries where _ascCmp(key, k) > 0  ("greater" in asc = "less" in desc)
    //               = LAST of those in _pairs (last in desc array = smallest asc = greatest in desc)
    //
    //   lower   → last  { _ascCmp(key) > 0  }
    //   floor   → last  { _ascCmp(key) >= 0 }
    //   ceiling → first { _ascCmp(key) <= 0 }
    //   higher  → first { _ascCmp(key) < 0  }

    func lowerEntry(_ key: K) -> java.util.MapEntry<K, V>? {
      guard let p = _pairs.last(where: { _ascCmp($0.key, key) > 0  }) else { return nil }
      return Entry(p.key, p.value)
    }

    func floorEntry(_ key: K) -> java.util.MapEntry<K, V>? {
      guard let p = _pairs.last(where: { _ascCmp($0.key, key) >= 0 }) else { return nil }
      return Entry(p.key, p.value)
    }

    func ceilingEntry(_ key: K) -> java.util.MapEntry<K, V>? {
      guard let p = _pairs.first(where: { _ascCmp($0.key, key) <= 0 }) else { return nil }
      return Entry(p.key, p.value)
    }

    func higherEntry(_ key: K) -> java.util.MapEntry<K, V>? {
      guard let p = _pairs.first(where: { _ascCmp($0.key, key) < 0  }) else { return nil }
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
      _SubTreeMap(pairs: Array(_pairs.reversed()), cmp: _ascCmp)
    }

    func descendingKeySet() -> any java.util.NavigableSet<K> {
      _SubTreeSet(elements: Array(_pairs.reversed().map { $0.key }), cmp: _ascCmp)
    }

    func navigableKeySet() -> any java.util.NavigableSet<K> {
      // Keys in ascending order → wrap in _DescendingTreeSet so they appear descending.
      _DescendingTreeSet(ascending: Array(_pairs.reversed().map { $0.key }), cmp: _ascCmp)
    }

    // MARK: NavigableMap — inclusive range views (inverted)

    func subMap(_ fromKey: K, _ fromInclusive: Bool,
                _ toKey: K, _ toInclusive: Bool) -> any java.util.NavigableMap<K, V> {
      // fromKey >= toKey in descending ordering; ascending range filtered accordingly.
      let filtered = _pairs.filter { p in
        let lo = fromInclusive ? _ascCmp(p.key, fromKey) <= 0 : _ascCmp(p.key, fromKey) < 0
        let hi = toInclusive   ? _ascCmp(p.key, toKey) >= 0   : _ascCmp(p.key, toKey) > 0
        return lo && hi
      }
      return _DescendingTreeMap(ascending: Array(filtered.reversed()), cmp: _ascCmp)
    }

    func headMap(_ toKey: K, _ inclusive: Bool) -> any java.util.NavigableMap<K, V> {
      let filtered = _pairs.filter { inclusive ? _ascCmp($0.key, toKey) >= 0 : _ascCmp($0.key, toKey) > 0 }
      return _DescendingTreeMap(ascending: Array(filtered.reversed()), cmp: _ascCmp)
    }

    func tailMap(_ fromKey: K, _ inclusive: Bool) -> any java.util.NavigableMap<K, V> {
      let filtered = _pairs.filter { inclusive ? _ascCmp($0.key, fromKey) <= 0 : _ascCmp($0.key, fromKey) < 0 }
      return _DescendingTreeMap(ascending: Array(filtered.reversed()), cmp: _ascCmp)
    }

    // MARK: SequencedMap

    func reversedMap() -> any java.util.SequencedMap<K, V> { descendingMap() }

    func sequencedKeySet() -> any java.util.SequencedSet<K> {
      _DescendingTreeSet(ascending: Array(_pairs.reversed().map { $0.key }), cmp: _ascCmp)
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
