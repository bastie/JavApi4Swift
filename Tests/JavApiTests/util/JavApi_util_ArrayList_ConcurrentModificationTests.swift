/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

// MARK: - ArrayList fail-fast iteration (ConcurrentModificationException)
//
// See Text-Implementierung.md priority section: `java.util.ArrayList` (and its
// iterators/list-iterators/sub-list) now track a `modCount` structural-modification
// counter, mirroring `java.util.ArrayList`'s fail-fast semantics. Any structural
// change to the list made outside the live iterator (add/insert/remove/clear, or
// the same through a sub-list view) causes the iterator's next `next()`/`remove()`
// call to throw `ConcurrentModificationException` instead of silently producing
// wrong results or crashing.

struct JavApi_util_ArrayList_ConcurrentModificationTests {

  // MARK: - Iterator (forward-only)

  @Test("Adding to the list while a plain iterator is live throws ConcurrentModificationException on next()")
  func iteratorNextThrowsAfterExternalAdd() throws {
    let list = java.util.ArrayList<Int>()
    try list.add(1)
    try list.add(2)
    let it = list.iterator()
    _ = try it.next() // consume "1" — iterator now holds a valid expectedModCount snapshot
    try list.add(3) // external structural modification
    #expect(throws: java.util.ConcurrentModificationException.self) {
      _ = try it.next()
    }
  }

  @Test("Removing from the list (by index) while a plain iterator is live throws ConcurrentModificationException on next()")
  func iteratorNextThrowsAfterExternalRemoveByIndex() throws {
    let list = java.util.ArrayList<Int>()
    try list.add(1)
    try list.add(2)
    try list.add(3)
    let it = list.iterator()
    _ = try it.next()
    _ = try list.remove(0) // external structural modification
    #expect(throws: java.util.ConcurrentModificationException.self) {
      _ = try it.next()
    }
  }

  @Test("Removing from the list (by element) while a plain iterator is live throws ConcurrentModificationException on next()")
  func iteratorNextThrowsAfterExternalRemoveByElement() throws {
    let list = java.util.ArrayList<Int>()
    try list.add(1)
    try list.add(2)
    try list.add(3)
    let it = list.iterator()
    _ = try it.next()
    // `3` alone is ambiguous between remove(_ location: Int) throws -> E? and
    // remove(_ element: E?) -> Bool since E == Int here — force the element
    // overload explicitly with `as Int?`.
    #expect(list.remove(3 as Int?) == true) // external structural modification
    #expect(throws: java.util.ConcurrentModificationException.self) {
      _ = try it.next()
    }
  }

  @Test("Clearing the list while a plain iterator is live throws ConcurrentModificationException on next()")
  func iteratorNextThrowsAfterExternalClear() throws {
    let list = java.util.ArrayList<Int>()
    try list.add(1)
    try list.add(2)
    let it = list.iterator()
    #expect(it.hasNext() == true)
    list.clear() // external structural modification
    #expect(throws: java.util.ConcurrentModificationException.self) {
      _ = try it.next()
    }
  }

  @Test("The iterator's own remove() does NOT trip its own fail-fast check")
  func iteratorOwnRemoveDoesNotThrow() throws {
    let list = java.util.ArrayList<Int>()
    try list.add(1)
    try list.add(2)
    try list.add(3)
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
    let list = java.util.ArrayList<Int>()
    try list.add(1)
    let it = list.iterator()
    #expect(throws: java.lang.IllegalStateException.self) {
      try it.remove()
    }
  }

  @Test("Replacing an element via set(_:_:) does NOT trip a live iterator (non-structural)")
  func setDoesNotTriggerConcurrentModification() throws {
    let list = java.util.ArrayList<Int>()
    try list.add(1)
    try list.add(2)
    let it = list.iterator()
    _ = try it.next()
    _ = try list.set(1, 99) // non-structural — must NOT bump modCount
    let second = try it.next()
    #expect(second == 99)
  }

  // MARK: - ListIterator

  @Test("Adding to the list while a ListIterator is live throws ConcurrentModificationException on next()")
  func listIteratorNextThrowsAfterExternalAdd() throws {
    let list = java.util.ArrayList<Int>()
    try list.add(1)
    try list.add(2)
    let it = list.listIterator()
    _ = try it.next()
    try list.add(3)
    #expect(throws: java.util.ConcurrentModificationException.self) {
      _ = try it.next()
    }
  }

  @Test("ListIterator.add(_:) does NOT trip its own fail-fast check, but a second, independent iterator does observe it")
  func listIteratorOwnAddDoesNotThrowButOtherIteratorDoes() throws {
    let list = java.util.ArrayList<Int>()
    try list.add(1)
    try list.add(2)
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

  @Test("Adding to the list while a ListIterator is live also throws ConcurrentModificationException on previous()")
  func listIteratorPreviousThrowsAfterExternalAdd() throws {
    let list = java.util.ArrayList<Int>()
    try list.add(1)
    try list.add(2)
    let it = list.listIterator()
    _ = try it.next() // 1
    _ = try it.next() // 2
    try list.add(3) // external structural modification
    #expect(throws: java.util.ConcurrentModificationException.self) {
      _ = try it.previous()
    }
  }

  // MARK: - SubList

  @Test("Structurally modifying the backing list while iterating its subList throws ConcurrentModificationException")
  func subListIteratorThrowsAfterExternalBackingModification() throws {
    let list = java.util.ArrayList<Int>()
    try list.add(1)
    try list.add(2)
    try list.add(3)
    try list.add(4)
    let sub = list.subList(1, 3) as! ArrayListSubList<Int>   // view over [2, 3]
    let it = sub.iterator()
    _ = try it.next() // 2
    try list.add(99) // structural modification on the BACKING list, bypassing the view
    #expect(throws: java.util.ConcurrentModificationException.self) {
      _ = try it.next()
    }
  }

  @Test("Structurally modifying the backing list while iterating its subList's ListIterator also throws ConcurrentModificationException on previous()")
  func subListListIteratorPreviousThrowsAfterExternalBackingModification() throws {
    let list = java.util.ArrayList<Int>()
    try list.add(1)
    try list.add(2)
    try list.add(3)
    try list.add(4)
    let sub = list.subList(1, 3) as! ArrayListSubList<Int>   // view over [2, 3]
    let it = sub.listIterator()
    _ = try it.next() // 2
    try list.add(99) // structural modification on the BACKING list, bypassing the view
    #expect(throws: java.util.ConcurrentModificationException.self) {
      _ = try it.previous()
    }
  }
}
