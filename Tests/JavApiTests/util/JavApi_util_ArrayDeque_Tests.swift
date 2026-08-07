/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

@Suite("java.util.ArrayDeque")
struct JavApi_util_ArrayDeque_Tests {

  // MARK: - Basic state

  @Test("empty deque has size 0")
  func testInitEmpty() {
    let dq = java.util.ArrayDeque<Int>()
    #expect(dq.size() == 0)
    #expect(dq.isEmpty() == true)
  }

  @Test("add() appends to tail")
  func testAddTail() throws {
    let dq = java.util.ArrayDeque<Int>()
    _ = try dq.add(1)
    _ = try dq.add(2)
    _ = try dq.add(3)
    #expect(dq.size() == 3)
    #expect(try dq.getFirst() == 1)
    #expect(try dq.getLast()  == 3)
  }

  // MARK: - addFirst / addLast

  @Test("addFirst() inserts at front")
  func testAddFirst() throws {
    let dq = java.util.ArrayDeque<Int>()
    try dq.addLast(2)
    try dq.addFirst(1)
    #expect(try dq.getFirst() == 1)
    #expect(dq.size() == 2)
  }

  @Test("addLast() appends at tail")
  func testAddLast() throws {
    let dq = java.util.ArrayDeque<Int>()
    try dq.addFirst(1)
    try dq.addLast(2)
    #expect(try dq.getLast() == 2)
    #expect(dq.size() == 2)
  }

  @Test("offerFirst / offerLast always return true")
  func testOfferFirstLast() {
    let dq = java.util.ArrayDeque<Int>()
    #expect(dq.offerFirst(0) == true)
    #expect(dq.offerLast(1)  == true)
    #expect(dq.size() == 2)
  }

  // MARK: - getFirst / getLast

  @Test("getFirst() and getLast() do not remove elements")
  func testPeekSemantics() throws {
    let dq = java.util.ArrayDeque<String>()
    try dq.addLast("a")
    try dq.addLast("b")
    _ = try dq.getFirst()
    _ = try dq.getLast()
    #expect(dq.size() == 2)
  }

  @Test("getFirst() on empty deque throws NoSuchElementException")
  func testGetFirstEmpty() {
    let dq = java.util.ArrayDeque<Int>()
    #expect(throws: java.util.NoSuchElementException.self) { try dq.getFirst() }
  }

  @Test("getLast() on empty deque throws NoSuchElementException")
  func testGetLastEmpty() {
    let dq = java.util.ArrayDeque<Int>()
    #expect(throws: java.util.NoSuchElementException.self) { try dq.getLast() }
  }

  @Test("peekFirst / peekLast return nil on empty deque")
  func testPeekEmpty() {
    let dq = java.util.ArrayDeque<Int>()
    #expect(dq.peekFirst() == nil)
    #expect(dq.peekLast()  == nil)
  }

  // MARK: - removeFirst / removeLast

  @Test("removeFirst() removes and returns head")
  func testRemoveFirst() throws {
    let dq = java.util.ArrayDeque<Int>()
    for v in [10, 20, 30] { try dq.addLast(v) }
    let removed = try dq.removeFirst()
    #expect(removed == 10)
    #expect(dq.size() == 2)
    #expect(try dq.getFirst() == 20)
  }

  @Test("removeLast() removes and returns tail")
  func testRemoveLast() throws {
    let dq = java.util.ArrayDeque<Int>()
    for v in [10, 20, 30] { try dq.addLast(v) }
    let removed = try dq.removeLast()
    #expect(removed == 30)
    #expect(dq.size() == 2)
    #expect(try dq.getLast() == 20)
  }

  @Test("removeFirst() on empty deque throws NoSuchElementException")
  func testRemoveFirstEmpty() {
    let dq = java.util.ArrayDeque<Int>()
    #expect(throws: java.util.NoSuchElementException.self) { try dq.removeFirst() }
  }

  @Test("pollFirst / pollLast return nil on empty deque")
  func testPollEmpty() {
    let dq = java.util.ArrayDeque<Int>()
    #expect(dq.pollFirst() == nil)
    #expect(dq.pollLast()  == nil)
  }

  @Test("pollFirst() removes and returns head, nil when empty")
  func testPollFirst() throws {
    let dq = java.util.ArrayDeque<Int>()
    try dq.addLast(5); try dq.addLast(6)
    #expect(dq.pollFirst() == 5)
    #expect(dq.pollFirst() == 6)
    #expect(dq.pollFirst() == nil)
  }

  // MARK: - Stack operations (push / pop)

  @Test("push() inserts at front, pop() removes from front (LIFO)")
  func testStackBehaviour() throws {
    let dq = java.util.ArrayDeque<Int>()
    try dq.push(1); try dq.push(2); try dq.push(3)
    #expect(try dq.pop() == 3)
    #expect(try dq.pop() == 2)
    #expect(try dq.pop() == 1)
    #expect(dq.isEmpty() == true)
  }

  // MARK: - Queue semantics (FIFO)

  @Test("offer() + poll() give FIFO order")
  func testQueueBehaviour() {
    let dq = java.util.ArrayDeque<Int>()
    _ = dq.offer(1); _ = dq.offer(2); _ = dq.offer(3)
    #expect(dq.poll() == 1)
    #expect(dq.poll() == 2)
    #expect(dq.poll() == 3)
    #expect(dq.poll() == nil)
  }

  @Test("element() returns head without removal, throws when empty")
  func testElement() throws {
    let dq = java.util.ArrayDeque<Int>()
    try dq.addLast(42)
    #expect(try dq.element() == 42)
    #expect(dq.size() == 1)
    _ = try dq.removeFirst()
    #expect(throws: java.util.NoSuchElementException.self) { try dq.element() }
  }

  @Test("remove() returns head, throws when empty")
  func testRemoveQueue() throws {
    let dq = java.util.ArrayDeque<Int>()
    try dq.addLast(7)
    #expect(try dq.remove() == 7)
    #expect(throws: java.util.NoSuchElementException.self) { try dq.remove() }
  }

  // MARK: - Occurrence removal

  @Test("removeFirstOccurrence() removes first matching element")
  func testRemoveFirstOccurrence() throws {
    let dq = java.util.ArrayDeque<Int>()
    for v in [1, 2, 3, 2, 1] { try dq.addLast(v) }
    #expect(dq.removeFirstOccurrence(2) == true)
    #expect(dq.size() == 4)
    #expect(try dq.getFirst() == 1)
    // second 2 still present
    #expect(dq.contains(2) == true)
  }

  @Test("removeLastOccurrence() removes last matching element")
  func testRemoveLastOccurrence() throws {
    let dq = java.util.ArrayDeque<Int>()
    for v in [1, 2, 3, 2, 1] { try dq.addLast(v) }
    #expect(dq.removeLastOccurrence(2) == true)
    #expect(dq.size() == 4)
    // first 2 still present
    #expect(dq.contains(2) == true)
  }

  @Test("removeFirstOccurrence() on absent element returns false")
  func testRemoveFirstOccurrenceAbsent() throws {
    let dq = java.util.ArrayDeque<Int>()
    try dq.addLast(1)
    #expect(dq.removeFirstOccurrence(99) == false)
    #expect(dq.size() == 1)
  }

  // MARK: - Iterator / descendingIterator

  @Test("iterator() yields elements in head-to-tail order")
  func testIterator() throws {
    let dq = java.util.ArrayDeque<Int>()
    for v in [10, 20, 30] { try dq.addLast(v) }
    let it = dq.iterator()
    var result: [Int] = []
    while it.hasNext() { if let e = try? it.next() { result.append(e) } }
    #expect(result == [10, 20, 30])
  }

  @Test("descendingIterator() yields elements in tail-to-head order")
  func testDescendingIterator() throws {
    let dq = java.util.ArrayDeque<Int>()
    for v in [10, 20, 30] { try dq.addLast(v) }
    let it = dq.descendingIterator()
    var result: [Int] = []
    while it.hasNext() { if let e = try? it.next() { result.append(e) } }
    #expect(result == [30, 20, 10])
  }

  // MARK: - SequencedCollection

  @Test("reversed() returns SequencedCollection in tail-to-head order")
  func testReversed() throws {
    let dq = java.util.ArrayDeque<Int>()
    for v in [1, 2, 3] { try dq.addLast(v) }
    let rev = dq.reversed()
    #expect(try rev.getFirst() == 3)
    #expect(try rev.getLast()  == 1)
  }

  // MARK: - clear / contains

  @Test("clear() empties the deque")
  func testClear() throws {
    let dq = java.util.ArrayDeque<Int>()
    for v in 1...5 { try dq.addLast(v) }
    dq.clear()
    #expect(dq.size() == 0)
    #expect(dq.isEmpty() == true)
  }

  @Test("contains() finds present and rejects absent elements")
  func testContains() throws {
    let dq = java.util.ArrayDeque<String>()
    try dq.addLast("hello")
    #expect(dq.contains("hello") == true)
    #expect(dq.contains("world") == false)
  }

  // MARK: - Protocol conformance

  @Test("ArrayDeque conforms to Deque protocol")
  func testDequeConformance() throws {
    let dq: any java.util.Deque<Int> = java.util.ArrayDeque<Int>()
    _ = dq.offer(1)
    #expect(dq.peek() == 1)
  }

  @Test("clone() produces independent copy")
  func testClone() throws {
    let original = java.util.ArrayDeque<Int>()
    try original.addLast(1); try original.addLast(2)
    let copy = original.clone()
    try original.addLast(3)
    #expect(copy.size() == 2)   // copy is unaffected
    #expect(try copy.getFirst() == 1)
  }

  // MARK: - Missing edge cases

  @Test("removeLast() on empty deque throws NoSuchElementException")
  func testRemoveLastEmpty() {
    let dq = java.util.ArrayDeque<Int>()
    #expect(throws: java.util.NoSuchElementException.self) { try dq.removeLast() }
  }

  @Test("pop() on empty deque throws NoSuchElementException")
  func testPopEmpty() {
    let dq = java.util.ArrayDeque<Int>()
    #expect(throws: java.util.NoSuchElementException.self) { try dq.pop() }
  }

  @Test("single-element deque: all peek/poll operations work correctly")
  func testSingleElement() throws {
    let dq = java.util.ArrayDeque<String>()
    try dq.addLast("only")
    #expect(dq.peekFirst() == "only")
    #expect(dq.peekLast()  == "only")
    #expect(try dq.getFirst() == "only")
    #expect(try dq.getLast()  == "only")
    #expect(dq.size() == 1)
    let removed = try dq.removeFirst()
    #expect(removed == "only")
    #expect(dq.isEmpty() == true)
  }

  @Test("alternating addFirst/addLast maintains correct order")
  func testAlternatingInserts() throws {
    let dq = java.util.ArrayDeque<Int>()
    try dq.addLast(3)
    try dq.addFirst(2)
    try dq.addLast(4)
    try dq.addFirst(1)
    // Expected order: [1, 2, 3, 4]
    let it = dq.iterator()
    var result: [Int] = []
    while it.hasNext() { if let e = try? it.next() { result.append(e) } }
    #expect(result == [1, 2, 3, 4])
  }

  @Test("interleaved insertions and removals preserve FIFO order")
  func testInterleavedQueueOps() {
    let dq = java.util.ArrayDeque<Int>()
    _ = dq.offer(1); _ = dq.offer(2)
    #expect(dq.poll() == 1)
    _ = dq.offer(3); _ = dq.offer(4)
    #expect(dq.poll() == 2)
    #expect(dq.poll() == 3)
    #expect(dq.poll() == 4)
    #expect(dq.poll() == nil)
  }

  @Test("add(nil) returns false and does not change size")
  func testAddNil() throws {
    let dq = java.util.ArrayDeque<Int>()
    let nilValue: Int? = nil
    let result = try dq.add(nilValue)
    #expect(result == false)
    #expect(dq.size() == 0)
  }

  @Test("for-in loop iterates all elements in head-to-tail order")
  func testForIn() throws {
    let dq = java.util.ArrayDeque<Int>()
    for v in [10, 20, 30] { try dq.addLast(v) }
    var collected: [Int] = []
    for e in dq { if let e { collected.append(e) } }
    #expect(collected == [10, 20, 30])
  }

  @Test("removeFirstOccurrence with multiple duplicates removes only first")
  func testRemoveFirstOccurrenceMultipleDups() throws {
    let dq = java.util.ArrayDeque<Int>()
    for v in [7, 7, 7] { try dq.addLast(v) }
    #expect(dq.removeFirstOccurrence(7) == true)
    #expect(dq.size() == 2)
    #expect(dq.contains(7) == true)  // two remain
  }

  @Test("removeLastOccurrence with multiple duplicates removes only last")
  func testRemoveLastOccurrenceMultipleDups() throws {
    let dq = java.util.ArrayDeque<Int>()
    for v in [7, 7, 7] { try dq.addLast(v) }
    #expect(dq.removeLastOccurrence(7) == true)
    #expect(dq.size() == 2)
    #expect(dq.contains(7) == true)  // two remain
  }

  @Test("numElements constructor creates empty deque")
  func testInitWithCapacity() {
    let dq = java.util.ArrayDeque<Int>(numElements: 32)
    #expect(dq.isEmpty() == true)
  }

  @Test("collection constructor copies elements in iteration order")
  func testInitFromCollection() throws {
    let src = java.util.ArrayList<Int>()
    for v in [3, 1, 2] { _ = try src.add(v) }
    let dq = java.util.ArrayDeque<Int>(collection: src)
    #expect(dq.size() == 3)
    #expect(try dq.getFirst() == 3)
    #expect(try dq.getLast()  == 2)
  }

  @Test("large deque: 1000 elements inserted and drained in FIFO order")
  func testLargeDeque() {
    let dq = java.util.ArrayDeque<Int>()
    for i in 0..<1000 { _ = dq.offer(i) }
    #expect(dq.size() == 1000)
    for i in 0..<1000 {
      #expect(dq.poll() == i)
    }
    #expect(dq.isEmpty() == true)
  }
}
