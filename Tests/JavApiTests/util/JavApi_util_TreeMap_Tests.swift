/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

struct JavApi_util_TreeMap_Tests {

  // MARK: - Basic put / get / size

  @Test("put and get return correct values")
  func testPutGet() {
    let map = java.util.TreeMap<String, Int>()
    map.put("b", 2)
    map.put("a", 1)
    map.put("c", 3)
    #expect(map.get("a") == 1)
    #expect(map.get("b") == 2)
    #expect(map.get("c") == 3)
    #expect(map.size() == 3)
  }

  @Test("put returns previous value when key already exists")
  func testPutOverwrite() {
    let map = java.util.TreeMap<String, Int>()
    map.put("x", 10)
    let old = map.put("x", 99)
    #expect(old == 10)
    #expect(map.get("x") == 99)
    #expect(map.size() == 1)
  }

  @Test("put returns nil when key is new")
  func testPutNewKeyReturnsNil() {
    let map = java.util.TreeMap<Int, String>()
    let prev = map.put(1, "one")
    #expect(prev == nil)
  }

  @Test("get returns nil for missing key")
  func testGetMissing() {
    let map = java.util.TreeMap<Int, Int>()
    #expect(map.get(42) == nil)
  }

  // MARK: - Ordering

  @Test("keys are maintained in ascending order")
  func testKeyOrder() {
    let map = java.util.TreeMap<Int, String>()
    map.put(5, "five")
    map.put(1, "one")
    map.put(3, "three")
    map.put(2, "two")
    map.put(4, "four")
    let keys = map.entrySet().map { $0.key }
    #expect(keys == [1, 2, 3, 4, 5])
  }

  @Test("String keys are sorted lexicographically")
  func testStringKeyOrder() {
    let map = java.util.TreeMap<String, Int>()
    map.put("banana", 2)
    map.put("apple", 1)
    map.put("cherry", 3)
    let keys = map.entrySet().map { $0.key }
    #expect(keys == ["apple", "banana", "cherry"])
  }

  // MARK: - remove

  @Test("remove deletes existing key and returns value")
  func testRemove() {
    let map = java.util.TreeMap<Int, Int>()
    map.put(1, 10)
    map.put(2, 20)
    let removed = map.remove(1)
    #expect(removed == 10)
    #expect(map.size() == 1)
    #expect(map.get(1) == nil)
  }

  @Test("remove on missing key returns nil")
  func testRemoveMissing() {
    let map = java.util.TreeMap<Int, Int>()
    #expect(map.remove(99) == nil)
  }

  // MARK: - containsKey / containsValue

  @Test("containsKey finds existing key")
  func testContainsKey() {
    let map = java.util.TreeMap<String, Int>()
    map.put("hello", 1)
    #expect(map.containsKey("hello") == true)
    #expect(map.containsKey("world") == false)
  }

  // MARK: - clear / isEmpty

  @Test("clear removes all entries")
  func testClear() {
    let map = java.util.TreeMap<Int, Int>()
    map.put(1, 1); map.put(2, 2)
    map.clear()
    #expect(map.isEmpty() == true)
    #expect(map.size() == 0)
  }

  @Test("empty map is isEmpty")
  func testIsEmpty() {
    let map = java.util.TreeMap<Int, Int>()
    #expect(map.isEmpty() == true)
    map.put(1, 1)
    #expect(map.isEmpty() == false)
  }

  // MARK: - keySet / values

  @Test("keySet returns all keys as a Swift Set")
  func testKeySet() {
    let map = java.util.TreeMap<Int, String>()
    map.put(3, "c"); map.put(1, "a"); map.put(2, "b")
    #expect(map.keySet() == Swift.Set([1, 2, 3]))
  }

  @Test("values returns all values in key order")
  func testValues() {
    let map = java.util.TreeMap<Int, String>()
    map.put(2, "b"); map.put(1, "a"); map.put(3, "c")
    #expect(map.values() == ["a", "b", "c"])
  }

  // MARK: - putAll

  @Test("putAll copies all entries from another map")
  func testPutAll() {
    let src = java.util.TreeMap<Int, String>()
    src.put(1, "one"); src.put(2, "two")
    let dst = java.util.TreeMap<Int, String>()
    dst.putAll(src)
    #expect(dst.size() == 2)
    #expect(dst.get(1) == "one")
    #expect(dst.get(2) == "two")
  }

  // MARK: - SortedMap: firstKey / lastKey

  @Test("firstKey returns smallest key")
  func testFirstKey() throws {
    let map = java.util.TreeMap<Int, String>()
    map.put(3, "c"); map.put(1, "a"); map.put(2, "b")
    #expect(try map.firstKey() == 1)
  }

  @Test("lastKey returns largest key")
  func testLastKey() throws {
    let map = java.util.TreeMap<Int, String>()
    map.put(3, "c"); map.put(1, "a"); map.put(2, "b")
    #expect(try map.lastKey() == 3)
  }

  @Test("firstKey on empty map throws NoSuchElementException")
  func testFirstKeyEmpty() {
    let map = java.util.TreeMap<Int, String>()
    #expect(throws: java.util.NoSuchElementException.self) {
      _ = try map.firstKey()
    }
  }

  @Test("lastKey on empty map throws NoSuchElementException")
  func testLastKeyEmpty() {
    let map = java.util.TreeMap<Int, String>()
    #expect(throws: java.util.NoSuchElementException.self) {
      _ = try map.lastKey()
    }
  }

  // MARK: - SortedMap: headMap

  @Test("headMap returns keys strictly less than toKey")
  func testHeadMap() throws {
    let map = java.util.TreeMap<Int, String>()
    for i in 1...5 { map.put(i, "\(i)") }
    let head = map.headMap(3)
    #expect(head.size() == 2)
    #expect(try head.firstKey() == 1)
    #expect(try head.lastKey() == 2)
  }

  @Test("headMap with toKey below all keys returns empty map")
  func testHeadMapEmpty() {
    let map = java.util.TreeMap<Int, String>()
    map.put(5, "five"); map.put(10, "ten")
    let head = map.headMap(3)
    #expect(head.isEmpty() == true)
  }

  // MARK: - SortedMap: tailMap

  @Test("tailMap returns keys >= fromKey")
  func testTailMap() throws {
    let map = java.util.TreeMap<Int, String>()
    for i in 1...5 { map.put(i, "\(i)") }
    let tail = map.tailMap(4)
    #expect(tail.size() == 2)
    #expect(try tail.firstKey() == 4)
    #expect(try tail.lastKey() == 5)
  }

  // MARK: - SortedMap: subMap

  @Test("subMap returns keys in [fromKey, toKey)")
  func testSubMap() throws {
    let map = java.util.TreeMap<Int, String>()
    for i in 1...7 { map.put(i, "\(i)") }
    let sub = map.subMap(3, 6)
    #expect(sub.size() == 3)
    #expect(try sub.firstKey() == 3)
    #expect(try sub.lastKey() == 5)
    #expect(sub.containsKey(6) == false)
  }

  @Test("subMap with equal bounds returns empty map")
  func testSubMapEqualBounds() {
    let map = java.util.TreeMap<Int, String>()
    map.put(1, "one"); map.put(2, "two")
    let sub = map.subMap(2, 2)
    #expect(sub.isEmpty() == true)
  }

  // MARK: - Reference semantics

  @Test("TreeMap has reference semantics — two vars share the same map")
  func testReferenceSemantics() {
    let a = java.util.TreeMap<Int, Int>()
    let b = a
    a.put(1, 100)
    #expect(b.get(1) == 100)
  }
}
