/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.util {

  /// Swift implementation of ``java.util.AbstractSequentialList``.
  ///
  /// Provides a skeletal implementation of the `List` protocol backed by a
  /// sequential-access data store. All random-access operations (`get`, `set`,
  /// `add(at:)`, `remove(at:)`) are implemented by walking a `ListIterator` to
  /// the requested index, matching the Java specification exactly.
  ///
  /// Subclasses must implement:
  /// - `listIterator(_ location: Int) -> any ListIterator<E>`
  /// - `size() -> Int`
  ///
  /// - Since: Java 1.2
  open class AbstractSequentialList<E: Equatable>: AbstractList<E> {

    // MARK: - Random access via ListIterator

    /// Returns the element at the specified position.
    ///
    /// Walks the list iterator to `location` and returns the element.
    ///
    /// - Throws: `IndexOutOfBoundsException` if `location` is out of range.
    public override func get(_ location: Int) throws -> E? {
      guard location >= 0 && location < size() else {
        throw IndexOutOfBoundsException("Index: \(location), Size: \(size())")
      }
      let it = listIterator(location)
      return try it.next()
    }

    /// Replaces the element at the specified position.
    ///
    /// - Returns: The element previously at that position.
    /// - Throws: `IndexOutOfBoundsException` if `location` is out of range.
    public override func set(_ location: Int, _ element: E?) throws -> E? {
      guard location >= 0 && location < size() else {
        throw IndexOutOfBoundsException("Index: \(location), Size: \(size())")
      }
      let it = listIterator(location)
      let old = try it.next()
      it.set(element)
      return old
    }

    /// Inserts the element at the specified position.
    ///
    /// - Throws: `IndexOutOfBoundsException` if `location` is out of range (`< 0` or `> size()`).
    public override func add(_ location: Int, _ element: E?) throws {
      guard location >= 0 && location <= size() else {
        throw IndexOutOfBoundsException("Index: \(location), Size: \(size())")
      }
      let it = listIterator(location)
      it.add(element)
    }

    /// Removes and returns the element at the specified position.
    ///
    /// - Throws: `IndexOutOfBoundsException` if `location` is out of range.
    public override func remove(_ location: Int) throws -> E? {
      guard location >= 0 && location < size() else {
        throw IndexOutOfBoundsException("Index: \(location), Size: \(size())")
      }
      let it = listIterator(location)
      let element = try it.next()
      try it.remove()
      return element
    }

    // MARK: - Iterator

    /// Returns a forward `Iterator` starting at index 0, delegating to `listIterator(0)`.
    public override func iterator() -> any java.util.Iterator<E> {
      return listIterator(0)
    }

    // MARK: - Abstract (must be overridden)

    /// Returns a `ListIterator` starting at `location`.
    ///
    /// Subclasses **must** override this method.
    public override func listIterator(_ location: Int) -> any java.util.ListIterator<E> {
      fatalError("listIterator(_:) must be implemented by subclass")
    }
  }
}
