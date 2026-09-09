/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

// MARK: - PriorityQueue fail-fast iteration (ConcurrentModificationException)
//
// See Util-Implementierung.md priority section: `java.util.PriorityQueue`
// now tracks a `modCount` structural-modification counter, bumped inside the
// two shared heap primitives `_heapPush`/`_heapPop` (every insertion/removal
// funnels through one of these two), plus `clear()` and the linear-scan
// `remove(_ element:)`. `iterator()` returns a heap-storage-order snapshot
// (matching Java's documented "no particular order" guarantee for
// PriorityQueue.iterator()), but the snapshot iterator still checks the
// *originating* queue's `modCount`.

struct JavApi_util_PriorityQueue_ConcurrentModificationTests {

  @Test("Adding an element while an iterator is live throws ConcurrentModificationException on next()")
  func iteratorNextThrowsAfterExternalAdd() throws {
    let q = java.util.PriorityQueue<Int>()
    _ = try q.add(5)
    _ = try q.add(3)
    let it = q.iterator()
    _ = try it.next()
    _ = try q.add(1) // external structural modification
    #expect(throws: java.util.ConcurrentModificationException.self) {
      _ = try it.next()
    }
  }

  @Test("offer(_:) while an iterator is live throws ConcurrentModificationException on next()")
  func iteratorNextThrowsAfterExternalOffer() throws {
    let q = java.util.PriorityQueue<Int>()
    _ = try q.add(5)
    _ = try q.add(3)
    let it = q.iterator()
    _ = try it.next()
    #expect(q.offer(1) == true) // external structural modification
    #expect(throws: java.util.ConcurrentModificationException.self) {
      _ = try it.next()
    }
  }

  @Test("poll()/remove() while an iterator is live throws ConcurrentModificationException on next()")
  func iteratorNextThrowsAfterExternalPoll() throws {
    let q = java.util.PriorityQueue<Int>()
    _ = try q.add(5)
    _ = try q.add(3)
    _ = try q.add(1)
    let it = q.iterator()
    _ = try it.next()
    #expect(q.poll() == 1) // head is the smallest -> external structural modification
    #expect(throws: java.util.ConcurrentModificationException.self) {
      _ = try it.next()
    }
  }

  @Test("Clearing the queue while an iterator is live throws ConcurrentModificationException on next()")
  func iteratorNextThrowsAfterExternalClear() throws {
    let q = java.util.PriorityQueue<Int>()
    _ = try q.add(5)
    _ = try q.add(3)
    let it = q.iterator()
    #expect(it.hasNext() == true)
    q.clear() // external structural modification
    #expect(throws: java.util.ConcurrentModificationException.self) {
      _ = try it.next()
    }
  }

  @Test("remove(_:) of a present element while an iterator is live throws ConcurrentModificationException")
  func iteratorNextThrowsAfterExternalRemoveElement() throws {
    let q = java.util.PriorityQueue<Int>()
    _ = try q.add(5)
    _ = try q.add(3)
    _ = try q.add(1)
    let it = q.iterator()
    _ = try it.next()
    #expect(q.remove(3) == true) // external structural modification
    #expect(throws: java.util.ConcurrentModificationException.self) {
      _ = try it.next()
    }
  }

  @Test("remove(_:) of an absent element does NOT trigger ConcurrentModificationException (non-structural)")
  func removeOfAbsentElementDoesNotTrigger() throws {
    let q = java.util.PriorityQueue<Int>()
    _ = try q.add(5)
    _ = try q.add(3)
    let it = q.iterator()
    _ = try it.next()
    #expect(q.remove(99) == false) // 99 is absent -> no-op
    _ = try it.next() // must not throw
    #expect(!it.hasNext())
  }

  @Test("Peeking at the head does NOT trigger ConcurrentModificationException (non-structural)")
  func peekDoesNotTrigger() throws {
    let q = java.util.PriorityQueue<Int>()
    _ = try q.add(5)
    _ = try q.add(3)
    let it = q.iterator()
    _ = try it.next()
    #expect(q.peek() == 3) // pure lookup, does not remove
    _ = try it.next() // must not throw
    #expect(!it.hasNext())
  }

  @Test("The iterator's remove() throws IllegalStateException when unmodified (PriorityQueue's snapshot iterator never supports removal)")
  func iteratorRemoveThrowsIllegalStateWhenUnmodified() throws {
    let q = java.util.PriorityQueue<Int>()
    _ = try q.add(1)
    let it = q.iterator()
    _ = try it.next()
    #expect(throws: java.lang.IllegalStateException.self) {
      try it.remove()
    }
  }

  @Test("The iterator's remove() throws ConcurrentModificationException instead when the queue was modified first")
  func iteratorRemoveThrowsCMEWhenModified() throws {
    let q = java.util.PriorityQueue<Int>()
    _ = try q.add(1)
    _ = try q.add(2)
    let it = q.iterator()
    _ = try it.next()
    _ = try q.add(3)
    #expect(throws: java.util.ConcurrentModificationException.self) {
      try it.remove()
    }
  }
}
