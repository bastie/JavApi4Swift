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
  public protocol SortedSet<E>: java.util.Collection where E: Comparable {

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
  }
}
