/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

// MARK: - TreeSet fail-fast iteration (ConcurrentModificationException)
//
// See Util-Implementierung.md priority section: `java.util.TreeSet` now
// tracks a `modCount` structural-modification counter (bumped only on an
// actual insert/removal, including via `pollFirst`/`pollLast`, which bypass
// `add`/`remove`). Its `iterator()`/`descendingIterator()` are snapshot
// iterators tied back to the live `TreeSet`'s `modCount`.
//
// Known scope limit (documented in Util-Implementierung.md): `headSet`/
// `tailSet`/`subSet`/`descendingSet` are pre-existing disconnected snapshots
// in this port, unrelated to this CME work — their own iterators never throw
// ConcurrentModificationException regardless of source-set changes, and that
// is unchanged. Elements are sorted, so these tests can assert on order.

struct JavApi_util_TreeSet_ConcurrentModificationTests {

  @Test("Adding a new element while an iterator is live throws ConcurrentModificationException on next()")
  func iteratorNextThrowsAfterExternalAdd() throws {
    let set = java.util.TreeSet<Int>()
    _ = try set.add(2)
    _ = try set.add(1)
    let it = set.iterator()
    #expect(try it.next() == 1) // sorted order guaranteed
    _ = try set.add(3)
    #expect(throws: java.util.ConcurrentModificationException.self) {
      _ = try it.next()
    }
  }

  @Test("Adding an already-present element does NOT trigger ConcurrentModificationException (non-structural)")
  func addingDuplicateDoesNotTriggerCME() throws {
    let set = java.util.TreeSet<Int>()
    _ = try set.add(1)
    _ = try set.add(2)
    let it = set.iterator()
    #expect(try it.next() == 1)
    let added = try set.add(2) // already present -> no-op
    #expect(added == false)
    #expect(try it.next() == 2)
    #expect(!it.hasNext())
  }

  @Test("Removing an element while an iterator is live throws ConcurrentModificationException on next()")
  func iteratorNextThrowsAfterExternalRemove() throws {
    let set = java.util.TreeSet<Int>()
    _ = try set.add(1)
    _ = try set.add(2)
    _ = try set.add(3)
    let it = set.iterator()
    _ = try it.next()
    #expect(set.remove(2) == true)
    #expect(throws: java.util.ConcurrentModificationException.self) {
      _ = try it.next()
    }
  }

  @Test("Clearing the set while an iterator is live throws ConcurrentModificationException on next()")
  func iteratorNextThrowsAfterExternalClear() throws {
    let set = java.util.TreeSet<Int>()
    _ = try set.add(1)
    _ = try set.add(2)
    let it = set.iterator()
    #expect(it.hasNext() == true)
    set.clear()
    #expect(throws: java.util.ConcurrentModificationException.self) {
      _ = try it.next()
    }
  }

  @Test("pollFirst() while an iterator is live throws ConcurrentModificationException on next()")
  func iteratorNextThrowsAfterExternalPollFirst() throws {
    let set = java.util.TreeSet<Int>()
    _ = try set.add(1)
    _ = try set.add(2)
    _ = try set.add(3)
    let it = set.iterator()
    _ = try it.next()
    #expect(set.pollFirst() == 1)
    #expect(throws: java.util.ConcurrentModificationException.self) {
      _ = try it.next()
    }
  }

  @Test("Adding an element while a descendingIterator() is live throws ConcurrentModificationException on next()")
  func descendingIteratorNextThrowsAfterExternalAdd() throws {
    let set = java.util.TreeSet<Int>()
    _ = try set.add(1)
    _ = try set.add(2)
    let it = set.descendingIterator()
    #expect(try it.next() == 2) // descending order
    _ = try set.add(3)
    #expect(throws: java.util.ConcurrentModificationException.self) {
      _ = try it.next()
    }
  }

  @Test("The iterator's remove() throws IllegalStateException when unmodified (TreeSet's snapshot iterator never supports removal)")
  func iteratorRemoveThrowsIllegalStateWhenUnmodified() throws {
    let set = java.util.TreeSet<Int>()
    _ = try set.add(1)
    let it = set.iterator()
    _ = try it.next()
    #expect(throws: java.lang.IllegalStateException.self) {
      try it.remove()
    }
  }

  @Test("The iterator's remove() throws ConcurrentModificationException instead when the set was modified first")
  func iteratorRemoveThrowsCMEWhenModified() throws {
    let set = java.util.TreeSet<Int>()
    _ = try set.add(1)
    _ = try set.add(2)
    let it = set.iterator()
    _ = try it.next()
    _ = try set.add(3)
    #expect(throws: java.util.ConcurrentModificationException.self) {
      try it.remove()
    }
  }
}
