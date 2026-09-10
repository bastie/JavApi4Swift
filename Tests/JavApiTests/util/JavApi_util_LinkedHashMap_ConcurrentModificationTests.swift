/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

// MARK: - LinkedHashMap fail-fast iteration (ConcurrentModificationException)
//
// See JavApi_util_HashMap_ConcurrentModificationTests.swift for the general
// rationale (same modCount semantics, same snapshot-view-but-still-checked
// design). LinkedHashMap additionally exercises `putFirst`/`putLast` (Java 21
// SequencedMap), which this port always treats as structural — even when
// only moving an already-present key — since it changes the encounter order.

struct JavApi_util_LinkedHashMap_ConcurrentModificationTests {

  @Test("Putting a new key while iterating keySet() throws ConcurrentModificationException on next()")
  func keySetNextThrowsAfterExternalPutNewKey() throws {
    let map = java.util.LinkedHashMap<Int, String>()
    _ = map.put(1, "a")
    _ = map.put(2, "b")
    let it = map.keySet().iterator()
    #expect(try it.next() == 1) // insertion order guaranteed
    _ = map.put(3, "c")
    #expect(throws: java.util.ConcurrentModificationException.self) {
      _ = try it.next()
    }
  }

  @Test("Replacing the value of an already-present key does NOT trigger ConcurrentModificationException")
  func keySetNextNotAffectedByValueReplace() throws {
    let map = java.util.LinkedHashMap<Int, String>()
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
    let map = java.util.LinkedHashMap<Int, String>()
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
    let map = java.util.LinkedHashMap<Int, String>()
    _ = map.put(1, "a")
    _ = map.put(2, "b")
    let it = map.values().iterator()
    #expect(it.hasNext() == true)
    map.clear()
    #expect(throws: java.util.ConcurrentModificationException.self) {
      _ = try it.next()
    }
  }

  @Test("putFirst(_:_:) while iterating keySet() throws ConcurrentModificationException, even for an already-present key")
  func putFirstMovingExistingKeyTriggersCME() throws {
    let map = java.util.LinkedHashMap<Int, String>()
    _ = map.put(1, "a")
    _ = map.put(2, "b")
    let it = map.keySet().iterator()
    _ = try it.next()
    _ = try map.putFirst(2, "moved") // moves an existing key -> still structural (reorders)
    #expect(throws: java.util.ConcurrentModificationException.self) {
      _ = try it.next()
    }
  }

  @Test("putLast(_:_:) inserting a new key while iterating keySet() throws ConcurrentModificationException")
  func putLastNewKeyTriggersCME() throws {
    let map = java.util.LinkedHashMap<Int, String>()
    _ = map.put(1, "a")
    let it = map.keySet().iterator()
    _ = try it.next()
    _ = try map.putLast(2, "b")
    #expect(throws: java.util.ConcurrentModificationException.self) {
      _ = try it.next()
    }
  }

  @Test("pollFirstEntry() while iterating keySet() throws ConcurrentModificationException")
  func pollFirstEntryTriggersCME() throws {
    let map = java.util.LinkedHashMap<Int, String>()
    _ = map.put(1, "a")
    _ = map.put(2, "b")
    let it = map.keySet().iterator()
    _ = try it.next()
    _ = map.pollFirstEntry()
    #expect(throws: java.util.ConcurrentModificationException.self) {
      _ = try it.next()
    }
  }

  // MARK: - sequencedKeySet() / sequencedValues() / sequencedEntrySet() (Java 21 SequencedMap)

  @Test("Putting a new key while iterating sequencedKeySet() throws ConcurrentModificationException on next()")
  func sequencedKeySetNextThrowsAfterExternalPutNewKey() throws {
    let map = java.util.LinkedHashMap<Int, String>()
    _ = map.put(1, "a")
    _ = map.put(2, "b")
    let it = map.sequencedKeySet().iterator()
    #expect(try it.next() == 1) // insertion order guaranteed
    _ = map.put(3, "c")
    #expect(throws: java.util.ConcurrentModificationException.self) {
      _ = try it.next()
    }
  }

  @Test("Replacing the value of an already-present key does NOT trigger ConcurrentModificationException on sequencedKeySet()")
  func sequencedKeySetNotAffectedByValueReplace() throws {
    let map = java.util.LinkedHashMap<Int, String>()
    _ = map.put(1, "a")
    _ = map.put(2, "b")
    let it = map.sequencedKeySet().iterator()
    #expect(try it.next() == 1)
    _ = map.put(1, "updated")
    #expect(try it.next() == 2)
    #expect(!it.hasNext())
  }

  @Test("Removing a key while iterating sequencedValues() throws ConcurrentModificationException on next()")
  func sequencedValuesNextThrowsAfterExternalRemove() throws {
    let map = java.util.LinkedHashMap<Int, String>()
    _ = map.put(1, "a")
    _ = map.put(2, "b")
    let it = map.sequencedValues().iterator()
    _ = try it.next()
    _ = map.remove(1)
    #expect(throws: java.util.ConcurrentModificationException.self) {
      _ = try it.next()
    }
  }

  @Test("Clearing the map while iterating sequencedEntrySet() throws ConcurrentModificationException on next()")
  func sequencedEntrySetNextThrowsAfterExternalClear() throws {
    let map = java.util.LinkedHashMap<Int, String>()
    _ = map.put(1, "a")
    _ = map.put(2, "b")
    let it = map.sequencedEntrySet().iterator()
    #expect(it.hasNext() == true)
    map.clear()
    #expect(throws: java.util.ConcurrentModificationException.self) {
      _ = try it.next()
    }
  }
}
