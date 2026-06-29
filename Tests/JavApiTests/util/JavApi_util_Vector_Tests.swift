/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

/// Comprehensive test suite for java.util.Vector<E>
/// Tests all 23 Java 1.0 Vector methods.
struct JavApi_util_Vector_Tests {

  // MARK: - addElement()

  @Test("addElement() appends element and increases size")
  func testAddElement() throws {
    let v = try java.util.Vector<String>()
    v.addElement("a")
    v.addElement("b")
    #expect(v.size() == 2)
    #expect(try v.elementAt(0) == "a")
    #expect(try v.elementAt(1) == "b")
  }

  // MARK: - capacity()

  @Test("capacity() returns backing buffer size")
  func testCapacity() throws {
    let v = try java.util.Vector<Int>(20)
    #expect(v.capacity() >= 20)
  }

  @Test("capacity() of default vector is at least 10")
  func testDefaultCapacity() throws {
    let v = try java.util.Vector<Int>()
    #expect(v.capacity() >= 10)
  }

  // MARK: - contains()

  @Test("contains() returns true for present element")
  func testContainsTrue() throws {
    let v = try java.util.Vector<String>()
    v.addElement("hello")
    #expect(v.contains("hello") == true)
  }

  @Test("contains() returns false for absent element")
  func testContainsFalse() throws {
    let v = try java.util.Vector<String>()
    v.addElement("hello")
    #expect(v.contains("world") == false)
  }

  @Test("contains() returns false on empty vector")
  func testContainsEmpty() throws {
    let v = try java.util.Vector<String>()
    #expect(v.contains("x") == false)
  }

  // MARK: - copyInto()

  @Test("copyInto() copies all elements into array")
  func testCopyInto() throws {
    let v = try java.util.Vector<String>()
    v.addElement("x")
    v.addElement("y")
    v.addElement("z")
    var arr = Array(repeating: "", count: 3)
    v.copyInto(&arr)
    #expect(arr == ["x", "y", "z"])
  }

  // MARK: - elementAt()

  @Test("elementAt() returns correct element")
  func testElementAt() throws {
    let v = try java.util.Vector<String>()
    v.addElement("first")
    v.addElement("second")
    #expect(try v.elementAt(0) == "first")
    #expect(try v.elementAt(1) == "second")
  }

  @Test("elementAt() throws ArrayIndexOutOfBoundsException for invalid index")
  func testElementAtOutOfBounds() throws {
    let v = try java.util.Vector<String>()
    v.addElement("only")
    #expect(throws: java.lang.ArrayIndexOutOfBoundsException.self) {
      _ = try v.elementAt(5)
    }
  }

  // MARK: - elements()

  @Test("elements() enumerates all elements in order")
  func testElements() throws {
    let v = try java.util.Vector<String>()
    v.addElement("a")
    v.addElement("b")
    v.addElement("c")
    var e = v.elements()
    #expect(e.hasMoreElements() == true)
    #expect(try e.nextElement() == "a")
    #expect(try e.nextElement() == "b")
    #expect(try e.nextElement() == "c")
    #expect(e.hasMoreElements() == false)
  }

  @Test("elements() on empty vector has no elements")
  func testElementsEmpty() throws {
    let v = try java.util.Vector<String>()
    let e = v.elements()
    #expect(e.hasMoreElements() == false)
  }

  // MARK: - ensureCapacity()

  @Test("ensureCapacity() grows backing buffer to at least minCapacity")
  func testEnsureCapacity() throws {
    let v = try java.util.Vector<Int>()
    v.ensureCapacity(100)
    #expect(v.capacity() >= 100)
  }

  // MARK: - firstElement()

  @Test("firstElement() returns first element")
  func testFirstElement() throws {
    let v = try java.util.Vector<String>()
    v.addElement("first")
    v.addElement("second")
    #expect(try v.firstElement() == "first")
  }

  @Test("firstElement() throws NoSuchElementException on empty vector")
  func testFirstElementEmpty() throws {
    let v = try java.util.Vector<String>()
    #expect(throws: java.util.NoSuchElementException.self) {
      _ = try v.firstElement()
    }
  }

  // MARK: - indexOf()

  @Test("indexOf() returns index of first occurrence")
  func testIndexOf() throws {
    let v = try java.util.Vector<String>()
    v.addElement("a")
    v.addElement("b")
    v.addElement("a")
    #expect(v.indexOf("a") == 0)
  }

  @Test("indexOf() returns -1 for absent element")
  func testIndexOfMissing() throws {
    let v = try java.util.Vector<String>()
    v.addElement("a")
    #expect(v.indexOf("z") == -1)
  }

  @Test("indexOf(elem, fromIndex) searches from given index")
  func testIndexOfFromIndex() throws {
    let v = try java.util.Vector<String>()
    v.addElement("a")
    v.addElement("b")
    v.addElement("a")
    // Search from index 1: first "a" at index 2
    #expect(v.indexOf("a", 1) == 2)
  }

  // MARK: - insertElementAt()

  @Test("insertElementAt() inserts at given position")
  func testInsertElementAt() throws {
    let v = try java.util.Vector<String>()
    v.addElement("a")
    v.addElement("c")
    try v.insertElementAt("b", 1)
    #expect(v.size() == 3)
    #expect(try v.elementAt(0) == "a")
    #expect(try v.elementAt(1) == "b")
    #expect(try v.elementAt(2) == "c")
  }

  @Test("insertElementAt() at end appends element")
  func testInsertElementAtEnd() throws {
    let v = try java.util.Vector<String>()
    v.addElement("a")
    try v.insertElementAt("b", 1)
    #expect(try v.elementAt(1) == "b")
  }

  @Test("insertElementAt() throws for invalid index")
  func testInsertElementAtInvalid() throws {
    let v = try java.util.Vector<String>()
    #expect(throws: java.lang.ArrayIndexOutOfBoundsException.self) {
      try v.insertElementAt("x", 5)
    }
  }

  // MARK: - isEmpty()

  @Test("isEmpty() returns true for new vector")
  func testIsEmptyTrue() throws {
    let v = try java.util.Vector<String>()
    #expect(v.isEmpty() == true)
  }

  @Test("isEmpty() returns false after addElement()")
  func testIsEmptyFalse() throws {
    let v = try java.util.Vector<String>()
    v.addElement("x")
    #expect(v.isEmpty() == false)
  }

  // MARK: - lastElement()

  @Test("lastElement() returns last element")
  func testLastElement() throws {
    let v = try java.util.Vector<String>()
    v.addElement("first")
    v.addElement("last")
    #expect(try v.lastElement() == "last")
  }

  @Test("lastElement() throws NoSuchElementException on empty vector")
  func testLastElementEmpty() throws {
    let v = try java.util.Vector<String>()
    #expect(throws: java.util.NoSuchElementException.self) {
      _ = try v.lastElement()
    }
  }

  // MARK: - lastIndexOf()

  @Test("lastIndexOf() returns index of last occurrence")
  func testLastIndexOf() throws {
    let v = try java.util.Vector<String>()
    v.addElement("a")
    v.addElement("b")
    v.addElement("a")
    #expect(v.lastIndexOf("a") == 2)
  }

  @Test("lastIndexOf() returns -1 for absent element")
  func testLastIndexOfMissing() throws {
    let v = try java.util.Vector<String>()
    v.addElement("a")
    #expect(v.lastIndexOf("z") == -1)
  }

  @Test("lastIndexOf(elem, fromIndex) searches backward from index")
  func testLastIndexOfFromIndex() throws {
    let v = try java.util.Vector<String>()
    v.addElement("a")
    v.addElement("b")
    v.addElement("a")
    v.addElement("c")
    // Search backward from index 2: last "a" at index 2
    #expect(try v.lastIndexOf("a", 2) == 2)
  }

  // MARK: - removeAllElements()

  @Test("removeAllElements() empties the vector")
  func testRemoveAllElements() throws {
    let v = try java.util.Vector<String>()
    v.addElement("a")
    v.addElement("b")
    v.removeAllElements()
    #expect(v.size() == 0)
    #expect(v.isEmpty() == true)
  }

  // MARK: - removeElement()

  @Test("removeElement() removes first occurrence and returns true")
  func testRemoveElementTrue() throws {
    let v = try java.util.Vector<String>()
    v.addElement("a")
    v.addElement("b")
    v.addElement("a")
    let removed = v.removeElement("a")
    #expect(removed == true)
    #expect(v.size() == 2)
    #expect(try v.elementAt(0) == "b")
  }

  @Test("removeElement() returns false when element not present")
  func testRemoveElementFalse() throws {
    let v = try java.util.Vector<String>()
    v.addElement("a")
    #expect(v.removeElement("z") == false)
    #expect(v.size() == 1)
  }

  // MARK: - removeElementAt()

  @Test("removeElementAt() removes element at given index")
  func testRemoveElementAt() throws {
    let v = try java.util.Vector<String>()
    v.addElement("a")
    v.addElement("b")
    v.addElement("c")
    _ = try v.removeElementAt(1)
    #expect(v.size() == 2)
    #expect(try v.elementAt(0) == "a")
    #expect(try v.elementAt(1) == "c")
  }

  @Test("removeElementAt() throws for invalid index")
  func testRemoveElementAtInvalid() throws {
    let v = try java.util.Vector<String>()
    #expect(throws: java.lang.ArrayIndexOutOfBoundsException.self) {
      _ = try v.removeElementAt(0)
    }
  }

  // MARK: - setElementAt()

  @Test("setElementAt() replaces element at index")
  func testSetElementAt() throws {
    let v = try java.util.Vector<String>()
    v.addElement("old")
    _ = try v.setElementAt("new", 0)
    #expect(try v.elementAt(0) == "new")
  }

  @Test("setElementAt() returns old element")
  func testSetElementAtReturnsOld() throws {
    let v = try java.util.Vector<String>()
    v.addElement("old")
    let old = try v.setElementAt("new", 0)
    #expect(old == "old")
  }

  @Test("setElementAt() throws for invalid index")
  func testSetElementAtInvalid() throws {
    let v = try java.util.Vector<String>()
    #expect(throws: java.lang.ArrayIndexOutOfBoundsException.self) {
      _ = try v.setElementAt("x", 0)
    }
  }

  // MARK: - setSize()

  @Test("setSize() grows vector with nil slots")
  func testSetSizeGrow() throws {
    let v = try java.util.Vector<String>()
    v.addElement("a")
    try v.setSize(3)
    #expect(v.size() == 3)
    #expect(try v.elementAt(0) == "a")
  }

  @Test("setSize() shrinks vector")
  func testSetSizeShrink() throws {
    let v = try java.util.Vector<String>()
    v.addElement("a")
    v.addElement("b")
    v.addElement("c")
    try v.setSize(1)
    #expect(v.size() == 1)
    #expect(try v.elementAt(0) == "a")
  }

  @Test("setSize() throws for negative size")
  func testSetSizeNegative() throws {
    let v = try java.util.Vector<String>()
    #expect(throws: java.lang.ArrayIndexOutOfBoundsException.self) {
      try v.setSize(-1)
    }
  }

  // MARK: - size()

  @Test("size() returns 0 for empty vector")
  func testSizeEmpty() throws {
    let v = try java.util.Vector<Int>()
    #expect(v.size() == 0)
  }

  @Test("size() increments with each addElement()")
  func testSizeAfterAdd() throws {
    let v = try java.util.Vector<Int>()
    v.addElement(1)
    v.addElement(2)
    v.addElement(3)
    #expect(v.size() == 3)
  }

  // MARK: - toString()

  @Test("toString() returns non-empty string representation")
  func testToString() throws {
    let v = try java.util.Vector<String>()
    v.addElement("hello")
    // Stack verwendet Vector.toString() implizit via Swift description
    let desc = "\(v)"
    #expect(!desc.isEmpty)
  }

  // MARK: - Equatable

  @Test("equal vectors compare as equal")
  func testEquatable_equal() throws {
    let a = try java.util.Vector<Int>()
    let b = try java.util.Vector<Int>()
    a.addElement(1); a.addElement(2)
    b.addElement(1); b.addElement(2)
    #expect(a == b)
  }

  @Test("vectors with different elements compare as not equal")
  func testEquatable_differentElements() throws {
    let a = try java.util.Vector<Int>()
    let b = try java.util.Vector<Int>()
    a.addElement(1)
    b.addElement(2)
    #expect(a != b)
  }

  @Test("vectors with different sizes compare as not equal")
  func testEquatable_differentSizes() throws {
    let a = try java.util.Vector<Int>()
    let b = try java.util.Vector<Int>()
    a.addElement(1)
    b.addElement(1); b.addElement(2)
    #expect(a != b)
  }

  @Test("empty vectors compare as equal")
  func testEquatable_empty() throws {
    let a = try java.util.Vector<Int>()
    let b = try java.util.Vector<Int>()
    #expect(a == b)
  }

  @Test("nested Vector<Vector<String>> equality works")
  func testEquatable_nested() throws {
    let inner1 = try java.util.Vector<String>()
    inner1.addElement("hello")
    let inner2 = try java.util.Vector<String>()
    inner2.addElement("hello")

    let outer1 = try java.util.Vector<java.util.Vector<String>>()
    outer1.addElement(inner1)
    let outer2 = try java.util.Vector<java.util.Vector<String>>()
    outer2.addElement(inner2)

    #expect(outer1 == outer2)
  }

  // MARK: - Java 1.2 List API

  @Test("add(element) appends and returns true")
  func testAdd_returnsTrue() throws {
    let v = try java.util.Vector<String>()
    let result = try v.add("hello")
    #expect(result == true)
    #expect(v.size() == 1)
    #expect(try v.elementAt(0) == "hello")
  }

  @Test("add(element) called multiple times preserves order")
  func testAdd_order() throws {
    let v = try java.util.Vector<String>()
    _ = try v.add("a")
    _ = try v.add("b")
    _ = try v.add("c")
    #expect(v.size() == 3)
    #expect(try v.elementAt(0) == "a")
    #expect(try v.elementAt(2) == "c")
  }

  @Test("add(index, element) inserts at position")
  func testAdd_atIndex() throws {
    let v = try java.util.Vector<String>()
    _ = try v.add("a")
    _ = try v.add("c")
    try v.add(1, "b")
    #expect(v.size() == 3)
    #expect(try v.elementAt(1) == "b")
    #expect(try v.elementAt(2) == "c")
  }

  @Test("add(index, element) throws for out-of-bounds index")
  func testAdd_atIndex_outOfBounds() throws {
    let v = try java.util.Vector<String>()
    #expect(throws: (any Error).self) {
      try v.add(5, "x")
    }
  }

  @Test("set(index, element) replaces and returns old value")
  func testSet() throws {
    let v = try java.util.Vector<String>()
    _ = try v.add("old")
    let old = try v.set(0, "new")
    #expect(old == "old")
    #expect(try v.elementAt(0) == "new")
  }

  @Test("remove(index) removes element and returns it")
  func testRemove_atIndex() throws {
    let v = try java.util.Vector<String>()
    _ = try v.add("a")
    _ = try v.add("b")
    _ = try v.add("c")
    let removed = try v.remove(1)
    #expect(removed == "b")
    #expect(v.size() == 2)
    #expect(try v.elementAt(1) == "c")
  }

  @Test("remove(element) removes first occurrence and returns true")
  func testRemove_element() throws {
    let v = try java.util.Vector<String>()
    _ = try v.add("a")
    _ = try v.add("b")
    _ = try v.add("a")
    let removed = v.remove("a")
    #expect(removed == true)
    #expect(v.size() == 2)
    #expect(try v.elementAt(0) == "b")
  }

  @Test("get(index) returns element at position")
  func testGet() throws {
    let v = try java.util.Vector<String>()
    _ = try v.add("x")
    _ = try v.add("y")
    #expect(try v.get(0) == "x")
    #expect(try v.get(1) == "y")
  }

  @Test("Vector usable as any java.util.List")
  func testListProtocolConformance() throws {
    let v = try java.util.Vector<String>()
    _ = try v.add("item")
    let list: any java.util.List = v
    #expect(list.size() == 1)
  }

}
