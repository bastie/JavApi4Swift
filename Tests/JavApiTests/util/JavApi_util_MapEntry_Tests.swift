/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

@Suite("java.util.Map.Entry")
struct JavApi_util_MapEntry_Tests {

  typealias Entry = java.util.MapEntry<String, Int>

  // MARK: - Construction

  @Test("getKey() and getValue() return initialised values")
  func testGetKeyAndValue() {
    let e = Entry("hello", 42)
    #expect(e.getKey() == "hello")
    #expect(e.getValue() == 42)
  }

  // MARK: - setValue

  @Test("setValue() replaces value and returns old value")
  func testSetValue() {
    var e = Entry("key", 1)
    let old = e.setValue(99)
    #expect(old == 1)
    #expect(e.getValue() == 99)
  }

  // MARK: - Equatable

  @Test("two entries with same key and value are equal")
  func testEquality() {
    let a = Entry("x", 10)
    let b = Entry("x", 10)
    #expect(a == b)
  }

  @Test("entries with different values are not equal")
  func testInequalityValue() {
    let a = Entry("x", 10)
    let b = Entry("x", 20)
    #expect(a != b)
  }

  @Test("entries with different keys are not equal")
  func testInequalityKey() {
    let a = Entry("x", 10)
    let b = Entry("y", 10)
    #expect(a != b)
  }

  // MARK: - Hashable (can be stored in a Set)

  @Test("Entry can be added to a HashSet")
  func testInHashSet() throws {
    let set = java.util.HashSet<Entry>()
    let e1 = Entry("a", 1)
    let e2 = Entry("b", 2)
    let e3 = Entry("a", 1)   // duplicate of e1
    _ = try set.add(e1)
    _ = try set.add(e2)
    _ = try set.add(e3)   // should not increase size
    #expect(set.size() == 2)
    #expect(set.contains(e1))
    #expect(set.contains(e2))
  }

  // MARK: - entrySet() integration

  @Test("HashMap.entrySet() returns all entries")
  func testHashMapEntrySet() {
    let map = java.util.HashMap<String, Int>()
    _ = map.put("a", 1)
    _ = map.put("b", 2)
    let entries = map.entrySet()
    #expect(entries.size() == 2)
    let me1 = java.util.MapEntry("a", 1)
    #expect(entries.contains(me1))
    let me2 = java.util.MapEntry("b", 2)
    #expect(entries.contains(me2))
    let me3 = java.util.MapEntry("c", 3)
    #expect(!entries.contains(me3))
  }

  @Test("TreeMap.entrySet() returns all entries")
  func testTreeMapEntrySet() {
    let map = java.util.TreeMap<Int, String>()
    map.put(1, "one"); map.put(2, "two"); map.put(3, "three")
    let entries = map.entrySet()
    #expect(entries.size() == 3)
    let te1 = java.util.MapEntry(1, "one")
    #expect(entries.contains(te1))
    let te3 = java.util.MapEntry(3, "three")
    #expect(entries.contains(te3))
  }

  // MARK: - comparingByKey (Java 8)

  @Test("comparingByKey() orders entries ascending by key")
  func testComparingByKey() {
    let cmp = java.util.MapEntry<String, Int>.comparingByKey()
    let a = java.util.MapEntry("apple", 1)
    let b = java.util.MapEntry("banana", 2)
    let c = java.util.MapEntry("apple", 99)  // same key, different value
    #expect(cmp.compare(a, b) < 0)    // "apple" < "banana"
    #expect(cmp.compare(b, a) > 0)    // "banana" > "apple"
    #expect(cmp.compare(a, c) == 0)   // same key → equal
  }

  @Test("comparingByKey() can sort an array")
  func testComparingByKeySort() {
    let cmp = java.util.MapEntry<Int, String>.comparingByKey()
    var entries = [
      java.util.MapEntry(3, "c"),
      java.util.MapEntry(1, "a"),
      java.util.MapEntry(2, "b"),
    ]
    entries.sort { cmp.compare($0, $1) < 0 }
    #expect(entries.map { $0.key } == [1, 2, 3])
  }

  @Test("comparingByKey() handles nil entries")
  func testComparingByKeyNil() {
    let cmp = java.util.MapEntry<Int, String>.comparingByKey()
    let a: java.util.MapEntry<Int, String>? = java.util.MapEntry(1, "a")
    #expect(cmp.compare(nil, a) < 0)
    #expect(cmp.compare(a, nil) > 0)
    #expect(cmp.compare(nil, nil) == 0)
  }

  // MARK: - comparingByValue (Java 8)

  @Test("comparingByValue() orders entries ascending by value")
  func testComparingByValue() {
    let cmp = java.util.MapEntry<String, Int>.comparingByValue()
    let a = java.util.MapEntry("x", 10)
    let b = java.util.MapEntry("y", 20)
    let c = java.util.MapEntry("z", 10)  // same value, different key
    #expect(cmp.compare(a, b) < 0)    // 10 < 20
    #expect(cmp.compare(b, a) > 0)    // 20 > 10
    #expect(cmp.compare(a, c) == 0)   // same value → equal
  }

  @Test("comparingByValue() can sort an array")
  func testComparingByValueSort() {
    let cmp = java.util.MapEntry<String, Int>.comparingByValue()
    var entries = [
      java.util.MapEntry("c", 30),
      java.util.MapEntry("a", 10),
      java.util.MapEntry("b", 20),
    ]
    entries.sort { cmp.compare($0, $1) < 0 }
    #expect(entries.map { $0.value } == [10, 20, 30])
  }

  @Test("comparingByValue() handles nil entries")
  func testComparingByValueNil() {
    let cmp = java.util.MapEntry<String, Int>.comparingByValue()
    let a: java.util.MapEntry<String, Int>? = java.util.MapEntry("x", 5)
    #expect(cmp.compare(nil, a) < 0)
    #expect(cmp.compare(a, nil) > 0)
    #expect(cmp.compare(nil, nil) == 0)
  }
}
