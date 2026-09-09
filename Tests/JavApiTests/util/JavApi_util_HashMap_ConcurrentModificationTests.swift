/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

// MARK: - HashMap fail-fast iteration (ConcurrentModificationException)
//
// See Util-Implementierung.md priority section: `java.util.HashMap` now
// tracks a `modCount` structural-modification counter, bumped only when a
// key is actually inserted or removed — never on a pure value replacement
// for an already-present key (verified against the OpenJDK source: `put`'s
// `putVal` only bumps `modCount` when inserting a brand-new node;
// `replace`/`computeIfPresent`'s update path and `merge`'s update path all
// mutate the existing node's value in place without touching it).
//
// `keySet()`/`entrySet()`/`values()` return disconnected snapshot copies in
// this port (a pre-existing design choice — see
// MapView+ConcurrentModification.swift), but their iterators still check
// the *originating* map's `modCount`, so `for k in map.keySet() { map.put(...) }`
// still throws `ConcurrentModificationException` as Java guarantees.

struct JavApi_util_HashMap_ConcurrentModificationTests {

  @Test("Putting a new key while iterating keySet() throws ConcurrentModificationException on next()")
  func keySetNextThrowsAfterExternalPutNewKey() throws {
    let map = java.util.HashMap<Int, String>()
    _ = map.put(1, "a")
    _ = map.put(2, "b")
    let it = map.keySet().iterator()
    _ = try it.next()
    _ = map.put(3, "c") // new key -> structural
    #expect(throws: java.util.ConcurrentModificationException.self) {
      _ = try it.next()
    }
  }

  @Test("Replacing the value of an already-present key via put() does NOT trigger ConcurrentModificationException")
  func keySetNextNotAffectedByValueReplaceViaPut() throws {
    let map = java.util.HashMap<Int, String>()
    _ = map.put(1, "a")
    _ = map.put(2, "b")
    let it = map.keySet().iterator()
    _ = try it.next()
    _ = map.put(1, "updated") // key already present -> not structural
    _ = try it.next() // must not throw
    #expect(!it.hasNext())
  }

  @Test("Removing a key while iterating entrySet() throws ConcurrentModificationException on next()")
  func entrySetNextThrowsAfterExternalRemove() throws {
    let map = java.util.HashMap<Int, String>()
    _ = map.put(1, "a")
    _ = map.put(2, "b")
    _ = map.put(3, "c")
    let it = map.entrySet().iterator()
    _ = try it.next()
    _ = map.remove(1)
    #expect(throws: java.util.ConcurrentModificationException.self) {
      _ = try it.next()
    }
  }

  @Test("Clearing the map while iterating values() throws ConcurrentModificationException on next()")
  func valuesNextThrowsAfterExternalClear() throws {
    let map = java.util.HashMap<Int, String>()
    _ = map.put(1, "a")
    _ = map.put(2, "b")
    let it = map.values().iterator()
    #expect(it.hasNext() == true)
    map.clear()
    #expect(throws: java.util.ConcurrentModificationException.self) {
      _ = try it.next()
    }
  }

  @Test("replace(_:_:) on an existing key does NOT trigger ConcurrentModificationException (non-structural)")
  func replaceDoesNotTriggerCME() throws {
    let map = java.util.HashMap<Int, String>()
    _ = map.put(1, "a")
    _ = map.put(2, "b")
    let it = map.keySet().iterator()
    _ = try it.next()
    _ = map.replace(1, "updated")
    _ = try it.next()
    #expect(!it.hasNext())
  }

  @Test("putIfAbsent inserting a genuinely new key throws ConcurrentModificationException on a live iterator")
  func putIfAbsentNewKeyTriggersCME() throws {
    let map = java.util.HashMap<Int, String>()
    _ = map.put(1, "a")
    let it = map.keySet().iterator()
    _ = try it.next()
    _ = map.putIfAbsent(2, "b") // 2 absent -> structural insert
    #expect(throws: java.util.ConcurrentModificationException.self) {
      _ = try it.next()
    }
  }

  @Test("putIfAbsent on an already-present key does NOT trigger ConcurrentModificationException")
  func putIfAbsentExistingKeyDoesNotTriggerCME() throws {
    let map = java.util.HashMap<Int, String>()
    _ = map.put(1, "a")
    _ = map.put(2, "b")
    let it = map.keySet().iterator()
    _ = try it.next()
    _ = map.putIfAbsent(1, "ignored") // 1 already present -> no-op, not structural
    _ = try it.next()
    #expect(!it.hasNext())
  }

  @Test("merge() that only updates an existing value does NOT trigger ConcurrentModificationException")
  func mergeUpdateOnlyDoesNotTriggerCME() throws {
    let map = java.util.HashMap<Int, Int>()
    _ = map.put(1, 10)
    _ = map.put(2, 20)
    let it = map.keySet().iterator()
    _ = try it.next()
    _ = map.merge(1, 5) { old, new in old + new } // key already present -> value update only
    _ = try it.next()
    #expect(!it.hasNext())
  }

  @Test("merge() that removes a key (remapping function returns nil) throws ConcurrentModificationException")
  func mergeRemovalTriggersCME() throws {
    let map = java.util.HashMap<Int, Int>()
    _ = map.put(1, 10)
    _ = map.put(2, 20)
    let it = map.keySet().iterator()
    _ = try it.next()
    _ = map.merge(1, 5) { _, _ in nil } // removes key 1 -> structural
    #expect(throws: java.util.ConcurrentModificationException.self) {
      _ = try it.next()
    }
  }

  @Test("compute() that only updates an existing value does NOT trigger ConcurrentModificationException")
  func computeUpdateOnlyDoesNotTriggerCME() throws {
    let map = java.util.HashMap<Int, Int>()
    _ = map.put(1, 10)
    _ = map.put(2, 20)
    let it = map.keySet().iterator()
    _ = try it.next()
    _ = map.compute(1) { _, old in (old ?? 0) + 1 } // key present -> value update only
    _ = try it.next()
    #expect(!it.hasNext())
  }

  @Test("compute() that inserts a new key throws ConcurrentModificationException on a live iterator")
  func computeInsertTriggersCME() throws {
    let map = java.util.HashMap<Int, Int>()
    _ = map.put(1, 10)
    let it = map.keySet().iterator()
    _ = try it.next()
    _ = map.compute(2) { _, old in (old ?? 0) + 1 } // key absent -> structural insert
    #expect(throws: java.util.ConcurrentModificationException.self) {
      _ = try it.next()
    }
  }
}
