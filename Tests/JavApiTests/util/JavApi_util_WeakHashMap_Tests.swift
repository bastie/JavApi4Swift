/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

// Keys must be class types (AnyObject) for WeakHashMap.
private final class Key: Hashable {
  let id: Int
  init(_ id: Int) { self.id = id }
  static func == (lhs: Key, rhs: Key) -> Bool { lhs.id == rhs.id }
  func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

struct JavApi_util_WeakHashMap_Tests {

  @Test("WeakHashMap starts empty")
  func testInitEmpty() {
    let map = java.util.WeakHashMap<Key, String>()
    #expect(map.isEmpty())
    #expect(map.size() == 0)
  }

  @Test("put and get round-trip")
  func testPutGet() {
    let map = java.util.WeakHashMap<Key, String>()
    let k = Key(1)
    map.put(k, "one")
    #expect(map.get(k) == "one")
  }

  @Test("put returns previous value")
  func testPutReturnsPreviousValue() {
    let map = java.util.WeakHashMap<Key, String>()
    let k = Key(2)
    let prev1 = map.put(k, "first")
    #expect(prev1 == nil)
    let prev2 = map.put(k, "second")
    #expect(prev2 == "first")
    #expect(map.get(k) == "second")
  }

  @Test("containsKey returns true for existing key")
  func testContainsKey() {
    let map = java.util.WeakHashMap<Key, String>()
    let k = Key(3)
    map.put(k, "v")
    #expect(map.containsKey(k))
  }

  @Test("containsKey returns false for absent key")
  func testContainsKeyAbsent() {
    let map = java.util.WeakHashMap<Key, String>()
    #expect(!map.containsKey(Key(99)))
  }

  @Test("remove deletes entry and returns old value")
  func testRemove() {
    let map = java.util.WeakHashMap<Key, String>()
    let k = Key(4)
    map.put(k, "val")
    let removed = map.remove(k)
    #expect(removed == "val")
    #expect(map.get(k) == nil)
    #expect(map.isEmpty())
  }

  @Test("clear removes all entries")
  func testClear() {
    let map = java.util.WeakHashMap<Key, String>()
    map.put(Key(1), "a")
    map.put(Key(2), "b")
    map.clear()
    #expect(map.isEmpty())
    #expect(map.size() == 0)
  }

  @Test("size reflects number of entries")
  func testSize() {
    let map = java.util.WeakHashMap<Key, String>()
    let k1 = Key(10)
    let k2 = Key(11)
    map.put(k1, "x")
    map.put(k2, "y")
    #expect(map.size() == 2)
  }

  @Test("entrySet contains all live entries")
  func testEntrySet() {
    let map = java.util.WeakHashMap<Key, String>()
    let k1 = Key(20)
    let k2 = Key(21)
    map.put(k1, "a")
    map.put(k2, "b")
    let entries = map.entrySet()
    #expect(entries.size() == 2)
  }

  @Test("subscript get and set work like put/get")
  func testSubscript() {
    let map = java.util.WeakHashMap<Key, String>()
    let k = Key(30)
    map[k] = "hello"
    #expect(map[k] == "hello")
    map[k] = nil
    #expect(map[k] == nil)
  }

  @Test("purge does not crash on empty map")
  func testPurgeEmpty() {
    let map = java.util.WeakHashMap<Key, String>()
    map.purge()
    #expect(map.isEmpty())
  }
}
