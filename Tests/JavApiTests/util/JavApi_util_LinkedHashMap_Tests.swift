/*
 * SPDX-FileCopyrightText: 2023, 2025 - 2026 Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

@Suite("java.util.LinkedHashMap")
struct JavApi_util_LinkedHashMap_Tests {

  // MARK: - Constructors

  @Test("empty constructor creates map with size 0")
  func testInitEmpty() {
    let map = java.util.LinkedHashMap<Int, Int>()
    #expect(map.size() == 0)
    #expect(map.isEmpty())
  }

  @Test("constructor with initial capacity creates map with size 0")
  func testInitWithCapacity() {
    let map = java.util.LinkedHashMap<Int, Int>(12)
    #expect(map.size() == 0)
  }

  @Test("copy constructor from empty map produces size 0")
  func testInitCopyEmpty() {
    let source = java.util.LinkedHashMap<Int, Int>()
    let copy   = java.util.LinkedHashMap<Int, Int>(source)
    #expect(copy.size() == 0)
  }

  @Test("copy constructor from non-empty map copies entries")
  func testInitCopyWithEntries() {
    let source = java.util.LinkedHashMap<Int, Int>()
    _ = source.put(0, 1)
    let copy = java.util.LinkedHashMap<Int, Int>(source)
    #expect(copy.size() == 1)
    #expect(copy.get(0) == 1)
  }

  // MARK: - put / get / remove

  @Test("put and get round-trip")
  func testPutGet() {
    let map = java.util.LinkedHashMap<String, Int>()
    _ = map.put("a", 1)
    _ = map.put("b", 2)
    #expect(map.get("a") == 1)
    #expect(map.get("b") == 2)
    #expect(map.get("c") == nil)
  }

  @Test("put returns previous value when key already exists")
  func testPutReturnsPrevious() {
    let map = java.util.LinkedHashMap<String, Int>()
    let old = map.put("x", 10)
    #expect(old == nil)
    let replaced = map.put("x", 20)
    #expect(replaced == 10)
    #expect(map.get("x") == 20)
  }

  @Test("remove returns the removed value and shrinks size")
  func testRemove() {
    let map = java.util.LinkedHashMap<String, Int>()
    _ = map.put("a", 1)
    _ = map.put("b", 2)
    let removed = map.remove("a")
    #expect(removed == 1)
    #expect(map.size() == 1)
    #expect(map.get("a") == nil)
  }

  @Test("remove on absent key returns nil")
  func testRemoveAbsent() {
    let map = java.util.LinkedHashMap<String, Int>()
    #expect(map.remove("missing") == nil)
  }

  // MARK: - containsKey / containsValue

  @Test("containsKey returns true for present key")
  func testContainsKey() {
    let map = java.util.LinkedHashMap<String, Int>()
    _ = map.put("k", 7)
    #expect(map.containsKey("k"))
    #expect(!map.containsKey("missing"))
  }

  @Test("containsValue returns true for present value")
  func testContainsValue() {
    let map = java.util.LinkedHashMap<String, Int>()
    _ = map.put("k", 42)
    #expect(map.containsValue(42))
    #expect(!map.containsValue(0))
  }

  // MARK: - Insertion order

  @Test("iteration preserves insertion order")
  func testInsertionOrder() {
    let map = java.util.LinkedHashMap<String, Int>()
    _ = map.put("c", 3)
    _ = map.put("a", 1)
    _ = map.put("b", 2)
    let keys = map.map { $0.0 }
    #expect(keys == ["c", "a", "b"])
  }

  @Test("updating an existing key preserves original insertion position")
  func testUpdatePreservesOrder() {
    let map = java.util.LinkedHashMap<String, Int>()
    _ = map.put("x", 1)
    _ = map.put("y", 2)
    _ = map.put("z", 3)
    _ = map.put("y", 99)  // update, must stay in position 1
    let keys = map.map { $0.0 }
    #expect(keys == ["x", "y", "z"])
    #expect(map.get("y") == 99)
  }

  @Test("remove shifts subsequent entries correctly")
  func testRemoveShiftsOrder() {
    let map = java.util.LinkedHashMap<String, Int>()
    _ = map.put("a", 1); _ = map.put("b", 2); _ = map.put("c", 3)
    _ = map.remove("b")
    let keys = map.map { $0.0 }
    #expect(keys == ["a", "c"])
  }

  // MARK: - Views: keySet, values, entrySet

  @Test("keySet() contains all keys")
  func testKeySet() {
    let map = java.util.LinkedHashMap<String, Int>()
    _ = map.put("a", 1); _ = map.put("b", 2)
    let ks = map.keySet()
    #expect(ks.size() == 2)
    #expect(ks.contains("a"))
    #expect(ks.contains("b"))
  }

  @Test("values() contains all values in insertion order")
  func testValues() {
    let map = java.util.LinkedHashMap<String, Int>()
    _ = map.put("first", 10); _ = map.put("second", 20); _ = map.put("third", 30)
    let vals = map.values()
    // ArrayList preserves insertion order
    let it = vals.iterator()
    var collected: [Int] = []
    while it.hasNext() { if let v = try? it.next() { collected.append(v) } }
    #expect(collected == [10, 20, 30])
  }

  @Test("entrySet() contains all MapEntry pairs")
  func testEntrySet() {
    let map = java.util.LinkedHashMap<String, Int>()
    _ = map.put("a", 1); _ = map.put("b", 2)
    let es = map.entrySet()
    #expect(es.size() == 2)
    #expect(es.contains(java.util.MapEntry("a", 1)))
    #expect(es.contains(java.util.MapEntry("b", 2)))
    #expect(!es.contains(java.util.MapEntry("c", 3)))
  }

  // MARK: - SequencedMap methods

  @Test("firstEntry and lastEntry return correct entries")
  func testFirstLastEntry() {
    let map = java.util.LinkedHashMap<String, Int>()
    _ = map.put("first", 1); _ = map.put("middle", 2); _ = map.put("last", 3)
    #expect(map.firstEntry()?.key == "first")
    #expect(map.lastEntry()?.key == "last")
  }

  @Test("pollFirstEntry removes and returns first entry")
  func testPollFirst() {
    let map = java.util.LinkedHashMap<String, Int>()
    _ = map.put("a", 1); _ = map.put("b", 2)
    let e = map.pollFirstEntry()
    #expect(e?.key == "a")
    #expect(map.size() == 1)
    #expect(map.get("a") == nil)
  }

  @Test("pollLastEntry removes and returns last entry")
  func testPollLast() {
    let map = java.util.LinkedHashMap<String, Int>()
    _ = map.put("a", 1); _ = map.put("b", 2)
    let e = map.pollLastEntry()
    #expect(e?.key == "b")
    #expect(map.size() == 1)
    #expect(map.get("b") == nil)
  }

  @Test("putFirst moves key to front")
  func testPutFirst() throws {
    let map = java.util.LinkedHashMap<String, Int>()
    _ = map.put("a", 1); _ = map.put("b", 2); _ = map.put("c", 3)
    _ = try map.putFirst("c", 99)
    let keys = map.map { $0.0 }
    #expect(keys == ["c", "a", "b"])
    #expect(map.get("c") == 99)
  }

  @Test("putLast moves key to back")
  func testPutLast() throws {
    let map = java.util.LinkedHashMap<String, Int>()
    _ = map.put("a", 1); _ = map.put("b", 2); _ = map.put("c", 3)
    _ = try map.putLast("a", 99)
    let keys = map.map { $0.0 }
    #expect(keys == ["b", "c", "a"])
    #expect(map.get("a") == 99)
  }

  @Test("reversedMap iterates in reversed insertion order")
  func testReversedMap() {
    let map = java.util.LinkedHashMap<String, Int>()
    _ = map.put("a", 1); _ = map.put("b", 2); _ = map.put("c", 3)
    let rev = map.reversedMap()
    var keys: [String] = []
    let it = rev.sequencedKeySet().iterator()
    while it.hasNext() { if let k = try? it.next() { keys.append(k) } }
    #expect(keys == ["c", "b", "a"])
  }

  // MARK: - accessOrder (Java 1.4)

  @Test("accessOrder=false uses insertion order (default)")
  func testInsertionOrderConstructor() {
    let map = java.util.LinkedHashMap<String, Int>(4, 0.75, false)
    _ = map.put("a", 1); _ = map.put("b", 2); _ = map.put("c", 3)
    _ = map.get("a")  // must NOT reorder in insertion-order mode
    let keys = map.map { $0.0 }
    #expect(keys == ["a", "b", "c"])
  }

  @Test("accessOrder=true moves accessed key to end")
  func testAccessOrderGet() {
    let map = java.util.LinkedHashMap<String, Int>(4, 0.75, true)
    _ = map.put("a", 1); _ = map.put("b", 2); _ = map.put("c", 3)
    _ = map.get("a")   // "a" becomes most-recently-used → moves to end
    let keys = map.map { $0.0 }
    #expect(keys == ["b", "c", "a"])
  }

  @Test("accessOrder=true moves updated key to end on put")
  func testAccessOrderPut() {
    let map = java.util.LinkedHashMap<String, Int>(4, 0.75, true)
    _ = map.put("x", 1); _ = map.put("y", 2); _ = map.put("z", 3)
    _ = map.put("x", 99)  // update existing key → must move to end
    let keys = map.map { $0.0 }
    #expect(keys == ["y", "z", "x"])
    #expect(map.get("x") == 99)
  }

  @Test("accessOrder=true new insertion goes to end, no reorder")
  func testAccessOrderNewKey() {
    let map = java.util.LinkedHashMap<String, Int>(4, 0.75, true)
    _ = map.put("a", 1); _ = map.put("b", 2)
    _ = map.put("c", 3)  // new key → plain append, no reorder
    let keys = map.map { $0.0 }
    #expect(keys == ["a", "b", "c"])
  }

  // MARK: - removeEldestEntry (Java 1.4)

  @Test("removeEldestEntry default always returns false (no eviction)")
  func testRemoveEldestEntryDefault() {
    let map = java.util.LinkedHashMap<Int, Int>()
    for i in 0..<10 { _ = map.put(i, i) }
    #expect(map.size() == 10)  // nothing evicted
  }

  @Test("subclass with removeEldestEntry evicts eldest when over capacity")
  func testRemoveEldestEntrySubclass() {
    final class BoundedMap: java.util.LinkedHashMap<Int, Int> {
      let maxEntries: Int
      init(max: Int) {
        self.maxEntries = max
        super.init(max, 0.75, true)
      }
      required init() { fatalError() }
      override func removeEldestEntry(_ eldest: java.util.MapEntry<Int, Int>) -> Bool {
        size() > maxEntries
      }
    }
    let cache = BoundedMap(max: 3)
    _ = cache.put(1, 1); _ = cache.put(2, 2); _ = cache.put(3, 3)
    #expect(cache.size() == 3)
    _ = cache.put(4, 4)           // inserts 4, triggers eviction of eldest (1)
    #expect(cache.size() == 3)
    #expect(cache.get(1) == nil)  // eldest was evicted
    #expect(cache.get(4) == 4)
  }

  // MARK: - clear / putAll

  @Test("clear removes all entries")
  func testClear() {
    let map = java.util.LinkedHashMap<String, Int>()
    _ = map.put("a", 1); _ = map.put("b", 2)
    map.clear()
    #expect(map.size() == 0)
    #expect(map.isEmpty())
  }

  @Test("putAll copies all entries from another map")
  func testPutAll() {
    let source = java.util.LinkedHashMap<String, Int>()
    _ = source.put("x", 10); _ = source.put("y", 20)
    let dest = java.util.LinkedHashMap<String, Int>()
    dest.putAll(source)
    #expect(dest.size() == 2)
    #expect(dest.get("x") == 10)
    #expect(dest.get("y") == 20)
  }
}
