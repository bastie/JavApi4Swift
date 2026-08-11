/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

// Shared test enum used by both EnumMap and EnumSet tests.
private enum Planet: CaseIterable, Hashable {
  case mercury, venus, earth, mars, jupiter, saturn, uranus, neptune
}

struct JavApi_util_EnumMap_Tests {

  // MARK: - Init & isEmpty

  @Test("EnumMap starts empty")
  func testInitEmpty() {
    let map = java.util.EnumMap<Planet, Int>()
    #expect(map.isEmpty())
    #expect(map.size() == 0)
  }

  // MARK: - put / get

  @Test("put and get round-trip")
  func testPutGet() {
    let map = java.util.EnumMap<Planet, String>()
    map.put(.earth, "home")
    #expect(map.get(.earth) == "home")
  }

  @Test("put returns previous value")
  func testPutReturnsPrevious() {
    let map = java.util.EnumMap<Planet, Int>()
    let first = map.put(.mars, 1)
    #expect(first == nil)
    let second = map.put(.mars, 2)
    #expect(second == 1)
    #expect(map.get(.mars) == 2)
  }

  @Test("get returns nil for absent key")
  func testGetAbsent() {
    let map = java.util.EnumMap<Planet, Int>()
    #expect(map.get(.venus) == nil)
  }

  // MARK: - containsKey

  @Test("containsKey returns true after put")
  func testContainsKeyPresent() {
    let map = java.util.EnumMap<Planet, String>()
    map.put(.saturn, "rings")
    #expect(map.containsKey(.saturn))
  }

  @Test("containsKey returns false for absent key")
  func testContainsKeyAbsent() {
    let map = java.util.EnumMap<Planet, String>()
    #expect(!map.containsKey(.uranus))
  }

  // MARK: - remove

  @Test("remove returns old value and deletes mapping")
  func testRemove() {
    let map = java.util.EnumMap<Planet, String>()
    map.put(.jupiter, "giant")
    let removed = map.remove(.jupiter)
    #expect(removed == "giant")
    #expect(map.get(.jupiter) == nil)
    #expect(map.isEmpty())
  }

  @Test("remove on absent key returns nil")
  func testRemoveAbsent() {
    let map = java.util.EnumMap<Planet, Int>()
    #expect(map.remove(.neptune) == nil)
  }

  // MARK: - size & clear

  @Test("size reflects number of mappings")
  func testSize() {
    let map = java.util.EnumMap<Planet, Int>()
    map.put(.mercury, 1)
    map.put(.venus, 2)
    map.put(.earth, 3)
    #expect(map.size() == 3)
  }

  @Test("clear removes all mappings")
  func testClear() {
    let map = java.util.EnumMap<Planet, Int>()
    map.put(.earth, 1)
    map.put(.mars, 2)
    map.clear()
    #expect(map.isEmpty())
    #expect(map.size() == 0)
  }

  // MARK: - keySet / values / entrySet

  @Test("keySet returns keys in declaration order")
  func testKeySet() {
    let map = java.util.EnumMap<Planet, Int>()
    map.put(.neptune, 8)
    map.put(.mercury, 1)
    // Declaration order: mercury first, neptune last
    let keys = map.keySet()
    #expect(keys.first == .mercury)
    #expect(keys.last == .neptune)
    #expect(keys.count == 2)
  }

  @Test("values returns mapped values in declaration order")
  func testValues() {
    let map = java.util.EnumMap<Planet, Int>()
    map.put(.mercury, 1)
    map.put(.venus, 2)
    #expect(map.values() == [1, 2])
  }

  @Test("entrySet contains all key-value pairs")
  func testEntrySet() {
    let map = java.util.EnumMap<Planet, String>()
    map.put(.earth, "home")
    let entries = map.entrySet()
    #expect(entries.count == 1)
    #expect(entries[0].key == .earth)
    #expect(entries[0].value == "home")
  }

  // MARK: - forEach

  @Test("forEach visits all entries")
  func testForEach() {
    let map = java.util.EnumMap<Planet, Int>()
    map.put(.mars, 4)
    map.put(.saturn, 6)
    var visited: [Planet] = []
    map.forEach { k, _ in visited.append(k) }
    #expect(visited.count == 2)
    #expect(visited.contains(.mars))
    #expect(visited.contains(.saturn))
  }

  // MARK: - subscript

  @Test("subscript get and set work like put/get")
  func testSubscript() {
    let map = java.util.EnumMap<Planet, String>()
    map[.uranus] = "ice giant"
    #expect(map[.uranus] == "ice giant")
    map[.uranus] = nil
    #expect(map[.uranus] == nil)
  }

  // MARK: - copy constructor

  @Test("copy constructor creates independent copy")
  func testCopyConstructor() {
    let original = java.util.EnumMap<Planet, Int>()
    original.put(.earth, 3)
    let copy = java.util.EnumMap<Planet, Int>(original)
    copy.put(.mars, 4)
    // Original must not be affected
    #expect(!original.containsKey(.mars))
    #expect(copy.containsKey(.earth))
  }

  // MARK: - containsValue

  @Test("containsValue returns true when value exists")
  func testContainsValue() {
    let map = java.util.EnumMap<Planet, Int>()
    map.put(.earth, 42)
    #expect(map.containsValue(42))
    #expect(!map.containsValue(99))
  }
}
