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

    // MARK: - Init

    public override init() {}

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

    // MARK: - Internal helpers

    /// Binary search: returns the index of `element` if present, or
    /// `-(insertionPoint + 1)` if absent.
    internal func _indexOf(_ element: E) -> Int {
      var lo = 0
      var hi = _elements.count - 1
      while lo <= hi {
        let mid = (lo + hi) >> 1
        if _elements[mid] < element {
          lo = mid + 1
        } else if _elements[mid] > element {
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

    open func headSet(_ toElement: E) -> any java.util.SortedSet<E> {
      _SubTreeSet(elements: _elements.filter { $0 < toElement })
    }

    open func tailSet(_ fromElement: E) -> any java.util.SortedSet<E> {
      _SubTreeSet(elements: _elements.filter { $0 >= fromElement })
    }

    open func subSet(_ fromElement: E, _ toElement: E) -> any java.util.SortedSet<E> {
      _SubTreeSet(elements: _elements.filter { $0 >= fromElement && $0 < toElement })
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
      _DescendingTreeSet(ascending: _elements)
    }

    open func descendingIterator() -> any java.util.Iterator<E> {
      _TreeSetIterator(elements: _elements.reversed())
    }

    // MARK: - NavigableSet — inclusive range views

    open func subSet(_ fromElement: E, _ fromInclusive: Bool,
                     _ toElement: E, _ toInclusive: Bool) -> any java.util.NavigableSet<E> {
      let filtered = _elements.filter { e in
        let lo = fromInclusive ? e >= fromElement : e > fromElement
        let hi = toInclusive   ? e <= toElement   : e < toElement
        return lo && hi
      }
      return _SubTreeSet(elements: filtered)
    }

    open func headSet(_ toElement: E, _ inclusive: Bool) -> any java.util.NavigableSet<E> {
      _SubTreeSet(elements: _elements.filter { inclusive ? $0 <= toElement : $0 < toElement })
    }

    open func tailSet(_ fromElement: E, _ inclusive: Bool) -> any java.util.NavigableSet<E> {
      _SubTreeSet(elements: _elements.filter { inclusive ? $0 >= fromElement : $0 > fromElement })
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

    internal let _elements: [E]   // ascending order

    init(elements: [E]) {
      self._elements = elements
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
      _SubTreeSet(elements: _elements.filter { $0 < toElement })
    }

    func tailSet(_ fromElement: E) -> any java.util.SortedSet<E> {
      _SubTreeSet(elements: _elements.filter { $0 >= fromElement })
    }

    func subSet(_ fromElement: E, _ toElement: E) -> any java.util.SortedSet<E> {
      _SubTreeSet(elements: _elements.filter { $0 >= fromElement && $0 < toElement })
    }

    // MARK: NavigableSet — closest-match navigation (linear search — snapshot is small)

    func lower(_ e: E) -> E? { _elements.last { $0 < e } }
    func floor(_ e: E) -> E? { _elements.last { $0 <= e } }
    func ceiling(_ e: E) -> E? { _elements.first { $0 >= e } }
    func higher(_ e: E) -> E? { _elements.first { $0 > e } }

    // MARK: NavigableSet — polling (read-only: not supported)

    func pollFirst() -> E? { fatalError("_SubTreeSet is a read-only view") }
    func pollLast() -> E?  { fatalError("_SubTreeSet is a read-only view") }

    // MARK: NavigableSet — descending views

    func descendingSet() -> any java.util.NavigableSet<E> {
      _DescendingTreeSet(ascending: _elements)
    }

    func descendingIterator() -> any java.util.Iterator<E> {
      _TreeSetIterator(elements: _elements.reversed())
    }

    // MARK: NavigableSet — inclusive range views

    func subSet(_ fromElement: E, _ fromInclusive: Bool,
                _ toElement: E, _ toInclusive: Bool) -> any java.util.NavigableSet<E> {
      let filtered = _elements.filter { e in
        let lo = fromInclusive ? e >= fromElement : e > fromElement
        let hi = toInclusive   ? e <= toElement   : e < toElement
        return lo && hi
      }
      return _SubTreeSet(elements: filtered)
    }

    func headSet(_ toElement: E, _ inclusive: Bool) -> any java.util.NavigableSet<E> {
      _SubTreeSet(elements: _elements.filter { inclusive ? $0 <= toElement : $0 < toElement })
    }

    func tailSet(_ fromElement: E, _ inclusive: Bool) -> any java.util.NavigableSet<E> {
      _SubTreeSet(elements: _elements.filter { inclusive ? $0 >= fromElement : $0 > fromElement })
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
  /// largest natural-order element appears first).
  final class _DescendingTreeSet<E: Hashable & Comparable & Equatable>: java.util.AbstractCollection<E>,
                                                                          java.util.NavigableSet {

    internal let _elements: [E]   // descending order

    /// Accepts the caller's ascending array and reverses it internally.
    init(ascending: [E]) {
      self._elements = ascending.reversed()
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

    // MARK: SortedSet — inverted semantics (largest is "first")

    func first() throws -> E {
      guard let f = _elements.first else { throw java.util.NoSuchElementException() }
      return f  // largest element
    }

    func last() throws -> E {
      guard let l = _elements.last else { throw java.util.NoSuchElementException() }
      return l  // smallest element
    }

    /// headSet in a descending view: elements before `toElement` in descending traversal
    /// = elements strictly greater than `toElement` in natural order.
    func headSet(_ toElement: E) -> any java.util.SortedSet<E> {
      _DescendingTreeSet(ascending: _elements.filter { $0 > toElement })
    }

    /// tailSet in a descending view: elements from `fromElement` onward in descending traversal
    /// = elements ≤ `fromElement` in natural order.
    func tailSet(_ fromElement: E) -> any java.util.SortedSet<E> {
      _DescendingTreeSet(ascending: _elements.filter { $0 <= fromElement })
    }

    func subSet(_ fromElement: E, _ toElement: E) -> any java.util.SortedSet<E> {
      // fromElement > toElement in a descending set
      _DescendingTreeSet(ascending: _elements.filter { $0 > toElement && $0 <= fromElement })
    }

    // MARK: NavigableSet — inverted navigation

    func lower(_ e: E) -> E?   { _elements.first { $0 > e } }   // next-larger in descending
    func floor(_ e: E) -> E?   { _elements.first { $0 >= e } }
    func ceiling(_ e: E) -> E? { _elements.first { $0 <= e } }
    func higher(_ e: E) -> E?  { _elements.first { $0 < e } }   // next-smaller in descending

    // MARK: NavigableSet — polling (read-only snapshot)

    func pollFirst() -> E? { fatalError("_DescendingTreeSet is a read-only snapshot") }
    func pollLast() -> E?  { fatalError("_DescendingTreeSet is a read-only snapshot") }

    // MARK: NavigableSet — descending of descending = ascending

    func descendingSet() -> any java.util.NavigableSet<E> {
      _SubTreeSet(elements: _elements.reversed())   // back to ascending
    }

    func descendingIterator() -> any java.util.Iterator<E> {
      _TreeSetIterator(elements: _elements.reversed())   // ascending order
    }

    // MARK: NavigableSet — inclusive range views (inverted semantics)

    func subSet(_ fromElement: E, _ fromInclusive: Bool,
                _ toElement: E, _ toInclusive: Bool) -> any java.util.NavigableSet<E> {
      // In descending set: fromElement >= toElement; iterate in [toElement, fromElement]
      let filtered = _elements.filter { e in
        let lo = fromInclusive ? e <= fromElement : e < fromElement
        let hi = toInclusive   ? e >= toElement   : e > toElement
        return lo && hi
      }
      return _DescendingTreeSet(ascending: filtered)
    }

    func headSet(_ toElement: E, _ inclusive: Bool) -> any java.util.NavigableSet<E> {
      // headSet in descending: elements > toElement (or >= if inclusive)
      _DescendingTreeSet(ascending: _elements.filter { inclusive ? $0 >= toElement : $0 > toElement })
    }

    func tailSet(_ fromElement: E, _ inclusive: Bool) -> any java.util.NavigableSet<E> {
      // tailSet in descending: elements < fromElement (or <= if inclusive)
      _DescendingTreeSet(ascending: _elements.filter { inclusive ? $0 <= fromElement : $0 < fromElement })
    }

    // MARK: SequencedSet

    func reversedSet() -> any java.util.SequencedSet<E> { descendingSet() }
  }
}
