/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

/// Tests for `java.util.Deque` via its primary implementation `java.util.LinkedList`.
struct JavApi_util_Deque_Tests {

  // MARK: - offerFirst / offerLast

  @Test("offerFirst inserts at the front")
  func testOfferFirst() throws {
    let d = java.util.LinkedList<Int>()
    #expect(d.offerFirst(2) == true)
    #expect(d.offerFirst(1) == true)
    #expect(try d.get(0) == 1)
    #expect(try d.get(1) == 2)
  }

  @Test("offerLast inserts at the tail")
  func testOfferLast() throws {
    let d = java.util.LinkedList<Int>()
    #expect(d.offerLast(1) == true)
    #expect(d.offerLast(2) == true)
    #expect(try d.get(0) == 1)
    #expect(try d.get(1) == 2)
  }

  // MARK: - peekFirst / peekLast

  @Test("peekFirst returns head without removal")
  func testPeekFirst() throws {
    let d = java.util.LinkedList<String>()
    _ = d.offerLast("a")
    _ = d.offerLast("b")
    #expect(d.peekFirst() == "a")
    #expect(d.size() == 2)
  }

  @Test("peekFirst on empty deque returns nil")
  func testPeekFirstEmpty() {
    let d = java.util.LinkedList<Int>()
    #expect(d.peekFirst() == nil)
  }

  @Test("peekLast returns tail without removal")
  func testPeekLast() throws {
    let d = java.util.LinkedList<String>()
    _ = d.offerLast("a")
    _ = d.offerLast("b")
    #expect(d.peekLast() == "b")
    #expect(d.size() == 2)
  }

  @Test("peekLast on empty deque returns nil")
  func testPeekLastEmpty() {
    let d = java.util.LinkedList<Int>()
    #expect(d.peekLast() == nil)
  }

  // MARK: - pollFirst / pollLast

  @Test("pollFirst removes and returns head")
  func testPollFirst() {
    let d = java.util.LinkedList<Int>()
    _ = d.offerLast(10)
    _ = d.offerLast(20)
    #expect(d.pollFirst() == 10)
    #expect(d.size() == 1)
  }

  @Test("pollFirst on empty deque returns nil")
  func testPollFirstEmpty() {
    let d = java.util.LinkedList<Int>()
    #expect(d.pollFirst() == nil)
  }

  @Test("pollLast removes and returns tail")
  func testPollLast() {
    let d = java.util.LinkedList<Int>()
    _ = d.offerLast(10)
    _ = d.offerLast(20)
    #expect(d.pollLast() == 20)
    #expect(d.size() == 1)
  }

  @Test("pollLast on empty deque returns nil")
  func testPollLastEmpty() {
    let d = java.util.LinkedList<Int>()
    #expect(d.pollLast() == nil)
  }

  // MARK: - push / pop (stack operations)

  @Test("push inserts at front (LIFO order)")
  func testPush() throws {
    let d = java.util.LinkedList<Int>()
    try d.push(1)
    try d.push(2)
    try d.push(3)
    // Stack top is front: 3, 2, 1
    #expect(try d.get(0) == 3)
    #expect(try d.get(1) == 2)
    #expect(try d.get(2) == 1)
  }

  @Test("pop removes and returns top (front)")
  func testPop() throws {
    let d = java.util.LinkedList<Int>()
    try d.push(1)
    try d.push(2)
    let top = try d.pop()
    #expect(top == 2)
    #expect(d.size() == 1)
  }

  @Test("pop on empty deque throws")
  func testPopEmpty() {
    let d = java.util.LinkedList<Int>()
    #expect(throws: (any Error).self) { try d.pop() }
  }

  @Test("push/pop roundtrip preserves LIFO order")
  func testPushPopLIFO() throws {
    let d = java.util.LinkedList<String>()
    try d.push("a")
    try d.push("b")
    try d.push("c")
    #expect(try d.pop() == "c")
    #expect(try d.pop() == "b")
    #expect(try d.pop() == "a")
    #expect(d.isEmpty())
  }

  // MARK: - removeFirstOccurrence / removeLastOccurrence

  @Test("removeFirstOccurrence removes only first match")
  func testRemoveFirstOccurrence() throws {
    let d = java.util.LinkedList<Int>()
    _ = d.offerLast(1); _ = d.offerLast(2); _ = d.offerLast(1); _ = d.offerLast(3)
    #expect(d.removeFirstOccurrence(1) == true)
    #expect(d.size() == 3)
    #expect(try d.get(0) == 2)
    #expect(try d.get(1) == 1)  // second occurrence remains
  }

  @Test("removeFirstOccurrence returns false when element not present")
  func testRemoveFirstOccurrenceNotFound() {
    let d = java.util.LinkedList<Int>()
    _ = d.offerLast(5)
    #expect(d.removeFirstOccurrence(99) == false)
    #expect(d.size() == 1)
  }

  @Test("removeLastOccurrence removes only last match")
  func testRemoveLastOccurrence() throws {
    let d = java.util.LinkedList<Int>()
    _ = d.offerLast(1); _ = d.offerLast(2); _ = d.offerLast(1); _ = d.offerLast(3)
    #expect(d.removeLastOccurrence(1) == true)
    #expect(d.size() == 3)
    #expect(try d.get(0) == 1)   // first occurrence remains
    #expect(try d.get(1) == 2)
    #expect(try d.get(2) == 3)
  }

  @Test("removeLastOccurrence returns false when element not present")
  func testRemoveLastOccurrenceNotFound() {
    let d = java.util.LinkedList<Int>()
    _ = d.offerLast(5)
    #expect(d.removeLastOccurrence(99) == false)
    #expect(d.size() == 1)
  }

  @Test("removeFirstOccurrence and removeLastOccurrence on single element")
  func testOccurrenceRemovalSingleElement() {
    let d1 = java.util.LinkedList<Int>()
    _ = d1.offerLast(42)
    #expect(d1.removeFirstOccurrence(42) == true)
    #expect(d1.isEmpty())

    let d2 = java.util.LinkedList<Int>()
    _ = d2.offerLast(42)
    #expect(d2.removeLastOccurrence(42) == true)
    #expect(d2.isEmpty())
  }

  // MARK: - descendingIterator

  @Test("descendingIterator traverses tail to head")
  func testDescendingIterator() throws {
    let d = java.util.LinkedList<Int>()
    _ = d.offerLast(1); _ = d.offerLast(2); _ = d.offerLast(3)
    let it = d.descendingIterator()
    var result: [Int] = []
    while it.hasNext() {
      if let v = try? it.next() { result.append(v) }
    }
    #expect(result == [3, 2, 1])
  }

  @Test("descendingIterator on empty deque has no elements")
  func testDescendingIteratorEmpty() {
    let d = java.util.LinkedList<Int>()
    let it = d.descendingIterator()
    #expect(it.hasNext() == false)
  }

  @Test("for-in over descendingIterator (Swift Sequence)")
  func testDescendingIteratorForIn() {
    let d = java.util.LinkedList<Int>()
    _ = d.offerLast(10); _ = d.offerLast(20); _ = d.offerLast(30)
    let it = d.descendingIterator() as! LinkedListDescendingIterator<Int>
    var result: [Int] = []
    for e in it { result.append(e) }
    #expect(result == [30, 20, 10])
  }

  // MARK: - Deque used via protocol type

  @Test("LinkedList conforms to Deque protocol")
  func testDequeProtocolConformance() {
    let d: any java.util.Deque<Int> = java.util.LinkedList<Int>()
    #expect(d.offerFirst(1) == true)
    #expect(d.offerLast(2) == true)
    #expect(d.peekFirst() == 1)
    #expect(d.peekLast() == 2)
    #expect(d.pollFirst() == 1)
    #expect(d.pollLast() == 2)
    #expect(d.isEmpty())
  }
}
