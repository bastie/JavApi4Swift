/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

extension java.util {
  
  // ---------------------------------------------------------------------------
  // MARK: - Vector<E>, KI generated
  // ---------------------------------------------------------------------------
  
  /// A thread-safe, growable array of objects.
  ///
  /// `Vector` mirrors the Java `java.util.Vector<E>` API as faithfully as Swift
  /// allows.  All public methods are synchronized via an `NSLock` so that
  /// concurrent access is safe — just as in the Java specification.
  ///
  /// Unlike `java.util.ArrayList`, `Vector` retains Java's legacy
  /// synchronisation guarantee and its classic method names (`addElement`,
  /// `elementAt`, `removeElementAt`, …) **in addition to** the modern
  /// `List<E>` interface names (`add`, `get`, `remove`, `set`, …).
  ///
  /// Because `java.util.Stack` extends `Vector` in Java, this class is
  /// declared `open` so that a future `Stack` implementation (or your own
  /// subclass) can inherit from it directly.
  ///
  /// ### Example
  /// ```swift
  /// let v = Java.util.Vector<NSString>()
  /// v.addElement("Hello")
  /// v.addElement("World")
  /// print(try v.elementAt(0))   // → Hello
  /// print(v.size())             // → 2
  /// ```
  open class Vector<E> {
    
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
    
    /// Recursive-safe lock — acquired once per public method call.
    /// Subclasses that need to lock across multiple operations should use
    /// `withLock(_:)`.
    internal let lock = NSLock()
    
    /// Executes `body` while holding the vector's lock.
    @inline(__always)
    internal func withLock<T>(_ body: () throws -> T) rethrows -> T {
      lock.lock()
      defer { lock.unlock() }
      return try body()
    }
    
    // =========================================================================
    // MARK: - Constructors
    // =========================================================================
    
    /// Creates a vector with the given initial capacity and growth increment.
    ///
    /// - Parameters:
    ///   - initialCapacity: Initial backing-buffer size. Must be ≥ 0.
    ///   - capacityIncrement: Number of slots added on each grow.
    ///                        `<= 0` means "double the current capacity".
    public init(_ initialCapacity: Int, _ capacityIncrement: Int) throws {
      guard initialCapacity >= 0 else {
        throw IllegalArgumentException.init("initialCapacity must not be negative")
      }
      self.elementData = [E?](repeating: nil, count: initialCapacity)
      self.capacityIncrement = capacityIncrement
    }
    
    /// Creates a vector with the given initial capacity and automatic growth.
    public convenience init(_ initialCapacity: Int) throws {
      try self.init(initialCapacity, 0)
    }
    
    /// Creates a vector with a default initial capacity of 10 and automatic growth.
    public convenience init() throws {
      try self.init(10, 0)
    }
    
    /// Creates a vector pre-loaded with all elements of `collection`.
    public convenience init(_ collection: [E]) throws {
      try self.init(collection.count, 0)
      for element in collection {
        // No lock needed — object is not yet visible to other threads.
        _appendUnsafe(element)
      }
    }
    
    // =========================================================================
    // MARK: - Capacity management
    // =========================================================================
    
    /// Returns the current backing-buffer capacity.
    public func capacity() -> Int {
      withLock { elementData.count }
    }
    
    /// Ensures the backing buffer can hold at least `minCapacity` elements.
    public func ensureCapacity(_ minCapacity: Int) {
      withLock { _growIfNeeded(minCapacity) }
    }
    
    /// Trims the backing buffer to the current element count.
    public func trimToSize() {
      withLock {
        if elementCount < elementData.count {
          elementData.removeSubrange(elementCount...)
        }
      }
    }
    
    // MARK: Private growth helpers (caller must hold `lock`)
    
    @inline(__always)
    private func _growIfNeeded(_ minCapacity: Int) {
      if minCapacity > elementData.count {
        _grow(to: minCapacity)
      }
    }
    
    private func _grow(to minCapacity: Int) {
      let oldCap = elementData.count
      let rawNewCap = capacityIncrement > 0
      ? oldCap + capacityIncrement
      : (oldCap == 0 ? 1 : oldCap * 2)
      let newCap = Swift.max(rawNewCap, minCapacity)
      elementData.append(contentsOf: [E?](repeating: nil, count: newCap - oldCap))
    }
    
    /// Appends without acquiring the lock (use only from `init`).
    @inline(__always)
    private func _appendUnsafe(_ element: E) {
      _growIfNeeded(elementCount + 1)
      elementData[elementCount] = element
      elementCount += 1
    }
    
    // =========================================================================
    // MARK: - Size
    // =========================================================================
    
    /// Returns the number of elements in this vector.
    public func size() -> Int {
      withLock { elementCount }
    }
    
    /// Returns `true` if this vector contains no elements.
    public func isEmpty() -> Bool {
      withLock { elementCount == 0 }
    }
    
    /// Resizes this vector to exactly `newSize` elements.
    ///
    /// If `newSize` is greater than the current size, the new slots contain
    /// `nil` (absent elements).  If smaller, the excess elements are discarded.
    ///
    /// - Throws: `Java.lang.ArrayIndexOutOfBoundsException` when `newSize < 0`.
    public func setSize(_ newSize: Int) throws {
      guard newSize >= 0 else {
        throw ArrayIndexOutOfBoundsException(newSize)
      }
      withLock {
        if newSize > elementData.count {
          _growIfNeeded(newSize)
        } else {
          for i in newSize..<elementCount { elementData[i] = nil }
        }
        elementCount = newSize
      }
    }
    
    // =========================================================================
    // MARK: - Element access
    // =========================================================================
    
    /// Returns the element at `index`.
    ///
    /// - Throws: `Java.lang.ArrayIndexOutOfBoundsException` when `index` is out of range.
    public func elementAt(_ index: Int) throws -> E {
      try withLock {
        try _rangeCheck(index)
        return elementData[index]!
      }
    }
    
    /// Returns the element at `index` (List-interface alias for `elementAt`).
    ///
    /// - Throws: `Java.lang.ArrayIndexOutOfBoundsException` when `index` is out of range.
    public func get(_ index: Int) throws -> E {
      try elementAt(index)
    }
    
    /// Returns the first element of this vector.
    ///
    /// - Throws: `Java.util.NoSuchElementException` when the vector is empty.
    public func firstElement() throws -> E {
      try withLock {
        guard elementCount > 0 else {
          throw java.util.NoSuchElementException("Vector is empty")
        }
        return elementData[0]!
      }
    }
    
    /// Returns the last element of this vector.
    ///
    /// - Throws: `Java.util.NoSuchElementException` when the vector is empty.
    public func lastElement() throws -> E {
      try withLock {
        guard elementCount > 0 else {
          throw java.util.NoSuchElementException("Vector is empty")
        }
        return elementData[elementCount - 1]!
      }
    }
    
    // =========================================================================
    // MARK: - Mutation
    // =========================================================================
    
    /// Replaces the element at `index` with `obj` and returns the old element.
    ///
    /// - Throws: `Java.lang.ArrayIndexOutOfBoundsException` when `index` is out of range.
    @discardableResult
    public func setElementAt(_ obj: E, at index: Int) throws -> E {
      try withLock {
        try _rangeCheck(index)
        let old = elementData[index]!
        elementData[index] = obj
        return old
      }
    }
    
    /// Replaces the element at `index` with `element` (List-interface alias).
    ///
    /// - Throws: `Java.lang.ArrayIndexOutOfBoundsException` when `index` is out of range.
    @discardableResult
    public func set(_ index: Int, element: E) throws -> E {
      try setElementAt(element, at: index)
    }
    
    /// Appends `obj` to the end of this vector (legacy method name).
    public func addElement(_ obj: E) {
      withLock {
        _growIfNeeded(elementCount + 1)
        elementData[elementCount] = obj
        elementCount += 1
      }
    }
    
    /// Appends `e` to the end of this vector (Collection / List interface).
    ///
    /// Always returns `true`, matching the Java contract for `List.add`.
    @discardableResult
    public func add(_ e: E) -> Bool {
      addElement(e)
      return true
    }
    
    /// Inserts `obj` before the element currently at `index`, shifting
    /// subsequent elements one position to the right.
    ///
    /// - Throws: `Java.lang.ArrayIndexOutOfBoundsException` when `index` is negative
    ///           or greater than `size()`.
    public func insertElementAt(_ obj: E, at index: Int) throws {
      try withLock {
        guard index >= 0, index <= elementCount else {
          throw ArrayIndexOutOfBoundsException(index)
        }
        _growIfNeeded(elementCount + 1)
        // Shift right  [index ... elementCount-1]  →  [index+1 ... elementCount]
        for i in stride(from: elementCount, through: index + 1, by: -1) {
          elementData[i] = elementData[i - 1]
        }
        elementData[index] = obj
        elementCount += 1
      }
    }
    
    /// Inserts `element` at `index` (List-interface alias for `insertElementAt`).
    ///
    /// - Throws: `Java.lang.ArrayIndexOutOfBoundsException` when `index` is out of range.
    public func add(at index: Int, element: E) throws {
      try insertElementAt(element, at: index)
    }
    
    // =========================================================================
    // MARK: - Removal
    // =========================================================================
    
    /// Removes and returns the element at `index`, shifting subsequent elements left.
    ///
    /// - Throws: `Java.lang.ArrayIndexOutOfBoundsException` when `index` is out of range.
    @discardableResult
    public func removeElementAt(_ index: Int) throws -> E {
      try withLock { try _removeAt(index) }
    }
    
    /// Removes and returns the element at `index` (List-interface alias).
    ///
    /// - Throws: `Java.lang.ArrayIndexOutOfBoundsException` when `index` is out of range.
    @discardableResult
    public func remove(_ index: Int) throws -> E {
      try removeElementAt(index)
    }
    /// Removes all elements from this vector (legacy method name).
    public func removeAllElements() {
      withLock {
        for i in 0..<elementCount { elementData[i] = nil }
        elementCount = 0
      }
    }
    
    /// Removes all elements from this vector (Collection-interface alias).
    public func clear() {
      removeAllElements()
    }
    
    // MARK: Private removal helper (caller must hold `lock`)
    
    /// Removes and returns the element at `index`.  Assumes index is valid.
    @discardableResult
    internal func _removeAt(_ index: Int) throws -> E {
      try _rangeCheck(index)
      let old = elementData[index]!
      for i in index..<(elementCount - 1) {
        elementData[i] = elementData[i + 1]
      }
      elementCount -= 1
      elementData[elementCount] = nil   // allow ARC to release
      return old
    }
    
    // =========================================================================
    // MARK: - Bulk operations
    // =========================================================================
    
    /// Copies all elements into `anArray`, which must be at least `size()` long.
    public func copyInto(_ anArray: inout [E]) {
      withLock {
        for i in 0..<elementCount { anArray[i] = elementData[i]! }
      }
    }
    
    /// Returns a Swift array containing all elements of this vector, in order.
    public func toArray() -> [E] {
      withLock { (0..<elementCount).map { elementData[$0]! } }
    }
    
    /// Returns a new list containing all elements between `fromIndex` (inclusive)
    /// and `toIndex` (exclusive).
    ///
    /// - Throws: `Java.lang.IndexOutOfBoundsException` for out-of-range indices.
    /// - Throws: `Java.lang.IllegalArgumentException` when `fromIndex > toIndex`.
    public func subList(fromIndex: Int, toIndex: Int) throws -> [E] {
      try withLock {
        guard fromIndex >= 0 else {
          throw java.lang.IndexOutOfBoundsException("fromIndex = \(fromIndex)")
        }
        guard toIndex <= elementCount else {
          throw java.lang.IndexOutOfBoundsException("toIndex = \(toIndex)")
        }
        guard fromIndex <= toIndex else {
          throw java.lang.IllegalArgumentException(
            "fromIndex(\(fromIndex)) > toIndex(\(toIndex))")
        }
        return (fromIndex..<toIndex).map { elementData[$0]! }
      }
    }
    
    /// Returns an `Enumeration` over the elements of this vector.
    ///
    /// The enumeration takes a snapshot of the current element list, so
    /// concurrent modifications to the vector do not affect it — matching
    /// the documented Java behaviour for `Vector.elements()`.
    public func elements() -> any java.util.Enumeration<E> {
      let snapshot = withLock { (0..<elementCount).map { elementData[$0]! } }
      return java.util.VectorEnumeration(snapshot)
    }
    
    // =========================================================================
    // MARK: - Private guard
    // =========================================================================
    
    /// Throws `ArrayIndexOutOfBoundsException` unless `index` is in `0..<elementCount`.
    /// Caller must already hold `lock`.
    @inline(__always)
    private func _rangeCheck(_ index: Int) throws {
      guard index >= 0, index < elementCount else {
        throw java.lang.ArrayIndexOutOfBoundsException(index)
      }
    }
  }
}

// =============================================================================
// MARK: - Enumeration  (java.util.Enumeration<E> — minimal impl for Vector)
// =============================================================================
//

extension java.util {
  
  /// A legacy Java-style iterator for sequential element access.
  ///
  /// Mirrors `java.util.Enumeration<E>`:
  /// - `hasMoreElements()` — returns `true` while elements remain.
  /// - `nextElement()` — returns the next element.
  ///
  /// ```swift
  /// let e = v.elements()
  /// while e.hasMoreElements() {
  ///   print(try e.nextElement())
  /// }
  /// ```
  internal final class VectorEnumeration<E> : java.util.Enumeration {
    
    // Verbindet den generischen Parameter E mit IteratorProtocol.Element
    public typealias Element = E
    
    private let storage: [E]
    private var cursor: Int = 0
    
    internal init(_ storage: [E]) {
      self.storage = storage
    }
    
    // MARK: - java.util.Enumeration (Java API)
    
    /// Returns `true` while elements remain.
    public func hasMoreElements() -> Bool {
      cursor < storage.count
    }
    
    /// Returns the next element.
    ///
    /// - Throws: `Java.util.NoSuchElementException` when exhausted.
    public func nextElement() throws -> E {
      guard cursor < storage.count else {
        throw java.util.NoSuchElementException("Enumeration exhausted")
      }
      defer { cursor += 1 }
      return storage[cursor]
    }
    
    // MARK: - IteratorProtocol  (muss public sein — Protokollanforderung)
    
    public func next() -> E? {
      guard hasMoreElements() else { return nil }
      defer { cursor += 1 }
      return storage[cursor]
    }
    
    // MARK: - Sequence  (muss public sein — Protokollanforderung)
    
    public func makeIterator() -> VectorEnumeration<E> {
      return self
    }
  }
}

