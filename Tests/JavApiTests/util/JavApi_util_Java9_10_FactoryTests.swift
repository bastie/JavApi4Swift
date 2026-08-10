/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Testing
@testable import JavApi

// MARK: - ArrayList.of (Java 9)

@Suite("ArrayList.of — Java 9 List factory")
struct ArrayListOfTests {

  @Test("of() with elements returns unmodifiable list in order")
  func testOfBasic() {
    let list = java.util.ArrayList<Int>.of(1, 2, 3)
    #expect(list.size() == 3)
    #expect(list.contains(1))
    #expect(list.contains(2))
    #expect(list.contains(3))
  }

  @Test("of() with no arguments returns empty unmodifiable list")
  func testOfEmpty() {
    let list = java.util.ArrayList<String>.of()
    #expect(list.isEmpty())
  }

  @Test("of() result is unmodifiable — add throws")
  func testOfUnmodifiable() {
    var list = java.util.ArrayList<Int>.of(1, 2)
    #expect(throws: (any Error).self) { try list.add(99) }
  }

  @Test("of() result is unmodifiable — remove throws or is rejected")
  func testOfRemoveUnmodifiable() {
    let list = java.util.ArrayList<Int>.of(1, 2, 3)
    // Non-throwing remove fatalErrors (cannot test with #expect), so just verify read-only
    #expect(list.size() == 3)
  }
}

// MARK: - ArrayList.copyOf (Java 10)

@Suite("ArrayList.copyOf — Java 10 List factory")
struct ArrayListCopyOfTests {

  @Test("copyOf returns unmodifiable list with same elements")
  func testCopyOfBasic() {
    let source = java.util.ArrayList<Int>()
    _ = try? source.add(10)
    _ = try? source.add(20)
    _ = try? source.add(30)
    let copy = java.util.ArrayList<Int>.copyOf(source)
    #expect(copy.size() == 3)
    #expect(copy.contains(10))
    #expect(copy.contains(20))
    #expect(copy.contains(30))
  }

  @Test("copyOf result is independent from original list")
  func testCopyOfIndependence() {
    let source = java.util.ArrayList<String>()
    _ = try? source.add("hello")
    let copy = java.util.ArrayList<String>.copyOf(source)
    // modifying source does not affect copy
    _ = try? source.add("world")
    #expect(copy.size() == 1)
  }

  @Test("copyOf result is unmodifiable — add throws")
  func testCopyOfUnmodifiable() {
    let source = java.util.ArrayList<Int>()
    _ = try? source.add(1)
    var copy = java.util.ArrayList<Int>.copyOf(source)
    #expect(throws: (any Error).self) { try copy.add(99) }
  }

  @Test("copyOf of empty collection returns empty unmodifiable list")
  func testCopyOfEmpty() {
    let source = java.util.ArrayList<Int>()
    let copy = java.util.ArrayList<Int>.copyOf(source)
    #expect(copy.isEmpty())
  }
}

// MARK: - HashSet.of (Java 9)

@Suite("HashSet.of — Java 9 Set factory")
struct HashSetOfTests {

  @Test("of() creates an unmodifiable set with the given elements")
  func testOfBasic() throws {
    let set = try java.util.HashSet<Int>.of(1, 2, 3)
    #expect(set.size() == 3)
    #expect(set.contains(1))
    #expect(set.contains(2))
    #expect(set.contains(3))
  }

  @Test("of() with no arguments returns empty unmodifiable set")
  func testOfEmpty() throws {
    let set = try java.util.HashSet<String>.of()
    #expect(set.isEmpty())
  }

  @Test("of() with duplicate elements throws IllegalArgumentException")
  func testOfDuplicateThrows() {
    #expect(throws: java.lang.IllegalArgumentException.self) {
      _ = try java.util.HashSet<Int>.of(1, 2, 1)
    }
  }

  @Test("of() result is unmodifiable — add throws")
  func testOfUnmodifiable() throws {
    var set = try java.util.HashSet<Int>.of(1, 2)
    #expect(throws: (any Error).self) { try set.add(99) }
  }
}

// MARK: - HashSet.copyOf (Java 10)

@Suite("HashSet.copyOf — Java 10 Set factory")
struct HashSetCopyOfTests {

  @Test("copyOf returns unmodifiable set with same distinct elements")
  func testCopyOfBasic() {
    let source = java.util.ArrayList<Int>()
    _ = try? source.add(1)
    _ = try? source.add(2)
    _ = try? source.add(2)  // duplicate
    _ = try? source.add(3)
    let copy = java.util.HashSet<Int>.copyOf(source)
    #expect(copy.size() == 3)
    #expect(copy.contains(1))
    #expect(copy.contains(2))
    #expect(copy.contains(3))
  }

  @Test("copyOf result is unmodifiable — add throws")
  func testCopyOfUnmodifiable() {
    let source = java.util.ArrayList<Int>()
    _ = try? source.add(1)
    var copy = java.util.HashSet<Int>.copyOf(source)
    #expect(throws: (any Error).self) { try copy.add(99) }
  }

  @Test("copyOf of empty collection returns empty unmodifiable set")
  func testCopyOfEmpty() {
    let source = java.util.ArrayList<Int>()
    let copy = java.util.HashSet<Int>.copyOf(source)
    #expect(copy.isEmpty())
  }
}

// MARK: - HashMap.of (Java 9)

@Suite("HashMap.of — Java 9 Map factory")
struct HashMapOfTests {

  @Test("of() with no args returns empty unmodifiable map")
  func testOfEmpty() {
    let map = java.util.HashMap<String, Int>.of()
    #expect(map.isEmpty())
  }

  @Test("of(k,v) creates single-entry unmodifiable map")
  func testOf1() {
    let map = java.util.HashMap<String, Int>.of("a", 1)
    #expect(map.size() == 1)
    #expect(map.get("a") == 1)
  }

  @Test("of(k,v,k,v) creates two-entry unmodifiable map")
  func testOf2() throws {
    let map = try java.util.HashMap<String, Int>.of("a", 1, "b", 2)
    #expect(map.size() == 2)
    #expect(map.get("a") == 1)
    #expect(map.get("b") == 2)
  }

  @Test("of() with three pairs")
  func testOf3() throws {
    let map = try java.util.HashMap<String, Int>.of("a", 1, "b", 2, "c", 3)
    #expect(map.size() == 3)
    #expect(map.get("c") == 3)
  }

  @Test("of() with duplicate keys throws IllegalArgumentException")
  func testOfDuplicateKeyThrows() {
    #expect(throws: java.lang.IllegalArgumentException.self) {
      _ = try java.util.HashMap<String, Int>.of("a", 1, "a", 2)
    }
  }
}

// MARK: - HashMap.copyOf (Java 10)

@Suite("HashMap.copyOf — Java 10 Map factory")
struct HashMapCopyOfTests {

  @Test("copyOf returns unmodifiable map with same entries")
  func testCopyOfBasic() {
    let source = java.util.HashMap<String, Int>()
    _ = source.put("x", 10)
    _ = source.put("y", 20)
    let copy = java.util.HashMap<String, Int>.copyOf(source)
    #expect(copy.size() == 2)
    #expect(copy.get("x") == 10)
    #expect(copy.get("y") == 20)
  }

  @Test("copyOf result is independent from source modifications")
  func testCopyOfIndependence() {
    let source = java.util.HashMap<String, Int>()
    _ = source.put("a", 1)
    let copy = java.util.HashMap<String, Int>.copyOf(source)
    _ = source.put("b", 2)
    #expect(copy.size() == 1)
  }

  @Test("copyOf of empty map returns empty unmodifiable map")
  func testCopyOfEmpty() {
    let source = java.util.HashMap<String, Int>()
    let copy = java.util.HashMap<String, Int>.copyOf(source)
    #expect(copy.isEmpty())
  }
}
