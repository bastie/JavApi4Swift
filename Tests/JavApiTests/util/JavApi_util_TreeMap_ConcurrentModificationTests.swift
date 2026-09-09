/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

// MARK: - TreeMap fail-fast iteration (ConcurrentModificationException)
//
// See JavApi_util_HashMap_ConcurrentModificationTests.swift for the general
// rationale. TreeMap's own `put`/`remove`/`clear` were given the same
// modCount treatment; `putIfAbsent`/`replace`/`replace(3-arg)`/`remove(K,V)`
// all inherit this correctly for free since AbstractMap's default
// implementations route through `put()`/`remove()`.
//
// Known scope limit (documented in Util-Implementierung.md): `headMap`/
// `tailMap`/`subMap`/`descendingMap`/`navigableKeySet` and similar
// NavigableMap views are pre-existing disconnected snapshots in this port
// (not live views, unrelated to this CME work), so fail-fast is wired only
// for the core `keySet()`/`entrySet()`/`values()` tested here. Keys are
// sorted, so these tests can assert on iteration order.

struct JavApi_util_TreeMap_ConcurrentModificationTests {

  @Test("Putting a new key while iterating keySet() throws ConcurrentModificationException on next()")
  func keySetNextThrowsAfterExternalPutNewKey() throws {
    let map = java.util.TreeMap<Int, String>()
    _ = map.put(2, "b")
    _ = map.put(1, "a")
    let it = map.keySet().iterator()
    #expect(try it.next() == 1) // sorted order guaranteed
    _ = map.put(3, "c")
    #expect(throws: java.util.ConcurrentModificationException.self) {
      _ = try it.next()
    }
  }

  @Test("Replacing the value of an already-present key via put() does NOT trigger ConcurrentModificationException")
  func keySetNextNotAffectedByValueReplace() throws {
    let map = java.util.TreeMap<Int, String>()
    _ = map.put(1, "a")
    _ = map.put(2, "b")
    let it = map.keySet().iterator()
    #expect(try it.next() == 1)
    _ = map.put(1, "updated")
    #expect(try it.next() == 2)
    #expect(!it.hasNext())
  }

  @Test("Removing a key while iterating entrySet() throws ConcurrentModificationException on next()")
  func entrySetNextThrowsAfterExternalRemove() throws {
    let map = java.util.TreeMap<Int, String>()
    _ = map.put(1, "a")
    _ = map.put(2, "b")
    _ = map.put(3, "c")
    let it = map.entrySet().iterator()
    _ = try it.next()
    _ = map.remove(2)
    #expect(throws: java.util.ConcurrentModificationException.self) {
      _ = try it.next()
    }
  }

  @Test("Clearing the map while iterating values() throws ConcurrentModificationException on next()")
  func valuesNextThrowsAfterExternalClear() throws {
    let map = java.util.TreeMap<Int, String>()
    _ = map.put(1, "a")
    _ = map.put(2, "b")
    let it = map.values().iterator()
    #expect(it.hasNext() == true)
    map.clear()
    #expect(throws: java.util.ConcurrentModificationException.self) {
      _ = try it.next()
    }
  }

  @Test("replace(_:_:) on an existing key does NOT trigger ConcurrentModificationException")
  func replaceDoesNotTriggerCME() throws {
    let map = java.util.TreeMap<Int, String>()
    _ = map.put(1, "a")
    _ = map.put(2, "b")
    let it = map.keySet().iterator()
    #expect(try it.next() == 1)
    _ = map.replace(1, "updated")
    #expect(try it.next() == 2)
    #expect(!it.hasNext())
  }

  @Test("putIfAbsent inserting a genuinely new key throws ConcurrentModificationException on a live iterator")
  func putIfAbsentNewKeyTriggersCME() throws {
    let map = java.util.TreeMap<Int, String>()
    _ = map.put(1, "a")
    let it = map.keySet().iterator()
    _ = try it.next()
    _ = map.putIfAbsent(2, "b")
    #expect(throws: java.util.ConcurrentModificationException.self) {
      _ = try it.next()
    }
  }

  @Test("putIfAbsent on an already-present key does NOT trigger ConcurrentModificationException")
  func putIfAbsentExistingKeyDoesNotTriggerCME() throws {
    let map = java.util.TreeMap<Int, String>()
    _ = map.put(1, "a")
    _ = map.put(2, "b")
    let it = map.keySet().iterator()
    #expect(try it.next() == 1)
    _ = map.putIfAbsent(1, "ignored")
    #expect(try it.next() == 2)
    #expect(!it.hasNext())
  }
}
