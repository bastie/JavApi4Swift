/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

// MARK: - HashSet fail-fast iteration (ConcurrentModificationException)
//
// See Util-Implementierung.md priority section: `java.util.HashSet` now tracks
// a `modCount` structural-modification counter (bumped only when add/remove
// actually change membership, or on clear()). Its iterator() returns a
// *snapshot* array (so a missed check would never crash), but still checks
// `modCount` on every next()/remove() to honour Java's fail-fast guarantee.
// Iteration order is unspecified for HashSet, so these tests avoid depending
// on which element is returned first.

struct JavApi_util_HashSet_ConcurrentModificationTests {

  @Test("Adding a new element to the set while an iterator is live throws ConcurrentModificationException on next()")
  func iteratorNextThrowsAfterExternalAdd() throws {
    let set = java.util.HashSet<Int>()
    try set.add(1)
    try set.add(2)
    let it = set.iterator()
    _ = try it.next()
    try set.add(3) // structural: 3 was absent
    #expect(throws: java.util.ConcurrentModificationException.self) {
      _ = try it.next()
    }
  }

  @Test("Removing an element from the set while an iterator is live throws ConcurrentModificationException on next()")
  func iteratorNextThrowsAfterExternalRemove() throws {
    let set = java.util.HashSet<Int>()
    try set.add(1)
    try set.add(2)
    try set.add(3)
    let it = set.iterator()
    _ = try it.next()
    #expect(set.remove(1) == true)
    #expect(throws: java.util.ConcurrentModificationException.self) {
      _ = try it.next()
    }
  }

  @Test("Clearing the set while an iterator is live throws ConcurrentModificationException on next()")
  func iteratorNextThrowsAfterExternalClear() throws {
    let set = java.util.HashSet<Int>()
    try set.add(1)
    try set.add(2)
    let it = set.iterator()
    #expect(it.hasNext() == true)
    set.clear()
    #expect(throws: java.util.ConcurrentModificationException.self) {
      _ = try it.next()
    }
  }

  @Test("Re-adding an already-present element does NOT trigger ConcurrentModificationException (non-structural)")
  func reAddingExistingElementDoesNotTriggerCME() throws {
    let set = java.util.HashSet<Int>()
    try set.add(1)
    try set.add(2)
    try set.add(3)
    let it = set.iterator()
    _ = try it.next()
    let wasNew = try set.add(2) // 2 is already present -> non-structural, no modCount bump
    #expect(wasNew == false)
    // Must be able to keep consuming the snapshot without CME.
    _ = try it.next()
    _ = try it.next()
    #expect(!it.hasNext())
  }

  @Test("The iterator's remove() throws IllegalStateException when unmodified (HashSet's snapshot iterator never supports removal)")
  func iteratorRemoveThrowsIllegalStateWhenUnmodified() throws {
    let set = java.util.HashSet<Int>()
    try set.add(1)
    let it = set.iterator()
    _ = try it.next()
    #expect(throws: java.lang.IllegalStateException.self) {
      try it.remove()
    }
  }

  @Test("The iterator's remove() throws ConcurrentModificationException instead when the set was modified first")
  func iteratorRemoveThrowsCMEWhenModified() throws {
    let set = java.util.HashSet<Int>()
    try set.add(1)
    try set.add(2)
    let it = set.iterator()
    _ = try it.next()
    try set.add(3)
    #expect(throws: java.util.ConcurrentModificationException.self) {
      try it.remove()
    }
  }
}
