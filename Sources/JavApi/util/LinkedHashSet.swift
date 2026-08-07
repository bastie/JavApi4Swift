/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.util {

  /// Swift implementation of `java.util.LinkedHashSet`.
  ///
  /// A hash set that maintains **insertion order**.  Backed by the inherited
  /// `HashSet._map` (`HashMap<E, _SentinelObject>`) for O(1) membership tests
  /// and mutation, plus a private `_order` array that records the encounter
  /// sequence.
  ///
  /// **Semantics that differ from plain `HashSet`:**
  /// - `iterator()` yields elements in insertion order.
  /// - `addFirst` / `addLast` move an existing element to the front/back
  ///   (matching Java 21 behaviour); new elements are simply inserted there.
  /// - `removeFirst` / `removeLast` remove and return the head/tail element.
  ///
  /// **Conformances:**
  /// - `java.util.Set<E>` (via `HashSet → AbstractSet`)
  /// - `java.util.SequencedSet<E>` (Java 21, JEP 431)
  ///
  /// - Since: Java 1.4
  open class LinkedHashSet<E: Hashable>: HashSet<E>, java.util.SequencedSet {

    // MARK: - Insertion-order tracking

    /// Elements in insertion order — kept in sync with `_map` at all times.
    internal var _order: [E] = []

    // MARK: - Init

    public override init() { super.init() }

    public override init(initialCapacity: Int) { super.init(initialCapacity: initialCapacity) }

    /// Creates a `LinkedHashSet` pre-populated from any `java.util.Collection`,
    /// preserving the collection's iteration order.
    public override init(collection: any java.util.Collection<E?>) {
      super.init(initialCapacity: Swift.max(16, collection.size() * 2))
      let it = collection.iterator()
      while it.hasNext() {
        if let e = try? it.next() { _ = try? add(e) }
      }
    }

    // MARK: - AbstractCollection overrides — keep _order in sync

    /// Adds `element` at the end of the encounter order if not already present.
    ///
    /// - Returns: `true` if the set was modified (element was absent).
    @discardableResult
    open override func add(_ element: E?) throws -> Bool {
      guard let element else { return false }
      let added = try super.add(element)
      if added { _order.append(element) }
      return added
    }

    /// Removes `element` from both the backing map and the order array.
    @discardableResult
    open override func remove(_ element: E?) -> Bool {
      guard let element else { return false }
      let removed = super.remove(element)
      if removed { _order.removeAll { $0 == element } }
      return removed
    }

    /// Removes all elements.
    open override func clear() {
      super.clear()
      _order.removeAll()
    }

    /// Returns an iterator over elements in **insertion order**.
    open override func iterator() -> any java.util.Iterator<E> {
      _LinkedHashSetIterator(_order)
    }

    // MARK: - SequencedCollection

    /// Returns the first element in insertion order.
    /// - Throws: `NoSuchElementException` if empty.
    open func getFirst() throws -> E {
      guard let f = _order.first else { throw java.util.NoSuchElementException() }
      return f
    }

    /// Returns the last element in insertion order.
    /// - Throws: `NoSuchElementException` if empty.
    open func getLast() throws -> E {
      guard let l = _order.last else { throw java.util.NoSuchElementException() }
      return l
    }

    /// Inserts `e` at the front of the encounter order.
    ///
    /// If `e` is already present it is **moved** to the front (not duplicated),
    /// matching Java 21 `LinkedHashSet` semantics.
    open func addFirst(_ e: E) throws {
      _forceRemove(e)
      _order.insert(e, at: 0)
      _ = _map.put(e, .shared)
    }

    /// Inserts `e` at the end of the encounter order.
    ///
    /// If `e` is already present it is **moved** to the end (not duplicated),
    /// matching Java 21 `LinkedHashSet` semantics.
    open func addLast(_ e: E) throws {
      _forceRemove(e)
      _order.append(e)
      _ = _map.put(e, .shared)
    }

    /// Removes and returns the first element.
    /// - Throws: `NoSuchElementException` if empty.
    open func removeFirst() throws -> E {
      guard !_order.isEmpty else { throw java.util.NoSuchElementException() }
      let e = _order.removeFirst()
      _ = _map.remove(e)
      return e
    }

    /// Removes and returns the last element.
    /// - Throws: `NoSuchElementException` if empty.
    open func removeLast() throws -> E {
      guard !_order.isEmpty else { throw java.util.NoSuchElementException() }
      let e = _order.removeLast()
      _ = _map.remove(e)
      return e
    }

    /// Returns a snapshot of this set's elements in **reverse** insertion order
    /// as a `SequencedCollection`.
    open func reversed() -> any java.util.SequencedCollection<E> {
      let rev = LinkedHashSet<E>(initialCapacity: _order.count * 2)
      for e in _order.reversed() { _ = try? rev.add(e) }
      return rev
    }

    // MARK: - SequencedSet

    /// Returns a snapshot of this set's elements in **reverse** insertion order
    /// as a `SequencedSet`.
    open func reversedSet() -> any java.util.SequencedSet<E> {
      let rev = LinkedHashSet<E>(initialCapacity: _order.count * 2)
      for e in _order.reversed() { _ = try? rev.add(e) }
      return rev
    }

    // MARK: - Cloning

    /// Returns a shallow copy preserving insertion order.
    open override func clone() -> HashSet<E> {
      let copy = LinkedHashSet<E>(initialCapacity: _order.count * 2)
      for e in _order { _ = try? copy.add(e) }
      return copy
    }

    // MARK: - Internal helper

    /// Removes `e` from both `_map` and `_order` without returning a result.
    /// Used by `addFirst`/`addLast` to move an existing element.
    private func _forceRemove(_ e: E) {
      _ = _map.remove(e)
      _order.removeAll { $0 == e }
    }
  }
}

// MARK: - Insertion-order iterator

/// Snapshot iterator over a `LinkedHashSet`'s ordered key array.
private final class _LinkedHashSetIterator<E: Hashable>: java.util.Iterator, IteratorProtocol {
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

  public func makeIterator() -> _LinkedHashSetIterator<E> { self }
}
