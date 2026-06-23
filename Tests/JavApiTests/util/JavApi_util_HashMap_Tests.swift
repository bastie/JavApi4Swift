/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

// MARK: - AbstractMap tests (via minimal concrete subclass)

/// Minimal concrete AbstractMap backed by a Swift Dictionary.
/// Used only in tests — verifies the AbstractMap default implementations.
private final class ConcreteMap<K: Hashable, V: Equatable>: java.util.AbstractMap<K, V> {
  private var _entries: [(key: K, value: V)] = []

  override func entrySet() -> [(key: K, value: V)] { _entries }

  @discardableResult
  override func put(_ key: K, _ value: V) -> V? {
    if let idx = _entries.firstIndex(where: { $0.key == key }) {
      let old = _entries[idx].value
      _entries[idx] = (key, value)
      return old
    }
    _entries.append((key, value))
    return nil
  }

  @discardableResult
  override func remove(_ key: K) -> V? {
    if let idx = _entries.firstIndex(where: { $0.key == key }) {
      let old = _entries[idx].value
      _entries.remove(at: idx)
      return old
    }
    return nil
  }
}

struct JavApi_util_AbstractMap_Tests {

  @Test("size() counts entries via entrySet()")
  func testSize() {
    let m = ConcreteMap<String, Int>()
    #expect(m.size() == 0)
    m.put("a", 1)
    m.put("b", 2)
    #expect(m.size() == 2)
  }

  @Test("isEmpty() reflects entry count")
  func testIsEmpty() {
    let m = ConcreteMap<String, Int>()
    #expect(m.isEmpty())
    m.put("x", 9)
    #expect(!m.isEmpty())
  }

  @Test("containsKey() finds existing key")
  func testContainsKey() {
    let m = ConcreteMap<String, Int>()
    m.put("hello", 42)
    #expect(m.containsKey("hello"))
    #expect(!m.containsKey("world"))
  }

  @Test("get() returns mapped value or nil")
  func testGet() {
    let m = ConcreteMap<Int, String>()
    m.put(1, "one")
    #expect(m.get(1) == "one")
    #expect(m.get(2) == nil)
  }

  @Test("put() returns previous value on overwrite")
  func testPutOverwrite() {
    let m = ConcreteMap<String, Int>()
    #expect(m.put("k", 1) == nil)
    #expect(m.put("k", 2) == 1)
    #expect(m.get("k") == 2)
  }

  @Test("remove() removes entry and returns old value")
  func testRemove() {
    let m = ConcreteMap<String, Int>()
    m.put("a", 10)
    let old = m.remove("a")
    #expect(old == 10)
    #expect(m.size() == 0)
    #expect(m.remove("a") == nil)
  }

  @Test("clear() empties the map")
  func testClear() {
    let m = ConcreteMap<Int, Int>()
    m.put(1, 1); m.put(2, 2)
    m.clear()
    #expect(m.isEmpty())
  }

  @Test("keySet() returns all keys")
  func testKeySet() {
    let m = ConcreteMap<String, Int>()
    m.put("a", 1); m.put("b", 2)
    let keys = m.keySet()
    #expect(keys.contains("a"))
    #expect(keys.contains("b"))
    #expect(keys.count == 2)
  }

  @Test("values() returns all values")
  func testValues() {
    let m = ConcreteMap<String, Int>()
    m.put("x", 10); m.put("y", 20)
    let vals = m.values().sorted()
    #expect(vals == [10, 20])
  }

  @Test("putAll() copies all entries from another map")
  func testPutAll() {
    let src = ConcreteMap<String, Int>()
    src.put("p", 1); src.put("q", 2)
    let dst = ConcreteMap<String, Int>()
    dst.putAll(src)
    #expect(dst.size() == 2)
    #expect(dst.get("p") == 1)
    #expect(dst.get("q") == 2)
  }

  @Test("equals() is true for identical mappings")
  func testEquals() {
    let a = ConcreteMap<String, Int>()
    let b = ConcreteMap<String, Int>()
    a.put("k", 1); b.put("k", 1)
    #expect(a.equals(b))
  }

  @Test("equals() is false when values differ")
  func testEqualsValueMismatch() {
    let a = ConcreteMap<String, Int>()
    let b = ConcreteMap<String, Int>()
    a.put("k", 1); b.put("k", 2)
    #expect(!a.equals(b))
  }

  @Test("toString() produces braced key=value pairs")
  func testToString() {
    let m = ConcreteMap<String, Int>()
    m.put("x", 7)
    let s = m.toString()
    #expect(s.hasPrefix("{"))
    #expect(s.hasSuffix("}"))
    #expect(s.contains("x=7"))
  }
}

// MARK: - HashMap tests

struct JavApi_util_HashMap_Tests {

  @Test("put returns nil for new key, stores value")
  func testPutAndGet() {
    let map = java.util.HashMap<String, Int>()
    let old = map.put("key", 42)
    #expect(old == nil)
    #expect(map.get("key") == 42)
  }

  @Test("put returns previous value on overwrite")
  func testPutOverwrite() {
    let map = java.util.HashMap<String, Int>()
    _ = map.put("key", 1)
    let old = map.put("key", 2)
    #expect(old == 1)
    #expect(map.get("key") == 2)
  }

  @Test("containsKey distinguishes present and absent keys")
  func testContainsKey() {
    let map = java.util.HashMap<String, String>()
    _ = map.put("hello", "world")
    #expect(map.containsKey("hello"))
    #expect(!map.containsKey("missing"))
  }

  @Test("get returns nil for missing key")
  func testGetMissingKey() {
    let map = java.util.HashMap<Int, Int>()
    #expect(map.get(99) == nil)
  }

  @Test("remove deletes entry and returns old value")
  func testRemove() {
    let map = java.util.HashMap<String, Int>()
    _ = map.put("a", 1)
    #expect(map.remove("a") == 1)
    #expect(map.get("a") == nil)
    #expect(map.remove("a") == nil)
  }

  @Test("clear empties the map")
  func testClear() {
    let map = java.util.HashMap<Int, Int>()
    _ = map.put(1, 10); _ = map.put(2, 20)
    map.clear()
    #expect(map.isEmpty())
  }

  @Test("keySet returns all inserted keys")
  func testKeySet() {
    let map = java.util.HashMap<String, Int>()
    _ = map.put("a", 1); _ = map.put("b", 2)
    let keys = map.keySet()
    #expect(keys.contains("a") && keys.contains("b"))
    #expect(keys.count == 2)
  }

  @Test("values returns all values (order undefined)")
  func testValues() {
    let map = java.util.HashMap<String, Int>()
    _ = map.put("x", 10); _ = map.put("y", 20)
    #expect(map.values().sorted() == [10, 20])
  }

  @Test("putAll copies entries from another HashMap")
  func testPutAll() {
    let src = java.util.HashMap<String, Int>()
    _ = src.put("p", 1); _ = src.put("q", 2)
    let dst = java.util.HashMap<String, Int>()
    dst.putAll(src)
    #expect(dst.size() == 2)
    #expect(dst.get("p") == 1)
  }

  @Test("multiple entries are stored independently")
  func testMultipleEntries() {
    let map = java.util.HashMap<Int, String>()
    _ = map.put(1, "one")
    _ = map.put(2, "two")
    _ = map.put(3, "three")
    #expect(map.size() == 3)
    #expect(map.get(2) == "two")
  }
}

// MARK: - AbstractSet tests (via minimal concrete subclass)

/// Minimal concrete AbstractSet backed by a Swift Array (preserves insertion order for tests).
private final class ConcreteSet<E: Equatable & Hashable>: java.util.AbstractSet<E> {
  private var _elements: [E] = []

  override func size() -> Int { _elements.count }

  override func iterator() -> any java.util.Iterator<E> {
    var index = 0
    let snapshot = _elements
    return AnyJavaIterator(
      hasNextFn: { index < snapshot.count },
      nextFn: { () throws(java.util.NoSuchElementException) -> E in
        guard index < snapshot.count else { throw java.util.NoSuchElementException() }
        let e = snapshot[index]; index += 1; return e
      }
    )
  }

  override func add(_ element: E?) throws -> Bool {
    guard let element else { return false }
    if _elements.contains(element) { return false }
    _elements.append(element)
    return true
  }

  override func remove(_ element: E?) -> Bool {
    guard let element, let idx = _elements.firstIndex(of: element) else { return false }
    _elements.remove(at: idx)
    return true
  }

  override func clear() {
    _elements.removeAll()
  }
}

/// Minimal AnyJavaIterator helper (no remove support needed for these tests).
private final class AnyJavaIterator<E: Equatable>: java.util.Iterator, IteratorProtocol {
  typealias Element = E
  private let _hasNext: () -> Bool
  private let _next: () throws(java.util.NoSuchElementException) -> E
  init(hasNextFn: @escaping () -> Bool, nextFn: @escaping () throws(java.util.NoSuchElementException) -> E) {
    _hasNext = hasNextFn; _next = nextFn
  }
  // java.util.Iterator
  func hasNext() -> Bool { _hasNext() }
  func next() throws(java.util.NoSuchElementException) -> E { try _next() }
  // IteratorProtocol (Swift for-in / Sequence)
  func next() -> E? { try? _next() }
  // Sequence
  func makeIterator() -> AnyJavaIterator<E> { self }
}

struct JavApi_util_AbstractSet_Tests {

  @Test("add inserts element; duplicate returns false")
  func testAddUniqueness() throws {
    let s = ConcreteSet<Int>()
    #expect(try s.add(1) == true)
    #expect(try s.add(1) == false)  // duplicate
    #expect(s.size() == 1)
  }

  @Test("size() and isEmpty() reflect element count")
  func testSizeAndIsEmpty() throws {
    let s = ConcreteSet<String>()
    #expect(s.isEmpty())
    _ = try s.add("a")
    #expect(!s.isEmpty())
    #expect(s.size() == 1)
  }

  @Test("contains() finds present element")
  func testContains() throws {
    let s = ConcreteSet<Int>()
    _ = try s.add(42)
    #expect(s.contains(42))
    #expect(!s.contains(99))
  }

  @Test("remove() deletes element and returns true; missing returns false")
  func testRemove() throws {
    let s = ConcreteSet<Int>()
    _ = try s.add(10)
    #expect(s.remove(10) == true)
    #expect(s.size() == 0)
    #expect(s.remove(10) == false)
  }

  @Test("clear() removes all elements")
  func testClear() throws {
    let s = ConcreteSet<Int>()
    _ = try s.add(1); _ = try s.add(2)
    s.clear()
    #expect(s.isEmpty())
  }

  @Test("equals() is true for two sets with same elements")
  func testEquals() throws {
    let a = ConcreteSet<Int>()
    let b = ConcreteSet<Int>()
    _ = try a.add(1); _ = try a.add(2)
    _ = try b.add(2); _ = try b.add(1)
    #expect(a.equals(b))
  }

  @Test("equals() is false when element counts differ")
  func testEqualsDifferentSize() throws {
    let a = ConcreteSet<Int>()
    let b = ConcreteSet<Int>()
    _ = try a.add(1)
    _ = try b.add(1); _ = try b.add(2)
    #expect(!a.equals(b))
  }

  @Test("hashCode() is order-independent (same elements → same hash)")
  func testHashCodeOrderIndependent() throws {
    let a = ConcreteSet<Int>()
    let b = ConcreteSet<Int>()
    _ = try a.add(1); _ = try a.add(2)
    _ = try b.add(2); _ = try b.add(1)
    #expect(a.hashCode() == b.hashCode())
  }

  @Test("removeAll() removes intersection")
  func testRemoveAll() throws {
    let s = ConcreteSet<Int>()
    _ = try s.add(1); _ = try s.add(2); _ = try s.add(3)
    let other = ConcreteSet<Int>()
    _ = try other.add(2); _ = try other.add(3)
    let modified = s.removeAll(other)
    #expect(modified == true)
    #expect(s.size() == 1)
    #expect(s.contains(1))
  }

  @Test("removeAll() returns false when no overlap")
  func testRemoveAllNoOverlap() throws {
    let s = ConcreteSet<Int>()
    _ = try s.add(1)
    let other = ConcreteSet<Int>()
    _ = try other.add(99)
    #expect(s.removeAll(other) == false)
    #expect(s.size() == 1)
  }
}
