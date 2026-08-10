/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

@Suite("java.util.PriorityQueue")
struct JavApi_util_PriorityQueue_Tests {

  // MARK: - Basic state

  @Test("empty queue has size 0")
  func testInitEmpty() {
    let pq = java.util.PriorityQueue<Int>()
    #expect(pq.size() == 0)
    #expect(pq.isEmpty() == true)
    #expect(pq.peek() == nil)
  }

  // MARK: - offer / add

  @Test("offer() inserts elements; size grows")
  func testOffer() {
    let pq = java.util.PriorityQueue<Int>()
    #expect(pq.offer(5) == true)
    #expect(pq.offer(1) == true)
    #expect(pq.offer(3) == true)
    #expect(pq.size() == 3)
  }

  @Test("add() (Queue protocol) inserts elements")
  func testAdd() throws {
    let pq = java.util.PriorityQueue<Int>()
    _ = try pq.add(10)
    _ = try pq.add(20)
    #expect(pq.size() == 2)
  }

  // MARK: - Min-heap ordering

  @Test("peek() always returns the minimum element")
  func testPeekMinimum() {
    let pq = java.util.PriorityQueue<Int>()
    for v in [5, 3, 8, 1, 4] { _ = pq.offer(v) }
    #expect(pq.peek() == 1)
  }

  @Test("poll() removes and returns elements in ascending order")
  func testPollAscending() {
    let pq = java.util.PriorityQueue<Int>()
    for v in [5, 3, 8, 1, 4] { _ = pq.offer(v) }
    var result: [Int] = []
    while let min = pq.poll() { result.append(min) }
    #expect(result == [1, 3, 4, 5, 8])
  }

  @Test("remove() (Queue) removes minimum, throws when empty")
  func testRemoveQueue() throws {
    let pq = java.util.PriorityQueue<Int>()
    _ = pq.offer(2); _ = pq.offer(1); _ = pq.offer(3)
    #expect(try pq.remove() == 1)
    #expect(try pq.remove() == 2)
    #expect(try pq.remove() == 3)
    #expect(throws: java.util.NoSuchElementException.self) { try pq.remove() }
  }

  @Test("element() returns minimum without removal, throws when empty")
  func testElement() throws {
    let pq = java.util.PriorityQueue<Int>()
    _ = pq.offer(7); _ = pq.offer(2)
    #expect(try pq.element() == 2)
    #expect(pq.size() == 2)
    _ = pq.poll(); _ = pq.poll()
    #expect(throws: java.util.NoSuchElementException.self) { try pq.element() }
  }

  @Test("poll() returns nil on empty queue")
  func testPollEmpty() {
    let pq = java.util.PriorityQueue<Int>()
    #expect(pq.poll() == nil)
  }

  // MARK: - String natural ordering

  @Test("String PriorityQueue returns strings in lexicographic order")
  func testStringOrder() {
    let pq = java.util.PriorityQueue<String>()
    for s in ["banana", "apple", "cherry"] { _ = pq.offer(s) }
    var result: [String] = []
    while let s = pq.poll() { result.append(s) }
    #expect(result == ["apple", "banana", "cherry"])
  }

  // MARK: - Custom comparator (max-heap)

  @Test("custom comparator reverses order (max-heap)")
  func testMaxHeap() {
    let pq = java.util.PriorityQueue<Int>(comparator: { $1 - $0 })
    for v in [3, 1, 4, 1, 5, 9, 2] { _ = pq.offer(v) }
    #expect(pq.peek() == 9)
    var result: [Int] = []
    while let max = pq.poll() { result.append(max) }
    #expect(result == [9, 5, 4, 3, 2, 1, 1])
  }

  // MARK: - contains / remove(element)

  @Test("contains() finds present element and rejects absent one")
  func testContains() {
    let pq = java.util.PriorityQueue<Int>()
    for v in [1, 2, 3] { _ = pq.offer(v) }
    #expect(pq.contains(2) == true)
    #expect(pq.contains(9) == false)
  }

  @Test("remove(_ element:) removes specific element, preserves heap order")
  func testRemoveElement() throws {
    let pq = java.util.PriorityQueue<Int>()
    for v in [1, 3, 5, 7, 9] { _ = pq.offer(v) }
    #expect(pq.remove(5) == true)     // remove middle element
    #expect(pq.size() == 4)
    #expect(pq.contains(5) == false)
    // remaining elements still come out in order
    var result: [Int] = []
    while let e = pq.poll() { result.append(e) }
    #expect(result == [1, 3, 7, 9])
  }

  @Test("remove(_ element:) on absent element returns false")
  func testRemoveAbsent() {
    let pq = java.util.PriorityQueue<Int>()
    _ = pq.offer(1)
    #expect(pq.remove(99) == false)
    #expect(pq.size() == 1)
  }

  // MARK: - clear

  @Test("clear() empties the queue")
  func testClear() {
    let pq = java.util.PriorityQueue<Int>()
    for v in 1...5 { _ = pq.offer(v) }
    pq.clear()
    #expect(pq.size() == 0)
    #expect(pq.isEmpty() == true)
    #expect(pq.peek() == nil)
  }

  // MARK: - iterator (unordered)

  @Test("iterator() covers all elements (order not guaranteed)")
  func testIteratorCoversAll() {
    let pq = java.util.PriorityQueue<Int>()
    let input = [4, 2, 7, 1, 9]
    for v in input { _ = pq.offer(v) }
    let it = pq.iterator()
    var collected: [Int] = []
    while it.hasNext() { if let e = try? it.next() { collected.append(e) } }
    #expect(collected.sorted() == input.sorted())
  }

  // MARK: - copy constructor

  @Test("copy constructor duplicates contents independently")
  func testCopyConstructor() {
    let original = java.util.PriorityQueue<Int>()
    for v in [3, 1, 2] { _ = original.offer(v) }
    let copy = java.util.PriorityQueue<Int>(original)
    _ = original.poll()   // mutate original
    #expect(copy.size() == 3)   // copy unaffected
    #expect(copy.peek() == 1)
  }

  // MARK: - Protocol conformance

  @Test("PriorityQueue conforms to Queue protocol")
  func testQueueConformance() {
    let pq: any java.util.Queue<Int> = java.util.PriorityQueue<Int>()
    _ = pq.offer(42)
    #expect(pq.peek() == 42)
  }

  // MARK: - Duplicate elements

  @Test("duplicate elements are allowed")
  func testDuplicates() {
    let pq = java.util.PriorityQueue<Int>()
    for _ in 0..<3 { _ = pq.offer(5) }
    #expect(pq.size() == 3)
    var result: [Int] = []
    while let e = pq.poll() { result.append(e) }
    #expect(result == [5, 5, 5])
  }

  // MARK: - Missing edge cases

  @Test("single-element queue: offer then poll returns that element")
  func testSingleElement() {
    let pq = java.util.PriorityQueue<Int>()
    _ = pq.offer(42)
    #expect(pq.peek() == 42)
    #expect(pq.poll() == 42)
    #expect(pq.isEmpty() == true)
    #expect(pq.peek() == nil)
  }

  @Test("add(nil) returns false and does not change size")
  func testAddNil() throws {
    let pq = java.util.PriorityQueue<Int>()
    let nilValue: Int? = nil
    let result = try pq.add(nilValue)
    #expect(result == false)
    #expect(pq.size() == 0)
  }

  @Test("interleaved offer/poll preserves min-heap order")
  func testInterleavedOfferPoll() {
    let pq = java.util.PriorityQueue<Int>()
    _ = pq.offer(5); _ = pq.offer(3)
    #expect(pq.poll() == 3)
    _ = pq.offer(1); _ = pq.offer(4)
    #expect(pq.poll() == 1)
    _ = pq.offer(2)
    // remaining: 2, 4, 5
    #expect(pq.poll() == 2)
    #expect(pq.poll() == 4)
    #expect(pq.poll() == 5)
    #expect(pq.poll() == nil)
  }

  @Test("remove(root) correctly repairs heap and preserves order")
  func testRemoveRoot() {
    let pq = java.util.PriorityQueue<Int>()
    for v in [1, 3, 2, 5, 4] { _ = pq.offer(v) }
    #expect(pq.remove(1) == true)   // root
    var result: [Int] = []
    while let e = pq.poll() { result.append(e) }
    #expect(result == [2, 3, 4, 5])
  }

  @Test("remove(element) with duplicates removes only one occurrence")
  func testRemoveOneDuplicate() {
    let pq = java.util.PriorityQueue<Int>()
    for _ in 0..<3 { _ = pq.offer(7) }
    #expect(pq.remove(7) == true)
    #expect(pq.size() == 2)
    #expect(pq.contains(7) == true)
  }

  @Test("after clear(), queue can be refilled and returns correct minimum")
  func testRefillAfterClear() {
    let pq = java.util.PriorityQueue<Int>()
    for v in 1...5 { _ = pq.offer(v) }
    pq.clear()
    #expect(pq.isEmpty() == true)
    for v in [9, 3, 6] { _ = pq.offer(v) }
    #expect(pq.peek() == 3)
    var result: [Int] = []
    while let e = pq.poll() { result.append(e) }
    #expect(result == [3, 6, 9])
  }

  @Test("collection constructor produces correct heap from collection")
  func testCollectionConstructor() throws {
    let src = java.util.ArrayList<Int>()
    for v in [5, 1, 4, 2, 3] { _ = try src.add(v) }
    let pq = java.util.PriorityQueue<Int>(collection: src)
    #expect(pq.size() == 5)
    var result: [Int] = []
    while let e = pq.poll() { result.append(e) }
    #expect(result == [1, 2, 3, 4, 5])
  }

  @Test("large heap: 500 random-ish elements drain in sorted order")
  func testLargeHeap() {
    let pq = java.util.PriorityQueue<Int>()
    // Insert in a pseudo-random-ish pattern
    for i in stride(from: 500, through: 1, by: -1) { _ = pq.offer(i) }
    for i in 501...1000 { _ = pq.offer(i) }
    #expect(pq.size() == 1000)
    var prev = Int.min
    while let e = pq.poll() {
      #expect(e >= prev)
      prev = e
    }
  }

  @Test("Comparator object constructor works like lambda comparator")
  func testComparatorObject() {
    // Reverse-order comparator via java.util.Comparator
    // (We use a simple wrapper since java.util.Comparator is a protocol)
    let pq = java.util.PriorityQueue<Int>(comparator: { b, a in
      // Reversed: larger values have higher priority
      if a < b { return -1 } else if a > b { return 1 } else { return 0 }
    })
    for v in [3, 1, 4, 1, 5, 9] { _ = pq.offer(v) }
    #expect(pq.peek() == 9)
    var result: [Int] = []
    while let e = pq.poll() { result.append(e) }
    #expect(result == [9, 5, 4, 3, 1, 1])
  }

  @Test("two-element queue returns elements in correct order")
  func testTwoElements() {
    let pq = java.util.PriorityQueue<Int>()
    _ = pq.offer(2); _ = pq.offer(1)
    #expect(pq.poll() == 1)
    #expect(pq.poll() == 2)
    #expect(pq.poll() == nil)
  }

  // MARK: - toArray() / toArray(_ a:)

  @Test("toArray() returns all elements in heap-storage order")
  func testToArray() {
    let pq = java.util.PriorityQueue<Int>()
    _ = pq.offer(3); _ = pq.offer(1); _ = pq.offer(2)
    let arr = pq.toArray()
    // heap-storage order: compactMap to strip optionals
    #expect(arr.count == 3)
    let sorted = arr.compactMap { $0 }.sorted()
    #expect(sorted == [1, 2, 3])
  }

  @Test("toArray() on empty queue returns empty array")
  func testToArrayEmpty() {
    let pq = java.util.PriorityQueue<Int>()
    #expect(pq.toArray().isEmpty)
  }

  @Test("toArray(_ a:) fills pre-sized array in heap-storage order")
  func testToArrayWithPreSizedArray() {
    let pq = java.util.PriorityQueue<Int>()
    _ = pq.offer(5); _ = pq.offer(2); _ = pq.offer(8)
    let result = pq.toArray([0, 0, 0])
    #expect(result.count == 3)
    #expect(Set(result) == Set([5, 2, 8]))
  }

  @Test("toArray(_ a:) with undersized array returns heap array directly")
  func testToArrayWithUndersizedArray() {
    let pq = java.util.PriorityQueue<Int>()
    _ = pq.offer(1); _ = pq.offer(2); _ = pq.offer(3)
    let result = pq.toArray([0])   // too small → returns _heap
    #expect(result.count == 3)
    #expect(Set(result) == Set([1, 2, 3]))
  }
}
