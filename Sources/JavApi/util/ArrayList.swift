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

    /// Returns a view of the portion of this list between `start` (inclusive) and `end` (exclusive).
    ///
    /// The returned list is backed by this list: non-structural changes in the returned list are
    /// reflected in this list, and vice-versa, matching `java.util.List.subList` specification.
    ///
    /// - Throws: `IndexOutOfBoundsException` indirectly if indices are out of range.
    public override func subList(_ start: Int, _ end: Int) -> any java.util.List {
      return ArrayListSubList<E>(backing: self, fromIndex: start, toIndex: end)
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

    // MARK: - Capacity

    /// Increases the capacity of this list, if necessary, to ensure it can hold
    /// at least `minimumCapacity` elements without reallocation.
    ///
    /// This is a performance hint; it does not affect observable behaviour.
    public func ensureCapacity(_ minimumCapacity: Int) {
      if elements.capacity < minimumCapacity {
        elements.reserveCapacity(minimumCapacity)
      }
    }

    /// Trims the capacity of this list to its current size.
    ///
    /// This is a performance hint that minimises memory usage when the list
    /// will not grow further.
    public func trimToSize() {
      // Swift arrays do not expose shrink-to-fit directly.
      // Replace the backing store with a fresh copy that has no spare capacity.
      var trimmed: [E?] = []
      trimmed.reserveCapacity(elements.count)
      trimmed.append(contentsOf: elements)
      elements = trimmed
    }

    // MARK: - Indexed bulk insert

    /// Inserts all elements of `collection` into this list, starting at `location`.
    ///
    /// - Returns: `true` if this list was modified.
    /// - Throws: `IndexOutOfBoundsException` if `location` is out of range.
    @discardableResult
    public override func addAll(_ location: Int, collection: any java.util.Collection<E?>) -> Bool {
      guard location >= 0 && location <= elements.count else {
        // Matching Java behaviour: throws IndexOutOfBoundsException at runtime.
        // Because AbstractList declares this as non-throwing, we crash like
        // the Harmony reference implementation does on invalid indices.
        fatalError("IndexOutOfBoundsException: Index: \(location), Size: \(elements.count)")
      }
      var newElements: [E?] = []
      let it = collection.iterator()
      while it.hasNext() {
        newElements.append(try? it.next())
      }
      guard !newElements.isEmpty else { return false }
      elements.insert(contentsOf: newElements, at: location)
      return true
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
  /// `nil` means "use list.elements.count dynamically" (normal ArrayList iterator).
  /// A fixed value is used only by ArrayListSubList to bound iteration to the subrange.
  internal let fixedEndIndex : Int?

  internal var endIndex : Int {
    return fixedEndIndex ?? list.elements.count
  }

  internal init(list: java.util.ArrayList<E>, startCursor: Int = 0, endIndex: Int? = nil) {
    self.list = list
    self.cursor = startCursor
    self.fixedEndIndex = endIndex
  }

  public func hasNext() -> Bool {
    return cursor < endIndex
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
  private let fixedEndIndex : Int?

  private var endIndex : Int {
    return fixedEndIndex ?? list.elements.count
  }

  internal init(list: java.util.ArrayList<E>, startCursor: Int = 0, endIndex: Int? = nil) {
    self.list = list
    self.cursor = startCursor
    self.fixedEndIndex = endIndex
  }

  // MARK: - Iterator

  public func hasNext() -> Bool { return cursor < endIndex }

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

// MARK: - ArrayListSubList

/// A live *view* over a contiguous range of a `java.util.ArrayList`.
///
/// All read and write operations are delegated to the backing list with an
/// offset of `fromIndex`, matching the `java.util.List.subList` specification:
/// changes made through the view are immediately visible in the original list
/// and vice-versa.
///
/// Structural modifications (add/remove) adjust `toIndex` so that `size()`
/// stays consistent. Structural modifications made directly on the backing list
/// (bypassing the view) leave the view's `toIndex` stale — this matches Java's
/// behaviour where such modifications invalidate the sublist.
public class ArrayListSubList<E: Equatable>: java.util.AbstractList<E> {

  internal let backing: java.util.ArrayList<E>
  internal let fromIndex: Int
  internal var toIndex: Int

  internal init(backing: java.util.ArrayList<E>, fromIndex: Int, toIndex: Int) {
    self.backing = backing
    self.fromIndex = fromIndex
    self.toIndex = toIndex
    super.init()
  }

  // MARK: - Size

  public override func size() -> Int {
    return toIndex - fromIndex
  }

  // MARK: - Access

  public override func get(_ location: Int) throws -> E? {
    guard location >= 0 && location < size() else {
      throw IndexOutOfBoundsException("Index: \(location), Size: \(size())")
    }
    return try backing.get(fromIndex + location)
  }

  // MARK: - Mutation

  @discardableResult
  public override func add(_ element: E?) throws -> Bool {
    try backing.add(toIndex, element)
    toIndex += 1
    return true
  }

  public override func add(_ location: Int, _ element: E?) throws {
    guard location >= 0 && location <= size() else {
      throw IndexOutOfBoundsException("Index: \(location), Size: \(size())")
    }
    try backing.add(fromIndex + location, element)
    toIndex += 1
  }

  public override func set(_ location: Int, _ element: E?) throws -> E? {
    guard location >= 0 && location < size() else {
      throw IndexOutOfBoundsException("Index: \(location), Size: \(size())")
    }
    return try backing.set(fromIndex + location, element)
  }

  public override func remove(_ location: Int) throws -> E? {
    guard location >= 0 && location < size() else {
      throw IndexOutOfBoundsException("Index: \(location), Size: \(size())")
    }
    let removed = try backing.remove(fromIndex + location)
    toIndex -= 1
    return removed
  }

  @discardableResult
  public override func remove(_ element: E?) -> Bool {
    for i in 0..<size() {
      let idx = fromIndex + i
      if backing.elements[idx] == element {
        backing.elements.remove(at: idx)
        toIndex -= 1
        return true
      }
    }
    return false
  }

  public override func clear() {
    backing.elements.removeSubrange(fromIndex..<toIndex)
    toIndex = fromIndex
  }

  // MARK: - Search

  public override func contains(_ element: E?) -> Bool {
    for i in 0..<size() {
      if backing.elements[fromIndex + i] == element { return true }
    }
    return false
  }

  public override func indexOf(element: Any?) -> Int {
    guard let typed = element as? E? else { return -1 }
    for i in 0..<size() {
      if backing.elements[fromIndex + i] == typed { return i }
    }
    return -1
  }

  public override func lastIndexOf(_ element: Any?) -> Int {
    guard let typed = element as? E? else { return -1 }
    for i in stride(from: size() - 1, through: 0, by: -1) {
      if backing.elements[fromIndex + i] == typed { return i }
    }
    return -1
  }

  // MARK: - Iterators

  public override func iterator() -> any java.util.Iterator<E> {
    return ArrayListSubListIterator<E>(subList: self)
  }

  public override func listIterator(_ location: Int) -> any java.util.ListIterator<E> {
    return ArrayListSubListIterator<E>(subList: self, startOffset: location)
  }

  public override func listIterator() -> any java.util.ListIterator<E> {
    return listIterator(0)
  }

  // MARK: - Sub-views

  public override func subList(_ start: Int, _ end: Int) -> any java.util.List {
    return ArrayListSubList<E>(backing: backing, fromIndex: fromIndex + start, toIndex: fromIndex + end)
  }

  // MARK: - Conversion

  public override func toArray() -> [E?] {
    return Array(backing.elements[fromIndex..<toIndex])
  }

  // MARK: - Hash

  public override func hashCode() -> Int {
    var result = 1
    for i in fromIndex..<toIndex {
      let elementHash: Int
      if let e = backing.elements[i] {
        if let h = e as? AnyHashable { elementHash = h.hashValue } else { elementHash = 1 }
      } else { elementHash = 0 }
      result = 31 &* result &+ elementHash
    }
    return result
  }
}

// MARK: - ArrayListSubListIterator

/// Iterator for `ArrayListSubList` that reads `size()` dynamically so that
/// structural modifications through the view (add/remove/clear) are reflected
/// in subsequent `hasNext()` calls — avoiding index-out-of-range crashes.
public class ArrayListSubListIterator<E: Equatable>: java.util.ListIterator, IteratorProtocol {
  public typealias Element = E

  private let subList: ArrayListSubList<E>
  private var offset: Int        // position within the subList (0-based)
  private var lastReturned: Int = -1

  internal init(subList: ArrayListSubList<E>, startOffset: Int = 0) {
    self.subList = subList
    self.offset = startOffset
  }

  // MARK: - Iterator

  public func hasNext() -> Bool { return offset < subList.size() }

  public func next() throws(java.util.NoSuchElementException) -> E {
    guard hasNext() else { throw java.util.NoSuchElementException() }
    lastReturned = offset
    defer { offset += 1 }
    // Direct backing access via the absolute index — subList.get() would re-validate bounds.
    return subList.backing.elements[subList.fromIndex + offset]!
  }

  public func remove() throws(java.lang.IllegalStateException) {
    guard lastReturned >= 0 else { throw java.lang.IllegalStateException() }
    _ = try? subList.remove(lastReturned)
    offset = lastReturned
    lastReturned = -1
  }

  public func next() -> E? {
    guard hasNext() else { return nil }
    lastReturned = offset
    defer { offset += 1 }
    return subList.backing.elements[subList.fromIndex + offset]
  }

  public func makeIterator() -> ArrayListSubListIterator<E> { return self }

  // MARK: - ListIterator

  public func hasPrevious() -> Bool { return offset > 0 }

  public func previous() throws -> E? {
    guard hasPrevious() else { throw java.util.NoSuchElementException() }
    offset -= 1
    lastReturned = offset
    return try? subList.get(offset)
  }

  public func nextIndex() -> Int { return offset }
  public func previousIndex() -> Int { return offset - 1 }

  public func add(_ element: E?) {
    _ = try? subList.add(offset, element)
    offset += 1
    lastReturned = -1
  }

  public func set(_ element: E?) {
    guard lastReturned >= 0 else { return }
    _ = try? subList.set(lastReturned, element)
  }
}
