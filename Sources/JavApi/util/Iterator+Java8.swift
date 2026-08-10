/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

// MARK: - Java 8 default methods for Iterator

extension java.util.Iterator {

  /// Performs the given action for each remaining element until all elements
  /// have been processed or the action throws.
  ///
  /// Mirrors `java.util.Iterator.forEachRemaining(Consumer<? super E>)` (Java 8).
  ///
  /// - Parameter action: The action to be performed for each element.
  /// - Since: Java 8
  public func forEachRemaining(_ action: some java.util.function.Consumer<Element>) {
    while hasNext() {
      if let e = try? next() {
        action.accept(e)
      }
    }
  }
}
