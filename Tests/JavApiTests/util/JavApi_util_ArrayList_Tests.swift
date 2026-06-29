/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

struct JavApi_util_ArrayList_Tests {

  // MARK: - Basic add / size

  @Test("add returns true and appends element")
  func testAdd() throws {
    let list = java.util.ArrayList<Int>()
    let added = try list.add(42)
    #expect(added == true)
    #expect(list.size() == 1 as Int)
    #expect(try list.get(0) == 42)
  }

  @Test("add multiple elements preserves order")
  func testAddMultiple() throws {
    let list = java.util.ArrayList<String>()
    _ = try? list.add("a")
    _ = try? list.add("b")
    _ = try? list.add("c")
    #expect(list.size() == 3 as Int)
    #expect(try list.get(0) == "a")
    #expect(try list.get(1) == "b")
    #expect(try list.get(2) == "c")
  }

  @Test("empty list has size 0")
  func testEmpty() {
    let list = java.util.ArrayList<Int>()
    #expect(list.isEmpty())
    #expect(list.size() == 0 as Int)
  }

  // MARK: - contains

  @Test("contains finds existing elements")
  func testContains() {
    let list = java.util.ArrayList<Int>()
    _ = try? list.add(1)
    _ = try? list.add(2)
    #expect(list.contains(1))
    #expect(!list.contains(99))
  }

  // MARK: - Reference semantics (vs. Swift Array copy semantics)

  @Test("two variables share the same list — mutation visible through both (Java reference semantics)")
  func testReferenceSemantics_sharedMutation() throws {
    let listA = java.util.ArrayList<Int>()
    let listB = listA
    _ = try? listA.add(7)
    #expect(listB.size() == 1 as Int)
    #expect(try listB.get(0) == 7)
  }

  @Test("mutation through second reference is visible in first (Java reference semantics)")
  func testReferenceSemantics_mutationThroughAlias() throws {
    let listA = java.util.ArrayList<Int>()
    _ = try? listA.add(1)
    let listB = listA
    _ = try? listB.add(2)
    #expect(listA.size() == 2 as Int)
    #expect(try listA.get(1) == 2)
  }

  @Test("remove through alias is visible in original (Java reference semantics)")
  func testReferenceSemantics_removeThroughAlias() throws {
    let listA = java.util.ArrayList<Int>()
    _ = try? listA.add(10)
    _ = try? listA.add(20)
    let listB = listA
    _ = listB.remove(10 as Int?)
    #expect(listA.size() == 1 as Int)
    #expect(try listA.get(0) == 20)
  }

  @Test("clone produces an independent copy (unlike alias assignment)")
  func testCloneIsIndependent() throws {
    let original = java.util.ArrayList<Int>()
    _ = try? original.add(1)
    let copy = original.clone()
    _ = try? copy.add(2)
    #expect(original.size() == 1 as Int)
    #expect(copy.size() == 2 as Int)
  }

  @Test("Swift Array copy-on-write does NOT apply to ArrayList — contrast demonstration")
  func testContrastWithSwiftArray() {
    let swiftA = [1, 2, 3]
    var swiftB = swiftA
    swiftB.append(4)
    #expect(swiftA.count == 3)   // Swift: independent copy

    let javaA = java.util.ArrayList<Int>()
    _ = try? javaA.add(1); _ = try? javaA.add(2); _ = try? javaA.add(3)
    let javaB = javaA
    _ = try? javaB.add(4)
    #expect(javaA.size() == 4 as Int)   // JavApi: shared reference
  }

  // MARK: - insert at index

  @Test("add at index inserts at correct position")
  func testAddAtIndex() throws {
    let list = java.util.ArrayList<Int>()
    _ = try? list.add(1)
    _ = try? list.add(3)
    try list.add(1, 2)
    #expect(list.size() == 3 as Int)
    #expect(try list.get(0) == 1)
    #expect(try list.get(1) == 2)
    #expect(try list.get(2) == 3)
  }

  @Test("add at index out of bounds throws")
  func testAddAtIndexOutOfBounds() {
    let list = java.util.ArrayList<Int>()
    #expect(throws: (any Error).self) {
      try list.add(1, 99)
    }
  }

  // MARK: - set

  @Test("set replaces element and returns old value")
  func testSet() throws {
    let list = java.util.ArrayList<String>()
    _ = try? list.add("x")
    let old = try list.set(0, "y")
    #expect(old == "x")
    #expect(try list.get(0) == "y")
  }

  // MARK: - remove by index

  @Test("remove by index returns removed element")
  func testRemoveByIndex() throws {
    let list = java.util.ArrayList<Int>()
    _ = try? list.add(10)
    _ = try? list.add(20)
    let removed = try list.remove(0)
    #expect(removed == 10)
    #expect(list.size() == 1 as Int)
    #expect(try list.get(0) == 20)
  }

  // MARK: - remove by value

  @Test("remove by value removes first occurrence only")
  func testRemoveByValue() throws {
    let list = java.util.ArrayList<Int>()
    _ = try? list.add(5)
    _ = try? list.add(5)
    let result = list.remove(5 as Int?)
    #expect(result == true)
    #expect(list.size() == 1 as Int)
    #expect(try list.get(0) == 5)
  }

  @Test("remove by value returns false when not found")
  func testRemoveByValueNotFound() {
    let list = java.util.ArrayList<Int>()
    _ = try? list.add(1)
    #expect(list.remove(99 as Int?) == false)
  }

  // MARK: - indexOf / lastIndexOf

  @Test("indexOf returns first occurrence")
  func testIndexOf() {
    let list = java.util.ArrayList<String>()
    _ = try? list.add("a")
    _ = try? list.add("b")
    _ = try? list.add("a")
    #expect(list.indexOf(element: "a") == 0)
  }

  @Test("lastIndexOf returns last occurrence")
  func testLastIndexOf() {
    let list = java.util.ArrayList<String>()
    _ = try? list.add("a")
    _ = try? list.add("b")
    _ = try? list.add("a")
    #expect(list.lastIndexOf("a") == 2)
  }

  // MARK: - clear

  @Test("clear removes all elements")
  func testClear() {
    let list = java.util.ArrayList<Int>()
    _ = try? list.add(1)
    _ = try? list.add(2)
    list.clear()
    #expect(list.isEmpty())
  }

  // MARK: - subList

  @Test("subList returns correct elements via view")
  func testSubList() throws {
    let list = java.util.ArrayList<Int>()
    for i in 0..<5 { _ = try? list.add(i) }
    let sub = list.subList(1, 4) as! ArrayListSubList<Int>   // view over [1,2,3]
    #expect(sub.size() == 3 as Int)
    #expect(try sub.get(0) == 1)
    #expect(try sub.get(2) == 3)
  }

  // MARK: - for-in (Swift Sequence)

  @Test("for-in iteration visits all elements in order")
  func testForIn() {
    let list = java.util.ArrayList<Int>()
    _ = try? list.add(10)
    _ = try? list.add(20)
    _ = try? list.add(30)
    var result : [Int] = []
    for element in list {
      if let e = element { result.append(e) }
    }
    #expect(result == [10, 20, 30])
  }

  // MARK: - toArray

  @Test("toArray returns all elements")
  func testToArray() {
    let list = java.util.ArrayList<Int>()
    _ = try? list.add(1)
    _ = try? list.add(2)
    _ = try? list.add(3)
    let array = list.toArray()
    #expect(array.count == 3)
    #expect(array[0] == 1)
    #expect(array[2] == 3)
  }

  // MARK: - Equatable

  @Test("equal lists compare as equal")
  func testEquatable_equalLists() throws {
    let a = java.util.ArrayList<String>()
    let b = java.util.ArrayList<String>()
    _ = try? a.add("x"); _ = try? a.add("y")
    _ = try? b.add("x"); _ = try? b.add("y")
    #expect(a == b)
  }

  @Test("lists with different elements compare as not equal")
  func testEquatable_differentElements() throws {
    let a = java.util.ArrayList<Int>()
    let b = java.util.ArrayList<Int>()
    _ = try? a.add(1)
    _ = try? b.add(2)
    #expect(a != b)
  }

  @Test("lists with different sizes compare as not equal")
  func testEquatable_differentSizes() throws {
    let a = java.util.ArrayList<Int>()
    let b = java.util.ArrayList<Int>()
    _ = try? a.add(1)
    _ = try? b.add(1); _ = try? b.add(2)
    #expect(a != b)
  }

  @Test("empty lists compare as equal")
  func testEquatable_emptyLists() {
    let a = java.util.ArrayList<Int>()
    let b = java.util.ArrayList<Int>()
    #expect(a == b)
  }

  @Test("nested ArrayList<ArrayList<String>> equality works")
  func testEquatable_nested() throws {
    let inner1 = java.util.ArrayList<String>()
    _ = try? inner1.add("hello")
    let inner2 = java.util.ArrayList<String>()
    _ = try? inner2.add("hello")

    let outer1 = java.util.ArrayList<java.util.ArrayList<String>>()
    _ = try? outer1.add(inner1)
    let outer2 = java.util.ArrayList<java.util.ArrayList<String>>()
    _ = try? outer2.add(inner2)

    #expect(outer1 == outer2)
  }

  @Test("nested ArrayList with different content compares as not equal")
  func testEquatable_nestedNotEqual() throws {
    let inner1 = java.util.ArrayList<String>()
    _ = try? inner1.add("a")
    let inner2 = java.util.ArrayList<String>()
    _ = try? inner2.add("b")

    let outer1 = java.util.ArrayList<java.util.ArrayList<String>>()
    _ = try? outer1.add(inner1)
    let outer2 = java.util.ArrayList<java.util.ArrayList<String>>()
    _ = try? outer2.add(inner2)

    #expect(outer1 != outer2)
  }

  // MARK: - subList view semantics
  // Note: subList() returns `any java.util.List` (existential). Swift restricts
  // calling generic methods like get/set/add on existentials directly, so we
  // cast to the concrete ArrayListSubList<T> to access typed operations.

  @Test("subList is a live view — mutation through view is visible in original")
  func testSubList_mutationVisibleInOriginal() throws {
    let list = java.util.ArrayList<Int>()
    for i in 0..<5 { _ = try? list.add(i) }   // [0,1,2,3,4]

    let sub = list.subList(1, 4) as! ArrayListSubList<Int>   // view over [1,2,3]
    _ = try? sub.set(0, 99)                    // sub[0] → index 1 in original
    #expect((try list.get(1)) == 99, "Mutation through subList view must be visible in original")
  }

  @Test("subList is a live view — mutation in original is visible through view")
  func testSubList_mutationInOriginalVisibleInView() throws {
    let list = java.util.ArrayList<Int>()
    for i in 0..<5 { _ = try? list.add(i) }   // [0,1,2,3,4]

    let sub = list.subList(1, 4) as! ArrayListSubList<Int>   // view over [1,2,3]
    _ = try? list.set(2, 77)                   // original index 2 → sub index 1
    #expect((try sub.get(1)) == 77, "Mutation in original must be visible through subList view")
  }

  @Test("subList size matches requested range")
  func testSubList_size() throws {
    let list = java.util.ArrayList<Int>()
    for i in 0..<5 { _ = try? list.add(i) }

    #expect(list.subList(1, 4).size() == 3 as Int)
    #expect(list.subList(0, 5).size() == 5 as Int)
    #expect(list.subList(2, 2).isEmpty())
  }

  @Test("subList range boundaries are inclusive-start, exclusive-end")
  func testSubList_rangeBoundaries() throws {
    let list = java.util.ArrayList<String>()
    for s in ["a","b","c","d","e"] { _ = try? list.add(s) }

    let sub = list.subList(0, 3) as! ArrayListSubList<String>   // view: [a,b,c]
    #expect(sub.size() == 3 as Int)
    #expect((try sub.get(0)) == "a")
    #expect((try sub.get(2)) == "c")
  }

  @Test("subList.clear() removes the range from the original list")
  func testSubList_clearRemovesFromOriginal() {
    let list = java.util.ArrayList<Int>()
    for i in [1, 2, 3, 4, 5] { _ = try? list.add(i) }

    let sub = list.subList(1, 4) as! ArrayListSubList<Int>   // view over [2,3,4]
    sub.clear()
    #expect(list.size() == 2 as Int)
    #expect(list.contains(1))
    #expect(list.contains(5))
    #expect(!list.contains(2))
    #expect(!list.contains(3))
    #expect(!list.contains(4))
  }

  @Test("subList.add() inserts into the original list at the correct position")
  func testSubList_addInsertsIntoOriginal() throws {
    let list = java.util.ArrayList<Int>()
    for i in [1, 2, 4, 5] { _ = try? list.add(i) }

    let sub = list.subList(1, 3) as! ArrayListSubList<Int>   // view over [2,4]
    _ = try? sub.add(1, 3)        // insert 3 at sub-index 1 → original index 2
    #expect(list.size() == 5 as Int)
    #expect((try list.get(2)) == 3)
    #expect(sub.size() == 3 as Int)
  }

  @Test("subList of subList produces a nested view")
  func testSubList_ofSubList() throws {
    let list = java.util.ArrayList<Int>()
    for i in 0..<6 { _ = try? list.add(i) }   // [0,1,2,3,4,5]

    let sub1 = list.subList(1, 5) as! ArrayListSubList<Int>   // view: [1,2,3,4]
    let sub2 = sub1.subList(1, 3) as! ArrayListSubList<Int>   // view: [2,3]
    #expect(sub2.size() == 2 as Int)
    #expect((try sub2.get(0)) == 2)

    // Mutation through nested view propagates to original
    _ = try? sub2.set(0, 99)
    #expect((try list.get(2)) == 99)
  }

  // MARK: - null elements

  @Test("add(nil) is accepted — ArrayList allows null elements")
  func testNull_add() throws {
    let list = java.util.ArrayList<String>()
    _ = try? list.add("before")
    _ = try? list.add(nil as String?)
    _ = try? list.add("after")
    #expect(list.size() == 3 as Int)
    let middle: String? = try list.get(1)
    #expect(middle == nil)
  }

  @Test("contains(nil) finds a nil element")
  func testNull_contains() {
    let list = java.util.ArrayList<String>()
    _ = try? list.add(nil as String?)
    #expect(list.contains(nil as String?))
  }

  @Test("contains(nil) returns false when no nil element present")
  func testNull_containsFalse() {
    let list = java.util.ArrayList<String>()
    _ = try? list.add("x")
    #expect(!list.contains(nil as String?))
  }

  @Test("indexOf(nil) returns first nil position")
  func testNull_indexOf() {
    let list = java.util.ArrayList<String>()
    _ = try? list.add("a")
    _ = try? list.add(nil as String?)
    _ = try? list.add(nil as String?)
    #expect(list.indexOf(element: nil as String?) == 1)
  }

  @Test("lastIndexOf(nil) returns last nil position")
  func testNull_lastIndexOf() {
    let list = java.util.ArrayList<String>()
    _ = try? list.add(nil as String?)
    _ = try? list.add("a")
    _ = try? list.add(nil as String?)
    #expect(list.lastIndexOf(nil as String?) == 2)
  }

  @Test("remove(nil) removes first nil element")
  func testNull_remove() throws {
    let list = java.util.ArrayList<String>()
    _ = try? list.add("a")
    _ = try? list.add(nil as String?)
    _ = try? list.add("b")
    let removed = list.remove(nil as String?)
    #expect(removed == true)
    #expect(list.size() == 2 as Int)
    #expect(!list.contains(nil as String?))
  }

  // MARK: - addAll / removeAll / retainAll

  @Test("addAll appends all elements from another collection")
  func testAddAll() throws {
    let base = java.util.ArrayList<Int>()
    _ = try? base.add(1)
    _ = try? base.add(2)

    let extra = java.util.ArrayList<Int?>()
    _ = try? extra.add(3)
    _ = try? extra.add(4)

    let changed = try base.addAll(extra)
    #expect(changed == true)
    #expect(base.size() == 4 as Int)
    #expect((try base.get(2)) == 3)
    #expect((try base.get(3)) == 4)
  }

  @Test("addAll with empty collection returns false and does not modify list")
  func testAddAll_empty() throws {
    let list = java.util.ArrayList<Int>()
    _ = try? list.add(1)
    let empty = java.util.ArrayList<Int?>()
    let changed = try list.addAll(empty)
    #expect(changed == false)
    #expect(list.size() == 1 as Int)
  }

  @Test("removeAll removes all elements that appear in the given collection")
  func testRemoveAll() {
    let list = java.util.ArrayList<Int>()
    for i in [1, 2, 3, 4, 5] { _ = try? list.add(i) }

    let toRemove = java.util.ArrayList<Int?>()
    _ = try? toRemove.add(2)
    _ = try? toRemove.add(4)

    let changed = list.removeAll(toRemove)
    #expect(changed == true)
    #expect(list.size() == 3 as Int)
    #expect(!list.contains(2))
    #expect(!list.contains(4))
    #expect(list.contains(1))
    #expect(list.contains(3))
    #expect(list.contains(5))
  }

  @Test("removeAll returns false when no element matches")
  func testRemoveAll_noMatch() {
    let list = java.util.ArrayList<Int>()
    _ = try? list.add(1)
    _ = try? list.add(2)
    let other = java.util.ArrayList<Int?>()
    _ = try? other.add(99)
    #expect(list.removeAll(other) == false)
    #expect(list.size() == 2 as Int)
  }

  @Test("retainAll keeps only elements present in the given collection")
  func testRetainAll() {
    let list = java.util.ArrayList<Int>()
    for i in [1, 2, 3, 4, 5] { _ = try? list.add(i) }

    let toKeep = java.util.ArrayList<Int?>()
    _ = try? toKeep.add(2)
    _ = try? toKeep.add(4)

    let changed = list.retainAll(toKeep)
    #expect(changed == true)
    #expect(list.size() == 2 as Int)
    #expect(list.contains(2))
    #expect(list.contains(4))
    #expect(!list.contains(1))
    #expect(!list.contains(3))
    #expect(!list.contains(5))
  }

  @Test("retainAll returns false when all elements already match")
  func testRetainAll_noChange() {
    let list = java.util.ArrayList<Int>()
    _ = try? list.add(1)
    _ = try? list.add(2)
    let keep = java.util.ArrayList<Int?>()
    _ = try? keep.add(1)
    _ = try? keep.add(2)
    _ = try? keep.add(3)  // extra element in keep — does not matter
    #expect(list.retainAll(keep) == false)
    #expect(list.size() == 2 as Int)
  }

  // MARK: - listIterator

  @Test("listIterator traverses forward and backward")
  func testListIterator_forwardBackward() throws {
    let list = java.util.ArrayList<Int>()
    for i in [10, 20, 30] { _ = try? list.add(i) }
    let it = list.listIterator()

    #expect(try it.next() == 10)
    #expect(try it.next() == 20)
    #expect(try it.previous() == 20)
    #expect(try it.previous() == 10)
    #expect(!it.hasPrevious())
  }

  @Test("listIterator(index) starts at given position")
  func testListIterator_startAtIndex() throws {
    let list = java.util.ArrayList<String>()
    for s in ["a","b","c"] { _ = try? list.add(s) }
    let it = list.listIterator(2)

    #expect(it.nextIndex() == 2)
    #expect(try it.next() == "c")
    #expect(!it.hasNext())
  }

  @Test("listIterator.set replaces last returned element")
  func testListIterator_set() throws {
    let list = java.util.ArrayList<Int>()
    _ = try? list.add(1)
    _ = try? list.add(2)
    _ = try? list.add(3)
    let it = list.listIterator()
    _ = try it.next()  // returns 1
    it.set(99)
    #expect((try list.get(0)) == 99)
  }

  @Test("listIterator.add inserts before next element")
  func testListIterator_add() throws {
    let list = java.util.ArrayList<Int>()
    _ = try? list.add(1)
    _ = try? list.add(3)
    let it = list.listIterator()
    _ = try it.next()  // moves past 1
    it.add(2)          // inserts 2 between 1 and 3
    #expect(list.size() == 3 as Int)
    #expect((try list.get(1)) == 2)
    #expect((try list.get(2)) == 3)
  }

  // MARK: - Iterator.remove

  @Test("listIterator.remove deletes last returned element")
  func testIterator_remove() throws {
    let list = java.util.ArrayList<Int>()
    for i in [1, 2, 3] { _ = try? list.add(i) }
    let it = list.listIterator()
    _ = try it.next()  // 1
    _ = try it.next()  // 2
    try it.remove()    // removes 2
    #expect(list.size() == 2 as Int)
    #expect(list.contains(1))
    #expect(!list.contains(2))
    #expect(list.contains(3))
  }

  @Test("listIterator.remove without prior next throws IllegalStateException")
  func testIterator_removeWithoutNext() {
    let list = java.util.ArrayList<Int>()
    _ = try? list.add(1)
    let it = list.listIterator()
    #expect(throws: IllegalStateException.self) {
      try it.remove()
    }
  }

  // MARK: - hashCode

  @Test("hashCode is consistent across calls")
  func testHashCode_stable() {
    let list = java.util.ArrayList<Int>()
    _ = try? list.add(1)
    _ = try? list.add(2)
    #expect(list.hashCode() == list.hashCode())
  }

  @Test("equal lists have equal hashCodes")
  func testHashCode_equalLists() {
    let a = java.util.ArrayList<Int>()
    let b = java.util.ArrayList<Int>()
    _ = try? a.add(1); _ = try? a.add(2)
    _ = try? b.add(1); _ = try? b.add(2)
    #expect(a.hashCode() == b.hashCode())
  }

  @Test("different lists have different hashCodes")
  func testHashCode_differentLists() {
    let a = java.util.ArrayList<Int>()
    let b = java.util.ArrayList<Int>()
    _ = try? a.add(1)
    _ = try? b.add(2)
    #expect(a.hashCode() != b.hashCode())
  }
}
