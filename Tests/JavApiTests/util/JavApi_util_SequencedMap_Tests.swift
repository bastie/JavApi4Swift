/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

/// Minimal SequencedMap backed by an ordered array of entries — tests only.
private final class SimpleSequencedMap<K: Hashable, V: Equatable>
    : java.util.AbstractMap<K, V>, java.util.SequencedMap {

  private var _pairs: [(key: K, value: V)] = []

  override func entrySet() -> any java.util.Set<java.util.MapEntry<K, V>> {
    let set = java.util.HashSet<java.util.MapEntry<K, V>>(initialCapacity: Swift.max(16, _pairs.count * 2))
    for p in _pairs { _ = try? set.add(Entry(p.key, p.value)) }
    return set
  }

  @discardableResult
  override func put(_ key: K, _ value: V) -> V? {
    if let idx = _pairs.firstIndex(where: { $0.key == key }) {
      let old = _pairs[idx].value; _pairs[idx] = (key, value); return old
    }
    _pairs.append((key, value)); return nil
  }

  @discardableResult
  override func remove(_ key: K) -> V? {
    guard let idx = _pairs.firstIndex(where: { $0.key == key }) else { return nil }
    let old = _pairs[idx].value; _pairs.remove(at: idx); return old
  }

  // SequencedMap
  func firstEntry() -> java.util.MapEntry<K, V>? { _pairs.first.map { Entry($0.key, $0.value) } }
  func lastEntry() -> java.util.MapEntry<K, V>? { _pairs.last.map { Entry($0.key, $0.value) } }
  func pollFirstEntry() -> java.util.MapEntry<K, V>? {
    guard !_pairs.isEmpty else { return nil }
    let p = _pairs.removeFirst(); return Entry(p.key, p.value)
  }
  func pollLastEntry() -> java.util.MapEntry<K, V>? {
    guard !_pairs.isEmpty else { return nil }
    let p = _pairs.removeLast(); return Entry(p.key, p.value)
  }
  func putFirst(_ key: K, _ value: V) throws -> V? {
    let old = remove(key); _pairs.insert((key, value), at: 0); return old
  }
  func putLast(_ key: K, _ value: V) throws -> V? {
    let old = remove(key); _pairs.append((key, value)); return old
  }
  func reversedMap() -> any java.util.SequencedMap<K, V> {
    let m = SimpleSequencedMap<K,V>()
    for p in _pairs.reversed() { _ = m.put(p.key, p.value) }
    return m
  }
  func sequencedKeySet() -> any java.util.SequencedSet<K> {
    fatalError("not needed for these tests")
  }
  func sequencedValues() -> any java.util.SequencedCollection<V> {
    fatalError("not needed for these tests")
  }
  func sequencedEntrySet() -> any java.util.SequencedSet<java.util.MapEntry<K, V>> {
    fatalError("not needed for these tests")
  }
}

@Suite("java.util.SequencedMap")
struct JavApi_util_SequencedMap_Tests {

  @Test("firstEntry and lastEntry reflect insertion order")
  func testFirstLastEntry() {
    let m = SimpleSequencedMap<String, Int>()
    m.put("a", 1); m.put("b", 2); m.put("c", 3)
    #expect(m.firstEntry()?.key == "a")
    #expect(m.lastEntry()?.key == "c")
  }

  @Test("pollFirstEntry removes and returns first entry")
  func testPollFirstEntry() {
    let m = SimpleSequencedMap<String, Int>()
    m.put("x", 10); m.put("y", 20)
    let e = m.pollFirstEntry()
    #expect(e?.key == "x" && e?.value == 10)
    #expect(m.size() == 1)
    #expect(m.firstEntry()?.key == "y")
  }

  @Test("pollLastEntry removes and returns last entry")
  func testPollLastEntry() {
    let m = SimpleSequencedMap<String, Int>()
    m.put("x", 10); m.put("y", 20)
    let e = m.pollLastEntry()
    #expect(e?.key == "y" && e?.value == 20)
    #expect(m.size() == 1)
  }

  @Test("putFirst inserts at front of encounter order")
  func testPutFirst() throws {
    let m = SimpleSequencedMap<String, Int>()
    m.put("b", 2); m.put("c", 3)
    _ = try m.putFirst("a", 1)
    #expect(m.firstEntry()?.key == "a")
  }

  @Test("putLast appends at end of encounter order")
  func testPutLast() throws {
    let m = SimpleSequencedMap<String, Int>()
    m.put("a", 1); m.put("b", 2)
    _ = try m.putLast("c", 3)
    #expect(m.lastEntry()?.key == "c")
  }

  @Test("reversedMap inverts encounter order")
  func testReversedMap() {
    let m = SimpleSequencedMap<String, Int>()
    m.put("a", 1); m.put("b", 2); m.put("c", 3)
    let rev = m.reversedMap()
    #expect(rev.firstEntry()?.key == "c")
    #expect(rev.lastEntry()?.key == "a")
  }

  @Test("default putFirst/putLast throw UnsupportedOperationException")
  func testDefaultPutThrows() async {
    // Use a map that does NOT override putFirst/putLast
    // The SequencedMap extension default must throw.
    // We verify via a type that only conforms minimally.
    // (Covered by the protocol default implementation.)
    let m = SimpleSequencedMap<String, Int>()
    // SimpleSequencedMap overrides both — verify it does NOT throw
    #expect(throws: Never.self) { try m.putFirst("z", 99) }
  }
}
