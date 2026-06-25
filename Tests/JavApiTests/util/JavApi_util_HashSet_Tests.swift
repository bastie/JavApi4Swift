/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

struct JavApi_util_HashSet_Tests {

  // MARK: - Basic add / size / isEmpty

  @Test("empty set has size 0 and isEmpty true")
  func testEmpty() {
    let set = java.util.HashSet<Int>()
    #expect(set.isEmpty())
    #expect(set.size() == 0)
  }

  @Test("add returns true for new element")
  func testAddNew() throws {
    let set = java.util.HashSet<Int>()
    let added = try set.add(42)
    #expect(added == true)
    #expect(set.size() == 1)
  }

  @Test("add returns false for duplicate element")
  func testAddDuplicate() throws {
    let set = java.util.HashSet<Int>()
    _ = try set.add(1)
    let addedAgain = try set.add(1)
    #expect(addedAgain == false)
    #expect(set.size() == 1)
  }

  @Test("add multiple distinct elements")
  func testAddMultiple() throws {
    let set = java.util.HashSet<String>()
    _ = try set.add("a")
    _ = try set.add("b")
    _ = try set.add("c")
    #expect(set.size() == 3)
  }

  // MARK: - contains

  @Test("contains finds added element")
  func testContainsFound() throws {
    let set = java.util.HashSet<Int>()
    _ = try set.add(7)
    #expect(set.contains(7))
  }

  @Test("contains returns false for absent element")
  func testContainsAbsent() throws {
    let set = java.util.HashSet<Int>()
    _ = try set.add(1)
    #expect(!set.contains(99))
  }

  // MARK: - Set semantics (no duplicates)

  @Test("adding same value twice keeps size at 1")
  func testNoDuplicates() throws {
    let set = java.util.HashSet<String>()
    _ = try set.add("hello")
    _ = try set.add("hello")
    _ = try set.add("hello")
    #expect(set.size() == 1)
  }

  // MARK: - remove

  @Test("remove returns true and shrinks size")
  func testRemove() throws {
    let set = java.util.HashSet<Int>()
    _ = try set.add(10)
    let removed = set.remove(10 as Int?)
    #expect(removed == true)
    #expect(set.size() == 0)
    #expect(!set.contains(10))
  }

  @Test("remove returns false for absent element")
  func testRemoveAbsent() {
    let set = java.util.HashSet<Int>()
    #expect(set.remove(99 as Int?) == false)
  }

  @Test("remove leaves other elements intact")
  func testRemoveLeavesOthers() throws {
    let set = java.util.HashSet<Int>()
    _ = try set.add(1)
    _ = try set.add(2)
    _ = try set.add(3)
    _ = set.remove(2 as Int?)
    #expect(set.size() == 2)
    #expect(set.contains(1))
    #expect(!set.contains(2))
    #expect(set.contains(3))
  }

  // MARK: - clear

  @Test("clear removes all elements")
  func testClear() throws {
    let set = java.util.HashSet<Int>()
    _ = try set.add(1)
    _ = try set.add(2)
    set.clear()
    #expect(set.isEmpty())
    #expect(set.size() == 0)
    #expect(!set.contains(1))
  }

  // MARK: - iterator

  @Test("iterator visits all elements exactly once")
  func testIterator() throws {
    let set = java.util.HashSet<Int>()
    _ = try set.add(1)
    _ = try set.add(2)
    _ = try set.add(3)
    var seen: [Int] = []
    let it = set.iterator()
    while it.hasNext() {
      if let v = try? it.next() { seen.append(v) }
    }
    #expect(seen.sorted() == [1, 2, 3])
  }

  @Test("iterator on empty set has no next")
  func testIteratorEmpty() {
    let set = java.util.HashSet<Int>()
    let it = set.iterator()
    #expect(!it.hasNext())
  }

  // MARK: - for-in (Swift Sequence via AbstractCollection)

  @Test("for-in iterates all elements")
  func testForIn() throws {
    let set = java.util.HashSet<Int>()
    _ = try set.add(10)
    _ = try set.add(20)
    _ = try set.add(30)
    var sum = 0
    for elem in set {
      if let e = elem { sum += e }
    }
    #expect(sum == 60)
  }

  // MARK: - Reference semantics

  @Test("two variables share the same set — mutation visible through both")
  func testReferenceSemantics() throws {
    let setA = java.util.HashSet<Int>()
    let setB = setA
    _ = try setA.add(99)
    #expect(setB.contains(99))
    #expect(setB.size() == 1)
  }

  // MARK: - clone

  @Test("clone produces independent copy")
  func testClone() throws {
    let original = java.util.HashSet<Int>()
    _ = try original.add(1)
    _ = try original.add(2)
    let copy = original.clone()
    _ = try copy.add(3)
    #expect(original.size() == 2)
    #expect(copy.size() == 3)
    #expect(!original.contains(3))
  }

  // MARK: - containsAll / addAll

  @Test("containsAll returns true when all elements present")
  func testContainsAll() throws {
    let set = java.util.HashSet<Int>()
    _ = try set.add(1)
    _ = try set.add(2)
    _ = try set.add(3)
    let other = java.util.HashSet<Int?>()
    _ = try other.add(1)
    _ = try other.add(3)
    #expect(set.containsAll(other))
  }

  @Test("containsAll returns false when element missing")
  func testContainsAllMissing() throws {
    let set = java.util.HashSet<Int>()
    _ = try set.add(1)
    _ = try set.add(2)
    let other = java.util.HashSet<Int?>()
    _ = try other.add(1)
    _ = try other.add(99)
    #expect(!set.containsAll(other))
  }

  // MARK: - initialCapacity constructor

  @Test("initialCapacity constructor works normally")
  func testInitialCapacity() throws {
    let set = java.util.HashSet<String>(initialCapacity: 64)
    _ = try set.add("hello")
    #expect(set.size() == 1)
    #expect(set.contains("hello"))
  }

  // MARK: - Equatable

  @Test("equal sets compare as equal")
  func testEquatable_equal() throws {
    let a = java.util.HashSet<String>()
    let b = java.util.HashSet<String>()
    _ = try a.add("x"); _ = try a.add("y")
    _ = try b.add("y"); _ = try b.add("x")  // different insertion order
    #expect(a == b)
  }

  @Test("sets with different elements compare as not equal")
  func testEquatable_differentElements() throws {
    let a = java.util.HashSet<Int>()
    let b = java.util.HashSet<Int>()
    _ = try a.add(1)
    _ = try b.add(2)
    #expect(a != b)
  }

  @Test("sets with different sizes compare as not equal")
  func testEquatable_differentSizes() throws {
    let a = java.util.HashSet<Int>()
    let b = java.util.HashSet<Int>()
    _ = try a.add(1)
    _ = try b.add(1); _ = try b.add(2)
    #expect(a != b)
  }

  @Test("empty sets compare as equal")
  func testEquatable_empty() {
    let a = java.util.HashSet<Int>()
    let b = java.util.HashSet<Int>()
    #expect(a == b)
  }
}
