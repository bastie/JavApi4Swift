/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

// MARK: - java.util.stream.IntStream

extension java.util.stream {

  /// A sequence of primitive `Int`-valued elements (Java's `int`) supporting
  /// sequential aggregate operations.
  ///
  /// Mirrors `java.util.stream.IntStream` (Java 8). Structurally the same
  /// lazy, single-use pipeline design as ``Stream``, specialised for `Int`
  /// to avoid boxing and to expose numeric terminal operations (``sum()``,
  /// ``average()``) that only make sense for a numeric element type.
  ///
  /// - Since: Java 8
  public final class IntStream: @unchecked Sendable {

    private let _makeSequence: () -> AnySequence<Int>
    nonisolated(unsafe) private var _isParallel: Bool = false

    // MARK: - Internal constructors

    init<S: Sequence>(_ sequence: S) where S.Element == Int {
      let captured = AnySequence(sequence)
      _makeSequence = { captured }
    }

    private init(_ factory: @escaping () -> AnySequence<Int>, isParallel: Bool = false) {
      _makeSequence = factory
      _isParallel = isParallel
    }

    // MARK: - Factory methods

    /// Returns a stream containing the given elements.
    /// - Since: Java 8
    public static func of(_ elements: Int...) -> IntStream { IntStream(elements) }

    /// Returns an empty stream.
    /// - Since: Java 8
    public static func empty() -> IntStream { IntStream(EmptyCollection<Int>()) }

    /// Returns a stream of the integers `startInclusive, startInclusive+1, …, endExclusive-1`.
    /// - Since: Java 8
    public static func range(_ startInclusive: Int, _ endExclusive: Int) -> IntStream {
      guard startInclusive < endExclusive else { return .empty() }
      return IntStream(startInclusive..<endExclusive)
    }

    /// Returns a stream of the integers `startInclusive, startInclusive+1, …, endInclusive`.
    /// - Since: Java 8
    public static func rangeClosed(_ startInclusive: Int, _ endInclusive: Int) -> IntStream {
      guard startInclusive <= endInclusive else { return .empty() }
      return IntStream(startInclusive...endInclusive)
    }

    /// Returns an infinite sequential stream where each element is generated
    /// by the supplied `IntSupplier`.
    /// - Since: Java 8
    public static func generate(_ supplier: java.util.function.IntSupplier) -> IntStream {
      IntStream(AnySequence(sequence(state: (), next: { _ in supplier.get() })))
    }

    /// Returns an infinite sequential ordered stream: `seed, f(seed), f(f(seed)), …`.
    /// - Since: Java 8
    public static func iterate(_ seed: Int, _ f: java.util.function.IntUnaryOperator) -> IntStream {
      IntStream(AnySequence(sequence(first: seed, next: { f.apply($0) })))
    }

    /// Returns a finite sequential ordered stream that begins with `seed` and
    /// continues applying `f` as long as `hasNext` holds for the current value.
    /// - Since: Java 9
    public static func iterate(
      _ seed: Int,
      _ hasNext: java.util.function.IntPredicate,
      _ f: java.util.function.IntUnaryOperator
    ) -> IntStream {
      IntStream({
        var results: [Int] = []
        var current = seed
        while hasNext.test(current) {
          results.append(current)
          current = f.apply(current)
        }
        return AnySequence(results)
      })
    }

    /// Concatenates two streams into one, elements of `a` followed by elements of `b`.
    /// - Since: Java 8
    public static func concat(_ a: IntStream, _ b: IntStream) -> IntStream {
      IntStream({ AnySequence(Array(a._makeSequence()) + Array(b._makeSequence())) })
    }

    // MARK: - Intermediate operations

    /// Returns a stream consisting of the elements that match `predicate`.
    /// - Since: Java 8
    public func filter(_ predicate: java.util.function.IntPredicate) -> IntStream {
      IntStream({ [_makeSequence] in
        AnySequence(_makeSequence().lazy.filter { predicate.test($0) })
      }, isParallel: _isParallel)
    }

    /// Returns a stream consisting of the results of applying `mapper` to each element.
    /// - Since: Java 8
    public func map(_ mapper: java.util.function.IntUnaryOperator) -> IntStream {
      IntStream({ [_makeSequence] in
        AnySequence(_makeSequence().lazy.map { mapper.apply($0) })
      }, isParallel: _isParallel)
    }

    /// Returns an object-valued `Stream` consisting of the results of applying `mapper`.
    /// - Since: Java 8
    public func mapToObj<R>(_ mapper: java.util.function.IntFunction<R>) -> java.util.stream.Stream<R> {
      java.util.stream.Stream<R>(_makeSequence().lazy.map { mapper.apply($0) })
    }

    /// Returns a `LongStream` consisting of the results of applying `mapper`.
    /// - Since: Java 8
    public func mapToLong(_ mapper: java.util.function.IntToLongFunction) -> java.util.stream.LongStream {
      java.util.stream.LongStream(_makeSequence().lazy.map { mapper.apply($0) })
    }

    /// Returns a `DoubleStream` consisting of the results of applying `mapper`.
    /// - Since: Java 8
    public func mapToDouble(_ mapper: java.util.function.IntToDoubleFunction) -> java.util.stream.DoubleStream {
      java.util.stream.DoubleStream(_makeSequence().lazy.map { mapper.apply($0) })
    }

    /// Returns a stream consisting of the results of replacing each element
    /// with the contents of the stream produced by `mapper`.
    /// - Since: Java 8
    public func flatMap(_ mapper: java.util.function.IntFunction<IntStream>) -> IntStream {
      IntStream({ [_makeSequence] in
        AnySequence(_makeSequence().lazy.flatMap { mapper.apply($0)._makeSequence() })
      }, isParallel: _isParallel)
    }

    /// Returns a stream consisting of the distinct elements.
    ///
    /// This is a **stateful** intermediate operation.
    /// - Since: Java 8
    public func distinct() -> IntStream {
      IntStream({ [_makeSequence] in
        var seen = Set<Int>()
        return AnySequence(_makeSequence().lazy.filter { seen.insert($0).inserted })
      }, isParallel: _isParallel)
    }

    /// Returns a stream consisting of the elements sorted in natural order.
    ///
    /// This is a **stateful** intermediate operation.
    /// - Since: Java 8
    public func sorted() -> IntStream {
      IntStream({ [_makeSequence] in AnySequence(Array(_makeSequence()).sorted()) }, isParallel: _isParallel)
    }

    /// Returns a stream consisting of the elements, additionally performing
    /// `action` on each element as they are consumed by the pipeline.
    /// - Since: Java 8
    public func peek(_ action: java.util.function.IntConsumer) -> IntStream {
      IntStream({ [_makeSequence] in
        AnySequence(_makeSequence().lazy.map { element -> Int in
          action.accept(element)
          return element
        })
      }, isParallel: _isParallel)
    }

    /// Returns a stream truncated to no more than `maxSize` elements.
    /// - Since: Java 8
    public func limit(_ maxSize: Int64) -> IntStream {
      IntStream({ [_makeSequence] in AnySequence(_makeSequence().prefix(Int(maxSize))) }, isParallel: _isParallel)
    }

    /// Returns a stream that discards the first `n` elements.
    /// - Since: Java 8
    public func skip(_ n: Int64) -> IntStream {
      IntStream({ [_makeSequence] in AnySequence(_makeSequence().dropFirst(Int(n))) }, isParallel: _isParallel)
    }

    /// Returns an object-valued `Stream` boxing each `Int` element.
    /// - Since: Java 8
    public func boxed() -> java.util.stream.Stream<Int> {
      java.util.stream.Stream<Int>(_makeSequence())
    }

    /// Returns a `LongStream` widening each `Int` element to `Int64`.
    /// - Since: Java 8
    public func asLongStream() -> java.util.stream.LongStream {
      java.util.stream.LongStream(_makeSequence().lazy.map { Int64($0) })
    }

    /// Returns a `DoubleStream` widening each `Int` element to `Double`.
    /// - Since: Java 8
    public func asDoubleStream() -> java.util.stream.DoubleStream {
      java.util.stream.DoubleStream(_makeSequence().lazy.map { Double($0) })
    }

    /// Returns this stream with parallel execution enabled for terminal operations.
    /// - Since: Java 8
    @discardableResult
    public func parallel() -> IntStream { _isParallel = true; return self }

    /// Returns this stream with parallel execution disabled.
    /// - Since: Java 8
    @discardableResult
    public func sequential() -> IntStream { _isParallel = false; return self }

    /// Returns `true` if this stream will execute terminal operations in parallel.
    /// - Since: Java 8
    public func isParallel() -> Bool { _isParallel }

    // MARK: - Terminal operations

    /// Performs `action` for each element of this stream.
    /// - Since: Java 8
    public func forEach(_ action: java.util.function.IntConsumer) {
      #if os(WASI)
      for element in _makeSequence() { action.accept(element) }
      #else
      if _isParallel {
        let elements = Array(_makeSequence())
        DispatchQueue.concurrentPerform(iterations: elements.count) { i in action.accept(elements[i]) }
      } else {
        for element in _makeSequence() { action.accept(element) }
      }
      #endif
    }

    /// Performs `action` for each element in encounter order.
    /// - Since: Java 8
    public func forEachOrdered(_ action: java.util.function.IntConsumer) {
      for element in _makeSequence() { action.accept(element) }
    }

    /// Returns the elements of this stream as a Swift array.
    /// - Since: Java 8
    public func toArray() -> [Int] { Array(_makeSequence()) }

    /// Performs a reduction on the elements using `identity` and `op`.
    /// - Since: Java 8
    public func reduce(_ identity: Int, _ op: java.util.function.IntBinaryOperator) -> Int {
      var result = identity
      for element in _makeSequence() { result = op.apply(result, element) }
      return result
    }

    /// Performs a reduction using `op` with no identity value. `nil` if empty.
    /// - Since: Java 8
    public func reduce(_ op: java.util.function.IntBinaryOperator) -> Int? {
      var result: Int? = nil
      for element in _makeSequence() {
        if let r = result { result = op.apply(r, element) } else { result = element }
      }
      return result
    }

    /// Returns the sum of the elements. `0` for an empty stream.
    /// - Since: Java 8
    public func sum() -> Int {
      var total = 0
      for element in _makeSequence() { total += element }
      return total
    }

    /// Returns the minimum element, or `nil` if the stream is empty.
    /// - Since: Java 8
    public func min() -> Int? { _makeSequence().min() }

    /// Returns the maximum element, or `nil` if the stream is empty.
    /// - Since: Java 8
    public func max() -> Int? { _makeSequence().max() }

    /// Returns the count of elements in this stream.
    /// - Since: Java 8
    public func count() -> Int64 {
      var c: Int64 = 0
      for _ in _makeSequence() { c += 1 }
      return c
    }

    /// Returns the arithmetic mean of the elements, or `nil` if the stream is empty.
    /// - Since: Java 8
    public func average() -> Double? {
      var total = 0
      var n = 0
      for element in _makeSequence() { total += element; n += 1 }
      guard n > 0 else { return nil }
      return Double(total) / Double(n)
    }

    /// Returns `true` if any element matches `predicate`.
    /// - Since: Java 8
    public func anyMatch(_ predicate: java.util.function.IntPredicate) -> Bool {
      for element in _makeSequence() { if predicate.test(element) { return true } }
      return false
    }

    /// Returns `true` if all elements match `predicate`, or the stream is empty.
    /// - Since: Java 8
    public func allMatch(_ predicate: java.util.function.IntPredicate) -> Bool {
      for element in _makeSequence() { if !predicate.test(element) { return false } }
      return true
    }

    /// Returns `true` if no elements match `predicate`, or the stream is empty.
    /// - Since: Java 8
    public func noneMatch(_ predicate: java.util.function.IntPredicate) -> Bool {
      for element in _makeSequence() { if predicate.test(element) { return false } }
      return true
    }

    /// Returns the first element of this stream, or `nil` if empty.
    /// - Since: Java 8
    public func findFirst() -> Int? {
      for element in _makeSequence() { return element }
      return nil
    }

    /// Returns any element of this stream, or `nil` if empty.
    /// In a sequential stream this is equivalent to ``findFirst()``.
    /// - Since: Java 8
    public func findAny() -> Int? { findFirst() }

    /// Returns an iterator over the elements of this stream.
    /// - Since: Java 8
    public func iterator() -> any java.util.Iterator<Int> {
      _ArrayIterator(toArray())
    }

    /// Returns a `Spliterator` over the elements of this stream.
    /// - Since: Java 8
    public func spliterator() -> any java.util.Spliterator<Int> {
      _ArraySpliterator(toArray())
    }
  }
}

// MARK: - Internal array-backed Iterator (shared shape with other stream types)

private final class _ArrayIterator<E>: java.util.Iterator, IteratorProtocol {
  public typealias Element = E
  private let _elements: [E]
  private var _index: Int = 0
  init(_ elements: [E]) { _elements = elements }
  public func hasNext() -> Bool { _index < _elements.count }
  public func next() throws(java.lang.RuntimeException) -> E {
    guard _index < _elements.count else { throw java.util.NoSuchElementException() }
    defer { _index += 1 }
    return _elements[_index]
  }
  public func next() -> E? {
    guard _index < _elements.count else { return nil }
    defer { _index += 1 }
    return _elements[_index]
  }
  public func remove() throws(java.lang.RuntimeException) {
    throw java.lang.IllegalStateException("remove() not supported on a stream-backed iterator")
  }
  public func makeIterator() -> _ArrayIterator<E> { self }
}
