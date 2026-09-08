/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

// MARK: - Vector fail-fast iteration (ConcurrentModificationException)
//
// See Util-Implementierung.md priority section: `java.util.Vector` now tracks
// a `modCount` structural-modification counter, bumped under the same `lock`
// as every structural mutation (add/insert/remove/clear). `iterator()`/
// `listIterator()` snapshot `modCount` atomically together with the element
// data, and the returned snapshot-based iterators compare against it on
// every access.

struct JavApi_util_Vector_ConcurrentModificationTests {

  @Test("Adding an element to the vector while an iterator is live throws ConcurrentModificationException on next()")
  func iteratorNextThrowsAfterExternalAdd() throws {
    let v = java.util.Vector<Int>()
    _ = try v.add(1)
    _ = try v.add(2)
    let it = v.iterator()
    _ = try it.next()
    _ = try v.add(3)
    #expect(throws: java.util.ConcurrentModificationException.self) {
      _ = try it.next()
    }
  }

  @Test("Removing an element (by index) from the vector while an iterator is live throws ConcurrentModificationException on next()")
  func iteratorNextThrowsAfterExternalRemoveByIndex() throws {
    let v = java.util.Vector<Int>()
    _ = try v.add(1)
    _ = try v.add(2)
    _ = try v.add(3)
    let it = v.iterator()
    _ = try it.next()
    _ = try v.remove(0)
    #expect(throws: java.util.ConcurrentModificationException.self) {
      _ = try it.next()
    }
  }

  @Test("Clearing the vector while an iterator is live throws ConcurrentModificationException on next()")
  func iteratorNextThrowsAfterExternalClear() throws {
    let v = java.util.Vector<Int>()
    _ = try v.add(1)
    _ = try v.add(2)
    let it = v.iterator()
    #expect(it.hasNext() == true)
    v.removeAllElements()
    #expect(throws: java.util.ConcurrentModificationException.self) {
      _ = try it.next()
    }
  }

  @Test("The iterator's remove() throws IllegalStateException when unmodified (Vector's snapshot iterator never supports removal)")
  func iteratorRemoveThrowsIllegalStateWhenUnmodified() throws {
    let v = java.util.Vector<Int>()
    _ = try v.add(1)
    let it = v.iterator()
    _ = try it.next()
    #expect(throws: java.lang.IllegalStateException.self) {
      try it.remove()
    }
  }

  @Test("The iterator's remove() throws ConcurrentModificationException instead when the vector was modified first")
  func iteratorRemoveThrowsCMEWhenModified() throws {
    let v = java.util.Vector<Int>()
    _ = try v.add(1)
    _ = try v.add(2)
    let it = v.iterator()
    _ = try it.next()
    _ = try v.add(3)
    #expect(throws: java.util.ConcurrentModificationException.self) {
      try it.remove()
    }
  }

  @Test("Adding an element while a ListIterator is live throws ConcurrentModificationException on next()")
  func listIteratorNextThrowsAfterExternalAdd() throws {
    let v = java.util.Vector<Int>()
    _ = try v.add(1)
    _ = try v.add(2)
    let it = v.listIterator()
    _ = try it.next()
    _ = try v.add(3)
    #expect(throws: java.util.ConcurrentModificationException.self) {
      _ = try it.next()
    }
  }

  @Test("Adding an element while a ListIterator is live also throws ConcurrentModificationException on previous()")
  func listIteratorPreviousThrowsAfterExternalAdd() throws {
    let v = java.util.Vector<Int>()
    _ = try v.add(1)
    _ = try v.add(2)
    let it = v.listIterator()
    _ = try it.next()
    _ = try v.add(3)
    #expect(throws: java.util.ConcurrentModificationException.self) {
      _ = try it.previous()
    }
  }
}
