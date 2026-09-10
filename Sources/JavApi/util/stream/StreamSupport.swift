/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.util.stream {

  /// Low-level utility methods for creating and manipulating streams from a
  /// `Spliterator`.
  ///
  /// Mirrors `java.util.stream.StreamSupport` (Java 8). This port drains the
  /// given `Spliterator` eagerly into an array before wrapping it as a
  /// stream (rather than truly streaming element-by-element from the
  /// spliterator), since ``Stream``/``IntStream``/``LongStream``/
  /// ``DoubleStream`` are themselves array/sequence-backed. This preserves
  /// the resulting stream's element order and content but not the
  /// spliterator's own incremental-consumption behaviour.
  ///
  /// - Since: Java 8
  public enum StreamSupport {

    /// Creates a new sequential or parallel `Stream` from `spliterator`.
    /// - Since: Java 8
    public static func stream<T>(_ spliterator: any java.util.Spliterator<T>, _ parallel: Bool) -> Stream<T> {
      let s = Stream<T>(_drain(spliterator))
      if parallel { s.parallel() }
      return s
    }

    /// Creates a new sequential or parallel `IntStream` from `spliterator`.
    /// - Since: Java 8
    public static func intStream(_ spliterator: any java.util.Spliterator<Int>, _ parallel: Bool) -> IntStream {
      let s = IntStream(_drain(spliterator))
      if parallel { s.parallel() }
      return s
    }

    /// Creates a new sequential or parallel `LongStream` from `spliterator`.
    /// - Since: Java 8
    public static func longStream(_ spliterator: any java.util.Spliterator<Int64>, _ parallel: Bool) -> LongStream {
      let s = LongStream(_drain(spliterator))
      if parallel { s.parallel() }
      return s
    }

    /// Creates a new sequential or parallel `DoubleStream` from `spliterator`.
    /// - Since: Java 8
    public static func doubleStream(_ spliterator: any java.util.Spliterator<Double>, _ parallel: Bool) -> DoubleStream {
      let s = DoubleStream(_drain(spliterator))
      if parallel { s.parallel() }
      return s
    }

    /// Drains a `Spliterator` into a plain Swift array via `forEachRemaining`.
    private static func _drain<T>(_ spliterator: any java.util.Spliterator<T>) -> [T] {
      var results: [T] = []
      spliterator.forEachRemaining(java.util.function.AnyConsumer<T> { results.append($0) })
      return results
    }
  }
}
