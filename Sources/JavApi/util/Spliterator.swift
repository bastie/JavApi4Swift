/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

// MARK: - java.util.Spliterator<T>

extension java.util {

  /// An object for traversing and partitioning elements of a source.
  ///
  /// A `Spliterator` may be used to traverse elements individually via
  /// ``tryAdvance(_:)``, or traverse all remaining elements via
  /// ``forEachRemaining(_:)``.  It may also partition off some of its elements
  /// using ``trySplit()``.
  ///
  /// - Since: Java 8
  public protocol Spliterator<T> {
    associatedtype T

    /// If a remaining element exists, performs `action` on it and returns `true`;
    /// otherwise returns `false`.
    ///
    /// - Parameter action: The action to perform on the next element.
    /// - Returns: `false` if no remaining elements exist.
    /// - Since: Java 8
    func tryAdvance(_ action: some java.util.function.Consumer<T>) -> Bool

    /// Performs `action` for each remaining element sequentially.
    ///
    /// The default implementation repeatedly calls ``tryAdvance(_:)`` until
    /// it returns `false`.
    ///
    /// - Since: Java 8
    func forEachRemaining(_ action: some java.util.function.Consumer<T>)

    /// Attempts to partition this spliterator into two halves.
    ///
    /// - Returns: a `Spliterator` covering a prefix of elements, or `nil` if
    /// this spliterator cannot be split.
    ///
    /// - Since: Java 8
    func trySplit() -> (any java.util.Spliterator<T>)?

    /// Returns an estimate of the number of elements this spliterator would
    /// encounter in a complete traversal.
    ///
    /// - Returns: `Int64.max` if infinite, unknown, or too expensive to compute.
    ///
    /// - Since: Java 8
    func estimateSize() -> Int64

    /// Returns a set of characteristics for this spliterator and its elements.
    ///
    /// - Since: Java 8
    func characteristics() -> Int
  }
}

// MARK: - Characteristic constants

extension java.util.Spliterator {

  /// Characteristic: the encounter order follows a defined sequence.
  /// - Since: Java 8
  public static var ORDERED: Int { 0x00000010 }

  /// Characteristic: each element is encountered at most once.
  /// - Since: Java 8
  public static var DISTINCT: Int { 0x00000001 }

  /// Characteristic: the encounter order follows a sorted order.
  /// - Since: Java 8
  public static var SORTED: Int { 0x00000004 }

  /// Characteristic: the size estimate returned by ``estimateSize()`` is exact.
  /// - Since: Java 8
  public static var SIZED: Int { 0x00000040 }

  /// Characteristic: no element returned by the source is `nil`.
  /// - Since: Java 8
  public static var NONNULL: Int { 0x00000100 }

  /// Characteristic: the element source cannot be structurally modified.
  /// - Since: Java 8
  public static var IMMUTABLE: Int { 0x00000400 }

  /// Characteristic: the element source may be safely concurrently modified.
  /// - Since: Java 8
  public static var CONCURRENT: Int { 0x00001000 }

  /// Characteristic: all ``trySplit()`` sub-spliterators are `SIZED` and `SUBSIZED`.
  /// - Since: Java 8
  public static var SUBSIZED: Int { 0x00004000 }
}

// MARK: - Default implementations

extension java.util.Spliterator {

  /// Default: repeatedly calls ``tryAdvance(_:)`` until it returns `false`.
  public func forEachRemaining(_ action: some java.util.function.Consumer<T>) {
    while tryAdvance(action) {}
  }
}

// MARK: - _ArraySpliterator (internal default implementation)

/// A simple array-backed `Spliterator` used as the default implementation for
/// `Collection.spliterator()`.
final class _ArraySpliterator<T>: java.util.Spliterator, @unchecked Sendable {

  private let elements: [T]
  private var index: Int

  init(_ elements: [T]) {
    self.elements = elements
    self.index = elements.startIndex
  }

  func tryAdvance(_ action: some java.util.function.Consumer<T>) -> Bool {
    guard index < elements.endIndex else { return false }
    action.accept(elements[index])
    index = elements.index(after: index)
    return true
  }

  func trySplit() -> (any java.util.Spliterator<T>)? {
    let remaining = elements.endIndex - index
    guard remaining > 1 else { return nil }
    let mid = index + remaining / 2
    let prefix = _ArraySpliterator(Array(elements[index..<mid]))
    index = mid
    return prefix
  }

  func estimateSize() -> Int64 { Int64(elements.endIndex - index) }

  func characteristics() -> Int {
    _ArraySpliterator<T>.ORDERED | _ArraySpliterator<T>.SIZED |
    _ArraySpliterator<T>.SUBSIZED | _ArraySpliterator<T>.IMMUTABLE
  }
}
