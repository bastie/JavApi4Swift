/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

@Suite("java.util.LinkedHashSet")
struct JavApi_util_LinkedHashSet_Tests {

  // MARK: - Basic Set behaviour

  @Test("empty set has size 0")
  func testInitEmpty() {
    let set = java.util.LinkedHashSet<Int>()
    #expect(set.size() == 0)
    #expect(set.isEmpty() == true)
  }

  @Test("add() inserts unique elements and returns true")
  func testAdd() throws {
    let set = java.util.LinkedHashSet<Int>()
    #expect(try set.add(1) == true)
    #expect(try set.add(2) == true)
    #expect(set.size() == 2)
  }

  @Test("add() duplicate returns false and does not increase size")
  func testAddDuplicate() throws {
    let set = java.util.LinkedHashSet<Int>()
    _ = try set.add(42)
    let result = try set.add(42)
    #expect(result == false)
    #expect(set.size() == 1)
  }

  @Test("contains() finds present elements and rejects absent ones")
  func testContains() throws {
    let set = java.util.LinkedHashSet<String>()
    _ = try set.add("hello")
    #expect(set.contains("hello") == true)
    #expect(set.contains("world") == false)
  }

  @Test("remove() deletes element and returns true; absent element returns false")
  func testRemove() throws {
    let set = java.util.LinkedHashSet<Int>()
    _ = try set.add(7)
    #expect(set.remove(7) == true)
    #expect(set.size() == 0)
    #expect(set.remove(7) == false)
  }

  @Test("clear() empties the set")
  func testClear() throws {
    let set = java.util.LinkedHashSet<Int>()
    for v in 1...5 { _ = try set.add(v) }
    set.clear()
    #expect(set.size() == 0)
    #expect(set.isEmpty() == true)
  }

  // MARK: - Insertion order

  @Test("iterator yields elements in insertion order")
  func testInsertionOrder() throws {
    let set = java.util.LinkedHashSet<Int>()
    for v in [5, 3, 8, 1, 9] { _ = try set.add(v) }
    let it = set.iterator()
    var result: [Int] = []
    while it.hasNext() {
      if let e = try? it.next() { result.append(e) }
    }
    #expect(result == [5, 3, 8, 1, 9])
  }

  @Test("insertion order is unaffected by duplicate add attempts")
  func testOrderOnDuplicateAdd() throws {
    let set = java.util.LinkedHashSet<Int>()
    _ = try set.add(1)
    _ = try set.add(2)
    _ = try set.add(1)   // duplicate — should not reorder
    let it = set.iterator()
    var result: [Int] = []
    while it.hasNext() { if let e = try? it.next() { result.append(e) } }
    #expect(result == [1, 2])
  }

  @Test("for-in loop yields elements in insertion order")
  func testForIn() throws {
    let set = java.util.LinkedHashSet<String>()
    for s in ["c", "a", "b"] { _ = try set.add(s) }
    var collected: [String] = []
    for s in set { if let s { collected.append(s) } }
    #expect(collected == ["c", "a", "b"])
  }

  // MARK: - SequencedCollection: getFirst / getLast

  @Test("getFirst() returns first-inserted element")
  func testGetFirst() throws {
    let set = java.util.LinkedHashSet<Int>()
    for v in [10, 20, 30] { _ = try set.add(v) }
    #expect(try set.getFirst() == 10)
  }

  @Test("getLast() returns last-inserted element")
  func testGetLast() throws {
    let set = java.util.LinkedHashSet<Int>()
    for v in [10, 20, 30] { _ = try set.add(v) }
    #expect(try set.getLast() == 30)
  }

  @Test("getFirst() on empty set throws NoSuchElementException")
  func testGetFirstEmpty() {
    let set = java.util.LinkedHashSet<Int>()
    #expect(throws: java.util.NoSuchElementException.self) { try set.getFirst() }
  }

  @Test("getLast() on empty set throws NoSuchElementException")
  func testGetLastEmpty() {
    let set = java.util.LinkedHashSet<Int>()
    #expect(throws: java.util.NoSuchElementException.self) { try set.getLast() }
  }

  // MARK: - SequencedCollection: removeFirst / removeLast

  @Test("removeFirst() removes and returns first element")
  func testRemoveFirst() throws {
    let set = java.util.LinkedHashSet<Int>()
    for v in [1, 2, 3] { _ = try set.add(v) }
    let removed = try set.removeFirst()
    #expect(removed == 1)
    #expect(set.size() == 2)
    #expect(set.contains(1) == false)
    #expect(try set.getFirst() == 2)
  }

  @Test("removeLast() removes and returns last element")
  func testRemoveLast() throws {
    let set = java.util.LinkedHashSet<Int>()
    for v in [1, 2, 3] { _ = try set.add(v) }
    let removed = try set.removeLast()
    #expect(removed == 3)
    #expect(set.size() == 2)
    #expect(set.contains(3) == false)
    #expect(try set.getLast() == 2)
  }

  @Test("removeFirst() on empty set throws NoSuchElementException")
  func testRemoveFirstEmpty() {
    let set = java.util.LinkedHashSet<Int>()
    #expect(throws: java.util.NoSuchElementException.self) { try set.removeFirst() }
  }

  // MARK: - SequencedCollection: addFirst / addLast

  @Test("addFirst() inserts new element at front")
  func testAddFirst() throws {
    let set = java.util.LinkedHashSet<Int>()
    _ = try set.add(2); _ = try set.add(3)
    try set.addFirst(1)
    #expect(try set.getFirst() == 1)
    #expect(set.size() == 3)
  }

  @Test("addFirst() moves existing element to front without duplication")
  func testAddFirstExisting() throws {
    let set = java.util.LinkedHashSet<Int>()
    for v in [1, 2, 3] { _ = try set.add(v) }
    try set.addFirst(3)   // 3 was last — move to front
    #expect(try set.getFirst() == 3)
    #expect(set.size() == 3)   // still 3 elements
    let it = set.iterator()
    var order: [Int] = []
    while it.hasNext() { if let e = try? it.next() { order.append(e) } }
    #expect(order == [3, 1, 2])
  }

  @Test("addLast() inserts new element at end")
  func testAddLast() throws {
    let set = java.util.LinkedHashSet<Int>()
    _ = try set.add(1); _ = try set.add(2)
    try set.addLast(3)
    #expect(try set.getLast() == 3)
    #expect(set.size() == 3)
  }

  @Test("addLast() moves existing element to end without duplication")
  func testAddLastExisting() throws {
    let set = java.util.LinkedHashSet<Int>()
    for v in [1, 2, 3] { _ = try set.add(v) }
    try set.addLast(1)   // 1 was first — move to end
    #expect(try set.getLast() == 1)
    #expect(set.size() == 3)
    let it = set.iterator()
    var order: [Int] = []
    while it.hasNext() { if let e = try? it.next() { order.append(e) } }
    #expect(order == [2, 3, 1])
  }

  // MARK: - SequencedSet: reversed / reversedSet

  @Test("reversed() returns elements in reverse insertion order")
  func testReversed() throws {
    let set = java.util.LinkedHashSet<Int>()
    for v in [1, 2, 3] { _ = try set.add(v) }
    let rev = set.reversed()
    #expect(try rev.getFirst() == 3)
    #expect(try rev.getLast() == 1)
    #expect(rev.size() == 3)
  }

  @Test("reversedSet() returns a SequencedSet in reverse insertion order")
  func testReversedSet() throws {
    let set = java.util.LinkedHashSet<Int>()
    for v in [10, 20, 30] { _ = try set.add(v) }
    let rev = set.reversedSet()
    #expect(try rev.getFirst() == 30)
    #expect(try rev.getLast() == 10)
  }

  // MARK: - Protocol conformance

  @Test("LinkedHashSet conforms to SequencedSet protocol")
  func testSequencedSetConformance() {
    let set: any java.util.SequencedSet<Int> = java.util.LinkedHashSet<Int>()
    #expect(set.size() == 0)
  }

  @Test("LinkedHashSet conforms to Set protocol")
  func testSetConformance() {
    let set: any java.util.Set<Int> = java.util.LinkedHashSet<Int>()
    #expect(set.isEmpty() == true)
  }

  // MARK: - Clone

  @Test("clone() produces independent copy with same insertion order")
  func testClone() throws {
    let original = java.util.LinkedHashSet<Int>()
    for v in [3, 1, 2] { _ = try original.add(v) }
    let copy = original.clone() as! java.util.LinkedHashSet<Int>
    // same order
    #expect(try copy.getFirst() == 3)
    #expect(try copy.getLast() == 2)
    // independent
    _ = try original.add(99)
    #expect(copy.size() == 3)
  }
}
