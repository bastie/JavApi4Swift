/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.util {

  /// Swift protocol mirroring `java.util.NavigableSet<E>`.
  ///
  /// A `SortedSet` extended with navigation methods that return the closest
  /// matching element for given search targets.  Methods `lower`, `floor`,
  /// `ceiling`, and `higher` return the nearest element strictly less than,
  /// less than or equal to, greater than or equal to, and strictly greater
  /// than the given value, respectively — returning `nil` if no such element
  /// exists.
  ///
  /// Navigation methods returning `nil` correspond to Java's `null` return
  /// for the same boundary conditions.  Polling methods (`pollFirst`,
  /// `pollLast`) remove and return the endpoint element, or return `nil` if
  /// the set is empty — matching Java's `null`.
  ///
  /// - Since: Java 6
  public protocol NavigableSet<E>: java.util.SortedSet {

    // MARK: - Closest-match navigation

    /// Returns the greatest element strictly less than `e`, or `nil`.
    func lower(_ e: E) -> E?

    /// Returns the greatest element less than or equal to `e`, or `nil`.
    func floor(_ e: E) -> E?

    /// Returns the least element greater than or equal to `e`, or `nil`.
    func ceiling(_ e: E) -> E?

    /// Returns the least element strictly greater than `e`, or `nil`.
    func higher(_ e: E) -> E?

    // MARK: - Polling (removes and returns endpoint)

    /// Retrieves and removes the first (lowest) element, or returns `nil`.
    func pollFirst() -> E?

    /// Retrieves and removes the last (highest) element, or returns `nil`.
    func pollLast() -> E?

    // MARK: - Descending views

    /// Returns a reverse-order view of this set.
    func descendingSet() -> any java.util.NavigableSet<E>

    /// Returns an iterator over the elements in descending order.
    func descendingIterator() -> any java.util.Iterator<E>

    // MARK: - Range views (inclusive overloads, Java 6)

    /// Returns a view of the portion of this set whose elements range from
    /// `fromElement` to `toElement`.
    ///
    /// - Parameters:
    ///   - fromElement: Low endpoint of the returned set.
    ///   - fromInclusive: If `true`, the low endpoint is included.
    ///   - toElement: High endpoint of the returned set.
    ///   - toInclusive: If `true`, the high endpoint is included.
    func subSet(_ fromElement: E, _ fromInclusive: Bool,
                _ toElement: E,   _ toInclusive: Bool) -> any java.util.NavigableSet<E>

    /// Returns a view of the portion of this set whose elements are less than
    /// (or, if `inclusive` is `true`, less than or equal to) `toElement`.
    func headSet(_ toElement: E, _ inclusive: Bool) -> any java.util.NavigableSet<E>

    /// Returns a view of the portion of this set whose elements are greater than
    /// (or, if `inclusive` is `true`, greater than or equal to) `fromElement`.
    func tailSet(_ fromElement: E, _ inclusive: Bool) -> any java.util.NavigableSet<E>
  }
}
