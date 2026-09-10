/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Testing
@testable import JavApi

/// Regression / API-surface coverage for `IntStream`, `LongStream`,
/// `DoubleStream` and `StreamSupport` (java.util.stream, Java 8/9).
@Suite("java.util.stream Primitive Streams")
struct JavApi_util_stream_PrimitiveStreams_Tests {

  // MARK: - IntStream

  @Test("IntStream.range/rangeClosed produce the expected elements")
  func intStreamRangeAndRangeClosed() {
    #expect(java.util.stream.IntStream.range(1, 5).toArray() == [1, 2, 3, 4])
    #expect(java.util.stream.IntStream.rangeClosed(1, 5).toArray() == [1, 2, 3, 4, 5])
    #expect(java.util.stream.IntStream.range(5, 5).toArray() == [])
  }

  @Test("IntStream.of/empty/generate/iterate produce the expected elements")
  func intStreamFactories() {
    #expect(java.util.stream.IntStream.of(1, 2, 3).toArray() == [1, 2, 3])
    #expect(java.util.stream.IntStream.empty().toArray() == [])

    var counter = 0
    let generated = java.util.stream.IntStream.generate(
      java.util.function.AnySupplier<Int> { counter += 1; return counter }
    ).limit(3).toArray()
    #expect(generated == [1, 2, 3])

    let iterated = java.util.stream.IntStream.iterate(
      1, java.util.function.AnyUnaryOperator<Int> { $0 * 2 }
    ).limit(4).toArray()
    #expect(iterated == [1, 2, 4, 8])

    let bounded = java.util.stream.IntStream.iterate(
      1,
      java.util.function.AnyPredicate<Int> { $0 < 20 },
      java.util.function.AnyUnaryOperator<Int> { $0 * 2 }
    ).toArray()
    #expect(bounded == [1, 2, 4, 8, 16])
  }

  @Test("IntStream.concat concatenates two streams in order")
  func intStreamConcat() {
    let a = java.util.stream.IntStream.of(1, 2)
    let b = java.util.stream.IntStream.of(3, 4)
    #expect(java.util.stream.IntStream.concat(a, b).toArray() == [1, 2, 3, 4])
  }

  @Test("IntStream intermediate operations: filter, map, distinct, sorted, limit, skip, peek")
  func intStreamIntermediateOperations() {
    #expect(
      java.util.stream.IntStream.of(1, 2, 3, 4, 5)
        .filter(java.util.function.AnyPredicate<Int> { $0 % 2 == 0 })
        .toArray() == [2, 4]
    )
    #expect(
      java.util.stream.IntStream.of(1, 2, 3)
        .map(java.util.function.AnyUnaryOperator<Int> { $0 * 10 })
        .toArray() == [10, 20, 30]
    )
    #expect(
      java.util.stream.IntStream.of(3, 1, 2, 1, 3)
        .distinct()
        .sorted()
        .toArray() == [1, 2, 3]
    )
    #expect(java.util.stream.IntStream.of(1, 2, 3, 4, 5).limit(2).toArray() == [1, 2])
    #expect(java.util.stream.IntStream.of(1, 2, 3, 4, 5).skip(3).toArray() == [4, 5])

    var peeked: [Int] = []
    let result = java.util.stream.IntStream.of(1, 2, 3)
      .peek(java.util.function.AnyConsumer<Int> { peeked.append($0) })
      .toArray()
    #expect(result == [1, 2, 3])
    #expect(peeked == [1, 2, 3])
  }

  @Test("IntStream.flatMap replaces each element with a sub-stream's contents")
  func intStreamFlatMap() {
    let result = java.util.stream.IntStream.of(1, 2, 3)
      .flatMap(java.util.function.AnyFunction<Int, java.util.stream.IntStream> { java.util.stream.IntStream.of($0, $0) })
      .toArray()
    #expect(result == [1, 1, 2, 2, 3, 3])
  }

  @Test("IntStream cross-type conversions: mapToObj, mapToLong, mapToDouble, boxed, asLongStream, asDoubleStream")
  func intStreamCrossTypeConversions() {
    let objects = java.util.stream.IntStream.of(1, 2, 3)
      .mapToObj(java.util.function.AnyFunction<Int, String> { "n\($0)" })
      .toArray()
    #expect(objects == ["n1", "n2", "n3"])

    let longs = java.util.stream.IntStream.of(1, 2, 3).mapToLong(java.util.function.AnyFunction<Int, Int64> { Int64($0) }).toArray()
    #expect(longs == [1, 2, 3])

    let doubles = java.util.stream.IntStream.of(1, 2, 3).mapToDouble(java.util.function.AnyFunction<Int, Double> { Double($0) }).toArray()
    #expect(doubles == [1.0, 2.0, 3.0])

    #expect(java.util.stream.IntStream.of(1, 2, 3).boxed().toArray() == [1, 2, 3])
    #expect(java.util.stream.IntStream.of(1, 2, 3).asLongStream().toArray() == [1, 2, 3])
    #expect(java.util.stream.IntStream.of(1, 2, 3).asDoubleStream().toArray() == [1.0, 2.0, 3.0])
  }

  @Test("IntStream terminal operations: sum, min, max, count, average, reduce, matches, find, iterator, spliterator")
  func intStreamTerminalOperations() {
    let stream = { java.util.stream.IntStream.of(1, 2, 3, 4, 5) }

    #expect(stream().sum() == 15)
    #expect(stream().min() == 1)
    #expect(stream().max() == 5)
    #expect(stream().count() == 5)
    #expect(stream().average() == 3.0)
    #expect(java.util.stream.IntStream.empty().average() == nil)

    #expect(stream().reduce(0, java.util.function.AnyBinaryOperator<Int> { $0 + $1 }) == 15)
    #expect(java.util.stream.IntStream.empty().reduce(java.util.function.AnyBinaryOperator<Int> { $0 + $1 }) == nil)

    #expect(stream().anyMatch(java.util.function.AnyPredicate<Int> { $0 == 3 }))
    #expect(stream().allMatch(java.util.function.AnyPredicate<Int> { $0 > 0 }))
    #expect(stream().noneMatch(java.util.function.AnyPredicate<Int> { $0 > 100 }))

    #expect(stream().findFirst() == 1)
    #expect(java.util.stream.IntStream.empty().findFirst() == nil)

    let it = java.util.stream.IntStream.of(1, 2).iterator()
    #expect(it.hasNext())
    #expect(try! it.next() == 1)
    #expect(try! it.next() == 2)
    #expect(!it.hasNext())

    var collected: [Int] = []
    java.util.stream.IntStream.of(1, 2, 3).spliterator().forEachRemaining(
      java.util.function.AnyConsumer<Int> { collected.append($0) }
    )
    #expect(collected == [1, 2, 3])
  }

  // MARK: - LongStream

  @Test("LongStream.range/rangeClosed/of/concat produce the expected elements")
  func longStreamFactoriesAndConcat() {
    #expect(java.util.stream.LongStream.range(1, 4).toArray() == [1, 2, 3])
    #expect(java.util.stream.LongStream.rangeClosed(1, 4).toArray() == [1, 2, 3, 4])
    #expect(java.util.stream.LongStream.of(10, 20).toArray() == [10, 20])

    let a = java.util.stream.LongStream.of(1, 2)
    let b = java.util.stream.LongStream.of(3, 4)
    #expect(java.util.stream.LongStream.concat(a, b).toArray() == [1, 2, 3, 4])
  }

  @Test("LongStream intermediate + cross-type conversions")
  func longStreamIntermediateAndConversions() {
    #expect(
      java.util.stream.LongStream.of(1, 2, 3, 4)
        .filter(java.util.function.AnyPredicate<Int64> { $0 % 2 == 0 })
        .toArray() == [2, 4]
    )
    #expect(
      java.util.stream.LongStream.of(1, 2, 3)
        .map(java.util.function.AnyUnaryOperator<Int64> { $0 * 10 })
        .toArray() == [10, 20, 30]
    )
    let narrowed = java.util.stream.LongStream.of(1, 2, 3)
      .mapToInt(java.util.function.AnyFunction<Int64, Int> { Int($0) })
      .toArray()
    #expect(narrowed == [1, 2, 3])

    let widened = java.util.stream.LongStream.of(1, 2, 3)
      .mapToDouble(java.util.function.AnyFunction<Int64, Double> { Double($0) })
      .toArray()
    #expect(widened == [1.0, 2.0, 3.0])

    #expect(java.util.stream.LongStream.of(1, 2, 3).boxed().toArray() == [1, 2, 3])
    #expect(java.util.stream.LongStream.of(1, 2, 3).asDoubleStream().toArray() == [1.0, 2.0, 3.0])
  }

  @Test("LongStream terminal operations: sum, average, reduce, count")
  func longStreamTerminalOperations() {
    let stream = { java.util.stream.LongStream.of(1, 2, 3, 4, 5) }
    #expect(stream().sum() == 15)
    #expect(stream().count() == 5)
    #expect(stream().average() == 3.0)
    #expect(stream().reduce(0, java.util.function.AnyBinaryOperator<Int64> { $0 + $1 }) == 15)
  }

  // MARK: - DoubleStream

  @Test("DoubleStream.of/empty/generate/iterate produce the expected elements")
  func doubleStreamFactories() {
    #expect(java.util.stream.DoubleStream.of(1.5, 2.5).toArray() == [1.5, 2.5])
    #expect(java.util.stream.DoubleStream.empty().toArray() == [])

    let iterated = java.util.stream.DoubleStream.iterate(
      1.0, java.util.function.AnyUnaryOperator<Double> { $0 * 2 }
    ).limit(3).toArray()
    #expect(iterated == [1.0, 2.0, 4.0])
  }

  @Test("DoubleStream intermediate + cross-type conversions (narrowing)")
  func doubleStreamIntermediateAndConversions() {
    #expect(
      java.util.stream.DoubleStream.of(1.0, 2.0, 3.0, 4.0)
        .filter(java.util.function.AnyPredicate<Double> { $0 > 2.0 })
        .toArray() == [3.0, 4.0]
    )
    let narrowedInt = java.util.stream.DoubleStream.of(1.9, 2.1)
      .mapToInt(java.util.function.AnyFunction<Double, Int> { Int($0) })
      .toArray()
    #expect(narrowedInt == [1, 2])

    let narrowedLong = java.util.stream.DoubleStream.of(1.9, 2.1)
      .mapToLong(java.util.function.AnyFunction<Double, Int64> { Int64($0) })
      .toArray()
    #expect(narrowedLong == [1, 2])

    #expect(java.util.stream.DoubleStream.of(1.0, 2.0).boxed().toArray() == [1.0, 2.0])
  }

  @Test("DoubleStream terminal operations: sum, average, min, max")
  func doubleStreamTerminalOperations() {
    let stream = { java.util.stream.DoubleStream.of(1.0, 2.0, 3.0) }
    #expect(stream().sum() == 6.0)
    #expect(stream().average() == 2.0)
    #expect(stream().min() == 1.0)
    #expect(stream().max() == 3.0)
  }

  // MARK: - StreamSupport

  @Test("StreamSupport.stream/intStream/longStream/doubleStream drain a Spliterator")
  func streamSupportDrainsSpliterator() {
    let objectSpliterator = java.util.stream.IntStream.of(1, 2, 3).boxed().spliterator()
    #expect(java.util.stream.StreamSupport.stream(objectSpliterator, false).toArray() == [1, 2, 3])

    let intSpliterator = java.util.stream.IntStream.of(1, 2, 3).spliterator()
    #expect(java.util.stream.StreamSupport.intStream(intSpliterator, false).toArray() == [1, 2, 3])

    let longSpliterator = java.util.stream.LongStream.of(1, 2, 3).spliterator()
    #expect(java.util.stream.StreamSupport.longStream(longSpliterator, false).toArray() == [1, 2, 3])

    let doubleSpliterator = java.util.stream.DoubleStream.of(1.0, 2.0, 3.0).spliterator()
    #expect(java.util.stream.StreamSupport.doubleStream(doubleSpliterator, false).toArray() == [1.0, 2.0, 3.0])
  }
}
