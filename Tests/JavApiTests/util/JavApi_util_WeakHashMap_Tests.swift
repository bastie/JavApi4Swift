/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

// WeakHashMap requires class-type (AnyObject) keys.
// A simple reference-type key used throughout these tests.
private final class Key: Hashable {
  let name: String
  init(_ name: String) { self.name = name }
  static func == (lhs: Key, rhs: Key) -> Bool { lhs === rhs }
  func hash(into hasher: inout Hasher) { hasher.combine(ObjectIdentifier(self)) }
}

struct JavApi_util_WeakHashMap_Tests {

  // MARK: - Basic put / get / size / isEmpty

  @Test("empty map has size 0 and isEmpty true")
  func testEmpty() {
    let map = java.util.WeakHashMap<Key, Int>()
    #expect(map.isEmpty())
    #expect(map.size() == 0)
  }

  @Test("put and get round-trip")
  func testPutGet() {
    let map = java.util.WeakHashMap<Key, String>()
    let k = Key("a")
    map.put(k, "hello")
    #expect(map.get(k) == "hello")
    #expect(map.size() == 1)
    #expect(!map.isEmpty())
  }

  @Test("put returns previous value")
  func testPutReturnsPrevious() {
    let map = java.util.WeakHashMap<Key, Int>()
    let k = Key("x")
    let prev1 = map.put(k, 1)
    #expect(prev1 == nil)
    let prev2 = map.put(k, 2)
    #expect(prev2 == 1)
    #expect(map.get(k) == 2)
  }

  @Test("put overwrites existing value")
  func testPutOverwrite() {
    let map = java.util.WeakHashMap<Key, Int>()
    let k = Key("k")
    map.put(k, 10)
    map.put(k, 20)
    #expect(map.get(k) == 20)
    #expect(map.size() == 1)
  }

  // MARK: - containsKey

  @Test("containsKey returns true for present key")
  func testContainsKeyPresent() {
    let map = java.util.WeakHashMap<Key, Int>()
    let k = Key("k")
    map.put(k, 1)
    #expect(map.containsKey(k))
  }

  @Test("containsKey returns false for absent key")
  func testContainsKeyAbsent() {
    let map = java.util.WeakHashMap<Key, Int>()
    let k = Key("missing")
    #expect(!map.containsKey(k))
  }

  // MARK: - remove

  @Test("remove returns value and shrinks map")
  func testRemove() {
    let map = java.util.WeakHashMap<Key, Int>()
    let k = Key("r")
    map.put(k, 42)
    let removed = map.remove(k)
    #expect(removed == 42)
    #expect(map.size() == 0)
    #expect(map.get(k) == nil)
  }

  @Test("remove absent key returns nil")
  func testRemoveAbsent() {
    let map = java.util.WeakHashMap<Key, Int>()
    let k = Key("nope")
    #expect(map.remove(k) == nil)
  }

  // MARK: - clear

  @Test("clear empties the map")
  func testClear() {
    let map = java.util.WeakHashMap<Key, Int>()
    let k1 = Key("a"); let k2 = Key("b")
    map.put(k1, 1); map.put(k2, 2)
    map.clear()
    #expect(map.isEmpty())
    #expect(map.size() == 0)
  }

  // MARK: - Subscript

  @Test("subscript get/set works like put/get")
  func testSubscript() {
    let map = java.util.WeakHashMap<Key, String>()
    let k = Key("s")
    map[k] = "world"
    #expect(map[k] == "world")
  }

  @Test("subscript nil removes entry")
  func testSubscriptNilRemoves() {
    let map = java.util.WeakHashMap<Key, Int>()
    let k = Key("d")
    map[k] = 99
    map[k] = nil
    #expect(map[k] == nil)
    #expect(map.size() == 0)
  }

  // MARK: - entrySet

  @Test("entrySet returns all live entries")
  func testEntrySet() {
    let map = java.util.WeakHashMap<Key, Int>()
    let k1 = Key("a"); let k2 = Key("b")
    map.put(k1, 1); map.put(k2, 2)
    let entries = map.entrySet()
    #expect(entries.count == 2)
    let values = Set(entries.map { $0.value })
    #expect(values == [1, 2])
  }

  // MARK: - Weak semantics

  @Test("entry disappears after key is deallocated")
  func testWeakKeyEviction() {
    let map = java.util.WeakHashMap<Key, Int>()
    var objectId: ObjectIdentifier? = nil
    do {
      let k = Key("temp")
      objectId = ObjectIdentifier(k)
      map.put(k, 123)
      #expect(map.size() == 1)
      // k goes out of scope at end of do-block
    }
    // After k is deallocated, purge() should remove the dead entry.
    map.purge()
    #expect(map.size() == 0)
    _ = objectId  // suppress unused-variable warning
  }

  @Test("multiple keys with independent lifetimes")
  func testMultipleKeyLifetimes() {
    let map = java.util.WeakHashMap<Key, Int>()
    let longLived = Key("persistent")
    map.put(longLived, 1)
    do {
      let shortLived = Key("temporary")
      map.put(shortLived, 2)
      #expect(map.size() == 2)
    }
    map.purge()
    #expect(map.size() == 1)
    #expect(map.get(longLived) == 1)
  }

  // MARK: - initialCapacity

  @Test("initialCapacity constructor produces working map")
  func testInitialCapacity() {
    let map = java.util.WeakHashMap<Key, Int>(initialCapacity: 16)
    let k = Key("cap")
    map.put(k, 7)
    #expect(map.get(k) == 7)
  }
}
