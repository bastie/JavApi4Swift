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

    func next() throws (java.util.NoSuchElementException) -> Element

    func remove() throws (java.lang.IllegalStateException)
  }
}
