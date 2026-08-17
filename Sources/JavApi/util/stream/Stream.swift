/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

// MARK: - java.util.stream.Stream<T>

extension java.util.stream {

  /// A sequence of elements supporting sequential aggregate operations.
  ///
  /// Mirrors `java.util.stream.Stream<T>` (Java 8).
  ///
  /// Streams are **lazy** — intermediate operations (``filter(_:)``,
  /// ``map(_:)``, etc.) are not evaluated until a terminal operation
  /// (``forEach(_:)``, ``count()``, etc.) is invoked.
  ///
  /// Streams are **single-use** — consuming a stream a second time produces
  /// undefined results, matching Java's specification.
  ///
  /// ```swift
  /// let list = java.util.ArrayList<Int>()
  /// _ = try? list.add(1); _ = try? list.add(2); _ = try? list.add(3)
  /// let sum = list.stream()
  ///   .filter(java.util.function.AnyPredicate { $0 > 1 })
  ///   .map(java.util.function.AnyFunction { $0 * 10 })
  ///   .reduce(0, java.util.function.AnyBinaryOperator { $0 + $1 })
  /// // sum == 50
  /// ```
  ///
  /// - Note: `parallel()` is accepted but treated as a no-op; all execution
  ///   is sequential.
  ///
  /// - Since: Java 8
  public final class Stream<T>: @unchecked Sendable {

    // The source is a lazy factory: evaluated once per terminal operation.
    private let _makeSequence: () -> AnySequence<T>

    // MARK: - Internal constructors

    /// Wraps any `Sequence` as a stream source.
    init<S: Sequence>(_ sequence: S) where S.Element == T {
      let captured = AnySequence(sequence)
      _makeSequence = { captured }
    }

    /// Wraps a lazy sequence factory (used by intermediate operations).
    private init(_ factory: @escaping () -> AnySequence<T>) {
      _makeSequence = factory
    }

    // MARK: - Factory methods

    /// Returns a stream containing the given elements.
    ///
    /// - Since: Java 8
    public static func of(_ elements: T...) -> Stream<T> {
      Stream(elements)
    }

    /// Returns an empty stream.
    ///
    /// - Since: Java 8
    public static func empty() -> Stream<T> {
      Stream(EmptyCollection<T>())
    }

    /// Returns an infinite sequential stream where each element is generated
    /// by the supplied `Supplier`.
    ///
    /// - Parameter supplier: A supplier of generated values.
    /// - Since: Java 8
    public static func generate(_ supplier: some java.util.function.Supplier<T>) -> Stream<T> {
      Stream(AnySequence(sequence(state: (), next: { _ in supplier.get() })))
    }

    /// Returns an infinite sequential ordered stream produced by iterative
    /// application of `f` to an initial `seed`.
    ///
    /// Elements: `seed, f(seed), f(f(seed)), …`
    ///
    /// - Parameters:
    ///   - seed: The initial element.
    ///   - f: A function applied to the preceding element to produce the next.
    /// - Since: Java 8
    public static func iterate(_ seed: T, _ f: some java.util.function.UnaryOperator<T>) -> Stream<T> {
      Stream(AnySequence(sequence(first: seed, next: { f.apply($0) })))
    }

    // MARK: - Intermediate operations (return a new Stream, evaluated lazily)

    /// Returns a stream consisting of the elements that match `predicate`.
    ///
    /// - Since: Java 8
    public func filter(_ predicate: some java.util.function.Predicate<T>) -> Stream<T> {
      Stream { [_makeSequence] in
        AnySequence(_makeSequence().lazy.filter { predicate.test($0) })
      }
    }

    /// Returns a stream consisting of the results of applying `mapper` to
    /// each element.
    ///
    /// - Since: Java 8
    public func map<R>(_ mapper: some java.util.function.Function<T, R>) -> Stream<R> {
      Stream<R> { [_makeSequence] in
        AnySequence(_makeSequence().lazy.map { mapper.apply($0) })
      }
    }

    /// Returns a stream consisting of the results of replacing each element
    /// with the contents of the stream produced by `mapper`.
    ///
    /// - Since: Java 8
    public func flatMap<R>(_ mapper: some java.util.function.Function<T, Stream<R>>) -> Stream<R> {
      Stream<R> { [_makeSequence] in
        AnySequence(_makeSequence().lazy.flatMap { mapper.apply($0)._makeSequence() })
      }
    }

    /// Returns a stream consisting of the elements, truncated to no more than
    /// `maxSize` elements in length.
    ///
    /// - Since: Java 8
    public func limit(_ maxSize: Int64) -> Stream<T> {
      Stream { [_makeSequence] in
        AnySequence(_makeSequence().prefix(Int(maxSize)))
      }
    }

    /// Returns a stream consisting of the remaining elements after discarding
    /// the first `n` elements.
    ///
    /// - Since: Java 8
    public func skip(_ n: Int64) -> Stream<T> {
      Stream { [_makeSequence] in
        AnySequence(_makeSequence().dropFirst(Int(n)))
      }
    }

    /// Returns a stream consisting of the elements, sorted by `comparator`.
    ///
    /// This is a **stateful** intermediate operation.
    ///
    /// - Since: Java 8
    public func sorted(_ comparator: some java.util.Comparator<T>) -> Stream<T> {
      Stream { [_makeSequence] in
        AnySequence(Array(_makeSequence()).sorted { comparator.compare($0, $1) < 0 })
      }
    }

    /// Returns a stream consisting of the elements, additionally performing
    /// `action` on each element as they are consumed by the pipeline.
    ///
    /// This method exists mainly for debugging pipelines.
    ///
    /// - Since: Java 8
    public func peek(_ action: some java.util.function.Consumer<T>) -> Stream<T> {
      Stream { [_makeSequence] in
        AnySequence(_makeSequence().lazy.map { element -> T in
          action.accept(element)
          return element
        })
      }
    }

    /// Returns a stream by replacing each element with zero or more elements
    /// produced by `mapper` via a `Consumer` push callback.
    ///
    /// Mirrors `java.util.stream.Stream.mapMulti(BiConsumer<T,Consumer<R>>)` (Java 16).
    ///
    /// Unlike `flatMap`, no intermediate stream is created — the mapper pushes
    /// results directly into a buffer by calling `push.accept(r)`.
    ///
    /// ```swift
    /// let doubled = stream.mapMulti(
    ///   java.util.function.AnyBiConsumer { (x: Int, push: java.util.function.AnyConsumer<Int>) in
    ///     push.accept(x)
    ///     push.accept(x * 2)
    ///   }
    /// )
    /// ```
    ///
    /// - Parameter mapper: A `BiConsumer` that receives each source element and
    ///   a `Consumer<R>` push callback; every value passed to `push.accept(_:)`
    ///   appears in the resulting stream.
    /// - Since: Java 16
    public func mapMulti<R>(
      _ mapper: some java.util.function.BiConsumer<T, java.util.function.AnyConsumer<R>>
    ) -> Stream<R> {
      Stream<R> { [_makeSequence] in
        var results: [R] = []
        let push = java.util.function.AnyConsumer<R> { r in results.append(r) }
        for element in _makeSequence() {
          mapper.accept(element, push)
        }
        return AnySequence(results)
      }
    }

    /// Returns a stream consisting of the results of applying `gatherer` to the
    /// elements of this stream.
    ///
    /// A `Gatherer` is a composable, stateful transformation that can implement
    /// patterns not expressible with `map`, `filter`, and `flatMap` alone —
    /// such as windowing, prefix scans, and concurrent mapping.
    ///
    /// ```swift
    /// let windows = stream.gather(java.util.stream.Gatherers.windowFixed(3))
    /// ```
    ///
    /// Mirrors `Stream.gather(Gatherer<? super T, ?, R>)` (Java 24).
    ///
    /// - Parameter gatherer: The gatherer to apply.
    /// - Since: Java 22 (finalised in Java 24)
    public func gather<R>(_ gatherer: Gatherer<T, R>) -> Stream<R> {
      Stream<R> { [_makeSequence] in
        AnySequence(gatherer._process(_makeSequence()))
      }
    }

    /// Returns a no-op that signals intent to parallelize — currently a no-op.
    ///
    /// All execution in JavApi⁴Swift streams is sequential.
    ///
    /// - Since: Java 8
    public func parallel() -> Stream<T> { self }

    /// Returns this stream as sequential — a no-op since all streams are sequential.
    ///
    /// - Since: Java 8
    public func sequential() -> Stream<T> { self }

    // MARK: - Terminal operations (trigger evaluation)

    /// Performs `action` for each element of this stream.
    ///
    /// - Since: Java 8
    public func forEach(_ action: some java.util.function.Consumer<T>) {
      for element in _makeSequence() { action.accept(element) }
    }

    /// Returns the count of elements in this stream.
    ///
    /// - Since: Java 8
    public func count() -> Int64 {
      var c: Int64 = 0
      for _ in _makeSequence() { c += 1 }
      return c
    }

    /// Performs a reduction on the elements using `identity` and `accumulator`.
    ///
    /// - Since: Java 8
    public func reduce(_ identity: T, _ accumulator: some java.util.function.BinaryOperator<T>) -> T {
      var result = identity
      for element in _makeSequence() { result = accumulator.apply(result, element) }
      return result
    }

    /// Performs a reduction using `accumulator` with no identity value.
    ///
    /// Returns `nil` if the stream is empty.
    ///
    /// - Since: Java 8
    public func reduce(_ accumulator: some java.util.function.BinaryOperator<T>) -> T? {
      var result: T? = nil
      for element in _makeSequence() {
        if let r = result { result = accumulator.apply(r, element) }
        else { result = element }
      }
      return result
    }

    /// Returns the first element of this stream, or `nil` if empty.
    ///
    /// - Since: Java 8
    public func findFirst() -> T? {
      for element in _makeSequence() { return element }
      return nil
    }

    /// Returns any element of this stream, or `nil` if empty.
    ///
    /// In a sequential stream this is equivalent to ``findFirst()``.
    ///
    /// - Since: Java 8
    public func findAny() -> T? { findFirst() }

    /// Returns `true` if any element matches `predicate`.
    ///
    /// - Since: Java 8
    public func anyMatch(_ predicate: some java.util.function.Predicate<T>) -> Bool {
      for element in _makeSequence() { if predicate.test(element) { return true } }
      return false
    }

    /// Returns `true` if all elements match `predicate`, or the stream is empty.
    ///
    /// - Since: Java 8
    public func allMatch(_ predicate: some java.util.function.Predicate<T>) -> Bool {
      for element in _makeSequence() { if !predicate.test(element) { return false } }
      return true
    }

    /// Returns `true` if no elements match `predicate`, or the stream is empty.
    ///
    /// - Since: Java 8
    public func noneMatch(_ predicate: some java.util.function.Predicate<T>) -> Bool {
      for element in _makeSequence() { if predicate.test(element) { return false } }
      return true
    }

    /// Returns the minimum element according to `comparator`, or `nil` if empty.
    ///
    /// - Since: Java 8
    public func min(_ comparator: some java.util.Comparator<T>) -> T? {
      var result: T? = nil
      for element in _makeSequence() {
        if let current = result {
          if comparator.compare(element, current) < 0 { result = element }
        } else { result = element }
      }
      return result
    }

    /// Returns the maximum element according to `comparator`, or `nil` if empty.
    ///
    /// - Since: Java 8
    public func max(_ comparator: some java.util.Comparator<T>) -> T? {
      var result: T? = nil
      for element in _makeSequence() {
        if let current = result {
          if comparator.compare(element, current) > 0 { result = element }
        } else { result = element }
      }
      return result
    }

    /// Returns the elements of this stream as a Swift array.
    ///
    /// - Since: Java 8
    public func toArray() -> [T] {
      Array(_makeSequence())
    }

    /// Returns the elements of this stream as a `java.util.List`.
    ///
    /// - Since: Java 16 (added to JavApi⁴Swift with Java 8 stream support)
    public func toList() -> any java.util.List<T> where T: Equatable {
      let list = java.util.ArrayList<T>()
      for element in _makeSequence() { _ = try? list.add(element) }
      return list
    }

    /// Performs a reduction on the stream's elements using `collector`.
    ///
    /// - Since: Java 8
    public func collect<R>(_ collector: some java.util.stream.Collector<T, R>) -> R {
      collector.collect(_makeSequence())
    }

    /// Returns a `Spliterator` over the elements of this stream.
    ///
    /// - Since: Java 8
    public func spliterator() -> any java.util.Spliterator<T> {
      _ArraySpliterator(toArray())
    }
  }
}

// MARK: - Constrained extensions

extension java.util.stream.Stream where T: Hashable {

  /// Returns a stream consisting of the distinct elements (according to ``==``).
  ///
  /// This is a **stateful** intermediate operation.
  ///
  /// - Since: Java 8
  public func distinct() -> java.util.stream.Stream<T> {
    java.util.stream.Stream<T> { [_makeSequence] in
      var seen = Set<T>()
      return AnySequence(_makeSequence().lazy.filter { seen.insert($0).inserted })
    }
  }
}

extension java.util.stream.Stream where T: Comparable {

  /// Returns a stream consisting of the elements sorted in natural order.
  ///
  /// This is a **stateful** intermediate operation.
  ///
  /// - Since: Java 8
  public func sorted() -> java.util.stream.Stream<T> {
    java.util.stream.Stream<T> { [_makeSequence] in
      AnySequence(Array(_makeSequence()).sorted())
    }
  }
}
