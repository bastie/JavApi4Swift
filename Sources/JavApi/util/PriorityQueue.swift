/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.util {

  /// Swift implementation of `java.util.PriorityQueue`.
  ///
  /// An unbounded priority queue based on a binary **min-heap**.  The head of
  /// this queue is the *least* element according to the ordering in effect
  /// (natural ordering via `Comparable`, or a custom comparator).
  ///
  /// **Key complexity:**
  /// - `offer`/`add`: O(log n)
  /// - `peek`/`element`: O(1)
  /// - `poll`/`remove()`: O(log n)
  /// - `contains`/`remove(_ element:)`: O(n) — linear scan
  /// - `iterator()`: unordered snapshot (matches Java semantics)
  ///
  /// **Thread safety:** not thread-safe (matches Java).
  ///
  /// - Since: Java 5
  open class PriorityQueue<E: Comparable & Equatable>: AbstractCollection<E>, Queue {

    // MARK: - Backing store

    /// Binary min-heap stored as a zero-indexed array.
    /// Parent of i: (i-1)/2  ·  Children of i: 2i+1, 2i+2
    internal var _heap: [E] = []

    /// Optional comparator — overrides natural ordering when non-nil.
    private let _comparator: ((E, E) -> Int)?

    // MARK: - Init

    /// Creates an empty priority queue with natural ordering (`E: Comparable`).
    public override init() {
      _comparator = nil
      super.init()
    }

    /// Creates an empty priority queue with an initial capacity hint (ignored).
    public init(initialCapacity: Int) {
      _comparator = nil
      super.init()
    }

    /// Creates a priority queue with a custom comparator.
    ///
    /// - Parameter comparator: Returns a negative integer, zero, or a positive
    ///   integer when the first argument is less than, equal to, or greater than
    ///   the second.
    public init(comparator: @escaping (E, E) -> Int) {
      _comparator = comparator
      super.init()
    }

    /// Creates a priority queue with a `java.util.Comparator`.
    public init(comparator: any java.util.Comparator<E>) {
      _comparator = { comparator.compare($0, $1) }
      super.init()
    }

    /// Creates a priority queue pre-populated from `collection`, using natural ordering.
    public init(collection: any java.util.Collection<E>) {
      _comparator = nil
      super.init()
      let it = collection.iterator()
      while it.hasNext() {
        if let e = try? it.next() { _ = _heapPush(e) }
      }
    }

    /// Creates a priority queue pre-populated from another `PriorityQueue`,
    /// preserving its comparator.
    public init(_ other: PriorityQueue<E>) {
      _comparator = other._comparator
      _heap = other._heap
      super.init()
    }

    // MARK: - Priority ordering

    /// Returns `true` when `a` should appear before `b` in the heap (i.e., `a`
    /// has higher priority / is "less than" `b`).
    private func _higher(_ a: E, _ b: E) -> Bool {
      if let cmp = _comparator { return cmp(a, b) < 0 }
      return a < b
    }

    // MARK: - Heap operations

    /// Pushes `element` onto the heap and sifts it up. Returns `true` always.
    @discardableResult
    private func _heapPush(_ element: E) -> Bool {
      _heap.append(element)
      _siftUp(_heap.count - 1)
      return true
    }

    /// Pops the minimum element (index 0) and sifts the replacement down.
    private func _heapPop() -> E {
      let top = _heap[0]
      let last = _heap.removeLast()
      if !_heap.isEmpty {
        _heap[0] = last
        _siftDown(0)
      }
      return top
    }

    private func _siftUp(_ index: Int) {
      var i = index
      while i > 0 {
        let parent = (i - 1) >> 1
        if _higher(_heap[i], _heap[parent]) {
          _heap.swapAt(i, parent)
          i = parent
        } else {
          break
        }
      }
    }

    private func _siftDown(_ index: Int) {
      var i = index
      let n = _heap.count
      while true {
        let left  = 2 * i + 1
        let right = 2 * i + 2
        var smallest = i
        if left  < n && _higher(_heap[left],  _heap[smallest]) { smallest = left }
        if right < n && _higher(_heap[right], _heap[smallest]) { smallest = right }
        if smallest == i { break }
        _heap.swapAt(i, smallest)
        i = smallest
      }
    }

    // MARK: - AbstractCollection required overrides

    open override func size() -> Int { _heap.count }

    /// Returns an array containing all elements in this queue in **heap-storage
    /// order** (not priority order) — matches Java's `PriorityQueue.toArray()` contract.
    open override func toArray() -> [E?] { _heap.map { $0 } }

    /// Stores all elements into `a` and returns it.
    ///
    /// If `a` is large enough the elements are written in-place (heap-storage
    /// order); otherwise a new array of the correct size is returned.
    open func toArray(_ a: [E]) -> [E] {
      if a.count >= _heap.count {
        var result = a
        for (i, e) in _heap.enumerated() { result[i] = e }
        return Array(result[0..<_heap.count])
      }
      return _heap
    }

    /// Returns a snapshot iterator in **heap-storage order** (not priority order).
    ///
    /// This matches Java's `PriorityQueue.iterator()` contract: "The iterator
    /// provided … is not guaranteed to traverse the elements of the priority
    /// queue in any particular order."
    open override func iterator() -> any java.util.Iterator<E> {
      _PriorityQueueIterator(_heap)
    }

    open override func contains(_ element: E?) -> Bool {
      guard let element else { return false }
      return _heap.contains(element)
    }

    open override func clear() { _heap.removeAll() }

    /// Adds `element` using the optional syntax (wraps non-optional version).
    @discardableResult
    open override func add(_ element: E?) throws -> Bool {
      guard let element else { return false }
      return _heapPush(element)
    }

    /// Removes the first occurrence of `element` from the heap (O(n)).
    @discardableResult
    open override func remove(_ element: E?) -> Bool {
      guard let element, let idx = _heap.firstIndex(of: element) else { return false }
      let last = _heap.removeLast()
      if idx < _heap.count {
        _heap[idx] = last
        _siftUp(idx)
        _siftDown(idx)
      }
      return true
    }

    // MARK: - Queue protocol

    /// Inserts `element` into the priority queue.
    /// - Returns: `true` always (unbounded queue never rejects elements).
    @discardableResult
    open func add(_ element: E) throws -> Bool { _heapPush(element) }

    /// Retrieves, but does not remove, the head element.
    /// - Throws: `NoSuchElementException` if empty.
    open func element() throws -> E {
      guard let top = _heap.first else { throw java.util.NoSuchElementException() }
      return top
    }

    /// Inserts `element`; returns `true` always (unbounded queue).
    open func offer(_ element: E) -> Bool { _heapPush(element) }

    /// Retrieves, but does not remove, the head; returns `nil` if empty.
    open func peek() -> E? { _heap.first }

    /// Retrieves and removes the head; returns `nil` if empty.
    open func poll() -> E? { _heap.isEmpty ? nil : _heapPop() }

    /// Retrieves and removes the head.
    /// - Throws: `NoSuchElementException` if empty.
    open func remove() throws -> E {
      guard !_heap.isEmpty else { throw java.util.NoSuchElementException() }
      return _heapPop()
    }

    // MARK: - Comparator access

    /// Returns the comparator used to order elements, or `nil` for natural ordering.
    open func comparator() -> ((E, E) -> Int)? { _comparator }
  }
}

// MARK: - Snapshot iterator (heap-storage order)

private final class _PriorityQueueIterator<E: Equatable>: java.util.Iterator, IteratorProtocol {
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

  public func makeIterator() -> _PriorityQueueIterator<E> { self }
}
