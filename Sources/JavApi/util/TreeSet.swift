/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.util {

  /// A sorted set implementation of `java.util.TreeSet`.
  ///
  /// Elements are maintained in ascending natural order (`Comparable`) with
  /// no duplicates. Backed internally by a sorted array; all structural
  /// operations are O(log n) lookup and O(n) insert/delete.
  ///
  /// **Supported Java 1.2 / Java 6 / Java 21 API:**
  /// - All `Collection` methods
  /// - `SortedSet` extensions: `first`, `last`, `headSet`, `tailSet`, `subSet`
  /// - `NavigableSet` extensions: `lower`, `floor`, `ceiling`, `higher`,
  ///   `pollFirst`, `pollLast`, `descendingSet`, `descendingIterator`,
  ///   inclusive range views
  /// - `SequencedSet` / `SequencedCollection` via protocol hierarchy
  ///
  /// - Since: Java 1.2
  open class TreeSet<E: Hashable & Comparable & Equatable>: java.util.AbstractCollection<E>,
                                                             java.util.NavigableSet {

    // MARK: - Backing store

    /// Sorted, deduplicated element array — ascending order.
    internal var _elements: [E] = []

    /// Optional custom comparator; `nil` means natural ordering.
    private var _comparator: (any java.util.Comparator<E>)? = nil

    // MARK: - Init

    public override init() {}

    /// Creates a `TreeSet` ordered by a custom comparator.
    ///
    /// Elements are kept in the order defined by `comparator` rather than their
    /// natural `Comparable` ordering.
    ///
    /// - Parameter comparator: A `java.util.Comparator` defining the element order.
    /// - Since: Java 1.2
    public init(comparator: any java.util.Comparator<E>) {
      _comparator = comparator
      super.init()
    }

    /// Creates a `TreeSet` pre-populated from any `java.util.Collection`.
    public init(_ collection: any java.util.Collection<E?>) {
      super.init()
      let it = collection.iterator()
      while it.hasNext() {
        if let element = try? it.next() {
          _ = try? add(element)
        }
      }
    }

    /// Creates a `TreeSet` containing the same elements and using the same
    /// ordering as the given `SortedSet`.
    ///
    /// - Since: Java 1.2
    public init(sortedSet: any java.util.SortedSet<E>) {
      _comparator = sortedSet.comparator()   // Java-konform: Ordering der Quelle übernehmen
      super.init()
      let it = sortedSet.iterator()
      while it.hasNext() {
        if let element = try? it.next() {
          _ = try? add(element)   // add() maintains correct order via _indexOf
        }
      }
    }

    // MARK: - Internal helpers

    /// Compares two elements using the custom comparator or natural ordering.
    internal func _compare(_ a: E, _ b: E) -> Int {
      if let cmp = _comparator { return cmp.compare(a, b) }
      return a < b ? -1 : a > b ? 1 : 0
    }

    /// Returns the effective comparison closure for passing to subview constructors.
    /// Captures the comparator by value — no retain cycle with `self`.
    private func _cmpFn() -> (E, E) -> Int {
      if let c = _comparator { return { a, b in c.compare(a, b) } }
      return { a, b in a < b ? -1 : a > b ? 1 : 0 }
    }

    /// Binary search: returns the index of `element` if present, or
    /// `-(insertionPoint + 1)` if absent.
    internal func _indexOf(_ element: E) -> Int {
      var lo = 0
      var hi = _elements.count - 1
      while lo <= hi {
        let mid = (lo + hi) >> 1
        let c = _compare(_elements[mid], element)
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

    // MARK: - AbstractCollection required overrides

    open override func size() -> Int { _elements.count }

    open override func iterator() -> any java.util.Iterator<E> {
      _TreeSetIterator(elements: _elements)
    }

    // MARK: - Collection — Mutation

    @discardableResult
    open override func add(_ element: E?) throws -> Bool {
      guard let element else { return false }
      let idx = _indexOf(element)
      if idx >= 0 { return false }      // already present
      _elements.insert(element, at: -(idx + 1))
      return true
    }

    @discardableResult
    open override func remove(_ element: E?) -> Bool {
      guard let element else { return false }
      let idx = _indexOf(element)
      guard idx >= 0 else { return false }
      _elements.remove(at: idx)
      return true
    }

    open override func clear() {
      _elements.removeAll()
    }

    open override func contains(_ element: E?) -> Bool {
      guard let element else { return false }
      return _indexOf(element) >= 0
    }

    // MARK: - SortedSet

    open func first() throws -> E {
      guard let first = _elements.first else {
        throw java.util.NoSuchElementException("TreeSet is empty")
      }
      return first
    }

    open func last() throws -> E {
      guard let last = _elements.last else {
        throw java.util.NoSuchElementException("TreeSet is empty")
      }
      return last
    }

    /// Returns the comparator used to order elements, or `nil` if natural ordering.
    ///
    /// - Since: Java 1.2
    open func comparator() -> (any java.util.Comparator<E>)? { _comparator }

    /// Returns a shallow copy of this `TreeSet` with the same comparator.
    ///
    /// - Since: Java 1.2
    open func clone() -> TreeSet<E> {
      let copy: TreeSet<E>
      if let cmp = _comparator {
        copy = TreeSet<E>(comparator: cmp)
      } else {
        copy = TreeSet<E>()
      }
      copy._elements = self._elements
      return copy
    }

    open func headSet(_ toElement: E) -> any java.util.SortedSet<E> {
      _SubTreeSet(elements: _elements.filter { _compare($0, toElement) < 0 }, cmp: _cmpFn())
    }

    open func tailSet(_ fromElement: E) -> any java.util.SortedSet<E> {
      _SubTreeSet(elements: _elements.filter { _compare($0, fromElement) >= 0 }, cmp: _cmpFn())
    }

    open func subSet(_ fromElement: E, _ toElement: E) -> any java.util.SortedSet<E> {
      _SubTreeSet(
        elements: _elements.filter { _compare($0, fromElement) >= 0 && _compare($0, toElement) < 0 },
        cmp: _cmpFn()
      )
    }

    // MARK: - NavigableSet — closest-match navigation

    open func lower(_ e: E) -> E? {
      // Greatest element strictly less than e
      let idx = _indexOf(e)
      let pos = idx >= 0 ? idx - 1 : -(idx + 1) - 1
      return pos >= 0 ? _elements[pos] : nil
    }

    open func floor(_ e: E) -> E? {
      // Greatest element ≤ e
      let idx = _indexOf(e)
      if idx >= 0 { return _elements[idx] }
      let insertionPoint = -(idx + 1)
      let pos = insertionPoint - 1
      return pos >= 0 ? _elements[pos] : nil
    }

    open func ceiling(_ e: E) -> E? {
      // Least element ≥ e
      let idx = _indexOf(e)
      if idx >= 0 { return _elements[idx] }
      let insertionPoint = -(idx + 1)
      return insertionPoint < _elements.count ? _elements[insertionPoint] : nil
    }

    open func higher(_ e: E) -> E? {
      // Least element strictly greater than e
      let idx = _indexOf(e)
      let pos = idx >= 0 ? idx + 1 : -(idx + 1)
      return pos < _elements.count ? _elements[pos] : nil
    }

    // MARK: - NavigableSet — polling

    open func pollFirst() -> E? {
      guard !_elements.isEmpty else { return nil }
      return _elements.removeFirst()
    }

    open func pollLast() -> E? {
      guard !_elements.isEmpty else { return nil }
      return _elements.removeLast()
    }

    // MARK: - NavigableSet — descending views

    open func descendingSet() -> any java.util.NavigableSet<E> {
      _DescendingTreeSet(ascending: _elements, cmp: _cmpFn())
    }

    open func descendingIterator() -> any java.util.Iterator<E> {
      _TreeSetIterator(elements: _elements.reversed())
    }

    // MARK: - NavigableSet — inclusive range views

    open func subSet(_ fromElement: E, _ fromInclusive: Bool,
                     _ toElement: E, _ toInclusive: Bool) -> any java.util.NavigableSet<E> {
      let cmp = _cmpFn()
      let filtered = _elements.filter { e in
        let lo = fromInclusive ? _compare(e, fromElement) >= 0 : _compare(e, fromElement) > 0
        let hi = toInclusive   ? _compare(e, toElement) <= 0   : _compare(e, toElement) < 0
        return lo && hi
      }
      return _SubTreeSet(elements: filtered, cmp: cmp)
    }

    open func headSet(_ toElement: E, _ inclusive: Bool) -> any java.util.NavigableSet<E> {
      let cmp = _cmpFn()
      return _SubTreeSet(
        elements: _elements.filter { inclusive ? _compare($0, toElement) <= 0 : _compare($0, toElement) < 0 },
        cmp: cmp
      )
    }

    open func tailSet(_ fromElement: E, _ inclusive: Bool) -> any java.util.NavigableSet<E> {
      let cmp = _cmpFn()
      return _SubTreeSet(
        elements: _elements.filter { inclusive ? _compare($0, fromElement) >= 0 : _compare($0, fromElement) > 0 },
        cmp: cmp
      )
    }

    // MARK: - SequencedSet

    open func reversedSet() -> any java.util.SequencedSet<E> { descendingSet() }
  }
}

// MARK: - Snapshot ascending iterator

private final class _TreeSetIterator<E: Equatable>: java.util.Iterator, IteratorProtocol {
  public typealias Element = E

  private let _elements: [E]
  private var _index: Int = 0

  init(elements: [E]) { self._elements = elements }

  public func hasNext() -> Bool { _index < _elements.count }

  public func next() throws(java.util.NoSuchElementException) -> E {
    guard _index < _elements.count else {
      throw java.util.NoSuchElementException()
    }
    defer { _index += 1 }
    return _elements[_index]
  }

  public func next() -> E? {
    guard _index < _elements.count else { return nil }
    defer { _index += 1 }
    return _elements[_index]
  }

  public func remove() throws(java.lang.IllegalStateException) {
    throw java.lang.IllegalStateException("remove() not supported on TreeSet snapshot iterator")
  }

  public func makeIterator() -> _TreeSetIterator<E> { self }
}

// MARK: - Read-only ascending subview (NavigableSet)

extension java.util {

  /// Lightweight read-only ascending snapshot view returned by `headSet`, `tailSet`, `subSet`.
  ///
  /// Conforms to `NavigableSet` so that subviews of a `TreeSet` support the full
  /// Java 6 navigation API.  Mutation methods (`add`, `pollFirst`, `pollLast`) are
  /// not supported and will `fatalError`.
  final class _SubTreeSet<E: Hashable & Comparable & Equatable>: java.util.AbstractCollection<E>,
                                                                   java.util.NavigableSet {

    internal let _elements: [E]   // ascending order (relative to _cmp)

    /// Effective comparison function — matches the parent TreeSet's ordering.
    private let _cmp: (E, E) -> Int

    init(elements: [E], cmp: @escaping (E, E) -> Int = { a, b in a < b ? -1 : a > b ? 1 : 0 }) {
      self._elements = elements
      self._cmp = cmp
      super.init()
    }

    // MARK: AbstractCollection

    override func size() -> Int { _elements.count }

    override func iterator() -> any java.util.Iterator<E> {
      _TreeSetIterator(elements: _elements)
    }

    override func contains(_ element: E?) -> Bool {
      guard let element else { return false }
      return _elements.contains(element)
    }

    override func add(_ element: E?) throws -> Bool {
      fatalError("_SubTreeSet is a read-only view")
    }

    // MARK: SortedSet

    func first() throws -> E {
      guard let first = _elements.first else {
        throw java.util.NoSuchElementException("subSet is empty")
      }
      return first
    }

    func last() throws -> E {
      guard let last = _elements.last else {
        throw java.util.NoSuchElementException("subSet is empty")
      }
      return last
    }

    func headSet(_ toElement: E) -> any java.util.SortedSet<E> {
      _SubTreeSet(elements: _elements.filter { _cmp($0, toElement) < 0 }, cmp: _cmp)
    }

    func tailSet(_ fromElement: E) -> any java.util.SortedSet<E> {
      _SubTreeSet(elements: _elements.filter { _cmp($0, fromElement) >= 0 }, cmp: _cmp)
    }

    func subSet(_ fromElement: E, _ toElement: E) -> any java.util.SortedSet<E> {
      _SubTreeSet(elements: _elements.filter { _cmp($0, fromElement) >= 0 && _cmp($0, toElement) < 0 }, cmp: _cmp)
    }

    // MARK: NavigableSet — closest-match navigation (linear search — snapshot is small)

    func lower(_ e: E) -> E?   { _elements.last  { _cmp($0, e) < 0  } }
    func floor(_ e: E) -> E?   { _elements.last  { _cmp($0, e) <= 0 } }
    func ceiling(_ e: E) -> E? { _elements.first { _cmp($0, e) >= 0 } }
    func higher(_ e: E) -> E?  { _elements.first { _cmp($0, e) > 0  } }

    // MARK: NavigableSet — polling (read-only: not supported)

    func pollFirst() -> E? { fatalError("_SubTreeSet is a read-only view") }
    func pollLast() -> E?  { fatalError("_SubTreeSet is a read-only view") }

    // MARK: NavigableSet — descending views

    func descendingSet() -> any java.util.NavigableSet<E> {
      _DescendingTreeSet(ascending: _elements, cmp: _cmp)
    }

    func descendingIterator() -> any java.util.Iterator<E> {
      _TreeSetIterator(elements: _elements.reversed())
    }

    // MARK: NavigableSet — inclusive range views

    func subSet(_ fromElement: E, _ fromInclusive: Bool,
                _ toElement: E, _ toInclusive: Bool) -> any java.util.NavigableSet<E> {
      let filtered = _elements.filter { e in
        let lo = fromInclusive ? _cmp(e, fromElement) >= 0 : _cmp(e, fromElement) > 0
        let hi = toInclusive   ? _cmp(e, toElement) <= 0   : _cmp(e, toElement) < 0
        return lo && hi
      }
      return _SubTreeSet(elements: filtered, cmp: _cmp)
    }

    func headSet(_ toElement: E, _ inclusive: Bool) -> any java.util.NavigableSet<E> {
      _SubTreeSet(
        elements: _elements.filter { inclusive ? _cmp($0, toElement) <= 0 : _cmp($0, toElement) < 0 },
        cmp: _cmp
      )
    }

    func tailSet(_ fromElement: E, _ inclusive: Bool) -> any java.util.NavigableSet<E> {
      _SubTreeSet(
        elements: _elements.filter { inclusive ? _cmp($0, fromElement) >= 0 : _cmp($0, fromElement) > 0 },
        cmp: _cmp
      )
    }

    // MARK: SequencedSet

    func reversedSet() -> any java.util.SequencedSet<E> { descendingSet() }
  }
}

// MARK: - Read-only descending snapshot (NavigableSet)

extension java.util {

  /// Lightweight read-only snapshot in **descending** order.
  ///
  /// Returned by `TreeSet.descendingSet()` and `_SubTreeSet.descendingSet()`.
  /// `first()` / `last()` and navigation methods use inverted semantics (the
  /// element that sorts largest according to the original comparator appears first).
  final class _DescendingTreeSet<E: Hashable & Comparable & Equatable>: java.util.AbstractCollection<E>,
                                                                          java.util.NavigableSet {

    internal let _elements: [E]   // descending order (relative to _ascCmp)

    /// The **ascending** comparator from the parent TreeSet (or natural ordering).
    /// All navigation logic inverts this: greater-in-asc = "lower"-in-desc.
    private let _ascCmp: (E, E) -> Int

    /// Accepts the caller's ascending array (and the ascending comparator) and
    /// reverses the array internally so iteration is descending.
    init(ascending: [E], cmp: @escaping (E, E) -> Int = { a, b in a < b ? -1 : a > b ? 1 : 0 }) {
      self._elements = Array(ascending.reversed())
      self._ascCmp = cmp
      super.init()
    }

    // MARK: AbstractCollection

    override func size() -> Int { _elements.count }

    override func iterator() -> any java.util.Iterator<E> {
      _TreeSetIterator(elements: _elements)
    }

    override func contains(_ e: E?) -> Bool {
      guard let e else { return false }
      return _elements.contains(e)
    }

    override func add(_ e: E?) throws -> Bool { fatalError("_DescendingTreeSet is a read-only snapshot") }

    // MARK: SortedSet — inverted semantics (largest in asc-order is "first")

    func first() throws -> E {
      guard let f = _elements.first else { throw java.util.NoSuchElementException() }
      return f  // largest element in ascending ordering
    }

    func last() throws -> E {
      guard let l = _elements.last else { throw java.util.NoSuchElementException() }
      return l  // smallest element in ascending ordering
    }

    /// headSet in a descending view: elements before `toElement` in descending traversal
    /// = elements strictly greater than `toElement` in the ascending ordering.
    func headSet(_ toElement: E) -> any java.util.SortedSet<E> {
      // _elements is descending; filter preserves descending order.
      // Must reverse before passing to init(ascending:) which reverses again.
      let filtered = _elements.filter { _ascCmp($0, toElement) > 0 }
      return _DescendingTreeSet(ascending: Array(filtered.reversed()), cmp: _ascCmp)
    }

    /// tailSet in a descending view: elements from `fromElement` onward in descending traversal
    /// = elements ≤ `fromElement` in the ascending ordering.
    func tailSet(_ fromElement: E) -> any java.util.SortedSet<E> {
      let filtered = _elements.filter { _ascCmp($0, fromElement) <= 0 }
      return _DescendingTreeSet(ascending: Array(filtered.reversed()), cmp: _ascCmp)
    }

    func subSet(_ fromElement: E, _ toElement: E) -> any java.util.SortedSet<E> {
      // fromElement > toElement in descending ordering;
      // ascending range: (toElement, fromElement] → _ascCmp > 0 and _ascCmp <= 0
      let filtered = _elements.filter { _ascCmp($0, toElement) > 0 && _ascCmp($0, fromElement) <= 0 }
      return _DescendingTreeSet(ascending: Array(filtered.reversed()), cmp: _ascCmp)
    }

    // MARK: NavigableSet — inverted navigation
    //
    // _elements is stored in descending _ascCmp order (largest-in-asc first).
    // The descending set's own ordering is the INVERSE of _ascCmp.
    //
    // lower(e) = greatest element strictly less than e IN THE DESCENDING SET'S ORDERING
    //          = elements where _ascCmp(el, e) > 0  (they are "greater than e" in asc = "less than e" in desc)
    //          = LAST of those in _elements (last in desc array = smallest asc value = greatest in desc)
    //
    //   lower   → last  { _ascCmp > 0  }
    //   floor   → last  { _ascCmp >= 0 }
    //   ceiling → first { _ascCmp <= 0 }
    //   higher  → first { _ascCmp < 0  }

    func lower(_ e: E) -> E?   { _elements.last  { _ascCmp($0, e) > 0  } }
    func floor(_ e: E) -> E?   { _elements.last  { _ascCmp($0, e) >= 0 } }
    func ceiling(_ e: E) -> E? { _elements.first { _ascCmp($0, e) <= 0 } }
    func higher(_ e: E) -> E?  { _elements.first { _ascCmp($0, e) < 0  } }

    // MARK: NavigableSet — polling (read-only snapshot)

    func pollFirst() -> E? { fatalError("_DescendingTreeSet is a read-only snapshot") }
    func pollLast() -> E?  { fatalError("_DescendingTreeSet is a read-only snapshot") }

    // MARK: NavigableSet — descending of descending = ascending

    func descendingSet() -> any java.util.NavigableSet<E> {
      // _elements is descending; reversed gives ascending.
      _SubTreeSet(elements: Array(_elements.reversed()), cmp: _ascCmp)
    }

    func descendingIterator() -> any java.util.Iterator<E> {
      _TreeSetIterator(elements: _elements.reversed())   // ascending order
    }

    // MARK: NavigableSet — inclusive range views (inverted semantics)
    // In the descending set fromElement >= toElement (in descending ordering).
    // Ascending range: (toElement, fromElement] or variations thereof.

    func subSet(_ fromElement: E, _ fromInclusive: Bool,
                _ toElement: E, _ toInclusive: Bool) -> any java.util.NavigableSet<E> {
      let filtered = _elements.filter { e in
        let lo = fromInclusive ? _ascCmp(e, fromElement) <= 0 : _ascCmp(e, fromElement) < 0
        let hi = toInclusive   ? _ascCmp(e, toElement) >= 0   : _ascCmp(e, toElement) > 0
        return lo && hi
      }
      return _DescendingTreeSet(ascending: Array(filtered.reversed()), cmp: _ascCmp)
    }

    func headSet(_ toElement: E, _ inclusive: Bool) -> any java.util.NavigableSet<E> {
      let filtered = _elements.filter { inclusive ? _ascCmp($0, toElement) >= 0 : _ascCmp($0, toElement) > 0 }
      return _DescendingTreeSet(ascending: Array(filtered.reversed()), cmp: _ascCmp)
    }

    func tailSet(_ fromElement: E, _ inclusive: Bool) -> any java.util.NavigableSet<E> {
      let filtered = _elements.filter { inclusive ? _ascCmp($0, fromElement) <= 0 : _ascCmp($0, fromElement) < 0 }
      return _DescendingTreeSet(ascending: Array(filtered.reversed()), cmp: _ascCmp)
    }

    // MARK: SequencedSet

    func reversedSet() -> any java.util.SequencedSet<E> { descendingSet() }
  }
}
