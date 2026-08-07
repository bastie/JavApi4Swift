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
}
