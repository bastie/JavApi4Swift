/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

struct JavApi_util_TreeSet_Tests {

  // MARK: - Basic add / contains / size

  @Test("add inserts elements; size reflects count")
  func testAddSize() throws {
    let set = java.util.TreeSet<Int>()
    #expect(try set.add(3) == true)
    #expect(try set.add(1) == true)
    #expect(try set.add(2) == true)
    #expect(set.size() == 3)
  }

  @Test("add duplicate returns false and does not increase size")
  func testAddDuplicate() throws {
    let set = java.util.TreeSet<Int>()
    _ = try set.add(5)
    let result = try set.add(5)
    #expect(result == false)
    #expect(set.size() == 1)
  }

  @Test("contains finds present element")
  func testContains() throws {
    let set = java.util.TreeSet<String>()
    _ = try set.add("hello")
    #expect(set.contains("hello") == true)
    #expect(set.contains("world") == false)
  }

  // MARK: - Ordering

  @Test("elements are maintained in ascending order")
  func testAscendingOrder() throws {
    let set = java.util.TreeSet<Int>()
    for v in [5, 3, 1, 4, 2] { _ = try set.add(v) }
    let collected = set._elements
    #expect(collected == [1, 2, 3, 4, 5])
  }

  @Test("String elements sorted lexicographically")
  func testStringOrder() throws {
    let set = java.util.TreeSet<String>()
    _ = try set.add("cherry")
    _ = try set.add("apple")
    _ = try set.add("banana")
    #expect(set._elements == ["apple", "banana", "cherry"])
  }

  // MARK: - remove

  @Test("remove existing element returns true")
  func testRemove() throws {
    let set = java.util.TreeSet<Int>()
    _ = try set.add(10)
    _ = try set.add(20)
    let result = set.remove(10)
    #expect(result == true)
    #expect(set.size() == 1)
    #expect(set.contains(10) == false)
  }

  @Test("remove missing element returns false")
  func testRemoveMissing() {
    let set = java.util.TreeSet<Int>()
    #expect(set.remove(99) == false)
  }

  // MARK: - clear / isEmpty

  @Test("clear removes all elements")
  func testClear() throws {
    let set = java.util.TreeSet<Int>()
    _ = try set.add(1); _ = try set.add(2)
    set.clear()
    #expect(set.isEmpty() == true)
    #expect(set.size() == 0)
  }

  @Test("isEmpty is true for new set, false after add")
  func testIsEmpty() throws {
    let set = java.util.TreeSet<Int>()
    #expect(set.isEmpty() == true)
    _ = try set.add(1)
    #expect(set.isEmpty() == false)
  }

  // MARK: - iterator

  @Test("iterator visits all elements in ascending order")
  func testIterator() throws {
    let set = java.util.TreeSet<Int>()
    for v in [3, 1, 2] { _ = try set.add(v) }
    let it = set.iterator()
    var result: [Int] = []
    while it.hasNext() {
      result.append(try it.next())
    }
    #expect(result == [1, 2, 3])
  }

  @Test("for-in iteration visits elements in ascending order")
  func testForIn() throws {
    let set = java.util.TreeSet<Int>()
    for v in [5, 2, 4, 1, 3] { _ = try set.add(v) }
    var result: [Int] = []
    for e in set {
      if let v = e { result.append(v) }
    }
    #expect(result == [1, 2, 3, 4, 5])
  }

  // MARK: - toArray

  @Test("toArray returns elements in ascending order")
  func testToArray() throws {
    let set = java.util.TreeSet<Int>()
    for v in [30, 10, 20] { _ = try set.add(v) }
    let arr = set.toArray()
    #expect(arr.compactMap { $0 } == [10, 20, 30])
  }

  // MARK: - SortedSet: first / last

  @Test("first returns the smallest element")
  func testFirst() throws {
    let set = java.util.TreeSet<Int>()
    for v in [4, 2, 6] { _ = try set.add(v) }
    #expect(try set.first() == 2)
  }

  @Test("last returns the largest element")
  func testLast() throws {
    let set = java.util.TreeSet<Int>()
    for v in [4, 2, 6] { _ = try set.add(v) }
    #expect(try set.last() == 6)
  }

  @Test("first on empty set throws NoSuchElementException")
  func testFirstEmpty() {
    let set = java.util.TreeSet<Int>()
    #expect(throws: java.util.NoSuchElementException.self) {
      _ = try set.first()
    }
  }

  @Test("last on empty set throws NoSuchElementException")
  func testLastEmpty() {
    let set = java.util.TreeSet<Int>()
    #expect(throws: java.util.NoSuchElementException.self) {
      _ = try set.last()
    }
  }

  // MARK: - SortedSet: headSet

  @Test("headSet returns elements strictly less than toElement")
  func testHeadSet() throws {
    let set = java.util.TreeSet<Int>()
    for v in 1...6 { _ = try set.add(v) }
    let head = set.headSet(4)
    #expect(head.size() == 3)
    #expect(try head.first() == 1)
    #expect(try head.last() == 3)
    #expect(head.contains(4) == false)
  }

  @Test("headSet with toElement below all elements returns empty view")
  func testHeadSetEmpty() throws {
    let set = java.util.TreeSet<Int>()
    _ = try set.add(5); _ = try set.add(10)
    #expect(set.headSet(3).isEmpty() == true)
  }

  // MARK: - SortedSet: tailSet

  @Test("tailSet returns elements >= fromElement")
  func testTailSet() throws {
    let set = java.util.TreeSet<Int>()
    for v in 1...5 { _ = try set.add(v) }
    let tail = set.tailSet(4)
    #expect(tail.size() == 2)
    #expect(try tail.first() == 4)
    #expect(try tail.last() == 5)
  }

  @Test("tailSet with fromElement above all elements returns empty view")
  func testTailSetEmpty() throws {
    let set = java.util.TreeSet<Int>()
    _ = try set.add(1); _ = try set.add(2)
    #expect(set.tailSet(10).isEmpty() == true)
  }

  // MARK: - SortedSet: subSet

  @Test("subSet returns elements in [fromElement, toElement)")
  func testSubSet() throws {
    let set = java.util.TreeSet<Int>()
    for v in 1...8 { _ = try set.add(v) }
    let sub = set.subSet(3, 7)
    #expect(sub.size() == 4)
    #expect(try sub.first() == 3)
    #expect(try sub.last() == 6)
    #expect(sub.contains(7) == false)
  }

  @Test("subSet with equal bounds returns empty view")
  func testSubSetEqualBounds() throws {
    let set = java.util.TreeSet<Int>()
    _ = try set.add(1); _ = try set.add(2)
    #expect(set.subSet(2, 2).isEmpty() == true)
  }

  // MARK: - Reference semantics

  @Test("TreeSet has reference semantics")
  func testReferenceSemantics() throws {
    let a = java.util.TreeSet<Int>()
    let b = a
    _ = try a.add(42)
    #expect(b.contains(42) == true)
  }

  // MARK: - Contrast with Swift Set

  @Test("Swift Set has value semantics — TreeSet does not")
  func testContrastWithSwiftSet() throws {
    // Swift Set: value type — copy on assignment
    let swiftA = Swift.Set([1, 2, 3])
    var swiftB = swiftA
    swiftB.insert(4)
    #expect(swiftA.count == 3)   // independent

    // TreeSet: reference type — shared mutation
    let javaA = java.util.TreeSet<Int>()
    _ = try javaA.add(1); _ = try javaA.add(2); _ = try javaA.add(3)
    let javaB = javaA
    _ = try javaB.add(4)
    #expect(javaA.size() == 4)   // shared
  }
}
