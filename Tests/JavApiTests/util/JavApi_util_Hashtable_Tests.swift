/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

struct JavApi_util_Hashtable_Tests {

  // MARK: - init

  @Test("init() creates empty hashtable")
  func testInitDefault() {
    let ht = java.util.Hashtable<String, Int>()
    #expect(ht.size()    == 0)
    #expect(ht.isEmpty() == true)
  }

  @Test("init(initialCapacity) creates empty hashtable")
  func testInitCapacity() {
    let ht = java.util.Hashtable<String, Int>(16)
    #expect(ht.isEmpty())
  }

  @Test("init(initialCapacity, loadFactor) creates empty hashtable")
  func testInitCapacityLoadFactor() {
    let ht = java.util.Hashtable<String, Int>(16, 0.75)
    #expect(ht.isEmpty())
  }

  // MARK: - put / get

  @Test("put stores value and get retrieves it")
  func testPutGet() {
    let ht = java.util.Hashtable<String, Int>()
    ht.put("one", 1)
    #expect(ht.get("one") == 1)
  }

  @Test("put returns previous value")
  func testPutReturnsPrevious() {
    let ht = java.util.Hashtable<String, Int>()
    let prev1 = ht.put("x", 10)
    #expect(prev1 == nil)
    let prev2 = ht.put("x", 20)
    #expect(prev2 == 10)
    #expect(ht.get("x") == 20)
  }

  @Test("get returns nil for missing key")
  func testGetMissing() {
    let ht = java.util.Hashtable<String, Int>()
    #expect(ht.get("missing") == nil)
  }

  @Test("put multiple keys are stored independently")
  func testPutMultiple() {
    let ht = java.util.Hashtable<String, Int>()
    ht.put("a", 1)
    ht.put("b", 2)
    ht.put("c", 3)
    #expect(ht.get("a") == 1)
    #expect(ht.get("b") == 2)
    #expect(ht.get("c") == 3)
    #expect(ht.size()   == 3)
  }

  // MARK: - remove

  @Test("remove deletes entry and returns old value")
  func testRemove() {
    let ht = java.util.Hashtable<String, Int>()
    ht.put("x", 42)
    let removed = ht.remove("x")
    #expect(removed       == 42)
    #expect(ht.get("x")  == nil)
    #expect(ht.size()     == 0)
  }

  @Test("remove on missing key returns nil")
  func testRemoveMissing() {
    let ht = java.util.Hashtable<String, Int>()
    #expect(ht.remove("ghost") == nil)
  }

  // MARK: - clear

  @Test("clear removes all entries")
  func testClear() {
    let ht = java.util.Hashtable<String, Int>()
    ht.put("a", 1); ht.put("b", 2)
    ht.clear()
    #expect(ht.size()    == 0)
    #expect(ht.isEmpty() == true)
    #expect(ht.get("a")  == nil)
  }

  // MARK: - size / isEmpty

  @Test("size and isEmpty reflect current state")
  func testSizeIsEmpty() {
    let ht = java.util.Hashtable<String, Int>()
    #expect(ht.isEmpty())
    ht.put("k", 1)
    #expect(!ht.isEmpty())
    #expect(ht.size() == 1)
    ht.remove("k")
    #expect(ht.isEmpty())
  }

  // MARK: - containsKey / contains / containsValue

  @Test("containsKey returns true for present key")
  func testContainsKey() {
    let ht = java.util.Hashtable<String, Int>()
    ht.put("hello", 99)
    #expect(ht.containsKey("hello") == true)
    #expect(ht.containsKey("world") == false)
  }

  @Test("contains(value) returns true for present value")
  func testContainsValue() {
    let ht = java.util.Hashtable<String, Int>()
    ht.put("a", 7)
    #expect(ht.contains(7)  == true)
    #expect(ht.contains(99) == false)
  }

  @Test("containsValue is alias for contains")
  func testContainsValueAlias() {
    let ht = java.util.Hashtable<String, Int>()
    ht.put("x", 5)
    #expect(ht.containsValue(5) == true)
    #expect(ht.containsValue(6) == false)
  }

  // MARK: - keys / elements (Enumeration)

  @Test("keys() enumerates all keys")
  func testKeys() throws {
    let ht = java.util.Hashtable<String, Int>()
    ht.put("a", 1); ht.put("b", 2); ht.put("c", 3)
    var enum_ = ht.keys()
    var collected: [String] = []
    while enum_.hasMoreElements() {
      collected.append(try enum_.nextElement())
    }
    #expect(collected.sorted() == ["a", "b", "c"])
  }

  @Test("elements() enumerates all values")
  func testElements() throws {
    let ht = java.util.Hashtable<String, Int>()
    ht.put("a", 1); ht.put("b", 2); ht.put("c", 3)
    var enum_ = ht.elements()
    var collected: [Int] = []
    while enum_.hasMoreElements() {
      collected.append(try enum_.nextElement())
    }
    #expect(collected.sorted() == [1, 2, 3])
  }

  @Test("nextElement on exhausted Enumeration throws NoSuchElementException")
  func testEnumerationExhausted() throws {
    let ht = java.util.Hashtable<String, Int>()
    ht.put("x", 1)
    var enum_ = ht.keys()
    _ = try enum_.nextElement()   // consume the one element
    #expect(throws: java.util.NoSuchElementException.self) {
      try enum_.nextElement()
    }
  }

  // MARK: - clone

  @Test("clone produces independent copy")
  func testClone() {
    let original = java.util.Hashtable<String, Int>()
    original.put("a", 1)
    let copy = original.clone()
    #expect(copy.get("a") == 1)
    // Mutating copy does not affect original
    copy.put("b", 2)
    #expect(original.get("b") == nil)
    // Mutating original does not affect copy
    original.put("c", 3)
    #expect(copy.get("c") == nil)
  }

  // MARK: - Equatable (==)

  @Test("equal hashtables compare as equal")
  func testEquality() {
    let a = java.util.Hashtable<String, Int>()
    let b = java.util.Hashtable<String, Int>()
    a.put("x", 1); b.put("x", 1)
    #expect(a == b)
  }

  @Test("hashtables with different entries are not equal")
  func testInequality() {
    let a = java.util.Hashtable<String, Int>()
    let b = java.util.Hashtable<String, Int>()
    a.put("x", 1); b.put("x", 2)
    #expect(a != b)
  }

  @Test("empty hashtables are equal")
  func testEqualityEmpty() {
    let a = java.util.Hashtable<String, Int>()
    let b = java.util.Hashtable<String, Int>()
    #expect(a == b)
  }

  // MARK: - Sequence (for-in)

  @Test("Sequence iteration visits all entries")
  func testSequence() {
    let ht = java.util.Hashtable<String, Int>()
    ht.put("a", 1); ht.put("b", 2); ht.put("c", 3)
    var keys: [String] = []
    var vals: [Int]    = []
    for (k, v) in ht {
      keys.append(k); vals.append(v)
    }
    #expect(keys.sorted() == ["a", "b", "c"])
    #expect(vals.sorted() == [1, 2, 3])
  }

  // MARK: - toString / description

  @Test("toString of empty hashtable is {}")
  func testToStringEmpty() {
    let ht = java.util.Hashtable<String, Int>()
    #expect(ht.toString() == "{}")
  }

  @Test("toString of single entry contains key=value")
  func testToStringSingle() {
    let ht = java.util.Hashtable<String, Int>()
    ht.put("answer", 42)
    #expect(ht.toString() == "{answer=42}")
  }

  @Test("description matches toString")
  func testDescription() {
    let ht = java.util.Hashtable<String, Int>()
    ht.put("k", 7)
    #expect(ht.description == ht.toString())
  }

  // MARK: - Int keys

  @Test("Int keys work correctly")
  func testIntKeys() {
    let ht = java.util.Hashtable<Int, String>()
    ht.put(1, "one")
    ht.put(2, "two")
    #expect(ht.get(1) == "one")
    #expect(ht.get(2) == "two")
    #expect(ht.containsKey(1) == true)
    #expect(ht.containsKey(3) == false)
  }
}
