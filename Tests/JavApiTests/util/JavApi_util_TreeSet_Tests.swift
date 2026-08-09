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

  // MARK: - Equatable

  @Test("equal tree sets compare as equal")
  func testEquatable_equal() throws {
    let a = java.util.TreeSet<Int>()
    let b = java.util.TreeSet<Int>()
    _ = try a.add(1); _ = try a.add(2)
    _ = try b.add(2); _ = try b.add(1)  // different insertion order, same sorted result
    #expect(a == b)
  }

  @Test("tree sets with different elements compare as not equal")
  func testEquatable_differentElements() throws {
    let a = java.util.TreeSet<Int>()
    let b = java.util.TreeSet<Int>()
    _ = try a.add(1)
    _ = try b.add(2)
    #expect(a != b)
  }

  @Test("tree sets with different sizes compare as not equal")
  func testEquatable_differentSizes() throws {
    let a = java.util.TreeSet<Int>()
    let b = java.util.TreeSet<Int>()
    _ = try a.add(1)
    _ = try b.add(1); _ = try b.add(2)
    #expect(a != b)
  }

  @Test("empty tree sets compare as equal")
  func testEquatable_empty() {
    let a = java.util.TreeSet<Int>()
    let b = java.util.TreeSet<Int>()
    #expect(a == b)
  }

  // MARK: - comparator() / init(comparator:)

  @Test("init() yields nil comparator")
  func testComparatorNilForNaturalOrder() {
    let set = java.util.TreeSet<Int>()
    #expect(set.comparator() == nil)
  }

  @Test("init(comparator:) stores comparator and sorts by it")
  func testComparatorDescendingOrder() throws {
    // Reverse-order comparator: larger values sort first
    let cmp: any java.util.Comparator<Int> = java.util.Collections.reverseOrder()
    let set = java.util.TreeSet<Int>(comparator: cmp)
    _ = try set.add(3)
    _ = try set.add(1)
    _ = try set.add(2)
    #expect(set.comparator() != nil)
    // Internal array must be in descending order (3, 2, 1)
    #expect(set._elements == [3, 2, 1])
  }

  @Test("comparator TreeSet: first() returns largest element, last() returns smallest")
  func testComparatorFirstLast() throws {
    let cmp: any java.util.Comparator<Int> = java.util.Collections.reverseOrder()
    let set = java.util.TreeSet<Int>(comparator: cmp)
    _ = try set.add(5); _ = try set.add(1); _ = try set.add(3)
    #expect(try set.first() == 5)
    #expect(try set.last() == 1)
  }

  @Test("comparator TreeSet: contains and remove use comparator")
  func testComparatorContainsRemove() throws {
    let cmp: any java.util.Comparator<Int> = java.util.Collections.reverseOrder()
    let set = java.util.TreeSet<Int>(comparator: cmp)
    _ = try set.add(10); _ = try set.add(20)
    #expect(set.contains(10) == true)
    #expect(set.remove(10) == true)
    #expect(set.size() == 1)
  }

  // MARK: - init(sortedSet:)

  @Test("init(sortedSet:) copies elements from a SortedSet in order")
  func testInitSortedSet() throws {
    let source = java.util.TreeSet<Int>()
    _ = try source.add(30); _ = try source.add(10); _ = try source.add(20)
    let copy = java.util.TreeSet<Int>(sortedSet: source)
    #expect(copy.size() == 3)
    #expect(copy._elements == [10, 20, 30])
  }

  @Test("init(sortedSet:) produces independent copy")
  func testInitSortedSetIsIndependent() throws {
    let source = java.util.TreeSet<Int>()
    _ = try source.add(1); _ = try source.add(2)
    let copy = java.util.TreeSet<Int>(sortedSet: source)
    _ = try source.add(3)
    #expect(copy.size() == 2)   // copy not affected by later modification of source
  }

  // MARK: - clone()

  @Test("clone() returns an independent copy with same elements")
  func testClone() throws {
    let original = java.util.TreeSet<Int>()
    _ = try original.add(1); _ = try original.add(2); _ = try original.add(3)
    let copy = original.clone()
    #expect(copy.size() == 3)
    #expect(copy._elements == original._elements)
    // Modifying clone does not affect original
    _ = try copy.add(4)
    #expect(original.size() == 3)
  }

  @Test("clone() preserves custom comparator ordering")
  func testClonePreservesComparator() throws {
    let cmp: any java.util.Comparator<Int> = java.util.Collections.reverseOrder()
    let original = java.util.TreeSet<Int>(comparator: cmp)
    _ = try original.add(1); _ = try original.add(3); _ = try original.add(2)
    let copy = original.clone()
    #expect(copy._elements == [3, 2, 1])   // descending preserved
    #expect(copy.comparator() != nil)
  }

  // MARK: - Comparator propagation in range views

  @Test("headSet with comparator filters by comparator ordering")
  func testHeadSetWithComparator() throws {
    let cmp: any java.util.Comparator<Int> = java.util.Collections.reverseOrder()
    let set = java.util.TreeSet<Int>(comparator: cmp)
    for v in [5, 3, 1, 4, 2] { _ = try set.add(v) }
    // _elements = [5,4,3,2,1] (reverseOrder)
    // headSet(3) in reverseOrder: elements where reverseOrder(el, 3) < 0 ↔ el > 3 → {5,4}
    let head = set.headSet(3)
    #expect(head.size() == 2)
    #expect(head.contains(5) == true)
    #expect(head.contains(4) == true)
    #expect(head.contains(3) == false)
  }

  @Test("tailSet with comparator filters by comparator ordering")
  func testTailSetWithComparator() throws {
    let cmp: any java.util.Comparator<Int> = java.util.Collections.reverseOrder()
    let set = java.util.TreeSet<Int>(comparator: cmp)
    for v in [5, 3, 1, 4, 2] { _ = try set.add(v) }
    // tailSet(3) in reverseOrder: elements where reverseOrder(el, 3) >= 0 ↔ el <= 3 → {3,2,1}
    let tail = set.tailSet(3)
    #expect(tail.size() == 3)
    #expect(tail.contains(3) == true)
    #expect(tail.contains(2) == true)
    #expect(tail.contains(1) == true)
    #expect(tail.contains(4) == false)
  }

  @Test("subSet with comparator filters by comparator ordering")
  func testSubSetWithComparator() throws {
    let cmp: any java.util.Comparator<Int> = java.util.Collections.reverseOrder()
    let set = java.util.TreeSet<Int>(comparator: cmp)
    for v in [5, 3, 1, 4, 2] { _ = try set.add(v) }
    // subSet(4, 2) in reverseOrder: from=4 inclusive, to=2 exclusive → {4,3}
    let sub = set.subSet(4, 2)
    #expect(sub.size() == 2)
    #expect(sub.contains(4) == true)
    #expect(sub.contains(3) == true)
    #expect(sub.contains(2) == false)
    #expect(sub.contains(5) == false)
  }

  @Test("headSet inclusive with comparator filters by comparator ordering")
  func testHeadSetInclusiveWithComparator() throws {
    let cmp: any java.util.Comparator<Int> = java.util.Collections.reverseOrder()
    let set = java.util.TreeSet<Int>(comparator: cmp)
    for v in [5, 3, 1, 4, 2] { _ = try set.add(v) }
    // headSet(3, inclusive:true): elements where reverseOrder(el, 3) <= 0 ↔ el >= 3 → {5,4,3}
    let head = set.headSet(3, true)
    #expect(head.size() == 3)
    #expect(head.contains(3) == true)
    #expect(head.contains(5) == true)
    // headSet(3, inclusive:false): el > 3 → {5,4}
    let headEx = set.headSet(3, false)
    #expect(headEx.size() == 2)
    #expect(headEx.contains(3) == false)
  }

  @Test("subView headSet/tailSet use inherited comparator")
  func testSubViewInheritsComparator() throws {
    let cmp: any java.util.Comparator<Int> = java.util.Collections.reverseOrder()
    let set = java.util.TreeSet<Int>(comparator: cmp)
    for v in [10, 8, 6, 4, 2] { _ = try set.add(v) }
    // headSet(8) → {10} (elements where reverseOrder < 0 ↔ el > 8)
    let head = set.headSet(8)
    // headSet(6) on the sub-view → elements of {10} where reverseOrder(el, 6) < 0 ↔ el > 6 → {10}
    let subHead = head.headSet(6)
    #expect(subHead.size() == 1)
    #expect(subHead.contains(10) == true)
  }

  @Test("descendingSet lower/floor/ceiling/higher use comparator")
  func testDescendingSetNavigationWithComparator() throws {
    let cmp: any java.util.Comparator<Int> = java.util.Collections.reverseOrder()
    let set = java.util.TreeSet<Int>(comparator: cmp)
    for v in [1, 3, 5, 7, 9] { _ = try set.add(v) }
    // set._elements = [9,7,5,3,1] (reverseOrder)
    // descendingSet is ordered by REVERSE of reverseOrder = natural order → [1,3,5,7,9]
    let desc = set.descendingSet()
    // In descending set (natural order), lower(5) = greatest < 5 in natural = 3
    #expect(desc.lower(5) == 3)
    // floor(5) = greatest ≤ 5 in natural = 5
    #expect(desc.floor(5) == 5)
    // floor(4) = greatest ≤ 4 in natural = 3
    #expect(desc.floor(4) == 3)
    // ceiling(5) = least ≥ 5 in natural = 5
    #expect(desc.ceiling(5) == 5)
    // ceiling(4) = least ≥ 4 in natural = 5
    #expect(desc.ceiling(4) == 5)
    // higher(5) = least > 5 in natural = 7
    #expect(desc.higher(5) == 7)
  }
}
