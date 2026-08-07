/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

// MARK: - ArrayList via List → SequencedCollection defaults

@Suite("Java 21: ArrayList as SequencedCollection (via List defaults)")
struct JavApi_util_Java21_ArrayList_SequencedCollection_Tests {

  @Test("getFirst() returns first element")
  func testGetFirst() throws {
    let list = java.util.ArrayList<Int>()
    _ = try list.add(10)
    _ = try list.add(20)
    _ = try list.add(30)
    #expect(try list.getFirst() == 10)
  }

  @Test("getLast() returns last element")
  func testGetLast() throws {
    let list = java.util.ArrayList<Int>()
    _ = try list.add(10)
    _ = try list.add(20)
    _ = try list.add(30)
    #expect(try list.getLast() == 30)
  }

  @Test("getFirst() on empty list throws NoSuchElementException")
  func testGetFirstEmpty() {
    let list = java.util.ArrayList<Int>()
    #expect(throws: java.util.NoSuchElementException.self) { try list.getFirst() }
  }

  @Test("getLast() on empty list throws NoSuchElementException")
  func testGetLastEmpty() {
    let list = java.util.ArrayList<Int>()
    #expect(throws: java.util.NoSuchElementException.self) { try list.getLast() }
  }

  @Test("addFirst() inserts element at index 0")
  func testAddFirst() throws {
    let list = java.util.ArrayList<Int>()
    _ = try list.add(2)
    _ = try list.add(3)
    try list.addFirst(1)
    #expect(try list.getFirst() == 1)
    #expect(list.size() == 3)
    #expect(try list.get(1) == 2)
  }

  @Test("addLast() appends element at end")
  func testAddLast() throws {
    let list = java.util.ArrayList<Int>()
    _ = try list.add(1)
    _ = try list.add(2)
    try list.addLast(3)
    #expect(try list.getLast() == 3)
    #expect(list.size() == 3)
  }

  @Test("removeFirst() removes and returns element at index 0")
  func testRemoveFirst() throws {
    let list = java.util.ArrayList<String>()
    _ = try list.add("a")
    _ = try list.add("b")
    _ = try list.add("c")
    let removed = try list.removeFirst()
    #expect(removed == "a")
    #expect(list.size() == 2)
    #expect(try list.getFirst() == "b")
  }

  @Test("removeLast() removes and returns last element")
  func testRemoveLast() throws {
    let list = java.util.ArrayList<String>()
    _ = try list.add("x")
    _ = try list.add("y")
    _ = try list.add("z")
    let removed = try list.removeLast()
    #expect(removed == "z")
    #expect(list.size() == 2)
    #expect(try list.getLast() == "y")
  }

  @Test("removeFirst() on empty list throws NoSuchElementException")
  func testRemoveFirstEmpty() {
    let list = java.util.ArrayList<Int>()
    #expect(throws: java.util.NoSuchElementException.self) { try list.removeFirst() }
  }

  @Test("reversed() returns elements in reverse order")
  func testReversed() throws {
    let list = java.util.ArrayList<Int>()
    for v in [1, 2, 3] { _ = try list.add(v) }
    let rev = list.reversed()
    #expect(try rev.getFirst() == 3)
    #expect(try rev.getLast() == 1)
    #expect(rev.size() == 3)
  }

  @Test("ArrayList conforms to SequencedCollection via List protocol")
  func testProtocolConformance() {
    let list: any java.util.SequencedCollection<Int> = java.util.ArrayList<Int>()
    #expect(list.size() == 0)
  }
}

// MARK: - TreeSet via SortedSet → SequencedSet defaults

@Suite("Java 21: TreeSet as SequencedSet (via SortedSet defaults)")
struct JavApi_util_Java21_TreeSet_SequencedSet_Tests {

  @Test("getFirst() returns lowest element")
  func testGetFirst() throws {
    let set = java.util.TreeSet<Int>()
    for v in [5, 2, 8, 1] { _ = try set.add(v) }
    #expect(try set.getFirst() == 1)
  }

  @Test("getLast() returns highest element")
  func testGetLast() throws {
    let set = java.util.TreeSet<Int>()
    for v in [5, 2, 8, 1] { _ = try set.add(v) }
    #expect(try set.getLast() == 8)
  }

  @Test("removeFirst() removes and returns lowest element")
  func testRemoveFirst() throws {
    let set = java.util.TreeSet<Int>()
    for v in [3, 1, 2] { _ = try set.add(v) }
    let removed = try set.removeFirst()
    #expect(removed == 1)
    #expect(set.size() == 2)
    #expect(!set.contains(1))
  }

  @Test("removeLast() removes and returns highest element")
  func testRemoveLast() throws {
    let set = java.util.TreeSet<Int>()
    for v in [3, 1, 2] { _ = try set.add(v) }
    let removed = try set.removeLast()
    #expect(removed == 3)
    #expect(set.size() == 2)
    #expect(!set.contains(3))
  }

  @Test("reversedSet() returns elements in descending order")
  func testReversedSet() throws {
    let set = java.util.TreeSet<Int>()
    for v in [1, 2, 3] { _ = try set.add(v) }
    let rev = set.reversedSet()
    #expect(try rev.getFirst() == 3)
    #expect(try rev.getLast() == 1)
  }

  @Test("TreeSet conforms to SequencedSet via NavigableSet chain")
  func testProtocolConformance() {
    let set: any java.util.SequencedSet<Int> = java.util.TreeSet<Int>()
    #expect(set.size() == 0)
  }
}

// MARK: - LinkedHashMap Map + SequencedMap conformance

@Suite("Java 21: LinkedHashMap as Map + SequencedMap")
struct JavApi_util_Java21_LinkedHashMap_Map_Tests {

  // MARK: Map methods

  @Test("get() returns value for existing key, nil for missing key")
  func testGet() {
    let map = java.util.LinkedHashMap<String, Int>()
    _ = map.put("a", 1)
    #expect(map.get("a") == 1)
    #expect(map.get("z") == nil)
  }

  @Test("put() replaces existing value and returns old value")
  func testPutReplace() {
    let map = java.util.LinkedHashMap<String, Int>()
    let old1 = map.put("k", 10)
    let old2 = map.put("k", 20)
    #expect(old1 == nil)
    #expect(old2 == 10)
    #expect(map.get("k") == 20)
  }

  @Test("containsKey() and containsValue()")
  func testContains() {
    let map = java.util.LinkedHashMap<Int, String>()
    _ = map.put(1, "one")
    #expect(map.containsKey(1) == true)
    #expect(map.containsKey(2) == false)
    #expect(map.containsValue("one") == true)
    #expect(map.containsValue("two") == false)
  }

  @Test("remove() deletes entry and returns old value")
  func testRemove() {
    let map = java.util.LinkedHashMap<Int, Int>()
    _ = map.put(1, 100)
    let old = map.remove(1)
    #expect(old == 100)
    #expect(map.size() == 0)
    #expect(map.containsKey(1) == false)
  }

  @Test("putAll() copies all entries from another map")
  func testPutAll() {
    let src = java.util.LinkedHashMap<Int, Int>()
    _ = src.put(1, 10); _ = src.put(2, 20)
    let dst = java.util.LinkedHashMap<Int, Int>()
    dst.putAll(src)
    #expect(dst.size() == 2)
    #expect(dst.get(1) == 10)
    #expect(dst.get(2) == 20)
  }

  @Test("keySet() contains all inserted keys")
  func testKeySet() {
    let map = java.util.LinkedHashMap<String, Int>()
    _ = map.put("a", 1); _ = map.put("b", 2); _ = map.put("c", 3)
    let ks = map.keySet()
    #expect(ks.size() == 3)
    #expect(ks.contains("a") == true)
    #expect(ks.contains("x") == false)
  }

  @Test("values() contains all inserted values in insertion order")
  func testValues() {
    let map = java.util.LinkedHashMap<String, Int>()
    _ = map.put("x", 10); _ = map.put("y", 20); _ = map.put("z", 30)
    let vals = map.values()
    #expect(vals.size() == 3)
    #expect(vals.contains(10) == true)
    #expect(vals.contains(99) == false)
  }

  @Test("entrySet() contains all key-value pairs")
  func testEntrySet() {
    let map = java.util.LinkedHashMap<Int, Int>()
    _ = map.put(1, 10); _ = map.put(2, 20)
    let es = map.entrySet()
    #expect(es.size() == 2)
    #expect(es.contains(java.util.MapEntry(1, 10)) == true)
    #expect(es.contains(java.util.MapEntry(2, 99)) == false)
  }

  // MARK: SequencedMap methods

  @Test("firstEntry() returns entry with first-inserted key")
  func testFirstEntry() {
    let map = java.util.LinkedHashMap<Int, String>()
    _ = map.put(3, "c"); _ = map.put(1, "a"); _ = map.put(2, "b")
    let first = map.firstEntry()
    #expect(first?.key == 3)   // insertion order: 3 was inserted first
    #expect(first?.value == "c")
  }

  @Test("lastEntry() returns entry with last-inserted key")
  func testLastEntry() {
    let map = java.util.LinkedHashMap<Int, String>()
    _ = map.put(3, "c"); _ = map.put(1, "a"); _ = map.put(2, "b")
    let last = map.lastEntry()
    #expect(last?.key == 2)
    #expect(last?.value == "b")
  }

  @Test("firstEntry() on empty map returns nil")
  func testFirstEntryEmpty() {
    let map = java.util.LinkedHashMap<Int, Int>()
    #expect(map.firstEntry() == nil)
  }

  @Test("pollFirstEntry() removes and returns first entry")
  func testPollFirstEntry() {
    let map = java.util.LinkedHashMap<Int, Int>()
    _ = map.put(10, 100); _ = map.put(20, 200)
    let polled = map.pollFirstEntry()
    #expect(polled?.key == 10)
    #expect(polled?.value == 100)
    #expect(map.size() == 1)
    #expect(map.containsKey(10) == false)
  }

  @Test("pollLastEntry() removes and returns last entry")
  func testPollLastEntry() {
    let map = java.util.LinkedHashMap<Int, Int>()
    _ = map.put(10, 100); _ = map.put(20, 200)
    let polled = map.pollLastEntry()
    #expect(polled?.key == 20)
    #expect(polled?.value == 200)
    #expect(map.size() == 1)
    #expect(map.containsKey(20) == false)
  }

  @Test("putFirst() inserts at front of encounter order")
  func testPutFirst() throws {
    let map = java.util.LinkedHashMap<Int, String>()
    _ = map.put(1, "a"); _ = map.put(2, "b")
    _ = try map.putFirst(0, "z")
    #expect(map.firstEntry()?.key == 0)
    #expect(map.size() == 3)
  }

  @Test("putFirst() with existing key moves it to front")
  func testPutFirstExistingKey() throws {
    let map = java.util.LinkedHashMap<Int, String>()
    _ = map.put(1, "a"); _ = map.put(2, "b"); _ = map.put(3, "c")
    _ = try map.putFirst(3, "C")
    #expect(map.firstEntry()?.key == 3)
    #expect(map.firstEntry()?.value == "C")
    #expect(map.size() == 3)
  }

  @Test("putLast() appends at end of encounter order")
  func testPutLast() throws {
    let map = java.util.LinkedHashMap<Int, String>()
    _ = map.put(1, "a"); _ = map.put(2, "b")
    _ = try map.putLast(9, "z")
    #expect(map.lastEntry()?.key == 9)
    #expect(map.size() == 3)
  }

  @Test("reversedMap() returns entries in reverse insertion order")
  func testReversedMap() {
    let map = java.util.LinkedHashMap<Int, String>()
    _ = map.put(1, "a"); _ = map.put(2, "b"); _ = map.put(3, "c")
    let rev = map.reversedMap()
    #expect(rev.firstEntry()?.key == 3)
    #expect(rev.lastEntry()?.key == 1)
    #expect(rev.size() == 3)
  }

  @Test("sequencedKeySet() returns keys in insertion order")
  func testSequencedKeySet() throws {
    let map = java.util.LinkedHashMap<Int, String>()
    _ = map.put(10, "x"); _ = map.put(20, "y"); _ = map.put(30, "z")
    let ks = map.sequencedKeySet()
    #expect(try ks.getFirst() == 10)
    #expect(try ks.getLast() == 30)
    #expect(ks.size() == 3)
  }

  @Test("sequencedValues() returns values in insertion order")
  func testSequencedValues() throws {
    let map = java.util.LinkedHashMap<Int, String>()
    _ = map.put(1, "first"); _ = map.put(2, "second")
    let vals = map.sequencedValues()
    #expect(try vals.getFirst() == "first")
    #expect(try vals.getLast() == "second")
  }

  @Test("sequencedEntrySet() returns entries in insertion order")
  func testSequencedEntrySet() throws {
    let map = java.util.LinkedHashMap<Int, Int>()
    _ = map.put(100, 1); _ = map.put(200, 2); _ = map.put(300, 3)
    let es = map.sequencedEntrySet()
    let first = try es.getFirst()
    let last  = try es.getLast()
    #expect(first.key == 100)
    #expect(last.key  == 300)
  }

  @Test("LinkedHashMap conforms to SequencedMap protocol")
  func testProtocolConformance() {
    let map: any java.util.SequencedMap<Int, String> = java.util.LinkedHashMap<Int, String>()
    #expect(map.size() == 0)
    #expect(map.firstEntry() == nil)
  }
}
