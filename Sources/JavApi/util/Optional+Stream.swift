/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.util.Optional {

  /// If a value is present, returns a sequential `Stream` containing only
  /// that value; otherwise returns an empty `Stream`.
  ///
  /// ```swift
  /// let s = java.util.Optional.of(42).stream()   // Stream[42]
  /// let e = java.util.Optional<Int>.empty().stream() // Stream[]
  /// ```
  ///
  /// - Returns: A stream with zero or one element.
  /// - Since: Java 9
  public func stream() -> java.util.stream.Stream<T> {
    if let value = swiftOptional() {
      return java.util.stream.Stream.of(value)
    }
    else {
      return java.util.stream.Stream<T>.empty()
    }
  }
}
