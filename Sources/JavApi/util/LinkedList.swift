/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

// MARK: - Internal node (outside java.util to avoid generic-shadowing)

/// Internal doubly-linked node for ``java.util.LinkedList``.
/// Named `_LinkedListNode` to avoid the `Node<E>` generic-parameter
/// shadowing that would occur inside `extension java.util { class LinkedList<E> { class Node<E> } }`.
internal final class _LinkedListNode<E> {
  var element: E?
  var prev: _LinkedListNode<E>?
  var next: _LinkedListNode<E>?

  init(_ element: E?, prev: _LinkedListNode<E>? = nil, next: _LinkedListNode<E>? = nil) {
    self.element = element
    self.prev = prev
    self.next = next
  }
}

// MARK: - LinkedList

extension java.util {

  /// Swift implementation of ``java.util.LinkedList``.
  ///
  /// A doubly-linked list that implements `List`, `Deque`, and `Queue`.
  /// - Reference semantics: assigning a `LinkedList` to a second variable
  ///   gives access to the same underlying list (Java behaviour).
  /// - Thread safety: not thread-safe (matches Java).
  ///
  /// - Since: Java 1.2
  open class LinkedList<E: Equatable>: AbstractSequentialList<E>, Deque {

    // MARK: - Storage

    internal var head: _LinkedListNode<E>?
    internal var tail: _LinkedListNode<E>?
    internal var count: Int = 0

    // MARK: - Constructors

    /// Creates an empty linked list.
    public override init() {
      super.init()
    }

    /// Creates a linked list containing all elements of `collection` in iteration order.
    public init<C: java.util.Collection>(collection: C) where C.E == E {
      super.init()
      let it = collection.iterator()
      while it.hasNext() {
        let e: E? = try? it.next()
        linkLast(e)
      }
    }

    // MARK: - Internal link / unlink helpers

    @discardableResult
    internal func linkLast(_ element: E?) -> _LinkedListNode<E> {
      let node = _LinkedListNode(element, prev: tail, next: nil)
      if let t = tail { t.next = node } else { head = node }
      tail = node
      count += 1
      return node
    }

    @discardableResult
    internal func linkFirst(_ element: E?) -> _LinkedListNode<E> {
      let node = _LinkedListNode(element, prev: nil, next: head)
      if let h = head { h.prev = node } else { tail = node }
      head = node
      count += 1
      return node
    }

    internal func linkBefore(_ element: E?, _ successor: _LinkedListNode<E>) {
      let node = _LinkedListNode(element, prev: successor.prev, next: successor)
      if let p = successor.prev { p.next = node } else { head = node }
      successor.prev = node
      count += 1
    }

    @discardableResult
    internal func unlinkFirst() -> E? {
      guard let h = head else { return nil }
      let element = h.element
      head = h.next
      head?.prev = nil
      if head == nil { tail = nil }
      count -= 1
      return element
    }

    @discardableResult
    internal func unlinkLast() -> E? {
      guard let t = tail else { return nil }
      let element = t.element
      tail = t.prev
      tail?.next = nil
      if tail == nil { head = nil }
      count -= 1
      return element
    }

    @discardableResult
    internal func unlink(_ node: _LinkedListNode<E>) -> E? {
      let element = node.element
      node.prev?.next = node.next
      node.next?.prev = node.prev
      if node === head { head = node.next }
      if node === tail { tail = node.prev }
      count -= 1
      return element
    }

    /// Returns the node at index `location` — O(n/2) via midpoint shortcut.
    internal func nodeAt(_ location: Int) -> _LinkedListNode<E> {
      if location < count / 2 {
        var n = head!
        for _ in 0..<location { n = n.next! }
        return n
      } else {
        var n = tail!
        for _ in 0..<(count - 1 - location) { n = n.prev! }
        return n
      }
    }

    // MARK: - Size

    public override func size() -> Int { count }

    // MARK: - List — index access

    public override func get(_ location: Int) throws -> E? {
      guard location >= 0 && location < count else {
        throw IndexOutOfBoundsException("Index: \(location), Size: \(count)")
      }
      return nodeAt(location).element
    }

    public override func set(_ location: Int, _ element: E?) throws -> E? {
      guard location >= 0 && location < count else {
        throw IndexOutOfBoundsException("Index: \(location), Size: \(count)")
      }
      let node = nodeAt(location)
      let old = node.element
      node.element = element
      return old
    }

    /// Appends `element` (optional) — satisfies `Collection.add(_ element: E?) throws -> Bool`.
    @discardableResult
    public override func add(_ element: E?) throws -> Bool {
      linkLast(element)
      return true
    }

    public override func add(_ location: Int, _ element: E?) throws {
      guard location >= 0 && location <= count else {
        throw IndexOutOfBoundsException("Index: \(location), Size: \(count)")
      }
      if location == count { linkLast(element) } else { linkBefore(element, nodeAt(location)) }
    }

    public override func remove(_ location: Int) throws -> E? {
      guard location >= 0 && location < count else {
        throw IndexOutOfBoundsException("Index: \(location), Size: \(count)")
      }
      return unlink(nodeAt(location))
    }

    @discardableResult
    public override func remove(_ element: E?) -> Bool {
      var n = head
      while let node = n {
        if node.element == element { unlink(node); return true }
        n = node.next
      }
      return false
    }

    public override func clear() {
      head = nil; tail = nil; count = 0
    }

    // MARK: - List — search

    public override func contains(_ element: E?) -> Bool {
      return indexOf(element: element) >= 0
    }

    public override func indexOf(element: Any?) -> Int {
      guard let typed = element as? E? else { return -1 }
      var idx = 0; var n = head
      while let node = n {
        if node.element == typed { return idx }
        idx += 1; n = node.next
      }
      return -1
    }

    public override func lastIndexOf(_ element: Any?) -> Int {
      guard let typed = element as? E? else { return -1 }
      var idx = count - 1; var n = tail
      while let node = n {
        if node.element == typed { return idx }
        idx -= 1; n = node.prev
      }
      return -1
    }

    // MARK: - List — subList

    public override func subList(_ start: Int, _ end: Int) -> any java.util.List {
      let sub = LinkedList<E>()
      var n: _LinkedListNode<E>? = (start < count) ? nodeAt(start) : nil
      for _ in start..<end {
        guard let node = n else { break }
        sub.linkLast(node.element)
        n = node.next
      }
      return sub
    }

    // MARK: - Deque / Queue — first-end operations

    /// Returns but does not remove the first element.
    /// - Throws: `NoSuchElementException` if empty.
    public func getFirst() throws -> E? {
      guard let h = head else { throw NoSuchElementException() }
      return h.element
    }

    /// Returns but does not remove the last element.
    /// - Throws: `NoSuchElementException` if empty.
    public func getLast() throws -> E? {
      guard let t = tail else { throw NoSuchElementException() }
      return t.element
    }

    /// Inserts `elem` at the front (Deque protocol — non-optional).
    public func addFirst(_ elem: E) throws { linkFirst(elem) }

    /// Inserts `elem` at the tail (Deque protocol — non-optional).
    public func addLast(_ elem: E) throws { linkLast(elem) }

    /// Inserts `elem` at the front; always returns `true` (unbounded deque).
    public func offerFirst(_ elem: E) -> Bool { linkFirst(elem); return true }

    /// Inserts `elem` at the tail; always returns `true` (unbounded deque).
    public func offerLast(_ elem: E) -> Bool { linkLast(elem); return true }

    /// Returns the first element without removal, or `nil` if empty.
    public func peekFirst() -> E? { head?.element }

    /// Returns the last element without removal, or `nil` if empty.
    public func peekLast() -> E? { tail?.element }

    /// Removes and returns the first element, or `nil` if empty.
    public func pollFirst() -> E? { isEmpty() ? nil : unlinkFirst() }

    /// Removes and returns the last element, or `nil` if empty.
    public func pollLast() -> E? { isEmpty() ? nil : unlinkLast() }

    @discardableResult
    public func removeFirst() throws -> E? {
      guard !isEmpty() else { throw NoSuchElementException() }
      return unlinkFirst()
    }

    @discardableResult
    public func removeLast() throws -> E? {
      guard !isEmpty() else { throw NoSuchElementException() }
      return unlinkLast()
    }

    // MARK: - Deque — occurrence removal

    /// Removes the first occurrence of `elem`; returns `true` if the deque changed.
    @discardableResult
    public func removeFirstOccurrence(_ elem: E?) -> Bool {
      return remove(elem)
    }

    /// Removes the last occurrence of `elem`; returns `true` if the deque changed.
    @discardableResult
    public func removeLastOccurrence(_ elem: E?) -> Bool {
      var n = tail
      while let node = n {
        if node.element == elem { unlink(node); return true }
        n = node.prev
      }
      return false
    }

    // MARK: - Deque — reverse iterator

    /// Returns an iterator over elements in reverse order (tail → head).
    public func descendingIterator() -> any java.util.Iterator<E> {
      return LinkedListDescendingIterator<E>(list: self)
    }

    // MARK: - Queue protocol (non-optional Element)

    /// Appends `elem` (non-optional) — satisfies `Queue.add(_ elem: Element) throws -> Bool`.
    @discardableResult
    public func add(_ elem: E) throws -> Bool {
      linkLast(elem)
      return true
    }

    /// Returns the head without removal (non-optional).
    /// - Throws: `NoSuchElementException` if empty.
    public func element() throws -> E {
      guard let h = head, let e = h.element else { throw NoSuchElementException() }
      return e
    }

    /// Inserts `elem` at the tail; always returns `true`.
    public func offer(_ elem: E) -> Bool { linkLast(elem); return true }

    /// Returns the head element, or `nil` if empty.
    public func peek() -> E? { head?.element }

    /// Removes and returns the head element, or `nil` if empty.
    public func poll() -> E? { pollFirst() }

    /// Removes and returns the head element (non-optional).
    /// - Throws: `NoSuchElementException` if empty.
    public func remove() throws -> E {
      guard !isEmpty() else { throw NoSuchElementException() }
      guard let e = unlinkFirst() else { throw NoSuchElementException() }
      return e
    }

    // MARK: - ListIterator

    public override func listIterator(_ location: Int) -> any java.util.ListIterator<E> {
      return LinkedListIterator<E>(list: self, startIndex: location)
    }

    public override func listIterator() -> any java.util.ListIterator<E> {
      return listIterator(0)
    }

    // MARK: - toArray

    public override func toArray() -> [E?] {
      var result: [E?] = []
      result.reserveCapacity(count)
      var n = head
      while let node = n { result.append(node.element); n = node.next }
      return result
    }

    // MARK: - hashCode

    public override func hashCode() -> Int {
      var result = 1; var n = head
      while let node = n {
        let h: Int
        if let e = node.element, let hh = e as? AnyHashable { h = hh.hashValue } else { h = 0 }
        result = 31 &* result &+ h
        n = node.next
      }
      return result
    }

    // MARK: - clone

    public func clone() -> LinkedList<E> {
      let copy = LinkedList<E>()
      var n = head
      while let node = n { copy.linkLast(node.element); n = node.next }
      return copy
    }
  }
}

// MARK: - LinkedListIterator

// MARK: - LinkedListDescendingIterator

/// Reverse `Iterator` for `java.util.LinkedList` — tail to head.
public final class LinkedListDescendingIterator<E: Equatable>: java.util.Iterator, IteratorProtocol {
  public typealias Element = E

  private var current: _LinkedListNode<E>?

  internal init(list: java.util.LinkedList<E>) {
    self.current = list.tail
  }

  public func hasNext() -> Bool { current != nil }

  public func next() throws(java.util.NoSuchElementException) -> E {
    guard let node = current, let element = node.element else {
      throw java.util.NoSuchElementException()
    }
    current = node.prev
    return element
  }

  /// Swift `IteratorProtocol.next()` — returns `nil` at end.
  public func next() -> E? {
    guard let node = current else { return nil }
    defer { current = node.prev }
    return node.element
  }

  public func makeIterator() -> LinkedListDescendingIterator<E> { self }
}

// MARK: - LinkedListIterator

/// Bidirectional `ListIterator` for `java.util.LinkedList`.
///
/// Conforms to `java.util.ListIterator` and `IteratorProtocol` for native Swift `for-in`.
public final class LinkedListIterator<E: Equatable>: java.util.ListIterator, IteratorProtocol {
  public typealias Element = E

  private let list: java.util.LinkedList<E>
  private var nextNode: _LinkedListNode<E>?
  private var lastReturned: _LinkedListNode<E>?
  private var nextIdx: Int

  internal init(list: java.util.LinkedList<E>, startIndex: Int) {
    self.list = list
    self.nextIdx = startIndex
    self.nextNode = (startIndex < list.count) ? list.nodeAt(startIndex) : nil
  }

  // MARK: - Iterator

  public func hasNext() -> Bool { nextNode != nil }

  public func next() throws(java.util.NoSuchElementException) -> E {
    guard let node = nextNode else { throw java.util.NoSuchElementException() }
    guard let element = node.element else { throw java.util.NoSuchElementException() }
    lastReturned = node
    nextNode = node.next
    nextIdx += 1
    return element
  }

  /// Swift `IteratorProtocol.next()` — returns `nil` at end.
  public func next() -> E? {
    guard let node = nextNode else { return nil }
    lastReturned = node
    nextNode = node.next
    nextIdx += 1
    return node.element
  }

  public func makeIterator() -> LinkedListIterator<E> { self }

  // MARK: - ListIterator

  public func hasPrevious() -> Bool { nextIdx > 0 }

  public func previous() throws -> E? {
    guard nextIdx > 0 else { throw java.util.NoSuchElementException() }
    let prev: _LinkedListNode<E>
    if let nn = nextNode {
      guard let p = nn.prev else { throw java.util.NoSuchElementException() }
      prev = p
    } else {
      guard let t = list.tail else { throw java.util.NoSuchElementException() }
      prev = t
    }
    lastReturned = prev
    nextNode = prev
    nextIdx -= 1
    return prev.element
  }

  public func nextIndex()     -> Int { nextIdx }
  public func previousIndex() -> Int { nextIdx - 1 }

  public func remove() throws(java.lang.IllegalStateException) {
    guard let node = lastReturned else {
      throw java.lang.IllegalStateException("No current element")
    }
    if nextNode === node { nextNode = node.next } else { nextIdx -= 1 }
    list.unlink(node)
    lastReturned = nil
  }

  public func set(_ element: E?) {
    lastReturned?.element = element
  }

  public func add(_ element: E?) {
    if let nn = nextNode { list.linkBefore(element, nn) } else { list.linkLast(element) }
    nextIdx += 1
    lastReturned = nil
  }
}
