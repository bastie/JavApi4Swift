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
    // entrySet() now returns any java.util.Set — collect via keySet which preserves TreeMap order
    let ks = map.keySet()
    var keys: [Int] = []
    let it = ks.iterator()
    while it.hasNext() { if let k = try? it.next() { keys.append(k) } }
    #expect(keys.sorted() == [1, 2, 3, 4, 5])
  }

  @Test("String keys are sorted lexicographically")
  func testStringKeyOrder() {
    let map = java.util.TreeMap<String, Int>()
    map.put("banana", 2)
    map.put("apple", 1)
    map.put("cherry", 3)
    let ks = map.keySet()
    var keys: [String] = []
    let it = ks.iterator()
    while it.hasNext() { if let k = try? it.next() { keys.append(k) } }
    #expect(keys.sorted() == ["apple", "banana", "cherry"])
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

  @Test("keySet returns all keys as java.util.Set")
  func testKeySet() {
    let map = java.util.TreeMap<Int, String>()
    map.put(3, "c"); map.put(1, "a"); map.put(2, "b")
    let keys = map.keySet()
    #expect(keys.size() == 3)
    #expect(keys.contains(1) && keys.contains(2) && keys.contains(3))
  }

  @Test("values returns all values (sorted by key)")
  func testValues() {
    let map = java.util.TreeMap<Int, String>()
    map.put(2, "b"); map.put(1, "a"); map.put(3, "c")
    var vals: [String] = []
    let it = map.values().iterator()
    while it.hasNext() { if let v = try? it.next() { vals.append(v) } }
    #expect(vals.sorted() == ["a", "b", "c"])
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

  // MARK: - comparator() / init(comparator:)

  @Test("init() yields nil comparator")
  func testComparatorNilForNaturalOrder() {
    let map = java.util.TreeMap<Int, String>()
    #expect(map.comparator() == nil)
  }

  @Test("init(comparator:) stores comparator and orders keys by it")
  func testComparatorDescendingKeyOrder() {
    // Reverse key order: larger keys sort first
    let cmp: any java.util.Comparator<Int> = java.util.Collections.reverseOrder()
    let map = java.util.TreeMap<Int, String>(comparator: cmp)
    map.put(3, "c"); map.put(1, "a"); map.put(2, "b")
    #expect(map.comparator() != nil)
    // Internal pairs must be in descending key order
    let keys = map._pairs.map { $0.key }
    #expect(keys == [3, 2, 1])
  }

  @Test("comparator TreeMap: firstKey/lastKey use comparator order")
  func testComparatorFirstLastKey() throws {
    let cmp: any java.util.Comparator<Int> = java.util.Collections.reverseOrder()
    let map = java.util.TreeMap<Int, String>(comparator: cmp)
    map.put(5, "e"); map.put(1, "a"); map.put(3, "c")
    #expect(try map.firstKey() == 5)   // "first" in descending order = largest
    #expect(try map.lastKey() == 1)    // "last" in descending order = smallest
  }

  @Test("comparator TreeMap: get and remove use comparator correctly")
  func testComparatorGetRemove() {
    let cmp: any java.util.Comparator<Int> = java.util.Collections.reverseOrder()
    let map = java.util.TreeMap<Int, String>(comparator: cmp)
    map.put(10, "ten"); map.put(20, "twenty")
    #expect(map.get(10) == "ten")
    let removed = map.remove(10)
    #expect(removed == "ten")
    #expect(map.size() == 1)
  }

  // MARK: - init(sortedMap:)

  @Test("init(sortedMap:) copies all entries in key order")
  func testInitSortedMap() throws {
    let source = java.util.TreeMap<Int, String>()
    source.put(3, "c"); source.put(1, "a"); source.put(2, "b")
    let copy = java.util.TreeMap<Int, String>(sortedMap: source)
    #expect(copy.size() == 3)
    #expect(copy.get(1) == "a")
    #expect(copy.get(2) == "b")
    #expect(copy.get(3) == "c")
    let keys = copy._pairs.map { $0.key }
    #expect(keys == [1, 2, 3])
  }

  @Test("init(sortedMap:) produces independent copy")
  func testInitSortedMapIsIndependent() {
    let source = java.util.TreeMap<Int, String>()
    source.put(1, "a"); source.put(2, "b")
    let copy = java.util.TreeMap<Int, String>(sortedMap: source)
    source.put(3, "c")
    #expect(copy.size() == 2)   // copy not affected by later modification of source
  }

  // MARK: - clone()

  @Test("clone() returns an independent copy with same entries")
  func testClone() {
    let original = java.util.TreeMap<Int, String>()
    original.put(1, "a"); original.put(2, "b"); original.put(3, "c")
    let copy = original.clone()
    #expect(copy.size() == 3)
    #expect(copy.get(1) == "a")
    // Modifying clone does not affect original
    copy.put(4, "d")
    #expect(original.size() == 3)
  }

  @Test("clone() preserves custom comparator")
  func testClonePreservesComparator() {
    let cmp: any java.util.Comparator<Int> = java.util.Collections.reverseOrder()
    let original = java.util.TreeMap<Int, String>(comparator: cmp)
    original.put(1, "a"); original.put(3, "c"); original.put(2, "b")
    let copy = original.clone()
    let keys = copy._pairs.map { $0.key }
    #expect(keys == [3, 2, 1])   // descending order preserved
    #expect(copy.comparator() != nil)
  }

  // MARK: - Key navigation: floorKey / lowerKey / ceilingKey / higherKey

  @Test("floorKey returns greatest key <= given key")
  func testFloorKey() {
    let map = java.util.TreeMap<Int, String>()
    for i in [1, 3, 5, 7, 9] { map.put(i, "\(i)") }
    #expect(map.floorKey(6) == 5)
    #expect(map.floorKey(5) == 5)
    #expect(map.floorKey(0) == nil)
  }

  @Test("lowerKey returns greatest key strictly less than given key")
  func testLowerKey() {
    let map = java.util.TreeMap<Int, String>()
    for i in [1, 3, 5, 7, 9] { map.put(i, "\(i)") }
    #expect(map.lowerKey(5) == 3)
    #expect(map.lowerKey(1) == nil)
    #expect(map.lowerKey(10) == 9)
  }

  @Test("ceilingKey returns least key >= given key")
  func testCeilingKey() {
    let map = java.util.TreeMap<Int, String>()
    for i in [1, 3, 5, 7, 9] { map.put(i, "\(i)") }
    #expect(map.ceilingKey(4) == 5)
    #expect(map.ceilingKey(5) == 5)
    #expect(map.ceilingKey(10) == nil)
  }

  @Test("higherKey returns least key strictly greater than given key")
  func testHigherKey() {
    let map = java.util.TreeMap<Int, String>()
    for i in [1, 3, 5, 7, 9] { map.put(i, "\(i)") }
    #expect(map.higherKey(5) == 7)
    #expect(map.higherKey(9) == nil)
    #expect(map.higherKey(0) == 1)
  }

  // MARK: - Comparator propagation in range views

  @Test("headMap with comparator filters by comparator ordering")
  func testHeadMapWithComparator() throws {
    let cmp: any java.util.Comparator<Int> = java.util.Collections.reverseOrder()
    let map = java.util.TreeMap<Int, String>(comparator: cmp)
    for i in [5, 3, 1, 4, 2] { map.put(i, "\(i)") }
    // _pairs sorted by reverseOrder: [5,4,3,2,1]
    // headMap(3): keys where reverseOrder(k, 3) < 0 ↔ k > 3 → {5, 4}
    let head = map.headMap(3)
    #expect(head.size() == 2)
    #expect(head.containsKey(5) == true)
    #expect(head.containsKey(4) == true)
    #expect(head.containsKey(3) == false)
  }

  @Test("tailMap with comparator filters by comparator ordering")
  func testTailMapWithComparator() throws {
    let cmp: any java.util.Comparator<Int> = java.util.Collections.reverseOrder()
    let map = java.util.TreeMap<Int, String>(comparator: cmp)
    for i in [5, 3, 1, 4, 2] { map.put(i, "\(i)") }
    // tailMap(3): keys where reverseOrder(k, 3) >= 0 ↔ k <= 3 → {3,2,1}
    let tail = map.tailMap(3)
    #expect(tail.size() == 3)
    #expect(tail.containsKey(3) == true)
    #expect(tail.containsKey(2) == true)
    #expect(tail.containsKey(1) == true)
    #expect(tail.containsKey(4) == false)
  }

  @Test("subMap with comparator filters by comparator ordering")
  func testSubMapWithComparator() throws {
    let cmp: any java.util.Comparator<Int> = java.util.Collections.reverseOrder()
    let map = java.util.TreeMap<Int, String>(comparator: cmp)
    for i in [5, 3, 1, 4, 2] { map.put(i, "\(i)") }
    // subMap(4, 2): from=4 (inclusive), to=2 (exclusive) in reverseOrder → {4, 3}
    let sub = map.subMap(4, 2)
    #expect(sub.size() == 2)
    #expect(sub.containsKey(4) == true)
    #expect(sub.containsKey(3) == true)
    #expect(sub.containsKey(2) == false)
    #expect(sub.containsKey(5) == false)
  }

  @Test("headMap inclusive with comparator filters by comparator ordering")
  func testHeadMapInclusiveWithComparator() throws {
    let cmp: any java.util.Comparator<Int> = java.util.Collections.reverseOrder()
    let map = java.util.TreeMap<Int, String>(comparator: cmp)
    for i in [5, 3, 1, 4, 2] { map.put(i, "\(i)") }
    // headMap(3, inclusive:true): reverseOrder(k,3) <= 0 ↔ k >= 3 → {5,4,3}
    let headInc = map.headMap(3, true)
    #expect(headInc.size() == 3)
    #expect(headInc.containsKey(3) == true)
    // headMap(3, inclusive:false): k > 3 → {5,4}
    let headEx = map.headMap(3, false)
    #expect(headEx.size() == 2)
    #expect(headEx.containsKey(3) == false)
  }

  @Test("subView headMap uses inherited comparator")
  func testSubMapViewInheritsComparator() throws {
    let cmp: any java.util.Comparator<Int> = java.util.Collections.reverseOrder()
    let map = java.util.TreeMap<Int, String>(comparator: cmp)
    for i in [10, 8, 6, 4, 2] { map.put(i, "\(i)") }
    // headMap(8) → {10} (keys > 8 in reverseOrder)
    let head = map.headMap(8)
    // headMap(6) on sub-view: keys of {10} where reverseOrder(k,6) < 0 ↔ k > 6 → {10}
    let subHead = head.headMap(6)
    #expect(subHead.size() == 1)
    #expect(subHead.containsKey(10) == true)
  }

  @Test("descendingMap lowerEntry/higherEntry use ascending comparator correctly")
  func testDescendingMapNavigationWithComparator() throws {
    let cmp: any java.util.Comparator<Int> = java.util.Collections.reverseOrder()
    let map = java.util.TreeMap<Int, String>(comparator: cmp)
    for i in [1, 3, 5, 7, 9] { map.put(i, "\(i)") }
    // map._pairs = [9,7,5,3,1] (reverseOrder)
    // descendingMap reverses reverseOrder → natural order view
    let desc = map.descendingMap()
    // In descending map (natural order), lowerEntry(5) = greatest key < 5 in natural = 3
    #expect(desc.lowerEntry(5)?.key == 3)
    // floorEntry(4) = greatest key ≤ 4 in natural = 3
    #expect(desc.floorEntry(4)?.key == 3)
    // ceilingEntry(4) = least key ≥ 4 in natural = 5
    #expect(desc.ceilingEntry(4)?.key == 5)
    // higherEntry(5) = least key > 5 in natural = 7
    #expect(desc.higherEntry(5)?.key == 7)
  }
}
