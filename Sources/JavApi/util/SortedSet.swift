/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.util {

  /// Swift protocol mirroring `java.util.SortedSet<E>`.
  ///
  /// A `Collection` that contains no duplicate elements and maintains its
  /// elements in ascending natural order (`Comparable`). The `TreeSet`
  /// concrete implementation provides this contract.
  ///
  /// - Since: Java 1.2
  public protocol SortedSet<E>: java.util.SequencedSet where E: Comparable {

    // MARK: - Range views

    /// Returns a view of the portion of this set whose elements are strictly
    /// less than `toElement`.
    func headSet(_ toElement: E) -> any java.util.SortedSet<E>

    /// Returns a view of the portion of this set whose elements are greater
    /// than or equal to `fromElement`.
    func tailSet(_ fromElement: E) -> any java.util.SortedSet<E>

    /// Returns a view of the portion of this set whose elements range from
    /// `fromElement` (inclusive) to `toElement` (exclusive).
    func subSet(_ fromElement: E, _ toElement: E) -> any java.util.SortedSet<E>

    // MARK: - Endpoints

    /// Returns the first (lowest) element in this set.
    /// - Throws: `NoSuchElementException` if the set is empty.
    func first() throws -> E

    /// Returns the last (highest) element in this set.
    /// - Throws: `NoSuchElementException` if the set is empty.
    func last() throws -> E

    /// Returns the comparator used to order the elements in this set,
    /// or `nil` if it uses the elements' natural ordering.
    ///
    /// - Since: Java 1.2
    func comparator() -> (any java.util.Comparator<E>)?
  }
}

extension java.util.SortedSet {

  public func comparator() -> (any java.util.Comparator<E>)? { nil }

  // MARK: - SequencedCollection defaults for SortedSet

  /// Default: returns the first element in natural order.
  /// - Throws: `NoSuchElementException` if empty.
  public func getFirst() throws -> E { try first() }

  /// Default: returns the last element in natural order.
  /// - Throws: `NoSuchElementException` if empty.
  public func getLast() throws -> E { try last() }

  /// Default: removes and returns the first element.
  /// - Throws: `NoSuchElementException` if empty.
  public func removeFirst() throws -> E {
    let e = try first()
    _ = remove(e)
    return e
  }

  /// Default: removes and returns the last element.
  /// - Throws: `NoSuchElementException` if empty.
  public func removeLast() throws -> E {
    let e = try last()
    _ = remove(e)
    return e
  }

  /// Default: returns elements in descending order as an `ArrayList`.
  ///
  /// Concrete subclasses (e.g. `TreeSet`) should override this with a proper
  /// descending-order view.
  public func reversed() -> any java.util.SequencedCollection<E> {
    let arr = toArray()
    let result = java.util.ArrayList<E>()
    for e in arr.reversed() {
      if let e {
        _ = try? result.add(e)
      }
    }
    return result
  }

  // MARK: - SequencedSet default

  /// Default: not supported — concrete types must override.
  ///
  /// `TreeSet` provides a proper descending view in Phase 2.
  public func reversedSet() -> any java.util.SequencedSet<E> {
    fatalError("reversedSet() not implemented for \(type(of: self))")
  }
}
