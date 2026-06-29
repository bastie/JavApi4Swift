/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

extension java.util {

  // ---------------------------------------------------------------------------
  // MARK: - Vector<E>
  // ---------------------------------------------------------------------------

  /// A thread-safe, growable array of objects.
  ///
  /// Mirrors `java.util.Vector<E>` (Java 1.2).  Since Java 1.2 `Vector`
  /// implements `List`, this Swift port extends `AbstractList<E>` and
  /// therefore formally conforms to `java.util.List<E>`.
  ///
  /// All public methods are synchronised via `NSLock` to match Java's
  /// specification.
  ///
  /// `Stack<E>` extends this class in Java, so the class is declared `open`.
  open class Vector<E>: AbstractList<E> where E: Equatable { // Java 1.2: extends AbstractList, implements List, synchronized

    // -------------------------------------------------------------------------
    // MARK: Internal storage  (Java field names kept for porting fidelity)
    // -------------------------------------------------------------------------

    /// The backing buffer.  Slots ≥ `elementCount` are `nil`.
    internal var elementData: [E?]

    /// Number of valid (non-nil) elements currently stored.
    internal var elementCount: Int = 0

    /// Capacity growth step.  `<= 0` means "double the capacity".
    internal var capacityIncrement: Int

    // -------------------------------------------------------------------------
    // MARK: Synchronisation
    // -------------------------------------------------------------------------

    internal let lock = NSLock()

    @inline(__always)
    internal func withLock<T>(_ body: () throws -> T) rethrows -> T {
      lock.lock()
      defer { lock.unlock() }
      return try body()
    }

    // =========================================================================
    // MARK: - Constructors
    // =========================================================================

    public init(_ initialCapacity: Int, _ capacityIncrement: Int) throws {
      guard initialCapacity >= 0 else {
        throw IllegalArgumentException("initialCapacity must not be negative")
      }
      self.elementData = [E?](repeating: nil, count: initialCapacity)
      self.capacityIncrement = capacityIncrement
      super.init()
    }

    public convenience init(_ initialCapacity: Int) throws {
      try self.init(initialCapacity, 0)
    }

    public override convenience init() {
      try! self.init(10, 0)
    }

    public convenience init(_ collection: [E]) throws {
      try self.init(collection.count, 0)
      for element in collection { _appendUnsafe(element) }
    }

    // =========================================================================
    // MARK: - Capacity management
    // =========================================================================

    public func capacity() -> Int { withLock { elementData.count } }

    public func ensureCapacity(_ minCapacity: Int) {
      withLock { _growIfNeeded(minCapacity) }
    }

    public func trimToSize() {
      withLock {
        if elementCount < elementData.count { elementData.removeSubrange(elementCount...) }
      }
    }

    @inline(__always)
    private func _growIfNeeded(_ minCapacity: Int) {
      if minCapacity > elementData.count { _grow(to: minCapacity) }
    }

    private func _grow(to minCapacity: Int) {
      let oldCap = elementData.count
      let rawNewCap = capacityIncrement > 0 ? oldCap + capacityIncrement : (oldCap == 0 ? 1 : oldCap * 2)
      let newCap = Swift.max(rawNewCap, minCapacity)
      elementData.append(contentsOf: [E?](repeating: nil, count: newCap - oldCap))
    }

    @inline(__always)
    private func _appendUnsafe(_ element: E) {
      _growIfNeeded(elementCount + 1)
      elementData[elementCount] = element
      elementCount += 1
    }

    // =========================================================================
    // MARK: - Size  (List / Collection)
    // =========================================================================

    public override func size() -> Int { withLock { elementCount } }

    public override func isEmpty() -> Bool { withLock { elementCount == 0 } }

    public func setSize(_ newSize: Int) throws {
      guard newSize >= 0 else { throw ArrayIndexOutOfBoundsException(newSize) }
      withLock {
        if newSize > elementData.count { _growIfNeeded(newSize) }
        if newSize < elementCount {
          for i in newSize..<elementCount { elementData[i] = nil }
        }
        elementCount = newSize
      }
    }

    // =========================================================================
    // MARK: - Element access  (List)
    // =========================================================================

    /// Java legacy name for `get(_:)`.
    public func elementAt(_ index: Int) throws -> E {
      try withLock {
        try _rangeCheck(index)
        return elementData[index]!
      }
    }

    /// `List.get` — returns `E?` to match the protocol signature.
    public override func get(_ location: Int) throws -> E? {
      try withLock {
        try _rangeCheck(location)
        return elementData[location]
      }
    }

    public func firstElement() throws -> E {
      try withLock {
        guard elementCount > 0 else { throw java.util.NoSuchElementException("Vector is empty") }
        return elementData[0]!
      }
    }

    public func lastElement() throws -> E {
      try withLock {
        guard elementCount > 0 else { throw java.util.NoSuchElementException("Vector is empty") }
        return elementData[elementCount - 1]!
      }
    }

    // =========================================================================
    // MARK: - Mutation  (List / Collection)
    // =========================================================================

    /// Java legacy: replaces element at `index`, returns old value.
    @discardableResult
    public func setElementAt(_ obj: E, _ index: Int) throws -> E {
      try withLock {
        try _rangeCheck(index)
        let old = elementData[index]!
        elementData[index] = obj
        return old
      }
    }

    /// `List.set` — matches protocol signature.
    @discardableResult
    public override func set(_ location: Int, _ element: E?) throws -> E? {
      try withLock {
        try _rangeCheck(location)
        let old = elementData[location]
        elementData[location] = element
        return old
      }
    }

    /// Java legacy: appends to end.
    public func addElement(_ obj: E) {
      withLock {
        _growIfNeeded(elementCount + 1)
        elementData[elementCount] = obj
        elementCount += 1
      }
    }

    /// `Collection.add` — matches protocol signature (`throws -> Bool`).
    @discardableResult
    public override func add(_ element: E?) throws -> Bool {
      withLock {
        _growIfNeeded(elementCount + 1)
        elementData[elementCount] = element
        elementCount += 1
      }
      return true
    }

    /// Java legacy: inserts before `index`.
    public func insertElementAt(_ obj: E, _ index: Int) throws {
      try withLock {
        guard index >= 0, index <= elementCount else { throw ArrayIndexOutOfBoundsException(index) }
        _growIfNeeded(elementCount + 1)
        for i in stride(from: elementCount, through: index + 1, by: -1) {
          elementData[i] = elementData[i - 1]
        }
        elementData[index] = obj
        elementCount += 1
      }
    }

    /// `List.add(_:_:)` — matches protocol signature.
    public override func add(_ location: Int, _ element: E?) throws {
      try withLock {
        guard location >= 0, location <= elementCount else { throw ArrayIndexOutOfBoundsException(location) }
        _growIfNeeded(elementCount + 1)
        for i in stride(from: elementCount, through: location + 1, by: -1) {
          elementData[i] = elementData[i - 1]
        }
        elementData[location] = element
        elementCount += 1
      }
    }

    // =========================================================================
    // MARK: - Removal  (List / Collection)
    // =========================================================================

    /// Java legacy: removes at `index`, returns old element.
    @discardableResult
    public func removeElementAt(_ index: Int) throws -> E {
      try withLock { try _removeAt(index)! }
    }

    /// `List.remove(_:)` — matches protocol signature (returns `E?`).
    @discardableResult
    public override func remove(_ location: Int) throws -> E? {
      try withLock { try _removeAt(location) }
    }

    /// `Collection.remove(_:)` — removes first occurrence.
    @discardableResult
    public override func remove(_ element: E?) -> Bool {
      withLock {
        for i in 0..<elementCount {
          if elementData[i] == element {
            _ = try? _removeAt(i)
            return true
          }
        }
        return false
      }
    }

    public func removeAllElements() {
      withLock {
        for i in 0..<elementCount { elementData[i] = nil }
        elementCount = 0
      }
    }

    public override func clear() {
      removeAllElements()
    }

    @discardableResult
    internal func _removeAt(_ index: Int) throws -> E? {
      try _rangeCheck(index)
      let old = elementData[index]
      for i in index..<(elementCount - 1) { elementData[i] = elementData[i + 1] }
      elementCount -= 1
      elementData[elementCount] = nil
      return old
    }

    // =========================================================================
    // MARK: - Bulk operations  (List / Collection)
    // =========================================================================

    public func copyInto(_ anArray: inout [E]) {
      withLock { for i in 0..<elementCount { anArray[i] = elementData[i]! } }
    }

    public override func toArray() -> [E?] {
      withLock { (0..<elementCount).map { elementData[$0] } }
    }

    /// `List.subList` — matches protocol signature.
    public override func subList(_ start: Int, _ end: Int) -> any java.util.List {
      let sub = (try? java.util.ArrayList<E>()) ?? java.util.ArrayList<E>()
      withLock {
        let hi = Swift.min(end, elementCount)
        for i in start..<hi { _ = try? sub.add(elementData[i]) }
      }
      return sub
    }

    // =========================================================================
    // MARK: - Search  (List)
    // =========================================================================

    public override func indexOf(element: Any?) -> Int {
      withLock {
        let target = element as? E
        for i in 0..<elementCount {
          if elementData[i] == target { return i }
        }
        return -1
      }
    }

    public override func lastIndexOf(_ element: Any?) -> Int {
      withLock {
        let target = element as? E
        for i in stride(from: elementCount - 1, through: 0, by: -1) {
          if elementData[i] == target { return i }
        }
        return -1
      }
    }

    public override func contains(_ element: E?) -> Bool {
      indexOf(element: element) >= 0
    }

    // =========================================================================
    // MARK: - Iterator  (Collection / List)
    // =========================================================================

    public override func iterator() -> any java.util.Iterator<E> {
      let snapshot = withLock { (0..<elementCount).map { elementData[$0] } }
      return java.util.VectorIterator(snapshot)
    }

    public override func listIterator() -> any java.util.ListIterator<E> {
      let snapshot = withLock { (0..<elementCount).map { elementData[$0] } }
      return java.util.VectorListIterator(snapshot, 0)
    }

    public override func listIterator(_ location: Int) -> any java.util.ListIterator<E> {
      let snapshot = withLock { (0..<elementCount).map { elementData[$0] } }
      return java.util.VectorListIterator(snapshot, location)
    }

    // =========================================================================
    // MARK: - hashCode  (List)
    // =========================================================================

    public override func hashCode() -> Int {
      var hasher = Hasher()
      withLock {
        for i in 0..<elementCount {
          if let e = elementData[i] as? AnyHashable { hasher.combine(e) }
        }
      }
      return hasher.finalize()
    }

    // =========================================================================
    // MARK: - Legacy enumeration
    // =========================================================================

    public func elements() -> any java.util.Enumeration<E> {
      let snapshot = withLock { (0..<elementCount).map { elementData[$0] } }
      return java.util.VectorEnumeration(snapshot)
    }

    // =========================================================================
    // MARK: - Private guard
    // =========================================================================

    @inline(__always)
    private func _rangeCheck(_ index: Int) throws {
      guard index >= 0, index < elementCount else {
        throw java.lang.ArrayIndexOutOfBoundsException(index)
      }
    }
  }
}

// =============================================================================
// MARK: - Iterator implementations for Vector
// =============================================================================

extension java.util {

  /// A snapshot-based `Iterator<E>` for `Vector`.
  internal final class VectorIterator<E: Equatable>: java.util.Iterator, IteratorProtocol {
    public typealias Element = E

    private let storage: [E?]
    private var cursor: Int = 0

    internal init(_ storage: [E?]) { self.storage = storage }

    public func hasNext() -> Bool { cursor < storage.count }

    public func next() throws(java.util.NoSuchElementException) -> E {
      guard cursor < storage.count else { throw java.util.NoSuchElementException("Iterator exhausted") }
      defer { cursor += 1 }
      return storage[cursor]!
    }

    public func remove() throws(java.lang.IllegalStateException) {
      throw IllegalStateException("remove() not supported on snapshot iterator")
    }

    /// `IteratorProtocol.next()` — non-throwing, returns `nil` when exhausted.
    public func next() -> E? {
      guard cursor < storage.count else { return nil }
      defer { cursor += 1 }
      return storage[cursor]
    }

    public func makeIterator() -> VectorIterator<E> { return self }
  }

  /// A snapshot-based `ListIterator<E>` for `Vector`.
  internal final class VectorListIterator<E: Equatable>: java.util.ListIterator, IteratorProtocol {
    public typealias Element = E

    private let storage: [E?]
    private var cursor: Int

    internal init(_ storage: [E?], _ start: Int) {
      self.storage = storage
      self.cursor = start
    }

    public func hasNext() -> Bool { cursor < storage.count }
    public func hasPrevious() -> Bool { cursor > 0 }

    public func next() throws(java.util.NoSuchElementException) -> E {
      guard cursor < storage.count else { throw java.util.NoSuchElementException() }
      defer { cursor += 1 }
      return storage[cursor]!
    }

    public func previous() throws -> E? {
      guard cursor > 0 else { throw java.util.NoSuchElementException() }
      cursor -= 1
      return storage[cursor]
    }

    public func nextIndex() -> Int { cursor }
    public func previousIndex() -> Int { cursor - 1 }

    public func remove() throws(java.lang.IllegalStateException) {
      throw IllegalStateException("remove() not supported on snapshot iterator")
    }

    public func set(_ e: E?) {
      // snapshot iterator — no mutation support
    }

    public func add(_ e: E?) {
      // snapshot iterator — no mutation support
    }

    /// `IteratorProtocol.next()` — non-throwing, returns `nil` when exhausted.
    public func next() -> E? {
      guard cursor < storage.count else { return nil }
      defer { cursor += 1 }
      return storage[cursor]
    }

    public func makeIterator() -> VectorListIterator<E> { return self }
  }

  // ---------------------------------------------------------------------------
  // MARK: - Legacy Enumeration (unchanged)
  // ---------------------------------------------------------------------------

  /// A legacy Java-style iterator for sequential element access.
  internal final class VectorEnumeration<E>: java.util.Enumeration {
    public typealias Element = E

    private let storage: [E?]
    private var cursor: Int = 0

    internal init(_ storage: [E?]) { self.storage = storage }

    public func hasMoreElements() -> Bool { cursor < storage.count }

    public func nextElement() throws -> E {
      guard cursor < storage.count else {
        throw java.util.NoSuchElementException("Enumeration exhausted")
      }
      defer { cursor += 1 }
      return storage[cursor]!
    }

    public func next() -> E? {
      guard hasMoreElements() else { return nil }
      defer { cursor += 1 }
      return storage[cursor]
    }

    public func makeIterator() -> VectorEnumeration<E> { return self }
  }
}
