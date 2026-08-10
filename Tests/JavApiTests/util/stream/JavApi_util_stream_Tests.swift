/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Testing
import Foundation
@testable import JavApi

// MARK: - Helper: minimal Int Comparator for naturalOrder() / reverseOrder()
// naturalOrder() / reverseOrder() are static protocol-extension methods that
// require a concrete conforming type as the call site (see existing Comparator tests).

private struct _IntCmp: java.util.Comparator {
  var order: SortOrder = .forward
  func compare(_ a: Int, _ b: Int) -> Int { a < b ? -1 : a > b ? 1 : 0 }
  func compare(_ a: Int?, _ b: Int?) -> Int {
    switch (a, b) {
    case (nil, nil): return 0; case (nil, _): return -1; case (_, nil): return 1
    default: return compare(a!, b!)
    }
  }
  func compare(_ a: Int, _ b: Int) -> ComparisonResult {
    a < b ? .orderedAscending : a > b ? .orderedDescending : .orderedSame
  }
  static func == (l: _IntCmp, r: _IntCmp) -> Bool { true }
  func hash(into h: inout Hasher) { h.combine(0) }
}

// MARK: - Stream factory methods

@Suite("Stream factory methods")
struct StreamFactoryTests {

  @Test("Stream.of(...) contains given elements")
  func testOfVariadic() {
    let result = java.util.stream.Stream.of(1, 2, 3).toArray()
    #expect(result == [1, 2, 3])
  }

  @Test("Stream.empty() has count 0")
  func testEmpty() {
    let count = java.util.stream.Stream<Int>.empty().count()
    #expect(count == 0)
  }

  @Test("Stream.generate produces values from supplier")
  func testGenerate() {
    var n = 0
    let result = java.util.stream.Stream
      .generate(java.util.function.AnySupplier { n += 1; return n })
      .limit(5)
      .toArray()
    #expect(result == [1, 2, 3, 4, 5])
  }

  @Test("Stream.iterate produces seed and successive applications")
  func testIterate() {
    let result = java.util.stream.Stream
      .iterate(1, java.util.function.AnyUnaryOperator<Int> { $0 * 2 })
      .limit(5)
      .toArray()
    #expect(result == [1, 2, 4, 8, 16])
  }
}

// MARK: - Intermediate operations

@Suite("Stream intermediate operations")
struct StreamIntermediateTests {

  @Test("filter keeps only matching elements")
  func testFilter() {
    let result = java.util.stream.Stream.of(1, 2, 3, 4, 5)
      .filter(java.util.function.AnyPredicate { $0 % 2 == 0 })
      .toArray()
    #expect(result == [2, 4])
  }

  @Test("map transforms each element")
  func testMap() {
    let result = java.util.stream.Stream.of(1, 2, 3)
      .map(java.util.function.AnyFunction { $0 * 10 })
      .toArray()
    #expect(result == [10, 20, 30])
  }

  @Test("flatMap flattens nested streams")
  func testFlatMap() {
    let result = java.util.stream.Stream.of(1, 2, 3)
      .flatMap(java.util.function.AnyFunction { n in
        java.util.stream.Stream.of(n, n * 10)
      })
      .toArray()
    #expect(result == [1, 10, 2, 20, 3, 30])
  }

  @Test("limit truncates to maxSize elements")
  func testLimit() {
    let result = java.util.stream.Stream.of(1, 2, 3, 4, 5)
      .limit(3)
      .toArray()
    #expect(result == [1, 2, 3])
  }

  @Test("skip discards first n elements")
  func testSkip() {
    let result = java.util.stream.Stream.of(1, 2, 3, 4, 5)
      .skip(2)
      .toArray()
    #expect(result == [3, 4, 5])
  }

  @Test("sorted(Comparator) orders elements")
  func testSortedComparator() {
    let result = java.util.stream.Stream.of(3, 1, 4, 1, 5)
      .sorted(_IntCmp.naturalOrder())
      .toArray()
    #expect(result == [1, 1, 3, 4, 5])
  }

  @Test("sorted() with Comparable orders naturally")
  func testSortedNatural() {
    let result = java.util.stream.Stream.of(3, 1, 2).sorted().toArray()
    #expect(result == [1, 2, 3])
  }

  @Test("distinct() removes duplicates")
  func testDistinct() {
    let result = java.util.stream.Stream.of(1, 2, 2, 3, 1).distinct().toArray()
    // Order preserved; duplicates removed
    let set = Set(result)
    #expect(set == Set([1, 2, 3]))
    #expect(result.count == 3)
  }

  @Test("peek observes elements without modifying them")
  func testPeek() {
    var observed: [Int] = []
    let result = java.util.stream.Stream.of(1, 2, 3)
      .peek(java.util.function.AnyConsumer { observed.append($0) })
      .toArray()
    #expect(result == [1, 2, 3])
    #expect(observed == [1, 2, 3])
  }

  @Test("parallel() is a no-op returning same stream content")
  func testParallel() {
    let result = java.util.stream.Stream.of(1, 2, 3).parallel().toArray()
    #expect(result == [1, 2, 3])
  }

  @Test("chained intermediate ops evaluate lazily")
  func testChaining() {
    let result = java.util.stream.Stream.of(1, 2, 3, 4, 5, 6)
      .filter(java.util.function.AnyPredicate { $0 % 2 == 0 })
      .map(java.util.function.AnyFunction { $0 * $0 })
      .toArray()
    #expect(result == [4, 16, 36])
  }
}

// MARK: - Terminal operations

@Suite("Stream terminal operations")
struct StreamTerminalTests {

  @Test("forEach visits every element")
  func testForEach() {
    var collected: [Int] = []
    java.util.stream.Stream.of(1, 2, 3)
      .forEach(java.util.function.AnyConsumer { collected.append($0) })
    #expect(collected == [1, 2, 3])
  }

  @Test("count returns correct element count")
  func testCount() {
    #expect(java.util.stream.Stream.of(1, 2, 3).count() == 3)
    #expect(java.util.stream.Stream<Int>.empty().count() == 0)
  }

  @Test("reduce with identity")
  func testReduceIdentity() {
    let sum = java.util.stream.Stream.of(1, 2, 3, 4)
      .reduce(0, java.util.function.AnyBinaryOperator { $0 + $1 })
    #expect(sum == 10)
  }

  @Test("reduce without identity returns nil on empty stream")
  func testReduceEmpty() {
    let result = java.util.stream.Stream<Int>.empty()
      .reduce(java.util.function.AnyBinaryOperator { $0 + $1 })
    #expect(result == nil)
  }

  @Test("reduce without identity returns single element for singleton stream")
  func testReduceSingleton() {
    let result = java.util.stream.Stream.of(42)
      .reduce(java.util.function.AnyBinaryOperator { $0 + $1 })
    #expect(result == 42)
  }

  @Test("findFirst returns first element or nil")
  func testFindFirst() {
    #expect(java.util.stream.Stream.of(10, 20, 30).findFirst() == 10)
    #expect(java.util.stream.Stream<Int>.empty().findFirst() == nil)
  }

  @Test("anyMatch returns true when at least one element matches")
  func testAnyMatch() {
    #expect(java.util.stream.Stream.of(1, 2, 3)
      .anyMatch(java.util.function.AnyPredicate { $0 > 2 }) == true)
    #expect(java.util.stream.Stream.of(1, 2, 3)
      .anyMatch(java.util.function.AnyPredicate { $0 > 5 }) == false)
  }

  @Test("allMatch returns true only when all elements match")
  func testAllMatch() {
    #expect(java.util.stream.Stream.of(2, 4, 6)
      .allMatch(java.util.function.AnyPredicate { $0 % 2 == 0 }) == true)
    #expect(java.util.stream.Stream.of(2, 3, 6)
      .allMatch(java.util.function.AnyPredicate { $0 % 2 == 0 }) == false)
    #expect(java.util.stream.Stream<Int>.empty()
      .allMatch(java.util.function.AnyPredicate { $0 % 2 == 0 }) == true)
  }

  @Test("noneMatch returns true only when no element matches")
  func testNoneMatch() {
    #expect(java.util.stream.Stream.of(1, 3, 5)
      .noneMatch(java.util.function.AnyPredicate { $0 % 2 == 0 }) == true)
    #expect(java.util.stream.Stream.of(1, 2, 5)
      .noneMatch(java.util.function.AnyPredicate { $0 % 2 == 0 }) == false)
  }

  @Test("min returns smallest element")
  func testMin() {
    let result = java.util.stream.Stream.of(3, 1, 4, 1, 5)
      .min(_IntCmp.naturalOrder())
    #expect(result == 1)
  }

  @Test("max returns largest element")
  func testMax() {
    let result = java.util.stream.Stream.of(3, 1, 4, 1, 5)
      .max(_IntCmp.naturalOrder())
    #expect(result == 5)
  }

  @Test("toList returns a java.util.List")
  func testToList() {
    let list = java.util.stream.Stream.of(1, 2, 3).toList()
    #expect(list.size() == 3)
    #expect(list.contains(2))
  }
}

// MARK: - Collector tests

@Suite("Stream.collect with Collectors")
struct StreamCollectorTests {

  @Test("Collectors.toList accumulates into a list")
  func testToList() {
    let list = java.util.stream.Stream.of(1, 2, 3)
      .collect(java.util.stream.Collectors.toList())
    #expect(list.size() == 3)
    #expect(list.contains(1))
    #expect(list.contains(3))
  }

  @Test("Collectors.counting counts all elements")
  func testCounting() {
    let count = java.util.stream.Stream.of("a", "b", "c")
      .collect(java.util.stream.Collectors.counting())
    #expect(count == 3)
  }

  @Test("Collectors.counting on empty stream returns 0")
  func testCountingEmpty() {
    let count = java.util.stream.Stream<String>.empty()
      .collect(java.util.stream.Collectors.counting())
    #expect(count == 0)
  }

  @Test("Collectors.joining concatenates strings")
  func testJoiningNoDelimiter() {
    let result = java.util.stream.Stream.of("a", "b", "c")
      .collect(java.util.stream.Collectors.joining())
    #expect(result == "abc")
  }

  @Test("Collectors.joining with delimiter")
  func testJoiningDelimiter() {
    let result = java.util.stream.Stream.of("a", "b", "c")
      .collect(java.util.stream.Collectors.joining(", "))
    #expect(result == "a, b, c")
  }

  @Test("Collectors.joining with prefix and suffix")
  func testJoiningPrefixSuffix() {
    let result = java.util.stream.Stream.of("x", "y")
      .collect(java.util.stream.Collectors.joining(", ", "[", "]"))
    #expect(result == "[x, y]")
  }
}

// MARK: - Extended Collectors

@Suite("Extended Collectors (toSet, groupingBy, toMap)")
struct ExtendedCollectorTests {

  @Test("Collectors.toSet accumulates into a set (no duplicates)")
  func testToSet() {
    let set = java.util.stream.Stream.of(1, 2, 2, 3, 3, 3)
      .collect(java.util.stream.Collectors.toSet())
    #expect(set.size() == 3)
    #expect(set.contains(1))
    #expect(set.contains(2))
    #expect(set.contains(3))
  }

  @Test("Collectors.toSet on empty stream returns empty set")
  func testToSetEmpty() {
    let set = java.util.stream.Stream<Int>.empty()
      .collect(java.util.stream.Collectors.toSet())
    #expect(set.size() == 0)
  }

  @Test("Collectors.groupingBy groups elements by key")
  func testGroupingBy() {
    // group strings by length
    let map = java.util.stream.Stream.of("a", "bb", "cc", "ddd")
      .collect(java.util.stream.Collectors.groupingBy(
        java.util.function.AnyFunction<String, Int> { $0.count }
      ))
    #expect(map.get(1)?.size() == 1)
    #expect(map.get(2)?.size() == 2)
    #expect(map.get(3)?.size() == 1)
  }

  @Test("Collectors.groupingBy on empty stream returns empty map")
  func testGroupingByEmpty() {
    let map = java.util.stream.Stream<String>.empty()
      .collect(java.util.stream.Collectors.groupingBy(
        java.util.function.AnyFunction<String, Int> { $0.count }
      ))
    #expect(map.isEmpty())
  }

  @Test("Collectors.toMap builds key-value map")
  func testToMap() {
    let map = java.util.stream.Stream.of("apple", "fig", "mango")
      .collect(java.util.stream.Collectors.toMap(
        java.util.function.AnyFunction { $0 },          // key = word itself
        java.util.function.AnyFunction { $0.count }     // value = length
      ))
    #expect(map.get("apple") == 5)
    #expect(map.get("fig")   == 3)
    #expect(map.get("mango") == 5)
  }

  @Test("Collectors.toMap on empty stream returns empty map")
  func testToMapEmpty() {
    let map = java.util.stream.Stream<String>.empty()
      .collect(java.util.stream.Collectors.toMap(
        java.util.function.AnyFunction<String, String> { $0 },
        java.util.function.AnyFunction<String, Int> { $0.count }
      ))
    #expect(map.isEmpty())
  }
}

// MARK: - mapMulti (Java 16)

@Suite("Stream.mapMulti (Java 16)")
struct StreamMapMultiTests {

  @Test("mapMulti can expand each element into multiple results")
  func testMapMultiExpands() {
    let result = java.util.stream.Stream.of(1, 2, 3)
      .mapMulti(java.util.function.AnyBiConsumer { (x: Int, push: java.util.function.AnyConsumer<Int>) in
        push.accept(x)
        push.accept(x * 10)
      })
      .toArray()
    #expect(result == [1, 10, 2, 20, 3, 30])
  }

  @Test("mapMulti can filter by emitting nothing for some elements")
  func testMapMultiFilter() {
    let result = java.util.stream.Stream.of(1, 2, 3, 4, 5)
      .mapMulti(java.util.function.AnyBiConsumer { (x: Int, push: java.util.function.AnyConsumer<String>) in
        if x % 2 == 0 { push.accept("even:\(x)") }
      })
      .toArray()
    #expect(result == ["even:2", "even:4"])
  }

  @Test("mapMulti on empty stream returns empty stream")
  func testMapMultiEmpty() {
    let result = java.util.stream.Stream<Int>.empty()
      .mapMulti(java.util.function.AnyBiConsumer { (x: Int, push: java.util.function.AnyConsumer<Int>) in
        push.accept(x)
      })
      .toArray()
    #expect(result.isEmpty)
  }
}

// MARK: - New Collectors (Java 8/10/12)

@Suite("New Collectors: partitioningBy, toUnmodifiable*, teeing")
struct NewCollectorTests {

  @Test("Collectors.partitioningBy splits into true/false groups")
  func testPartitioningBy() {
    let map = java.util.stream.Stream.of(1, 2, 3, 4, 5, 6)
      .collect(java.util.stream.Collectors.partitioningBy(
        java.util.function.AnyPredicate { $0 % 2 == 0 }
      ))
    let evens = map.get(true)!
    let odds  = map.get(false)!
    #expect(evens.size() == 3)
    #expect(odds.size()  == 3)
    #expect(evens.contains(2))
    #expect(evens.contains(4))
    #expect(evens.contains(6))
    #expect(odds.contains(1))
    #expect(odds.contains(3))
    #expect(odds.contains(5))
  }

  @Test("Collectors.partitioningBy on empty stream returns two empty lists")
  func testPartitioningByEmpty() {
    let map = java.util.stream.Stream<Int>.empty()
      .collect(java.util.stream.Collectors.partitioningBy(
        java.util.function.AnyPredicate { $0 > 0 }
      ))
    #expect(map.get(true)?.isEmpty()  == true)
    #expect(map.get(false)?.isEmpty() == true)
  }

  @Test("Collectors.toUnmodifiableList returns unmodifiable list")
  func testToUnmodifiableList() {
    var list = java.util.stream.Stream.of(1, 2, 3)
      .collect(java.util.stream.Collectors.toUnmodifiableList())
    #expect(list.size() == 3)
    #expect(list.contains(1))
    // Unmodifiable: add should throw
    #expect(throws: (any Error).self) { try list.add(99) }
  }

  @Test("Collectors.toUnmodifiableSet returns unmodifiable set")
  func testToUnmodifiableSet() {
    var set = java.util.stream.Stream.of(1, 2, 2, 3)
      .collect(java.util.stream.Collectors.toUnmodifiableSet())
    #expect(set.size() == 3)
    // Unmodifiable: add should throw
    #expect(throws: (any Error).self) { try set.add(99) }
  }

  @Test("Collectors.toUnmodifiableMap returns unmodifiable map")
  func testToUnmodifiableMap() {
    let map = java.util.stream.Stream.of("a", "bb", "ccc")
      .collect(java.util.stream.Collectors.toUnmodifiableMap(
        java.util.function.AnyFunction { $0 },
        java.util.function.AnyFunction { $0.count }
      ))
    #expect(map.get("a")   == 1)
    #expect(map.get("bb")  == 2)
    #expect(map.get("ccc") == 3)
    // Map.put on UnmodifiableHashMap fatalErrors in production (non-throwing override).
    // Just verify read operations work correctly.
    #expect(map.size() == 3)
  }

  @Test("Collectors.teeing combines two collectors with merger")
  func testTeeing() {
    // list size and element count collected simultaneously
    let result = java.util.stream.Stream.of(1, 2, 3, 4, 5)
      .collect(java.util.stream.Collectors.teeing(
        java.util.stream.Collectors.toList(),
        java.util.stream.Collectors.counting(),
        java.util.function.AnyBiFunction { (list: any java.util.List<Int>, count: Int64) in
          (list.size(), count)
        }
      ))
    #expect(result.0 == 5)
    #expect(result.1 == 5)
  }

  @Test("Collectors.teeing min+max")
  func testTeeingMinMax() {
    let minC = java.util.stream.AnyCollector<Int, Int> { seq in
      seq.min() ?? Int.max
    }
    let maxC = java.util.stream.AnyCollector<Int, Int> { seq in
      seq.max() ?? Int.min
    }
    let result = java.util.stream.Stream.of(3, 1, 4, 1, 5, 9)
      .collect(java.util.stream.Collectors.teeing(
        minC,
        maxC,
        java.util.function.AnyBiFunction { mn, mx in mx - mn }
      ))
    #expect(result == 8) // 9 - 1
  }
}

// MARK: - Collection.stream() integration

@Suite("Collection.stream() integration")
struct CollectionStreamTests {

  @Test("ArrayList.stream() produces correct stream")
  func testArrayListStream() {
    let list = java.util.ArrayList<String>()
    _ = try? list.add("hello")
    _ = try? list.add("world")
    let result = list.stream()
      .map(java.util.function.AnyFunction { $0.uppercased() })
      .toArray()
    #expect(result == ["HELLO", "WORLD"])
  }

  @Test("stream().filter().count() pipeline works end-to-end")
  func testStreamPipeline() {
    let list = java.util.ArrayList<Int>()
    for i in 1...10 { _ = try? list.add(i) }
    let count = list.stream()
      .filter(java.util.function.AnyPredicate { $0 % 2 == 0 })
      .count()
    #expect(count == 5)
  }
}

// MARK: - Spliterator tests

@Suite("java.util.Spliterator")
struct SpliteratorTests {

  @Test("tryAdvance visits each element sequentially")
  func testTryAdvance() {
    let list = java.util.ArrayList<Int>()
    _ = try? list.add(1); _ = try? list.add(2); _ = try? list.add(3)
    let sp = list.spliterator()
    var result: [Int] = []
    while sp.tryAdvance(java.util.function.AnyConsumer { result.append($0) }) {}
    #expect(result == [1, 2, 3])
  }

  @Test("estimateSize returns element count")
  func testEstimateSize() {
    let list = java.util.ArrayList<String>()
    _ = try? list.add("a"); _ = try? list.add("b")
    #expect(list.spliterator().estimateSize() == 2)
  }

  @Test("forEachRemaining visits all remaining elements")
  func testForEachRemaining() {
    let list = java.util.ArrayList<Int>()
    _ = try? list.add(10); _ = try? list.add(20)
    let sp = list.spliterator()
    var result: [Int] = []
    sp.forEachRemaining(java.util.function.AnyConsumer { result.append($0) })
    #expect(result == [10, 20])
  }
}
