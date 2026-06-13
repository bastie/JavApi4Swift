/*
 * SPDX-FileCopyrightText: 2025-2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
extension java.util.Iterator {

  /// Default `makeIterator()` for `Sequence` conformance.
  /// Wraps the Java-style iterator in an `AnyIterator` so `for-in` works
  /// without requiring concrete types to implement `IteratorProtocol` directly.
  public func makeIterator() -> AnyIterator<Element?> {
    let it = self
    return AnyIterator {
      guard it.hasNext() else { return nil }
      return try? it.next()
    }
  }

  public func remove() throws (java.lang.IllegalStateException) {
    throw java.lang.IllegalStateException()
  }
}
