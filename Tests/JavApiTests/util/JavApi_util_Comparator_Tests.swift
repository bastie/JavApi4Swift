/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Foundation
import Testing
@testable import JavApi

@Suite("java.util.Comparator — Java-8 default methods")
struct JavApi_util_Comparator_Tests {

  // MARK: - Helper comparator (ascending Int)

  private struct IntComparator: java.util.Comparator {
    typealias T = Int
    var order: SortOrder = .forward
    func compare(_ lhs: Int, _ rhs: Int) -> Int { lhs - rhs }
    static func == (l: IntComparator, r: IntComparator) -> Bool { true }
    func hash(into hasher: inout Hasher) { hasher.combine(0) }
  }

  // MARK: - reversed()

  @Test("reversed() negates comparison result")
  func testReversed() {
    let asc = IntComparator()
    let desc = asc.reversed()
    #expect(desc.compare(1, 2) > 0)   // 1 > 2 in descending
    #expect(desc.compare(2, 1) < 0)   // 2 < 1 in descending
    #expect(desc.compare(3, 3) == 0)
  }

  @Test("reversed() of reversed() restores original order")
  func testDoubleReversed() {
    let asc = IntComparator()
    let restored = asc.reversed().reversed()
    #expect(restored.compare(1, 2) < 0)
    #expect(restored.compare(2, 1) > 0)
  }

  // MARK: - thenComparing()

  @Test("thenComparing() falls through to second comparator on tie")
  func testThenComparing() {
    // First comparator always returns 0 (tie), second uses natural Int order
    struct AlwaysEqualComparator: java.util.Comparator {
      typealias T = Int
      var order: SortOrder = .forward
      func compare(_ lhs: Int, _ rhs: Int) -> Int { 0 }
      static func == (l: Self, r: Self) -> Bool { true }
      func hash(into hasher: inout Hasher) { hasher.combine(0) }
    }
    let chained = AlwaysEqualComparator().thenComparing(IntComparator())
    #expect(chained.compare(1, 2) < 0)
    #expect(chained.compare(2, 1) > 0)
    #expect(chained.compare(5, 5) == 0)
  }

  @Test("thenComparing() uses primary comparator when elements differ")
  func testThenComparingPrimaryWins() {
    let desc = IntComparator().reversed()
    let chained = desc.thenComparing(IntComparator())
    // desc says 5 > 3 (result < 0 in descending), so primary wins
    #expect(chained.compare(5, 3) < 0)
  }

  // MARK: - naturalOrder()

  @Test("naturalOrder() orders Ints ascending")
  func testNaturalOrderInt() {
    // naturalOrder() is a static protocol-extension method; call it on any
    // conforming concrete type whose T matches the desired element type.
    let cmp: any java.util.Comparator<Int> = IntComparator.naturalOrder()
    #expect(cmp.compare(1, 2) < 0)
    #expect(cmp.compare(2, 1) > 0)
    #expect(cmp.compare(7, 7) == 0)
  }

  @Test("naturalOrder() orders Strings lexicographically")
  func testNaturalOrderString() {
    struct StrCmp: java.util.Comparator {
      typealias T = String
      var order: SortOrder = .forward
      func compare(_ l: String, _ r: String) -> Int { l < r ? -1 : l > r ? 1 : 0 }
      static func == (l: Self, r: Self) -> Bool { true }
      func hash(into hasher: inout Hasher) { hasher.combine(0) }
    }
    let cmp: any java.util.Comparator<String> = StrCmp.naturalOrder()
    #expect(cmp.compare("apple", "banana") < 0)
    #expect(cmp.compare("zebra", "ant") > 0)
    #expect(cmp.compare("same", "same") == 0)
  }

  // MARK: - reverseOrder()

  @Test("reverseOrder() orders Ints descending")
  func testReverseOrderInt() {
    let cmp: any java.util.Comparator<Int> = IntComparator.reverseOrder()
    #expect(cmp.compare(1, 2) > 0)
    #expect(cmp.compare(2, 1) < 0)
    #expect(cmp.compare(4, 4) == 0)
  }

  // MARK: - SortedMap.comparator()

  @Test("TreeMap.comparator() returns nil for natural-order map")
  func testTreeMapComparatorNil() {
    let map = java.util.TreeMap<Int, String>()
    map.put(1, "a"); map.put(2, "b")
    #expect(map.comparator() == nil)
  }

  // MARK: - SortedSet.comparator()

  @Test("TreeSet.comparator() returns nil for natural-order set")
  func testTreeSetComparatorNil() {
    let set = java.util.TreeSet<Int>()
    _ = try? set.add(1); _ = try? set.add(2)
    #expect(set.comparator() == nil)
  }

  // MARK: - keySet() returns java.util.Set

  @Test("HashMap.keySet() returns java.util.Set with correct size and contains")
  func testHashMapKeySet() {
    let map = java.util.HashMap<String, Int>()
    _ = map.put("alpha", 1); _ = map.put("beta", 2); _ = map.put("gamma", 3)
    let keys = map.keySet()
    #expect(keys.size() == 3)
    #expect(keys.contains("alpha"))
    #expect(keys.contains("beta"))
    #expect(keys.contains("gamma"))
    #expect(!keys.contains("delta"))
  }

  @Test("TreeMap.keySet() returns java.util.Set with correct content")
  func testTreeMapKeySet() {
    let map = java.util.TreeMap<Int, String>()
    map.put(10, "x"); map.put(20, "y"); map.put(30, "z")
    let keys = map.keySet()
    #expect(keys.size() == 3)
    #expect(keys.contains(10) && keys.contains(20) && keys.contains(30))
    #expect(!keys.contains(99))
  }
}
