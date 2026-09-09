/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

// MARK: - ArrayDeque fail-fast iteration (ConcurrentModificationException)
//
// See Util-Implementierung.md priority section: `java.util.ArrayDeque` now
// tracks a `modCount` structural-modification counter, bumped on every
// genuinely structural change (element actually added/removed, or clear()).
// `iterator()`/`descendingIterator()` return snapshot copies of the element
// data (a pre-existing design choice in this port), but the snapshot
// iterator still checks the *originating* deque's `modCount`, so
// `for e in deque { deque.addLast(...) }` still throws
// `ConcurrentModificationException` as Java guarantees.

struct JavApi_util_ArrayDeque_ConcurrentModificationTests {

  @Test("Adding to the tail while an iterator is live throws ConcurrentModificationException on next()")
  func iteratorNextThrowsAfterExternalAddLast() throws {
    let d = java.util.ArrayDeque<Int>()
    _ = try d.add(1)
    _ = try d.add(2)
    let it = d.iterator()
    _ = try it.next()
    _ = try d.add(3) // external structural modification
    #expect(throws: java.util.ConcurrentModificationException.self) {
      _ = try it.next()
    }
  }

  @Test("offerFirst while an iterator is live throws ConcurrentModificationException on next()")
  func iteratorNextThrowsAfterExternalOfferFirst() throws {
    let d = java.util.ArrayDeque<Int>()
    _ = try d.add(1)
    _ = try d.add(2)
    let it = d.iterator()
    _ = try it.next()
    #expect(d.offerFirst(0) == true) // external structural modification
    #expect(throws: java.util.ConcurrentModificationException.self) {
      _ = try it.next()
    }
  }

  @Test("removeFirst/removeLast while an iterator is live throws ConcurrentModificationException on next()")
  func iteratorNextThrowsAfterExternalRemoveFirst() throws {
    let d = java.util.ArrayDeque<Int>()
    _ = try d.add(1)
    _ = try d.add(2)
    _ = try d.add(3)
    let it = d.iterator()
    _ = try it.next()
    _ = try d.removeFirst() // external structural modification
    #expect(throws: java.util.ConcurrentModificationException.self) {
      _ = try it.next()
    }
  }

  @Test("pollFirst/pollLast while an iterator is live throws ConcurrentModificationException on next()")
  func iteratorNextThrowsAfterExternalPollLast() throws {
    let d = java.util.ArrayDeque<Int>()
    _ = try d.add(1)
    _ = try d.add(2)
    _ = try d.add(3)
    let it = d.iterator()
    _ = try it.next()
    #expect(d.pollLast() == 3) // external structural modification
    #expect(throws: java.util.ConcurrentModificationException.self) {
      _ = try it.next()
    }
  }

  @Test("pollFirst on an already-empty deque is a true no-op and does NOT trigger ConcurrentModificationException")
  func pollOnEmptyDequeDoesNotBumpModCount() throws {
    let d = java.util.ArrayDeque<Int>()
    _ = try d.add(1)
    _ = d.pollFirst() // removes the only element -> deque is now empty
    let it = d.iterator() // snapshot taken over the now-empty deque
    #expect(d.pollFirst() == nil) // no-op: nothing to remove, must NOT bump modCount
    // If the no-op above had incorrectly bumped modCount, next() would throw
    // ConcurrentModificationException instead of the expected NoSuchElementException.
    #expect(throws: java.util.NoSuchElementException.self) {
      _ = try it.next()
    }
  }

  @Test("Clearing the deque while an iterator is live throws ConcurrentModificationException on next()")
  func iteratorNextThrowsAfterExternalClear() throws {
    let d = java.util.ArrayDeque<Int>()
    _ = try d.add(1)
    _ = try d.add(2)
    let it = d.iterator()
    #expect(it.hasNext() == true)
    d.clear() // external structural modification
    #expect(throws: java.util.ConcurrentModificationException.self) {
      _ = try it.next()
    }
  }

  @Test("removeFirstOccurrence of a present element while an iterator is live throws ConcurrentModificationException")
  func iteratorNextThrowsAfterExternalRemoveFirstOccurrence() throws {
    let d = java.util.ArrayDeque<Int>()
    _ = try d.add(1)
    _ = try d.add(2)
    _ = try d.add(3)
    let it = d.iterator()
    _ = try it.next()
    #expect(d.removeFirstOccurrence(2) == true) // external structural modification
    #expect(throws: java.util.ConcurrentModificationException.self) {
      _ = try it.next()
    }
  }

  @Test("removeFirstOccurrence of an absent element does NOT trigger ConcurrentModificationException (non-structural)")
  func removeFirstOccurrenceOfAbsentElementDoesNotTrigger() throws {
    let d = java.util.ArrayDeque<Int>()
    _ = try d.add(1)
    _ = try d.add(2)
    let it = d.iterator()
    _ = try it.next()
    #expect(d.removeFirstOccurrence(99) == false) // 99 is absent -> no-op
    let second = try it.next()
    #expect(second == 2)
    #expect(!it.hasNext())
  }

  @Test("descendingIterator() throws ConcurrentModificationException after external structural modification")
  func descendingIteratorThrowsAfterExternalModification() throws {
    let d = java.util.ArrayDeque<Int>()
    _ = try d.add(1)
    _ = try d.add(2)
    _ = try d.add(3)
    let it = d.descendingIterator()
    #expect(try it.next() == 3) // tail-to-head order
    _ = try d.add(4) // external structural modification
    #expect(throws: java.util.ConcurrentModificationException.self) {
      _ = try it.next()
    }
  }

  @Test("The iterator's remove() throws IllegalStateException when unmodified (ArrayDeque's snapshot iterator never supports removal)")
  func iteratorRemoveThrowsIllegalStateWhenUnmodified() throws {
    let d = java.util.ArrayDeque<Int>()
    _ = try d.add(1)
    let it = d.iterator()
    _ = try it.next()
    #expect(throws: java.lang.IllegalStateException.self) {
      try it.remove()
    }
  }

  @Test("The iterator's remove() throws ConcurrentModificationException instead when the deque was modified first")
  func iteratorRemoveThrowsCMEWhenModified() throws {
    let d = java.util.ArrayDeque<Int>()
    _ = try d.add(1)
    _ = try d.add(2)
    let it = d.iterator()
    _ = try it.next()
    _ = try d.add(3)
    #expect(throws: java.util.ConcurrentModificationException.self) {
      try it.remove()
    }
  }
}
