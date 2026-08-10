/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

// MARK: - Java 8 default methods for List

extension java.util.List {

  /// Replaces each element of this list with the result of applying the given
  /// operator to that element.
  ///
  /// Mirrors `java.util.List.replaceAll(UnaryOperator<E>)` (Java 8).
  ///
  /// The default implementation iterates over all indices and calls ``set(_:_:)``
  /// with the result of `op.apply(element)`.
  ///
  /// - Parameter op: The operator to apply to each element.
  /// - Since: Java 8
  public func replaceAll(_ op: some java.util.function.UnaryOperator<E>) {
    for i in 0..<size() {
      // try? on E?-returning throwing func: SE-0230 flattens to E?
      if let current = try? get(i) {
        let newVal = op.apply(current)
        _ = try? set(i, newVal)
      }
    }
  }

  /// Sorts this list according to the order induced by the given comparator.
  ///
  /// Mirrors `java.util.List.sort(Comparator<? super E>)` (Java 8).
  ///
  /// The default implementation extracts all elements to a Swift array, sorts
  /// them using `comparator`, and writes the sorted values back via ``set(_:_:)``.
  ///
  /// - Parameter c: The comparator to determine the order of the list.
  /// - Since: Java 8
  public func sort(_ c: some java.util.Comparator<E>) {
    let arr = toArray().compactMap { $0 }
    let sorted = arr.sorted { c.compare($0, $1) < 0 }
    for (i, elem) in sorted.enumerated() {
      _ = try? set(i, elem)
    }
  }
}
