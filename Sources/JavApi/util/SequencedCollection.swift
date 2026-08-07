/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.util {

  /// A `Collection` with a well-defined encounter order that supports operations
  /// at both ends.  Part of the sequenced collections
  /// hierarchy to give a unified API to `List`, `Deque`, and `LinkedHashSet`.
  ///
  /// Methods `addFirst`/`addLast` and `removeFirst`/`removeLast` have optional
  /// default implementations that throw `UnsupportedOperationException`, matching
  /// Java's abstract default behaviour for read-only views.
  ///
  /// - Since: Java 21
  public protocol SequencedCollection<E>: java.util.Collection {

    // MARK: - Endpoint access

    /// Returns the first element of this collection.
    /// - Throws: `NoSuchElementException` if the collection is empty.
    func getFirst() throws -> E

    /// Returns the last element of this collection.
    /// - Throws: `NoSuchElementException` if the collection is empty.
    func getLast() throws -> E

    // MARK: - Endpoint mutation

    /// Inserts `e` as the first element (optional operation).
    func addFirst(_ e: E) throws

    /// Inserts `e` as the last element (optional operation).
    func addLast(_ e: E) throws

    /// Removes and returns the first element (optional operation).
    /// - Throws: `NoSuchElementException` if the collection is empty.
    func removeFirst() throws -> E

    /// Removes and returns the last element (optional operation).
    /// - Throws: `NoSuchElementException` if the collection is empty.
    func removeLast() throws -> E

    // MARK: - Reversed view

    /// Returns a reverse-order view of this collection.
    func reversed() -> any java.util.SequencedCollection<E>
  }
}

// MARK: - Default implementations

extension java.util.SequencedCollection {

  /// Default: throws `UnsupportedOperationException`.
  public func addFirst(_ e: E) throws {
    throw java.lang.UnsupportedOperationException("addFirst not supported")
  }

  /// Default: throws `UnsupportedOperationException`.
  public func addLast(_ e: E) throws {
    throw java.lang.UnsupportedOperationException("addLast not supported")
  }

  /// Default: throws `UnsupportedOperationException`.
  public func removeFirst() throws -> E {
    throw java.lang.UnsupportedOperationException("removeFirst not supported")
  }

  /// Default: throws `UnsupportedOperationException`.
  public func removeLast() throws -> E {
    throw java.lang.UnsupportedOperationException("removeLast not supported")
  }
}
