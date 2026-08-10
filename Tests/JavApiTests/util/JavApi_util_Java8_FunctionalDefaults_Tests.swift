/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Testing
import Foundation
@testable import JavApi

// MARK: - Helpers: minimal concrete Comparators
// naturalOrder() / reverseOrder() and comparing() are static protocol-extension
// methods — they require a concrete conforming type as the call site, NOT the
// protocol metatype (any java.util.Comparator).Type.
// Likewise, thenComparing(keyExtractor:) cannot be called on an existential
// (any java.util.Comparator<T>); use the non-generic thenComparing(_ other:) overload
// or call the instance method on a concrete type.

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

// Minimal String comparator — needed so comparing() and its siblings can be
// called as _StringCmp.comparing(...) rather than on the protocol metatype.
private struct _StringCmp: java.util.Comparator {
  var order: SortOrder = .forward
  func compare(_ a: String, _ b: String) -> Int { a < b ? -1 : a > b ? 1 : 0 }
  func compare(_ a: String?, _ b: String?) -> Int {
    switch (a, b) {
    case (nil, nil): return 0; case (nil, _): return -1; case (_, nil): return 1
    default: return compare(a!, b!)
    }
  }
  func compare(_ a: String, _ b: String) -> ComparisonResult {
    a < b ? .orderedAscending : a > b ? .orderedDescending : .orderedSame
  }
  static func == (l: _StringCmp, r: _StringCmp) -> Bool { true }
  func hash(into h: inout Hasher) { h.combine(0) }
}

// MARK: - Collection.forEach

@Suite("Collection.forEach(Consumer)")
struct CollectionForEachTests {

  @Test("forEach visits every element")
  func testForEachVisitsAll() {
    let list = java.util.ArrayList<String>()
    _ = try? list.add("a")
    _ = try? list.add("b")
    _ = try? list.add("c")
    var collected: [String] = []
    list.forEach(java.util.function.AnyConsumer<String> { collected.append($0) })
    #expect(collected == ["a", "b", "c"])
  }

  @Test("forEach on empty collection does nothing")
  func testForEachEmpty() {
    let list = java.util.ArrayList<Int>()
    var count = 0
    list.forEach(java.util.function.AnyConsumer<Int> { _ in count += 1 })
    #expect(count == 0)
  }

  @Test("forEach accumulates values correctly")
  func testForEachAccumulates() {
    let list = java.util.ArrayList<Int>()
    _ = try? list.add(1)
    _ = try? list.add(2)
    _ = try? list.add(3)
    var sum = 0
    list.forEach(java.util.function.AnyConsumer<Int> { sum += $0 })
    #expect(sum == 6)
  }
}

// MARK: - Iterator.forEachRemaining

@Suite("Iterator.forEachRemaining(Consumer)")
struct IteratorForEachRemainingTests {

  @Test("forEachRemaining visits all elements")
  func testForEachRemainingAll() {
    let list = java.util.ArrayList<String>()
    _ = try? list.add("x")
    _ = try? list.add("y")
    _ = try? list.add("z")
    let it = list.iterator()
    var result: [String] = []
    it.forEachRemaining(java.util.function.AnyConsumer<String> { result.append($0) })
    #expect(result == ["x", "y", "z"])
  }

  @Test("forEachRemaining visits only remaining elements after partial advance")
  func testForEachRemainingPartial() {
    let list = java.util.ArrayList<Int>()
    _ = try? list.add(1)
    _ = try? list.add(2)
    _ = try? list.add(3)
    let it = list.iterator()
    _ = try? it.next()  // advance past first element
    var result: [Int] = []
    it.forEachRemaining(java.util.function.AnyConsumer<Int> { result.append($0) })
    #expect(result == [2, 3])
  }

  @Test("forEachRemaining on exhausted iterator does nothing")
  func testForEachRemainingExhausted() {
    let list = java.util.ArrayList<String>()
    _ = try? list.add("only")
    let it = list.iterator()
    _ = try? it.next()
    var count = 0
    it.forEachRemaining(java.util.function.AnyConsumer<String> { _ in count += 1 })
    #expect(count == 0)
  }
}

// MARK: - List.replaceAll

@Suite("List.replaceAll(UnaryOperator)")
struct ListReplaceAllTests {

  @Test("replaceAll transforms all elements")
  func testReplaceAllUppercase() {
    let list = java.util.ArrayList<String>()
    _ = try? list.add("hello")
    _ = try? list.add("world")
    list.replaceAll(java.util.function.AnyUnaryOperator<String> { $0.uppercased() })
    #expect((try? list.get(0)) == "HELLO")
    #expect((try? list.get(1)) == "WORLD")
  }

  @Test("replaceAll doubles each integer")
  func testReplaceAllDouble() {
    let list = java.util.ArrayList<Int>()
    _ = try? list.add(1)
    _ = try? list.add(2)
    _ = try? list.add(3)
    list.replaceAll(java.util.function.AnyUnaryOperator<Int> { $0 * 2 })
    #expect((try? list.get(0)) == 2)
    #expect((try? list.get(1)) == 4)
    #expect((try? list.get(2)) == 6)
  }

  @Test("replaceAll on empty list does nothing")
  func testReplaceAllEmpty() {
    let list = java.util.ArrayList<String>()
    list.replaceAll(java.util.function.AnyUnaryOperator<String> { $0.uppercased() })
    #expect(list.size() == 0)
  }
}

// MARK: - List.sort

@Suite("List.sort(Comparator)")
struct ListSortTests {

  private struct StringLengthComparator: java.util.Comparator {
    var order: SortOrder = .forward
    func compare(_ lhs: String, _ rhs: String) -> Int { lhs.count - rhs.count }
    func compare(_ lhs: String?, _ rhs: String?) -> Int {
      switch (lhs, rhs) {
      case (nil, nil): return 0; case (nil, _): return -1; case (_, nil): return 1
      default: return compare(lhs!, rhs!)
      }
    }
    func compare(_ lhs: String, _ rhs: String) -> ComparisonResult {
      let r: Int = compare(lhs, rhs)
      return r < 0 ? .orderedAscending : r > 0 ? .orderedDescending : .orderedSame
    }
    static func == (lhs: StringLengthComparator, rhs: StringLengthComparator) -> Bool { true }
    func hash(into hasher: inout Hasher) { hasher.combine(0) }
  }

  @Test("sort by string length")
  func testSortByLength() {
    let list = java.util.ArrayList<String>()
    _ = try? list.add("banana")
    _ = try? list.add("fig")
    _ = try? list.add("apple")
    list.sort(StringLengthComparator())
    #expect((try? list.get(0)) == "fig")
    #expect((try? list.get(1)) == "apple")
    #expect((try? list.get(2)) == "banana")
  }

  @Test("sort integer list ascending")
  func testSortIntegers() {
    let list = java.util.ArrayList<Int>()
    _ = try? list.add(3)
    _ = try? list.add(1)
    _ = try? list.add(2)
    list.sort(_IntCmp.naturalOrder())
    #expect((try? list.get(0)) == 1)
    #expect((try? list.get(1)) == 2)
    #expect((try? list.get(2)) == 3)
  }

  @Test("sort integer list descending")
  func testSortDescending() {
    let list = java.util.ArrayList<Int>()
    _ = try? list.add(1)
    _ = try? list.add(3)
    _ = try? list.add(2)
    list.sort(_IntCmp.reverseOrder())
    #expect((try? list.get(0)) == 3)
    #expect((try? list.get(1)) == 2)
    #expect((try? list.get(2)) == 1)
  }
}

// MARK: - Map.forEach

@Suite("Map.forEach(BiConsumer)")
struct MapForEachTests {

  @Test("forEach visits all entries")
  func testForEachAllEntries() {
    let map = java.util.HashMap<String, Int>()
    _ = map.put("a", 1)
    _ = map.put("b", 2)
    var result: [String: Int] = [:]
    map.forEach(java.util.function.AnyBiConsumer<String, Int> { k, v in result[k] = v })
    #expect(result == ["a": 1, "b": 2])
  }

  @Test("forEach on empty map does nothing")
  func testForEachEmpty() {
    let map = java.util.HashMap<String, Int>()
    var count = 0
    map.forEach(java.util.function.AnyBiConsumer<String, Int> { _, _ in count += 1 })
    #expect(count == 0)
  }
}

// MARK: - Map.replaceAll

@Suite("Map.replaceAll(BiFunction)")
struct MapReplaceAllTests {

  @Test("replaceAll doubles each value")
  func testReplaceAllDoubles() {
    let map = java.util.HashMap<String, Int>()
    _ = map.put("x", 5)
    _ = map.put("y", 10)
    map.replaceAll(java.util.function.AnyBiFunction<String, Int, Int> { _, v in v * 2 })
    #expect(map.get("x") == 10)
    #expect(map.get("y") == 20)
  }

  @Test("replaceAll appends key to value string")
  func testReplaceAllKeyAppend() {
    let map = java.util.HashMap<String, String>()
    _ = map.put("key", "value")
    map.replaceAll(java.util.function.AnyBiFunction<String, String, String> { k, v in "\(k)=\(v)" })
    #expect(map.get("key") == "key=value")
  }
}

// MARK: - Map.computeIfAbsent

@Suite("Map.computeIfAbsent(Function)")
struct MapComputeIfAbsentTests {

  @Test("computeIfAbsent inserts when key absent")
  func testComputeWhenAbsent() {
    let map = java.util.HashMap<String, Int>()
    let result = map.computeIfAbsent("hello", java.util.function.AnyFunction<String, Int> { $0.count })
    #expect(result == 5)
    #expect(map.get("hello") == 5)
  }

  @Test("computeIfAbsent returns existing value when key present")
  func testComputeWhenPresent() {
    let map = java.util.HashMap<String, Int>()
    _ = map.put("hi", 99)
    let result = map.computeIfAbsent("hi", java.util.function.AnyFunction<String, Int> { $0.count })
    #expect(result == 99)
    #expect(map.get("hi") == 99)  // unchanged
  }

  @Test("computeIfAbsent does not overwrite existing entry")
  func testNoOverwrite() {
    let map = java.util.HashMap<String, String>()
    _ = map.put("k", "original")
    _ = map.computeIfAbsent("k", java.util.function.AnyFunction<String, String> { _ in "computed" })
    #expect(map.get("k") == "original")
  }
}

// MARK: - Comparator.comparing

@Suite("Comparator.comparing(keyExtractor)")
struct ComparatorComparingTests {

  @Test("comparing by string length")
  func testComparingByLength() {
    // comparing() is a static protocol-extension method — call on concrete _StringCmp
    let cmp = _StringCmp.comparing(
      java.util.function.AnyFunction<String, Int> { $0.count }
    )
    #expect(cmp.compare("hi", "hello") < 0)
    #expect(cmp.compare("hello", "hi") > 0)
    #expect(cmp.compare("abc", "xyz") == 0)
  }

  @Test("thenComparing as second sort key")
  func testThenComparingKeyExtractor() {
    // thenComparing(keyExtractor:) cannot be called on an existential (any Comparator<T>).
    // Use the non-generic thenComparing(_ other: any Comparator<T>) overload instead:
    // build both comparators via _StringCmp.comparing, then chain them.
    let byLength = _StringCmp.comparing(
      java.util.function.AnyFunction<String, Int> { $0.count }
    )
    let byAlpha = _StringCmp.comparing(
      java.util.function.AnyFunction<String, String> { $0 }
    )
    let cmp = byLength.thenComparing(byAlpha)
    // same length → fall through to alphabetical
    #expect(cmp.compare("abc", "abd") < 0)
    #expect(cmp.compare("hi", "hello") < 0)  // shorter first
  }

  @Test("sort list using Comparator.comparing")
  func testSortWithComparing() {
    let list = java.util.ArrayList<String>()
    _ = try? list.add("banana")
    _ = try? list.add("fig")
    _ = try? list.add("apple")
    list.sort(_StringCmp.comparing(
      java.util.function.AnyFunction<String, Int> { $0.count }
    ))
    #expect((try? list.get(0)) == "fig")
  }
}
