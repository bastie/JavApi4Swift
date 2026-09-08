/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

// MARK: - LinkedHashSet fail-fast iteration (ConcurrentModificationException)
//
// See Util-Implementierung.md priority section: `java.util.LinkedHashSet`
// inherits `HashSet`'s `modCount` field. Its own `add`/`remove`/`clear`
// delegate to `HashSet`'s (already bumping modCount), while `addFirst`/
// `addLast`/`removeFirst`/`removeLast` bypass those and bump `modCount`
// explicitly, since all four are structural. Unlike plain `HashSet`,
// iteration order here is insertion order, so these tests can assert on it.

struct JavApi_util_LinkedHashSet_ConcurrentModificationTests {

  @Test("Adding a new element while an iterator is live throws ConcurrentModificationException on next()")
  func iteratorNextThrowsAfterExternalAdd() throws {
    let set = java.util.LinkedHashSet<Int>()
    try set.add(1)
    try set.add(2)
    let it = set.iterator()
    #expect(try it.next() == 1)
    try set.add(3)
    #expect(throws: java.util.ConcurrentModificationException.self) {
      _ = try it.next()
    }
  }

  @Test("addFirst(_:) while an iterator is live throws ConcurrentModificationException on next()")
  func iteratorNextThrowsAfterExternalAddFirst() throws {
    let set = java.util.LinkedHashSet<Int>()
    try set.add(1)
    try set.add(2)
    let it = set.iterator()
    _ = try it.next()
    try set.addFirst(99)
    #expect(throws: java.util.ConcurrentModificationException.self) {
      _ = try it.next()
    }
  }

  @Test("removeFirst() while an iterator is live throws ConcurrentModificationException on next()")
  func iteratorNextThrowsAfterExternalRemoveFirst() throws {
    let set = java.util.LinkedHashSet<Int>()
    try set.add(1)
    try set.add(2)
    try set.add(3)
    let it = set.iterator()
    _ = try it.next()
    _ = try set.removeFirst()
    #expect(throws: java.util.ConcurrentModificationException.self) {
      _ = try it.next()
    }
  }

  @Test("Clearing the set while an iterator is live throws ConcurrentModificationException on next()")
  func iteratorNextThrowsAfterExternalClear() throws {
    let set = java.util.LinkedHashSet<Int>()
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
    let set = java.util.LinkedHashSet<Int>()
    try set.add(1)
    try set.add(2)
    try set.add(3)
    let it = set.iterator()
    #expect(try it.next() == 1)
    let wasNew = try set.add(2) // 2 is already present -> non-structural
    #expect(wasNew == false)
    #expect(try it.next() == 2)
    #expect(try it.next() == 3)
    #expect(!it.hasNext())
  }

  @Test("The iterator's remove() throws IllegalStateException when unmodified (LinkedHashSet's snapshot iterator never supports removal)")
  func iteratorRemoveThrowsIllegalStateWhenUnmodified() throws {
    let set = java.util.LinkedHashSet<Int>()
    try set.add(1)
    let it = set.iterator()
    _ = try it.next()
    #expect(throws: java.lang.IllegalStateException.self) {
      try it.remove()
    }
  }
}
