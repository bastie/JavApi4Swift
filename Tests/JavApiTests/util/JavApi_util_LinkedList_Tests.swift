/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

struct JavApi_util_LinkedList_Tests {

  // MARK: - Construction

  @Test("empty list has size 0")
  func testEmpty() {
    let list = java.util.LinkedList<Int>()
    #expect(list.isEmpty())
    #expect(list.size() == 0)
  }

  @Test("init(collection:) copies all elements in order")
  func testInitFromCollection() throws {
    let src = java.util.ArrayList<Int>()
    _ = try src.add(1); _ = try src.add(2); _ = try src.add(3)
    let list = java.util.LinkedList<Int>(collection: src)
    #expect(list.size() == 3)
    #expect(try list.get(0) == 1)
    #expect(try list.get(2) == 3)
  }

  // MARK: - add / get

  @Test("add appends elements and preserves order")
  func testAdd() throws {
    let list = java.util.LinkedList<String>()
    _ = try list.add("a")
    _ = try list.add("b")
    _ = try list.add("c")
    #expect(list.size() == 3)
    #expect(try list.get(0) == "a")
    #expect(try list.get(1) == "b")
    #expect(try list.get(2) == "c")
  }

  @Test("add at index inserts at correct position")
  func testAddAtIndex() throws {
    let list = java.util.LinkedList<Int>()
    _ = try list.add(1); _ = try list.add(3)
    try list.add(1, 2)
    #expect(list.size() == 3)
    #expect(try list.get(0) == 1)
    #expect(try list.get(1) == 2)
    #expect(try list.get(2) == 3)
  }

  @Test("add at index 0 prepends")
  func testAddAtIndexZero() throws {
    let list = java.util.LinkedList<Int>()
    _ = try list.add(2)
    try list.add(0, 1)
    #expect(try list.get(0) == 1)
    #expect(try list.get(1) == 2)
  }

  @Test("add at out-of-bounds index throws")
  func testAddAtIndexOutOfBounds() {
    let list = java.util.LinkedList<Int>()
    #expect(throws: (any Error).self) { try list.add(1, 99) }
  }

  @Test("get out-of-bounds throws")
  func testGetOutOfBounds() {
    let list = java.util.LinkedList<Int>()
    #expect(throws: (any Error).self) { try list.get(0) }
  }

  // MARK: - set

  @Test("set replaces element and returns old value")
  func testSet() throws {
    let list = java.util.LinkedList<String>()
    _ = try list.add("x")
    let old = try list.set(0, "y")
    #expect(old == "x")
    #expect(try list.get(0) == "y")
  }

  // MARK: - remove by index

  @Test("remove by index returns removed element and shrinks list")
  func testRemoveByIndex() throws {
    let list = java.util.LinkedList<Int>()
    _ = try list.add(10); _ = try list.add(20); _ = try list.add(30)
    let removed = try list.remove(1)
    #expect(removed == 20)
    #expect(list.size() == 2)
    #expect(try list.get(0) == 10)
    #expect(try list.get(1) == 30)
  }

  @Test("remove first element by index")
  func testRemoveFirstByIndex() throws {
    let list = java.util.LinkedList<Int>()
    _ = try list.add(1); _ = try list.add(2)
    _ = try list.remove(0)
    #expect(list.size() == 1)
    #expect(try list.get(0) == 2)
  }

  @Test("remove last element by index")
  func testRemoveLastByIndex() throws {
    let list = java.util.LinkedList<Int>()
    _ = try list.add(1); _ = try list.add(2)
    _ = try list.remove(1)
    #expect(list.size() == 1)
    #expect(try list.get(0) == 1)
  }

  @Test("remove by index out-of-bounds throws")
  func testRemoveByIndexOutOfBounds() {
    let list = java.util.LinkedList<Int>()
    #expect(throws: (any Error).self) { try list.remove(0) }
  }

  // MARK: - remove by value

  @Test("remove by value removes first occurrence only")
  func testRemoveByValue() throws {
    let list = java.util.LinkedList<Int>()
    _ = try list.add(5); _ = try list.add(5); _ = try list.add(6)
    let result = list.remove(5 as Int?)
    #expect(result == true)
    #expect(list.size() == 2)
    #expect(try list.get(0) == 5)
    #expect(try list.get(1) == 6)
  }

  @Test("remove by value returns false when not found")
  func testRemoveByValueNotFound() throws {
    let list = java.util.LinkedList<Int>()
    _ = try list.add(1)
    #expect(list.remove(99 as Int?) == false)
    #expect(list.size() == 1)
  }

  // MARK: - addFirst / addLast / removeFirst / removeLast / getFirst / getLast

  @Test("addFirst prepends element")
  func testAddFirst() throws {
    let list = java.util.LinkedList<Int>()
    _ = try list.add(2)
    list.addFirst(1)
    #expect(list.size() == 2)
    #expect(try list.get(0) == 1)
  }

  @Test("addLast appends element")
  func testAddLast() throws {
    let list = java.util.LinkedList<Int>()
    _ = try list.add(1)
    list.addLast(2)
    #expect(try list.get(1) == 2)
  }

  @Test("getFirst returns first element without removal")
  func testGetFirst() throws {
    let list = java.util.LinkedList<Int>()
    _ = try list.add(10); _ = try list.add(20)
    #expect(try list.getFirst() == 10)
    #expect(list.size() == 2)
  }

  @Test("getLast returns last element without removal")
  func testGetLast() throws {
    let list = java.util.LinkedList<Int>()
    _ = try list.add(10); _ = try list.add(20)
    #expect(try list.getLast() == 20)
    #expect(list.size() == 2)
  }

  @Test("getFirst on empty list throws")
  func testGetFirstEmpty() {
    let list = java.util.LinkedList<Int>()
    #expect(throws: (any Error).self) { try list.getFirst() }
  }

  @Test("removeFirst removes and returns head")
  func testRemoveFirst() throws {
    let list = java.util.LinkedList<Int>()
    _ = try list.add(1); _ = try list.add(2)
    let val = try list.removeFirst()
    #expect(val == 1)
    #expect(list.size() == 1)
  }

  @Test("removeLast removes and returns tail")
  func testRemoveLast() throws {
    let list = java.util.LinkedList<Int>()
    _ = try list.add(1); _ = try list.add(2)
    let val = try list.removeLast()
    #expect(val == 2)
    #expect(list.size() == 1)
  }

  @Test("removeFirst on empty list throws")
  func testRemoveFirstEmpty() {
    let list = java.util.LinkedList<Int>()
    #expect(throws: (any Error).self) { try list.removeFirst() }
  }

  // MARK: - Queue API

  @Test("offer appends; peek returns head; poll removes head")
  func testQueueOps() {
    let list = java.util.LinkedList<Int>()
    #expect(list.offer(1) == true)
    #expect(list.offer(2) == true)
    #expect(list.peek() == 1)
    #expect(list.poll() == 1)
    #expect(list.size() == 1)
    #expect(list.peek() == 2)
  }

  @Test("peek on empty list returns nil")
  func testPeekEmpty() {
    let list = java.util.LinkedList<Int>()
    #expect(list.peek() == nil)
  }

  @Test("poll on empty list returns nil")
  func testPollEmpty() {
    let list = java.util.LinkedList<Int>()
    #expect(list.poll() == nil)
  }

  @Test("element() returns head without removal")
  func testElement() throws {
    let list = java.util.LinkedList<Int>()
    _ = list.offer(42)
    #expect(try list.element() == 42)
    #expect(list.size() == 1)
  }

  @Test("element() on empty list throws")
  func testElementEmpty() {
    let list = java.util.LinkedList<Int>()
    #expect(throws: (any Error).self) { try list.element() }
  }

  @Test("remove() removes and returns head")
  func testRemoveQueue() throws {
    let list = java.util.LinkedList<Int>()
    _ = list.offer(7); _ = list.offer(8)
    let val = try list.remove()
    #expect(val == 7)
    #expect(list.size() == 1)
  }

  @Test("remove() on empty list throws")
  func testRemoveQueueEmpty() {
    let list = java.util.LinkedList<Int>()
    #expect(throws: (any Error).self) { try list.remove() }
  }

  // MARK: - contains / indexOf / lastIndexOf

  @Test("contains returns true for present element")
  func testContains() throws {
    let list = java.util.LinkedList<Int>()
    _ = try list.add(3); _ = try list.add(5)
    #expect(list.contains(3))
    #expect(!list.contains(99))
  }

  @Test("indexOf returns first occurrence index")
  func testIndexOf() throws {
    let list = java.util.LinkedList<String>()
    _ = try list.add("a"); _ = try list.add("b"); _ = try list.add("a")
    #expect(list.indexOf(element: "a") == 0)
    #expect(list.indexOf(element: "b") == 1)
    #expect(list.indexOf(element: "z") == -1)
  }

  @Test("lastIndexOf returns last occurrence index")
  func testLastIndexOf() throws {
    let list = java.util.LinkedList<String>()
    _ = try list.add("a"); _ = try list.add("b"); _ = try list.add("a")
    #expect(list.lastIndexOf("a") == 2)
  }

  // MARK: - clear

  @Test("clear removes all elements")
  func testClear() throws {
    let list = java.util.LinkedList<Int>()
    _ = try list.add(1); _ = try list.add(2)
    list.clear()
    #expect(list.isEmpty())
    #expect(list.size() == 0)
  }

  // MARK: - subList

  @Test("subList returns correct elements")
  func testSubList() throws {
    let list = java.util.LinkedList<Int>()
    for i in 0..<5 { _ = try list.add(i) }   // [0,1,2,3,4]
    let sub = list.subList(1, 4) as! java.util.LinkedList<Int>  // [1,2,3]
    #expect(sub.size() == 3)
    #expect(try sub.get(0) == 1)
    #expect(try sub.get(2) == 3)
  }

  // MARK: - for-in (Swift Sequence)

  @Test("for-in iterates all elements in order")
  func testForIn() throws {
    let list = java.util.LinkedList<Int>()
    _ = try list.add(10); _ = try list.add(20); _ = try list.add(30)
    var result: [Int] = []
    for element in list { if let e = element { result.append(e) } }
    #expect(result == [10, 20, 30])
  }

  // MARK: - toArray

  @Test("toArray returns all elements in order")
  func testToArray() throws {
    let list = java.util.LinkedList<Int>()
    _ = try list.add(1); _ = try list.add(2); _ = try list.add(3)
    let arr = list.toArray()
    #expect(arr.count == 3)
    #expect(arr[0] == 1)
    #expect(arr[2] == 3)
  }

  // MARK: - Reference semantics

  @Test("two variables share the same list (Java reference semantics)")
  func testReferenceSemantics() throws {
    let a = java.util.LinkedList<Int>()
    let b = a
    _ = try a.add(1)
    #expect(b.size() == 1)
    #expect(try b.get(0) == 1)
  }

  // MARK: - clone

  @Test("clone produces independent copy")
  func testClone() throws {
    let original = java.util.LinkedList<Int>()
    _ = try original.add(1); _ = try original.add(2)
    let copy = original.clone()
    _ = try copy.add(3)
    #expect(original.size() == 2)
    #expect(copy.size() == 3)
  }

  // MARK: - ListIterator

  @Test("ListIterator forward traversal")
  func testListIteratorForward() throws {
    let list = java.util.LinkedList<Int>()
    _ = try list.add(1); _ = try list.add(2); _ = try list.add(3)
    let it = list.listIterator()
    var result: [Int] = []
    while it.hasNext() { result.append(try it.next()) }
    #expect(result == [1, 2, 3])
  }

  @Test("ListIterator previous traversal")
  func testListIteratorPrevious() throws {
    let list = java.util.LinkedList<Int>()
    _ = try list.add(1); _ = try list.add(2); _ = try list.add(3)
    // advance to end
    let it = list.listIterator(3)
    var result: [Int] = []
    while it.hasPrevious() {
      if let v = try it.previous() { result.append(v) }
    }
    #expect(result == [3, 2, 1])
  }

  @Test("ListIterator nextIndex and previousIndex")
  func testListIteratorIndices() throws {
    let list = java.util.LinkedList<Int>()
    _ = try list.add(10); _ = try list.add(20)
    let it = list.listIterator()
    #expect(it.nextIndex() == 0)
    #expect(it.previousIndex() == -1)
    _ = try it.next()
    #expect(it.nextIndex() == 1)
    #expect(it.previousIndex() == 0)
  }

  @Test("ListIterator set modifies current element")
  func testListIteratorSet() throws {
    let list = java.util.LinkedList<Int>()
    _ = try list.add(1); _ = try list.add(2)
    let it = list.listIterator()
    _ = try it.next()
    it.set(99)
    #expect(try list.get(0) == 99)
  }

  @Test("ListIterator add inserts before next element")
  func testListIteratorAdd() throws {
    let list = java.util.LinkedList<Int>()
    _ = try list.add(1); _ = try list.add(3)
    let it = list.listIterator(1)  // positioned before element 3
    it.add(2)
    #expect(list.size() == 3)
    #expect(try list.get(1) == 2)
    #expect(try list.get(2) == 3)
  }

  @Test("ListIterator remove after next")
  func testListIteratorRemove() throws {
    let list = java.util.LinkedList<Int>()
    _ = try list.add(1); _ = try list.add(2); _ = try list.add(3)
    let it = list.listIterator()
    _ = try it.next()  // returns 1
    try it.remove()
    #expect(list.size() == 2)
    #expect(try list.get(0) == 2)
  }

  // MARK: - Single-element edge cases

  @Test("single element: add, get, remove cycle")
  func testSingleElement() throws {
    let list = java.util.LinkedList<Int>()
    _ = try list.add(42)
    #expect(try list.get(0) == 42)
    _ = try list.remove(0)
    #expect(list.isEmpty())
  }

  @Test("addFirst and addLast on empty list")
  func testAddFirstLastOnEmpty() throws {
    let list = java.util.LinkedList<Int>()
    list.addFirst(1)
    #expect(list.size() == 1)
    list.addLast(2)
    #expect(list.size() == 2)
    #expect(try list.get(0) == 1)
    #expect(try list.get(1) == 2)
  }
}
