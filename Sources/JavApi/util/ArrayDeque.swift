/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.util {

  /// Swift implementation of `java.util.ArrayDeque`.
  ///
  /// A resizable-array implementation of `Deque<E>`. Elements can be inserted
  /// and removed at both ends in amortized O(1) time.
  ///
  /// Unlike `LinkedList`, `ArrayDeque` is **not** a `List` — it has no
  /// index-based access. It is the preferred stack/queue implementation when
  /// thread-safety is not required.
  ///
  /// **Implementation note:** backed by a Swift `Array<E>` with the head at
  /// index 0. `addFirst`/`removeFirst` are O(n) in the worst case; all other
  /// deque operations are O(1) amortized.  For performance-critical code use
  /// `LinkedList` if head-insertion dominates.
  ///
  /// - Since: Java 6
  open class ArrayDeque<E: Equatable>: AbstractCollection<E>, Deque {

    // MARK: - Backing store

    internal var _elements: [E] = []

    // MARK: - Init

    /// Creates an empty deque.
    public override init() { super.init() }

    /// Creates an empty deque with an initial capacity hint (ignored in this
    /// implementation — provided for API compatibility).
    public init(numElements: Int) { super.init() }

    /// Creates a deque containing all elements of `collection` in iteration order.
    public init(collection: any java.util.Collection<E>) {
      super.init()
      let it = collection.iterator()
      while it.hasNext() {
        if let e = try? it.next() { _elements.append(e) }
      }
    }

    // MARK: - AbstractCollection required overrides

    open override func size() -> Int { _elements.count }

    open override func iterator() -> any java.util.Iterator<E> {
      _ArrayDequeIterator(_elements)
    }

    open override func contains(_ element: E?) -> Bool {
      guard let element else { return false }
      return _elements.contains(element)
    }

    open override func clear() { _elements.removeAll() }

    /// Appends `element` at the tail (satisfies `AbstractCollection.add(_:)`).
    @discardableResult
    open override func add(_ element: E?) throws -> Bool {
      guard let element else { return false }
      _elements.append(element)
      return true
    }

    /// Removes the first occurrence of `element`.
    @discardableResult
    open override func remove(_ element: E?) -> Bool {
      removeFirstOccurrence(element)
    }

    // MARK: - Deque — first-end operations

    open func offerFirst(_ elem: E) -> Bool {
      _elements.insert(elem, at: 0)
      return true
    }

    open func offerLast(_ elem: E) -> Bool {
      _elements.append(elem)
      return true
    }

    /// Retrieves, but does not remove, the first element.
    /// - Throws: `NoSuchElementException` if empty.
    open func getFirst() throws -> E {
      guard let f = _elements.first else { throw java.util.NoSuchElementException() }
      return f
    }

    /// Retrieves, but does not remove, the last element.
    /// - Throws: `NoSuchElementException` if empty.
    open func getLast() throws -> E {
      guard let l = _elements.last else { throw java.util.NoSuchElementException() }
      return l
    }

    open func peekFirst() -> E? { _elements.first }
    open func peekLast() -> E?  { _elements.last }

    /// Retrieves and removes the first element.
    /// - Throws: `NoSuchElementException` if empty.
    open func removeFirst() throws -> E {
      guard !_elements.isEmpty else { throw java.util.NoSuchElementException() }
      return _elements.removeFirst()
    }

    /// Retrieves and removes the last element.
    /// - Throws: `NoSuchElementException` if empty.
    open func removeLast() throws -> E {
      guard !_elements.isEmpty else { throw java.util.NoSuchElementException() }
      return _elements.removeLast()
    }

    open func pollFirst() -> E? { _elements.isEmpty ? nil : _elements.removeFirst() }
    open func pollLast() -> E?  { _elements.isEmpty ? nil : _elements.removeLast() }

    // MARK: - Deque — occurrence removal

    @discardableResult
    open func removeFirstOccurrence(_ elem: E?) -> Bool {
      guard let elem, let idx = _elements.firstIndex(of: elem) else { return false }
      _elements.remove(at: idx)
      return true
    }

    @discardableResult
    open func removeLastOccurrence(_ elem: E?) -> Bool {
      guard let elem, let idx = _elements.lastIndex(of: elem) else { return false }
      _elements.remove(at: idx)
      return true
    }

    // MARK: - Deque — descending iterator

    open func descendingIterator() -> any java.util.Iterator<E> {
      _ArrayDequeIterator(_elements.reversed())
    }

    // MARK: - Queue protocol

    /// Inserts `elem` at the tail; throws if the deque cannot be extended
    /// (never throws for `ArrayDeque`).
    @discardableResult
    open func add(_ elem: E) throws -> Bool {
      _elements.append(elem)
      return true
    }

    /// Retrieves, but does not remove, the head; throws if empty.
    open func element() throws -> E { try getFirst() }

    /// Inserts `elem` at the tail; always returns `true`.
    open func offer(_ elem: E) -> Bool { offerLast(elem) }

    /// Retrieves and removes the head; throws if empty.
    open func remove() throws -> E { try removeFirst() }

    // MARK: - Cloning

    /// Returns a shallow copy of this `ArrayDeque`.
    open func clone() -> ArrayDeque<E> {
      let copy = ArrayDeque<E>()
      copy._elements = _elements
      return copy
    }
  }
}

// MARK: - Snapshot iterator

private final class _ArrayDequeIterator<E: Equatable>: java.util.Iterator, IteratorProtocol {
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
    throw java.lang.IllegalStateException("remove() not supported on snapshot iterator")
  }

  public func makeIterator() -> _ArrayDequeIterator<E> { self }
}
