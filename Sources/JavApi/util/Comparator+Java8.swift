/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

// MARK: - Default methods (Java 8)

extension java.util.Comparator {

  /// Returns a comparator that reverses the order of this comparator.
  ///
  /// - Since: Java 8
  public func reversed() -> any java.util.Comparator<T> {
    _ReversedComparator(self)
  }

  /// Returns a lexicographic-order comparator: first compare by `self`,
  /// then by `other` when `self` considers two elements equal.
  ///
  /// - Since: Java 8
  public func thenComparing(_ other: any java.util.Comparator<T>) -> any java.util.Comparator<T> {
    _ChainedComparator(self, other)
  }
}

// MARK: - Key-extractor factories (Java 8)

extension java.util.Comparator {

  /// Returns a comparator that compares objects by extracting a `Comparable` key.
  ///
  /// Mirrors `java.util.Comparator.comparing(Function<? super T, ? extends U>)` (Java 8).
  ///
  /// - Parameter keyExtractor: The function used to extract the `Comparable` sort key.
  /// - Returns: A comparator that compares by the extracted key.
  /// - Since: Java 8
  public static func comparing<R: Comparable>(
    _ keyExtractor: some java.util.function.Function<T, R>
  ) -> any java.util.Comparator<T> {
    _KeyExtractorComparator<T, R>(keyExtractor)
  }

  /// Returns a lexicographic-order comparator with another comparator derived
  /// from a key-extractor function.
  ///
  /// Equivalent to `thenComparing(Comparator.comparing(keyExtractor))`.
  ///
  /// - Parameter keyExtractor: The function used to extract the `Comparable` sort key.
  /// - Returns: A chained comparator.
  /// - Since: Java 8
  public func thenComparing<R: Comparable>(
    _ keyExtractor: some java.util.function.Function<T, R>
  ) -> any java.util.Comparator<T> {
    thenComparing(_KeyExtractorComparator<T, R>(keyExtractor))
  }
}

// MARK: - Natural / reverse order factories (require T: Comparable)

extension java.util.Comparator where T: Comparable {

  /// Returns a comparator that orders elements according to their natural ordering.
  ///
  /// - Since: Java 8
  public static func naturalOrder() -> any java.util.Comparator<T> {
    _NaturalOrderComparator<T>()
  }

  /// Returns a comparator that orders elements in reverse of their natural ordering.
  ///
  /// - Since: Java 8
  public static func reverseOrder() -> any java.util.Comparator<T> {
    _NaturalOrderComparator<T>().reversed()
  }
}

// MARK: - Private helper types
// Using classes so ObjectIdentifier(self) works reliably for Hashable.

/// Negates the wrapped comparator's result.
private final class _ReversedComparator<T>: java.util.Comparator, SortComparator, @unchecked Sendable {
  var order: SortOrder = .forward
  private let base: any java.util.Comparator<T>

  init(_ base: any java.util.Comparator<T>) { self.base = base }

  func compare(_ lhs: T, _ rhs: T) -> Int { -base.compare(lhs, rhs) }
  func compare(_ lhs: T?, _ rhs: T?) -> Int { -base.compare(lhs, rhs) }
  func compare(_ lhs: T, _ rhs: T) -> ComparisonResult {
    let r: Int = compare(lhs, rhs)
    return r < 0 ? .orderedAscending : r > 0 ? .orderedDescending : .orderedSame
  }

  static func == (lhs: _ReversedComparator<T>, rhs: _ReversedComparator<T>) -> Bool {
    lhs === rhs
  }
  func hash(into hasher: inout Hasher) { hasher.combine(ObjectIdentifier(self)) }
}

/// Falls through to `second` when `first` considers elements equal.
private final class _ChainedComparator<T>: java.util.Comparator, SortComparator, @unchecked Sendable {
  var order: SortOrder = .forward
  private let first: any java.util.Comparator<T>
  private let second: any java.util.Comparator<T>

  init(_ first: any java.util.Comparator<T>, _ second: any java.util.Comparator<T>) {
    self.first = first; self.second = second
  }

  func compare(_ lhs: T, _ rhs: T) -> Int {
    let r = first.compare(lhs, rhs)
    return r != 0 ? r : second.compare(lhs, rhs)
  }
  func compare(_ lhs: T?, _ rhs: T?) -> Int {
    let r = first.compare(lhs, rhs)
    return r != 0 ? r : second.compare(lhs, rhs)
  }
  func compare(_ lhs: T, _ rhs: T) -> ComparisonResult {
    let r: Int = compare(lhs, rhs)
    return r < 0 ? .orderedAscending : r > 0 ? .orderedDescending : .orderedSame
  }

  static func == (lhs: _ChainedComparator<T>, rhs: _ChainedComparator<T>) -> Bool {
    lhs === rhs
  }
  func hash(into hasher: inout Hasher) { hasher.combine(ObjectIdentifier(self)) }
}

/// Compares by applying a key-extractor function and comparing the resulting `Comparable` keys.
private final class _KeyExtractorComparator<T, R: Comparable>: java.util.Comparator, SortComparator, @unchecked Sendable {
  var order: SortOrder = .forward
  private let keyExtractor: any java.util.function.Function<T, R>

  init(_ keyExtractor: any java.util.function.Function<T, R>) {
    self.keyExtractor = keyExtractor
  }

  func compare(_ lhs: T, _ rhs: T) -> Int {
    let l = keyExtractor.apply(lhs), r = keyExtractor.apply(rhs)
    return l < r ? -1 : l > r ? 1 : 0
  }
  func compare(_ lhs: T?, _ rhs: T?) -> Int {
    switch (lhs, rhs) {
    case (nil, nil): return 0
    case (nil, _):   return -1
    case (_, nil):   return  1
    default:         return compare(lhs!, rhs!)
    }
  }
  func compare(_ lhs: T, _ rhs: T) -> ComparisonResult {
    let r: Int = compare(lhs, rhs)
    return r < 0 ? .orderedAscending : r > 0 ? .orderedDescending : .orderedSame
  }

  static func == (lhs: _KeyExtractorComparator<T, R>, rhs: _KeyExtractorComparator<T, R>) -> Bool {
    lhs === rhs
  }
  func hash(into hasher: inout Hasher) { hasher.combine(ObjectIdentifier(self)) }
}

/// Natural ordering comparator for `Comparable` types.
private final class _NaturalOrderComparator<T: Comparable>: java.util.Comparator, SortComparator, @unchecked Sendable {
  var order: SortOrder = .forward

  func compare(_ lhs: T, _ rhs: T) -> Int {
    lhs < rhs ? -1 : lhs > rhs ? 1 : 0
  }
  func compare(_ lhs: T?, _ rhs: T?) -> Int {
    switch (lhs, rhs) {
    case (nil, nil): return 0
    case (nil, _):   return -1
    case (_, nil):   return  1
    default:         return compare(lhs!, rhs!)
    }
  }
  func compare(_ lhs: T, _ rhs: T) -> ComparisonResult {
    lhs < rhs ? .orderedAscending : lhs > rhs ? .orderedDescending : .orderedSame
  }

  // Two natural-order comparators for the same T are logically equal.
  static func == (lhs: _NaturalOrderComparator<T>, rhs: _NaturalOrderComparator<T>) -> Bool { true }
  func hash(into hasher: inout Hasher) { hasher.combine(ObjectIdentifier(T.self)) }
}
