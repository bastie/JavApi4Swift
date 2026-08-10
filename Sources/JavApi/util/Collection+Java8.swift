/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

// MARK: - Java 8 default methods for Collection

extension java.util.Collection {

  /// Performs the given action for each element of this collection.
  ///
  /// Mirrors `java.util.Iterable.forEach(Consumer<? super T>)` (Java 8).
  ///
  /// The default implementation iterates over all elements using ``iterator()``.
  /// Exceptions thrown by `action` propagate to the caller.
  ///
  /// - Parameter action: The action to be performed for each element.
  /// - Since: Java 8
  public func forEach(_ action: some java.util.function.Consumer<E>) {
    let it = iterator()
    while it.hasNext() {
      if let e = try? it.next() {
        action.accept(e)
      }
    }
  }

  /// Returns a sequential `Stream` over the elements in this collection.
  ///
  /// Mirrors `java.util.Collection.stream()` (Java 8).
  ///
  /// - Returns: A sequential `Stream` over the elements of this collection.
  /// - Since: Java 8
  public func stream() -> java.util.stream.Stream<E> {
    java.util.stream.Stream(toArray().compactMap { $0 })
  }

  /// Returns a `Spliterator` over the elements in this collection.
  ///
  /// Mirrors `java.util.Collection.spliterator()` (Java 8).
  ///
  /// - Since: Java 8
  public func spliterator() -> any java.util.Spliterator<E> {
    _ArraySpliterator(toArray().compactMap { $0 })
  }

  /// Removes all elements of this collection that satisfy the given predicate.
  ///
  /// Mirrors `java.util.Collection.removeIf(Predicate<? super E>)` (Java 8).
  ///
  /// The default implementation iterates over all elements and calls
  /// `iterator().remove()` for each element that matches the predicate.
  ///
  /// - Parameter filter: A predicate which returns `true` for elements to remove.
  /// - Returns: `true` if any elements were removed.
  /// - Since: Java 8
  @discardableResult
  public func removeIf(_ filter: some java.util.function.Predicate<E>) -> Bool {
    var removed = false
    let it = iterator()
    while it.hasNext() {
      if let e = try? it.next(), filter.test(e) {
        try? it.remove()
        removed = true
      }
    }
    return removed
  }
}
