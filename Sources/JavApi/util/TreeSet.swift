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
  /// **Supported Java 1.2 API:**
  /// - All `Collection` methods: `add`, `remove`, `contains`, `size`,
  ///   `isEmpty`, `clear`, `iterator`, `toArray`
  /// - `SortedSet` extensions: `first`, `last`, `headSet`, `tailSet`, `subSet`
  ///
  /// - Since: Java 1.2
  open class TreeSet<E: Hashable & Comparable & Equatable>: java.util.AbstractCollection<E>,
                                                             java.util.SortedSet {

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
    private func _indexOf(_ element: E) -> Int {
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
  }
}

// MARK: - Snapshot iterator

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

  // IteratorProtocol — non-throwing variant for Swift for-in
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

// MARK: - Read-only subview

extension java.util {

  final class _SubTreeSet<E: Hashable & Comparable & Equatable>: java.util.AbstractCollection<E>,
                                                                   java.util.SortedSet {

    private let _elements: [E]

    init(elements: [E]) {
      self._elements = elements
      super.init()
    }

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
  }
}
