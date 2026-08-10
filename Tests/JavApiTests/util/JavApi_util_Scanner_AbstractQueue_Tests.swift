/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Testing
@testable import JavApi

// MARK: - Scanner tests

@Suite("Scanner — string constructor")
struct ScannerStringTests {

  @Test("next() returns whitespace-delimited tokens")
  func testNextTokens() throws {
    let sc = java.util.Scanner("hello world foo")
    #expect(try sc.next() == "hello")
    #expect(try sc.next() == "world")
    #expect(try sc.next() == "foo")
  }

  @Test("hasNext() reflects remaining tokens")
  func testHasNext() throws {
    let sc = java.util.Scanner("one two")
    #expect(sc.hasNext())
    _ = try sc.next()
    #expect(sc.hasNext())
    _ = try sc.next()
    #expect(!sc.hasNext())
  }

  @Test("next() throws NoSuchElementException when exhausted")
  func testNextExhausted() throws {
    let sc = java.util.Scanner("")
    #expect(throws: java.util.NoSuchElementException.self) {
      try sc.next()
    }
  }

  @Test("nextLine() returns full lines")
  func testNextLine() throws {
    let sc = java.util.Scanner("line one\nline two\nline three")
    #expect(try sc.nextLine() == "line one")
    #expect(try sc.nextLine() == "line two")
    #expect(try sc.nextLine() == "line three")
  }

  @Test("nextLine() handles \\r\\n line endings")
  func testNextLineCRLF() throws {
    let sc = java.util.Scanner("alpha\r\nbeta\r\ngamma")
    #expect(try sc.nextLine() == "alpha")
    #expect(try sc.nextLine() == "beta")
    #expect(try sc.nextLine() == "gamma")
  }

  @Test("hasNextLine() is false when input is empty")
  func testHasNextLineEmpty() {
    let sc = java.util.Scanner("")
    #expect(!sc.hasNextLine())
  }

  @Test("nextInt() parses integers")
  func testNextInt() throws {
    let sc = java.util.Scanner("1 2 3")
    #expect(try sc.nextInt() == 1)
    #expect(try sc.nextInt() == 2)
    #expect(try sc.nextInt() == 3)
  }

  @Test("hasNextInt() returns false for non-integer token")
  func testHasNextIntFalse() {
    let sc = java.util.Scanner("hello")
    #expect(!sc.hasNextInt())
  }

  @Test("nextInt() throws InputMismatchException for non-integer")
  func testNextIntMismatch() {
    let sc = java.util.Scanner("abc")
    #expect(throws: java.util.InputMismatchException.self) {
      try sc.nextInt()
    }
  }

  @Test("nextLong() parses Int64 values")
  func testNextLong() throws {
    let sc = java.util.Scanner("9223372036854775807")
    #expect(try sc.nextLong() == Int64.max)
  }

  @Test("nextDouble() parses floating-point values")
  func testNextDouble() throws {
    let sc = java.util.Scanner("3.14 2.71828")
    #expect(try sc.nextDouble() == 3.14)
    #expect(abs((try sc.nextDouble()) - 2.71828) < 1e-5)
  }

  @Test("hasNextDouble() returns false for non-double token")
  func testHasNextDoubleFalse() {
    let sc = java.util.Scanner("hello")
    #expect(!sc.hasNextDouble())
  }

  @Test("nextBoolean() parses true and false (case-insensitive)")
  func testNextBoolean() throws {
    let sc = java.util.Scanner("true FALSE True")
    #expect(try sc.nextBoolean() == true)
    #expect(try sc.nextBoolean() == false)
    #expect(try sc.nextBoolean() == true)
  }

  @Test("nextBoolean() throws InputMismatchException for non-boolean")
  func testNextBooleanMismatch() {
    let sc = java.util.Scanner("yes")
    #expect(throws: java.util.InputMismatchException.self) {
      try sc.nextBoolean()
    }
  }

  @Test("useDelimiter() changes token separator")
  func testUseDelimiter() throws {
    let sc = java.util.Scanner("a,b,c")
    sc.useDelimiter(",")
    #expect(try sc.next() == "a")
    #expect(try sc.next() == "b")
    #expect(try sc.next() == "c")
  }

  @Test("useRadix() changes default number base")
  func testUseRadix() throws {
    let sc = java.util.Scanner("ff")
    sc.useRadix(16)
    #expect(try sc.nextInt() == 255)
  }

  @Test("nextInt(radix:) parses hex token")
  func testNextIntRadix() throws {
    let sc = java.util.Scanner("1a")
    #expect(try sc.nextInt(radix: 16) == 26)
  }

  @Test("nextLong(radix:) parses binary token")
  func testNextLongRadix() throws {
    let sc = java.util.Scanner("1101")
    #expect(try sc.nextLong(radix: 2) == 13)
  }

  @Test("close() prevents further scanning")
  func testClose() throws {
    let sc = java.util.Scanner("hello")
    try sc.close()
    #expect(throws: java.lang.IllegalStateException.self) {
      try sc.next()
    }
  }

  @Test("Scanner handles leading and trailing whitespace")
  func testLeadingTrailingWhitespace() throws {
    let sc = java.util.Scanner("  hello  ")
    #expect(try sc.next() == "hello")
    #expect(!sc.hasNext())
  }

  @Test("Scanner handles multiple spaces between tokens")
  func testMultipleSpaces() throws {
    let sc = java.util.Scanner("a   b\t\tc")
    #expect(try sc.next() == "a")
    #expect(try sc.next() == "b")
    #expect(try sc.next() == "c")
  }

  @Test("Scanner handles empty input correctly")
  func testEmptyInput() {
    let sc = java.util.Scanner("")
    #expect(!sc.hasNext())
    #expect(!sc.hasNextInt())
    #expect(!sc.hasNextDouble())
    #expect(!sc.hasNextBoolean())
    #expect(!sc.hasNextLine())
  }
}

// MARK: - Map.entry + Map.ofEntries tests

@Suite("HashMap — Map.entry + Map.ofEntries (Java 9)")
struct MapEntryOfEntriesTests {

  @Test("Map.entry() returns a MapEntry with correct key and value")
  func testMapEntry() {
    let e = java.util.HashMap<String, Int>.entry("key", 42)
    #expect(e.getKey() == "key")
    #expect(e.getValue() == 42)
  }

  @Test("Map.ofEntries() builds a map from one entry")
  func testOfEntriesOne() throws {
    let map = try java.util.HashMap<String, Int>.ofEntries(
      java.util.HashMap<String, Int>.entry("a", 1)
    )
    #expect(map.size() == 1)
    #expect(map.get("a") == 1)
  }

  @Test("Map.ofEntries() builds a map from multiple entries")
  func testOfEntriesMultiple() throws {
    let map = try java.util.HashMap<String, Int>.ofEntries(
      java.util.HashMap<String, Int>.entry("x", 10),
      java.util.HashMap<String, Int>.entry("y", 20),
      java.util.HashMap<String, Int>.entry("z", 30)
    )
    #expect(map.size() == 3)
    #expect(map.get("x") == 10)
    #expect(map.get("y") == 20)
    #expect(map.get("z") == 30)
  }

  @Test("Map.ofEntries() throws on duplicate keys")
  func testOfEntriesDuplicate() {
    #expect(throws: java.lang.IllegalArgumentException.self) {
      try java.util.HashMap<String, Int>.ofEntries(
        java.util.HashMap<String, Int>.entry("dup", 1),
        java.util.HashMap<String, Int>.entry("dup", 2)
      )
    }
  }

  @Test("Map.ofEntries() map is read-only by nature — size is correct")
  func testOfEntriesReadOnly() throws {
    let map = try java.util.HashMap<String, Int>.ofEntries(
      java.util.HashMap<String, Int>.entry("k", 9),
      java.util.HashMap<String, Int>.entry("m", 7)
    )
    // Verify the map is correctly populated and read-only access works
    #expect(map.size() == 2)
    #expect(map.get("k") == 9)
    #expect(map.get("m") == 7)
    #expect(map.containsKey("k"))
    #expect(!map.containsKey("missing"))
  }

  @Test("Map.ofEntries() with zero entries returns empty map")
  func testOfEntriesEmpty() throws {
    let map = try java.util.HashMap<String, Int>.ofEntries()
    #expect(map.size() == 0)
    #expect(map.isEmpty())
  }
}

// MARK: - AbstractQueue tests

/// Minimal concrete queue backed by a Swift array for testing AbstractQueue.
private final class TestQueue<E: Equatable>: java.util.AbstractQueue<E>, @unchecked Sendable {

  private var _elements: [E] = []

  override func offer(_ elem: E) -> Bool {
    _elements.append(elem)
    return true
  }

  override func poll() -> E? {
    guard !_elements.isEmpty else { return nil }
    return _elements.removeFirst()
  }

  override func peek() -> E? {
    _elements.first
  }

  override func iterator() -> any java.util.Iterator<E> {
    _ArrayIterator(_elements)
  }

  override func size() -> Int {
    _elements.count
  }
}

/// Bounded queue that rejects `offer` after `capacity` elements.
private final class BoundedQueue<E: Equatable>: java.util.AbstractQueue<E>, @unchecked Sendable {

  private let capacity: Int
  private var _elements: [E] = []

  init(capacity: Int) {
    self.capacity = capacity
    super.init()
  }

  override func offer(_ elem: E) -> Bool {
    guard _elements.count < capacity else { return false }
    _elements.append(elem)
    return true
  }

  override func poll() -> E? {
    guard !_elements.isEmpty else { return nil }
    return _elements.removeFirst()
  }

  override func peek() -> E? { _elements.first }

  override func iterator() -> any java.util.Iterator<E> {
    _ArrayIterator(_elements)
  }

  override func size() -> Int { _elements.count }
}

/// Simple snapshot iterator for tests.
private final class _ArrayIterator<E: Equatable>: java.util.Iterator, IteratorProtocol {
  typealias Element = E
  private let items: [E]
  private var idx = 0
  init(_ items: [E]) { self.items = items }
  func hasNext() -> Bool { idx < items.count }
  func next() throws(java.util.NoSuchElementException) -> E {
    guard idx < items.count else { throw java.util.NoSuchElementException() }
    defer { idx += 1 }
    return items[idx]
  }
  func next() -> E? {
    guard idx < items.count else { return nil }
    defer { idx += 1 }
    return items[idx]
  }
  func remove() throws(java.lang.IllegalStateException) {
    throw java.lang.IllegalStateException("remove() not supported")
  }
  func makeIterator() -> _ArrayIterator<E> { self }
}

@Suite("AbstractQueue")
struct AbstractQueueTests {

  @Test("add() and remove() follow FIFO order")
  func testAddRemoveFIFO() throws {
    let q = TestQueue<Int>()
    _ = try q.add(1)
    _ = try q.add(2)
    _ = try q.add(3)
    #expect(try q.remove() == 1)
    #expect(try q.remove() == 2)
    #expect(try q.remove() == 3)
  }

  @Test("element() peeks without removal")
  func testElement() throws {
    let q = TestQueue<String>()
    _ = try q.add("hello")
    #expect(try q.element() == "hello")
    #expect(q.size() == 1)
  }

  @Test("element() throws NoSuchElementException on empty queue")
  func testElementEmpty() {
    let q = TestQueue<Int>()
    #expect(throws: java.util.NoSuchElementException.self) {
      try q.element()
    }
  }

  @Test("remove() throws NoSuchElementException on empty queue")
  func testRemoveEmpty() {
    let q = TestQueue<Int>()
    #expect(throws: java.util.NoSuchElementException.self) {
      try q.remove()
    }
  }

  @Test("peek() returns nil on empty queue")
  func testPeekEmpty() {
    let q = TestQueue<Int>()
    #expect(q.peek() == nil)
  }

  @Test("poll() returns nil on empty queue")
  func testPollEmpty() {
    let q = TestQueue<Int>()
    #expect(q.poll() == nil)
  }

  @Test("size() reflects number of elements")
  func testSize() throws {
    let q = TestQueue<Int>()
    #expect(q.size() == 0)
    _ = try q.add(1)
    #expect(q.size() == 1)
    _ = try q.add(2)
    #expect(q.size() == 2)
    _ = q.poll()
    #expect(q.size() == 1)
  }

  @Test("clear() empties the queue")
  func testClear() throws {
    let q = TestQueue<Int>()
    _ = try q.add(1)
    _ = try q.add(2)
    q.clear()
    #expect(q.isEmpty())
    #expect(q.size() == 0)
  }

  @Test("add(E?) rejects nil with NullPointerException")
  func testAddNilRejectsNull() {
    let q = TestQueue<Int>()
    #expect(throws: java.lang.NullPointerException.self) {
      try q.add(nil as Int?)
    }
  }

  @Test("add() throws IllegalStateException on full bounded queue")
  func testBoundedQueueFull() throws {
    let q = BoundedQueue<Int>(capacity: 2)
    _ = try q.add(1)
    _ = try q.add(2)
    #expect(throws: java.lang.IllegalStateException.self) {
      try q.add(3)
    }
  }

  @Test("offer() returns false on full bounded queue")
  func testBoundedQueueOfferFalse() throws {
    let q = BoundedQueue<String>(capacity: 1)
    #expect(q.offer("first") == true)
    #expect(q.offer("second") == false)
  }

  @Test("isEmpty() returns true on empty queue")
  func testIsEmpty() throws {
    let q = TestQueue<Int>()
    #expect(q.isEmpty())
    _ = try q.add(42)
    #expect(!q.isEmpty())
  }
}
