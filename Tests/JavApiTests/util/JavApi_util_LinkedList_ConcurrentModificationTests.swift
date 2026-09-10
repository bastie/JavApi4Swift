/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

// MARK: - LinkedList fail-fast iteration (ConcurrentModificationException)
//
// See Text-Implementierung.md priority section: `java.util.LinkedList` tracks a
// `modCount` structural-modification counter, bumped in its 6 shared node-linking
// helpers (linkFirst/linkLast/linkBefore/unlinkFirst/unlinkLast/unlink) plus
// `clear()`. `LinkedListIterator` (the `ListIterator` returned by `iterator()`/
// `listIterator()`) and `LinkedListDescendingIterator` (`descendingIterator()`)
// both snapshot `expectedModCount` at creation and re-check it on traversal,
// mirroring `java.util.LinkedList`'s fail-fast semantics.
//
// Scope note: `LinkedListDescendingIterator.remove()` is not overridden — it
// always throws `IllegalStateException` via the shared default — so only its
// `next()` is comodification-checked. This is narrower than real Java but does
// not silently produce wrong results.

struct JavApi_util_LinkedList_ConcurrentModificationTests {

  // MARK: - Iterator / ListIterator (forward)

  @Test("Adding to the list while an iterator is live throws ConcurrentModificationException on next()")
  func iteratorNextThrowsAfterExternalAdd() throws {
    let list = java.util.LinkedList<Int>()
    _ = try list.add(1)
    _ = try list.add(2)
    let it = list.iterator()
    _ = try it.next() // 1
    _ = try list.add(3) // external structural modification
    #expect(throws: java.util.ConcurrentModificationException.self) {
      _ = try it.next()
    }
  }

  @Test("addFirst while an iterator is live throws ConcurrentModificationException on next()")
  func iteratorNextThrowsAfterExternalAddFirst() throws {
    let list = java.util.LinkedList<Int>()
    _ = try list.add(1)
    _ = try list.add(2)
    let it = list.iterator()
    _ = try it.next()
    try list.addFirst(0) // external structural modification
    #expect(throws: java.util.ConcurrentModificationException.self) {
      _ = try it.next()
    }
  }

  @Test("Removing by index while an iterator is live throws ConcurrentModificationException on next()")
  func iteratorNextThrowsAfterExternalRemoveByIndex() throws {
    let list = java.util.LinkedList<Int>()
    _ = try list.add(1)
    _ = try list.add(2)
    _ = try list.add(3)
    let it = list.iterator()
    _ = try it.next()
    _ = try list.remove(0) // external structural modification
    #expect(throws: java.util.ConcurrentModificationException.self) {
      _ = try it.next()
    }
  }

  @Test("removeFirst/removeLast while an iterator is live throws ConcurrentModificationException on next()")
  func iteratorNextThrowsAfterExternalRemoveFirst() throws {
    let list = java.util.LinkedList<Int>()
    _ = try list.add(1)
    _ = try list.add(2)
    _ = try list.add(3)
    let it = list.iterator()
    _ = try it.next()
    _ = try list.removeFirst() // external structural modification
    #expect(throws: java.util.ConcurrentModificationException.self) {
      _ = try it.next()
    }
  }

  @Test("pollFirst/pollLast while an iterator is live throws ConcurrentModificationException on next()")
  func iteratorNextThrowsAfterExternalPollLast() throws {
    let list = java.util.LinkedList<Int>()
    _ = try list.add(1)
    _ = try list.add(2)
    _ = try list.add(3)
    let it = list.iterator()
    _ = try it.next()
    _ = list.pollLast() // external structural modification
    #expect(throws: java.util.ConcurrentModificationException.self) {
      _ = try it.next()
    }
  }

  @Test("Clearing the list while an iterator is live throws ConcurrentModificationException on next()")
  func iteratorNextThrowsAfterExternalClear() throws {
    let list = java.util.LinkedList<Int>()
    _ = try list.add(1)
    _ = try list.add(2)
    let it = list.iterator()
    #expect(it.hasNext() == true)
    list.clear() // external structural modification
    #expect(throws: java.util.ConcurrentModificationException.self) {
      _ = try it.next()
    }
  }

  @Test("The iterator's own remove() does NOT trip its own fail-fast check")
  func iteratorOwnRemoveDoesNotThrow() throws {
    let list = java.util.LinkedList<Int>()
    _ = try list.add(1)
    _ = try list.add(2)
    _ = try list.add(3)
    let it = list.iterator()
    _ = try it.next() // 1
    try it.remove()   // removes 1 via the SAME iterator — must not throw
    let second = try it.next()
    #expect(second == 2)
    try it.remove() // removes 2 — must still not throw
    #expect(list.size() == 1 as Int)
    #expect(try list.get(0) == 3)
  }

  @Test("remove() without a preceding next() still throws IllegalStateException, not ConcurrentModificationException")
  func iteratorRemoveWithoutNextThrowsIllegalState() throws {
    let list = java.util.LinkedList<Int>()
    _ = try list.add(1)
    let it = list.iterator()
    #expect(throws: java.lang.IllegalStateException.self) {
      try it.remove()
    }
  }

  @Test("Replacing an element via set(_:) does NOT trip a live iterator (non-structural)")
  func setDoesNotTriggerConcurrentModification() throws {
    let list = java.util.LinkedList<Int>()
    _ = try list.add(1)
    _ = try list.add(2)
    let it = list.listIterator()
    _ = try it.next()
    _ = try list.set(1, 99) // non-structural — must NOT bump modCount
    let second = try it.next()
    #expect(second == 99)
  }

  // MARK: - ListIterator: previous(), add()

  @Test("previous() on a live ListIterator throws ConcurrentModificationException after external modification")
  func listIteratorPreviousThrowsAfterExternalModification() throws {
    let list = java.util.LinkedList<Int>()
    _ = try list.add(1)
    _ = try list.add(2)
    let it = list.listIterator(2)
    _ = try list.add(3) // external structural modification
    #expect(throws: java.util.ConcurrentModificationException.self) {
      _ = try it.previous()
    }
  }

  @Test("ListIterator.add(_:) does NOT trip its own fail-fast check, but a second, independent iterator does observe it")
  func listIteratorOwnAddDoesNotThrowButOtherIteratorDoes() throws {
    let list = java.util.LinkedList<Int>()
    _ = try list.add(1)
    _ = try list.add(2)
    let it = list.listIterator()
    let other = list.iterator()
    _ = try it.next() // 1
    it.add(42) // structural modification via the SAME ListIterator — must not throw
    let afterAdd = try it.next()
    #expect(afterAdd == 2)
    #expect(list.size() == 3 as Int)
    // The independent iterator created before the modification must now observe it.
    #expect(throws: java.util.ConcurrentModificationException.self) {
      _ = try other.next()
    }
  }

  // MARK: - descendingIterator()

  @Test("descendingIterator() throws ConcurrentModificationException after external structural modification")
  func descendingIteratorThrowsAfterExternalModification() throws {
    let list = java.util.LinkedList<Int>()
    _ = try list.add(1)
    _ = try list.add(2)
    _ = try list.add(3)
    let it = list.descendingIterator()
    _ = try it.next() // 3
    _ = try list.add(4) // external structural modification
    #expect(throws: java.util.ConcurrentModificationException.self) {
      _ = try it.next()
    }
  }

  @Test("descendingIterator() does not throw while unmodified, and traverses tail to head")
  func descendingIteratorTraversesInReverse() throws {
    let list = java.util.LinkedList<Int>()
    _ = try list.add(1)
    _ = try list.add(2)
    _ = try list.add(3)
    let it = list.descendingIterator()
    #expect(try it.next() == 3)
    #expect(try it.next() == 2)
    #expect(try it.next() == 1)
  }

  @Test("descendingIterator()'s own remove() removes the last-returned (tail-to-head) element and does not trip its own fail-fast check")
  func descendingIteratorOwnRemoveDoesNotThrow() throws {
    let list = java.util.LinkedList<Int>()
    _ = try list.add(1)
    _ = try list.add(2)
    _ = try list.add(3)
    let it = list.descendingIterator()
    #expect(try it.next() == 3)
    try it.remove() // removes 3 via the SAME iterator — must not throw
    #expect(list.size() == 2 as Int)
    #expect(try it.next() == 2)
    try it.remove() // removes 2 — must still not throw
    #expect(list.size() == 1 as Int)
    #expect(try list.get(0) == 1)
  }

  @Test("descendingIterator()'s remove() without a preceding next() throws IllegalStateException, not ConcurrentModificationException")
  func descendingIteratorRemoveWithoutNextThrowsIllegalState() throws {
    let list = java.util.LinkedList<Int>()
    _ = try list.add(1)
    let it = list.descendingIterator()
    #expect(throws: java.lang.IllegalStateException.self) {
      try it.remove()
    }
  }

  @Test("descendingIterator()'s remove() throws ConcurrentModificationException instead when the list was modified first")
  func descendingIteratorRemoveThrowsCMEWhenModified() throws {
    let list = java.util.LinkedList<Int>()
    _ = try list.add(1)
    _ = try list.add(2)
    let it = list.descendingIterator()
    _ = try it.next() // 2
    _ = try list.add(3) // external structural modification
    #expect(throws: java.util.ConcurrentModificationException.self) {
      try it.remove()
    }
  }
}
