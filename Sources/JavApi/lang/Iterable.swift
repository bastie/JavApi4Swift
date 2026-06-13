/*
 * SPDX-FileCopyrightText: 2025 - 2026 Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

/// Java's `Iterable<T>` — a type that can produce an `Iterator`.
///
/// Unlike Java, Swift's `for-in` requires `Sequence`, not `Iterable`.
/// Conforming types must implement `iterator()` (Java API) and
/// `makeIterator()` (Swift `Sequence` bridge) separately.
///
/// `Iterable` intentionally does NOT inherit `IteratorProtocol` because
/// in Java an `Iterable` is not itself an iterator — it only produces one.
public protocol Iterable<E> {
  associatedtype E
  func iterator() -> any java.util.Iterator<E>
}
