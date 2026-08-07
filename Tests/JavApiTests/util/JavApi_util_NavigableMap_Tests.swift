/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

/// Minimal NavigableMap backed by a sorted array — used only in tests.
private final class SimpleNavigableMap<K: Hashable & Comparable, V: Equatable>
    : java.util.AbstractMap<K, V>, java.util.NavigableMap {

  private var _pairs: [(key: K, value: V)] = []

  // MARK: - AbstractMap

  override func entrySet() -> any java.util.Set<java.util.MapEntry<K, V>> {
    let set = java.util.HashSet<java.util.MapEntry<K, V>>(initialCapacity: Swift.max(16, _pairs.count * 2))
    for p in _pairs { _ = try? set.add(Entry(p.key, p.value)) }
    return set
  }

  @discardableResult
  override func put(_ key: K, _ value: V) -> V? {
    if let idx = _pairs.firstIndex(where: { $0.key == key }) {
      let old = _pairs[idx].value
      _pairs[idx] = (key, value)
      return old
    }
    let ins = _pairs.firstIndex(where: { $0.key > key }) ?? _pairs.endIndex
    _pairs.insert((key, value), at: ins)
    return nil
  }

  @discardableResult
  override func remove(_ key: K) -> V? {
    guard let idx = _pairs.firstIndex(where: { $0.key == key }) else { return nil }
    let old = _pairs[idx].value; _pairs.remove(at: idx); return old
  }

  // MARK: - SortedMap

  func firstKey() throws -> K {
    guard let f = _pairs.first else { throw java.util.NoSuchElementException() }
    return f.key
  }
  func lastKey() throws -> K {
    guard let l = _pairs.last else { throw java.util.NoSuchElementException() }
    return l.key
  }
  func headMap(_ toKey: K) -> any java.util.SortedMap<K, V> {
    let m = SimpleNavigableMap<K,V>()
    _pairs.filter { $0.key < toKey }.forEach { _ = m.put($0.key, $0.value) }
    return m
  }
  func tailMap(_ fromKey: K) -> any java.util.SortedMap<K, V> {
    let m = SimpleNavigableMap<K,V>()
    _pairs.filter { $0.key >= fromKey }.forEach { _ = m.put($0.key, $0.value) }
    return m
  }
  func subMap(_ from: K, _ to: K) -> any java.util.SortedMap<K, V> {
    let m = SimpleNavigableMap<K,V>()
    _pairs.filter { $0.key >= from && $0.key < to }.forEach { _ = m.put($0.key, $0.value) }
    return m
  }
  func comparator() -> (any java.util.Comparator<K>)? { nil }

  // MARK: - NavigableMap

  func lowerEntry(_ key: K) -> java.util.MapEntry<K, V>? {
    _pairs.last(where: { $0.key < key }).map { Entry($0.key, $0.value) }
  }
  func floorEntry(_ key: K) -> java.util.MapEntry<K, V>? {
    _pairs.last(where: { $0.key <= key }).map { Entry($0.key, $0.value) }
  }
  func ceilingEntry(_ key: K) -> java.util.MapEntry<K, V>? {
    _pairs.first(where: { $0.key >= key }).map { Entry($0.key, $0.value) }
  }
  func higherEntry(_ key: K) -> java.util.MapEntry<K, V>? {
    _pairs.first(where: { $0.key > key }).map { Entry($0.key, $0.value) }
  }
  func firstEntry() -> java.util.MapEntry<K, V>? {
    _pairs.first.map { Entry($0.key, $0.value) }
  }
  func lastEntry() -> java.util.MapEntry<K, V>? {
    _pairs.last.map { Entry($0.key, $0.value) }
  }
  func pollFirstEntry() -> java.util.MapEntry<K, V>? {
    guard !_pairs.isEmpty else { return nil }
    let p = _pairs.removeFirst(); return Entry(p.key, p.value)
  }
  func pollLastEntry() -> java.util.MapEntry<K, V>? {
    guard !_pairs.isEmpty else { return nil }
    let p = _pairs.removeLast(); return Entry(p.key, p.value)
  }
  func descendingMap() -> any java.util.NavigableMap<K, V> {
    let m = SimpleNavigableMap<K,V>()
    for p in _pairs.reversed() { _ = m.put(p.key, p.value) }
    return m
  }
  func descendingKeySet() -> any java.util.NavigableSet<K> {
    fatalError("not needed for these tests")
  }
  func navigableKeySet() -> any java.util.NavigableSet<K> {
    fatalError("not needed for these tests")
  }
  func subMap(_ from: K, _ fromInc: Bool, _ to: K, _ toInc: Bool) -> any java.util.NavigableMap<K, V> {
    let m = SimpleNavigableMap<K,V>()
    _pairs.filter { p in
      let lo = fromInc ? p.key >= from : p.key > from
      let hi = toInc   ? p.key <= to   : p.key < to
      return lo && hi
    }.forEach { _ = m.put($0.key, $0.value) }
    return m
  }
  func headMap(_ to: K, _ inclusive: Bool) -> any java.util.NavigableMap<K, V> {
    let m = SimpleNavigableMap<K,V>()
    _pairs.filter { inclusive ? $0.key <= to : $0.key < to }.forEach { _ = m.put($0.key, $0.value) }
    return m
  }
  func tailMap(_ from: K, _ inclusive: Bool) -> any java.util.NavigableMap<K, V> {
    let m = SimpleNavigableMap<K,V>()
    _pairs.filter { inclusive ? $0.key >= from : $0.key > from }.forEach { _ = m.put($0.key, $0.value) }
    return m
  }
}

@Suite("java.util.NavigableMap")
struct JavApi_util_NavigableMap_Tests {

  private func makeMap() -> SimpleNavigableMap<Int, String> {
    let m = SimpleNavigableMap<Int, String>()
    m.put(1, "one"); m.put(3, "three"); m.put(5, "five"); m.put(7, "seven"); m.put(9, "nine")
    return m
  }

  @Test("lowerEntry returns entry with greatest key < given")
  func testLowerEntry() {
    let m = makeMap()
    #expect(m.lowerEntry(5)?.key == 3)
    #expect(m.lowerEntry(1) == nil)
  }

  @Test("floorEntry returns entry with greatest key <= given")
  func testFloorEntry() {
    let m = makeMap()
    #expect(m.floorEntry(5)?.key == 5)
    #expect(m.floorEntry(4)?.key == 3)
    #expect(m.floorEntry(0) == nil)
  }

  @Test("ceilingEntry returns entry with least key >= given")
  func testCeilingEntry() {
    let m = makeMap()
    #expect(m.ceilingEntry(5)?.key == 5)
    #expect(m.ceilingEntry(4)?.key == 5)
    #expect(m.ceilingEntry(10) == nil)
  }

  @Test("higherEntry returns entry with least key > given")
  func testHigherEntry() {
    let m = makeMap()
    #expect(m.higherEntry(5)?.key == 7)
    #expect(m.higherEntry(9) == nil)
  }

  @Test("firstEntry and lastEntry return endpoints")
  func testFirstLastEntry() {
    let m = makeMap()
    #expect(m.firstEntry()?.key == 1)
    #expect(m.lastEntry()?.key == 9)
  }

  @Test("pollFirstEntry removes and returns first entry")
  func testPollFirstEntry() {
    let m = makeMap()
    let e = m.pollFirstEntry()
    #expect(e?.key == 1)
    #expect(m.firstEntry()?.key == 3)
    #expect(m.size() == 4)
  }

  @Test("pollLastEntry removes and returns last entry")
  func testPollLastEntry() {
    let m = makeMap()
    let e = m.pollLastEntry()
    #expect(e?.key == 9)
    #expect(m.lastEntry()?.key == 7)
  }

  @Test("default lowerKey/floorKey/ceilingKey/higherKey derived from entry methods")
  func testKeyNavigation() {
    let m = makeMap()
    #expect(m.lowerKey(5) == 3)
    #expect(m.floorKey(6) == 5)
    #expect(m.ceilingKey(6) == 7)
    #expect(m.higherKey(7) == 9)
  }

  @Test("subMap with inclusive boundaries")
  func testSubMapInclusive() {
    let m = makeMap()
    let sub = m.subMap(3, true, 7, true)
    #expect(sub.containsKey(3) && sub.containsKey(7))
    #expect(!sub.containsKey(1) && !sub.containsKey(9))
  }

  @Test("headMap inclusive includes boundary key")
  func testHeadMapInclusive() {
    let m = makeMap()
    let head = m.headMap(5, true)
    #expect(head.containsKey(5))
    #expect(!head.containsKey(7))
  }

  @Test("tailMap exclusive excludes boundary key")
  func testTailMapExclusive() {
    let m = makeMap()
    let tail = m.tailMap(5, false)
    #expect(!tail.containsKey(5))
    #expect(tail.containsKey(7))
  }
}
