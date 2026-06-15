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

  @Test("subList returns correct elements")
  func testSubList() throws {
    let list = java.util.ArrayList<Int>()
    for i in 0..<5 { _ = try? list.add(i) }
    let sub = list.subList(1, 4) as! java.util.ArrayList<Int>  // [1, 2, 3]
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
}
