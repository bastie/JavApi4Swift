/*
 * SPDX-FileCopyrightText: 2023 - 2026 Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.util {

  /// Swift implementation of ``java.util.ArrayList`` as a reference type backed by a Swift Array.
  ///
  /// `ArrayList` is a resizable-array implementation of the `List` protocol.
  /// Unlike Swift's value-type `Array`, this class has reference semantics: multiple
  /// variables can refer to the same list and observe each other's mutations.
  ///
  /// - Note: This implementation corresponds to Java 1.2 `java.util.ArrayList`.
  open class ArrayList<E> : AbstractList<E> where E : Equatable {

    // MARK: - Backing store

    internal var elements : [E?]

    // MARK: - Constructors

    /// Creates an empty list with the given initial capacity (capacity hint only).
    public init(initialCapacity : Int = 10) {
      self.elements = []
      self.elements.reserveCapacity(initialCapacity)
    }

    /// Creates a list containing all elements of the given `Collection` in iteration order.
    public init(collection : any java.util.Collection<E?>) {
      // toArray() returns [E?] here because Collection is typed as Collection<E?>,
      // which would produce [E??]. We iterate instead to stay type-safe.
      self.elements = []
      let it = collection.iterator()
      while it.hasNext() {
        self.elements.append(try? it.next())
      }
    }

    // MARK: - Size

    /// Returns the number of elements in this list.
    public override func size() -> Int {
      return elements.count
    }

    // MARK: - Access

    /// Returns the element at the specified position.
    ///
    /// - Throws: `IndexOutOfBoundsException` if `location` is out of range.
    public override func get(_ location: Int) throws -> E? {
      guard location >= 0 && location < elements.count else {
        throw IndexOutOfBoundsException("Index: \(location), Size: \(elements.count)")
      }
      return elements[location]
    }

    // MARK: - Mutation

    /// Appends the specified element to the end of this list.
    ///
    /// - Returns: `true` always (as specified by `Collection.add`).
    @discardableResult
    public override func add(_ element: E?) throws -> Bool {
      elements.append(element)
      return true
    }

    /// Non-throwing convenience overload for the common case.
    /// Matches Java's typical usage where `ArrayList.add` never actually throws.
    @discardableResult
    public func add(_ element: E) -> Bool {
      elements.append(element)
      return true
    }

    /// Inserts the specified element at the specified position in this list.
    ///
    /// Shifts the element currently at that position and any subsequent elements to the right.
    ///
    /// - Throws: `IndexOutOfBoundsException` if `location` is out of range (`< 0` or `> size()`).
    public override func add(_ location: Int, _ element: E?) throws {
      guard location >= 0 && location <= elements.count else {
        throw IndexOutOfBoundsException("Index: \(location), Size: \(elements.count)")
      }
      elements.insert(element, at: location)
    }

    /// Replaces the element at the specified position with the specified element.
    ///
    /// - Returns: The element previously at the specified position.
    /// - Throws: `IndexOutOfBoundsException` if `location` is out of range.
    public override func set(_ location: Int, _ element: E?) throws -> E? {
      guard location >= 0 && location < elements.count else {
        throw IndexOutOfBoundsException("Index: \(location), Size: \(elements.count)")
      }
      let old = elements[location]
      elements[location] = element
      return old
    }

    /// Removes the element at the specified position in this list.
    ///
    /// Shifts any subsequent elements to the left.
    ///
    /// - Returns: The element that was removed.
    /// - Throws: `IndexOutOfBoundsException` if `location` is out of range.
    public override func remove(_ location: Int) throws -> E? {
      guard location >= 0 && location < elements.count else {
        throw IndexOutOfBoundsException("Index: \(location), Size: \(elements.count)")
      }
      return elements.remove(at: location)
    }

    /// Removes the first occurrence of the specified element from this list, if present.
    ///
    /// - Returns: `true` if this list contained the specified element.
    @discardableResult
    public override func remove(_ element: E?) -> Bool {
      if let idx = elements.firstIndex(where: { $0 == element }) {
        elements.remove(at: idx)
        return true
      }
      return false
    }

    /// Removes all elements from this list.
    public override func clear() {
      elements.removeAll()
    }

    // MARK: - Search

    /// Returns `true` if this list contains the specified element.
    public override func contains(_ element: E?) -> Bool {
      return elements.contains(where: { $0 == element })
    }

    /// Returns the index of the first occurrence of the specified element, or -1 if not present.
    public override func indexOf(element: Any?) -> Int {
      guard let typed = element as? E? else { return -1 }
      return elements.firstIndex(where: { $0 == typed }) ?? -1
    }

    /// Returns the index of the last occurrence of the specified element, or -1 if not present.
    public override func lastIndexOf(_ element: Any?) -> Int {
      guard let typed = element as? E? else { return -1 }
      return elements.lastIndex(where: { $0 == typed }) ?? -1
    }

    // MARK: - Views

    /// Returns a copy of the portion of this list between `start` (inclusive) and `end` (exclusive).
    ///
    /// - Note: Changes to the returned list are **not** reflected back (simplified semantics).
    public override func subList(_ start: Int, _ end: Int) -> any java.util.List {
      let sub = ArrayList<E>()
      for i in start..<end {
        sub.elements.append(elements[i])
      }
      return sub
    }

    // MARK: - Iterators

    /// Returns a forward iterator over the elements in this list.
    public override func iterator() -> any java.util.Iterator<E> {
      return ArrayListIterator<E>(list: self)
    }

    /// Returns a `ListIterator` over the elements in this list, starting at position `location`.
    public override func listIterator(_ location: Int) -> any java.util.ListIterator<E> {
      return ArrayListListIterator<E>(list: self, startCursor: location)
    }

    /// Returns a `ListIterator` over the elements in this list starting at position 0.
    public override func listIterator() -> any java.util.ListIterator<E> {
      return listIterator(0)
    }

    // MARK: - Conversion

    /// Returns an array containing all elements in this list in proper sequence.
    public override func toArray() -> [E?] {
      return elements
    }

    // MARK: - Hash

    /// Returns a hash code value for this list.
    ///
    /// Uses index-based hashing to avoid requiring `E: Hashable`.
    public override func hashCode() -> Int {
      var result = 1
      for element in elements {
        // Java ArrayList.hashCode(): result = 31 * result + (e == null ? 0 : e.hashCode())
        let elementHash : Int
        if let e = element {
          // AnyHashable wrapping works for most Equatable types that are also Hashable.
          // For types that are only Equatable, fall back to a constant.
          if let h = e as? AnyHashable {
            elementHash = h.hashValue
          } else {
            elementHash = 1
          }
        } else {
          elementHash = 0
        }
        result = 31 &* result &+ elementHash
      }
      return result
    }

    // MARK: - Clone

    /// Returns a shallow copy of this `ArrayList`.
    public func clone() -> ArrayList<E> {
      let copy = ArrayList<E>()
      copy.elements = self.elements
      return copy
    }
  }
}

// MARK: - ArrayListIterator

/// Forward-only iterator for `java.util.ArrayList`.
///
/// `Element = E` to satisfy `Iterable<E>` / `AbstractCollection<E>` which require
/// `iterator() -> any java.util.Iterator<E>`.
///
/// Conforms to both `java.util.Iterator` (throwing `next() -> E`) and
/// `IteratorProtocol` (non-throwing `next() -> E?`), enabling native Swift `for-in`.
public class ArrayListIterator<E: Equatable> : java.util.Iterator, IteratorProtocol {
  public typealias Element = E

  internal let list : java.util.ArrayList<E>
  internal var cursor : Int
  internal var lastReturned : Int = -1

  internal init(list: java.util.ArrayList<E>, startCursor: Int = 0) {
    self.list = list
    self.cursor = startCursor
  }

  public func hasNext() -> Bool {
    return cursor < list.elements.count
  }

  /// Java-style `next()` — throws `NoSuchElementException` when exhausted.
  /// A `nil` element in the backing store causes a force-unwrap crash,
  /// matching Java's `NullPointerException` on primitive unboxing.
  public func next() throws(java.util.NoSuchElementException) -> E {
    guard hasNext() else { throw java.util.NoSuchElementException() }
    lastReturned = cursor
    defer { cursor += 1 }
    return list.elements[cursor]!
  }

  public func remove() throws(java.lang.IllegalStateException) {
    guard lastReturned >= 0 else { throw java.lang.IllegalStateException() }
    list.elements.remove(at: lastReturned)
    cursor = lastReturned
    lastReturned = -1
  }

  /// `IteratorProtocol.next()` — returns `nil` when exhausted, bridges Java `next()` to Swift `for-in`.
  public func next() -> E? {
    guard hasNext() else { return nil }
    lastReturned = cursor
    defer { cursor += 1 }
    return list.elements[cursor]
  }

  public func makeIterator() -> ArrayListIterator<E> { return self }
}

// MARK: - ArrayListListIterator

/// Bidirectional list iterator for `java.util.ArrayList`.
///
/// `Element = E` matches `java.util.ListIterator<E>` — the nullable variants
/// (`add(E?)`, `previous() -> E?`, `set(E?)`) come from `ListIterator`'s
/// protocol definition which uses `Element?`.
public class ArrayListListIterator<E: Equatable> : java.util.ListIterator, IteratorProtocol {
  public typealias Element = E

  private let list : java.util.ArrayList<E>
  private var cursor : Int
  private var lastReturned : Int = -1

  internal init(list: java.util.ArrayList<E>, startCursor: Int = 0) {
    self.list = list
    self.cursor = startCursor
  }

  // MARK: - Iterator

  public func hasNext() -> Bool { return cursor < list.elements.count }

  /// Java-style `next()` — throws when exhausted, force-unwraps nil elements.
  public func next() throws(java.util.NoSuchElementException) -> E {
    guard hasNext() else { throw java.util.NoSuchElementException() }
    lastReturned = cursor
    defer { cursor += 1 }
    return list.elements[cursor]!
  }

  public func remove() throws(java.lang.IllegalStateException) {
    guard lastReturned >= 0 else { throw java.lang.IllegalStateException() }
    list.elements.remove(at: lastReturned)
    cursor = lastReturned
    lastReturned = -1
  }

  /// `IteratorProtocol.next()` — returns `nil` when exhausted, bridges Java `next()` to Swift `for-in`.
  public func next() -> E? {
    guard hasNext() else { return nil }
    lastReturned = cursor
    defer { cursor += 1 }
    return list.elements[cursor]
  }

  public func makeIterator() -> ArrayListListIterator<E> { return self }

  // MARK: - ListIterator

  public func hasPrevious() -> Bool { return cursor > 0 }

  public func previous() throws -> E? {
    guard hasPrevious() else { throw java.util.NoSuchElementException() }
    cursor -= 1
    lastReturned = cursor
    return list.elements[cursor]
  }

  public func nextIndex() -> Int { return cursor }

  public func previousIndex() -> Int { return cursor - 1 }

  /// Inserts the element before the element that would be returned by `next()`.
  public func add(_ element: E?) {
    list.elements.insert(element, at: cursor)
    cursor += 1
    lastReturned = -1
  }

  /// Replaces the last element returned by `next()` or `previous()`.
  public func set(_ element: E?) {
    guard lastReturned >= 0 else { return }
    list.elements[lastReturned] = element
  }
}
