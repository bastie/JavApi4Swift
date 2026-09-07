/*
 * SPDX-FileCopyrightText: 2025-2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
extension java.util {
  
  /// Java's `java.util.Iterator` — a cursor over a sequence of elements.
  ///
  /// Does NOT inherit `IteratorProtocol` to avoid the `next() throws -> E`
  /// vs `next() -> E?` signature conflict. Concrete implementations provide
  /// `IteratorProtocol` and `makeIterator()` themselves for Swift `for-in` support.
  public protocol Iterator<Element> : Sequence {

    func hasNext() -> Bool

    /// Throws `java.util.NoSuchElementException` if no more elements are
    /// available, or `java.util.ConcurrentModificationException` (fail-fast,
    /// where implemented) if the backing collection was structurally
    /// modified outside this iterator.
    ///
    /// Declared as `throws (java.lang.RuntimeException)` — a common
    /// supertype covering both — rather than a single concrete exception
    /// type, because Swift's typed-throws protocol conformance requires an
    /// exact type match from every conformer (no covariance); a single
    /// conforming type needs to be able to throw either exception.
    func next() throws(java.lang.RuntimeException) -> Element

    /// Throws `java.lang.IllegalStateException` if `next()` has not yet
    /// been called, or the element was already removed, or
    /// `java.util.ConcurrentModificationException` (fail-fast, where
    /// implemented) if the backing collection was structurally modified
    /// outside this iterator. See `next()` for why this uses the common
    /// `RuntimeException` supertype instead of one concrete type.
    func remove() throws(java.lang.RuntimeException)
  }
}
