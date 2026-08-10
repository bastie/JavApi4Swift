/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

// MARK: - Hashtable as java.util.Map

@Suite("Hashtable — java.util.Map-Konformanz")
struct HashtableMapTests {

  // MARK: - putAll

  @Test("putAll() kopiert alle Einträge")
  func testPutAll() {
    let source = java.util.Hashtable<String, Int>()
    source.put("a", 1)
    source.put("b", 2)

    let target = java.util.Hashtable<String, Int>()
    target.putAll(source)

    #expect(target.size() == 2)
    #expect(target.get("a") == 1)
    #expect(target.get("b") == 2)
  }

  @Test("putAll() überschreibt vorhandene Einträge")
  func testPutAllOverwrites() {
    let source = java.util.Hashtable<String, Int>()
    source.put("x", 99)

    let target = java.util.Hashtable<String, Int>()
    target.put("x", 1)
    target.putAll(source)

    #expect(target.get("x") == 99)
  }

  @Test("putAll() mit leerer Map ändert nichts")
  func testPutAllEmpty() {
    let target = java.util.Hashtable<String, Int>()
    target.put("z", 7)
    let empty = java.util.Hashtable<String, Int>()
    target.putAll(empty)
    #expect(target.size() == 1)
  }

  // MARK: - keySet

  @Test("keySet() enthält alle Schlüssel")
  func testKeySet() {
    let ht = java.util.Hashtable<String, Int>()
    ht.put("a", 1)
    ht.put("b", 2)
    ht.put("c", 3)
    let keys = ht.keySet()
    #expect(keys.size() == 3)
    #expect(keys.contains("a"))
    #expect(keys.contains("b"))
    #expect(keys.contains("c"))
  }

  @Test("keySet() ist leer für leere Hashtable")
  func testKeySetEmpty() {
    let ht = java.util.Hashtable<String, Int>()
    #expect(ht.keySet().isEmpty())
  }

  // MARK: - values()

  @Test("values() enthält alle Werte")
  func testValues() {
    let ht = java.util.Hashtable<String, Int>()
    ht.put("a", 10)
    ht.put("b", 20)
    let vals = ht.values()
    #expect(vals.size() == 2)
    #expect(vals.contains(10))
    #expect(vals.contains(20))
  }

  @Test("values() erlaubt Duplikate")
  func testValuesDuplicates() {
    let ht = java.util.Hashtable<String, Int>()
    ht.put("a", 5)
    ht.put("b", 5)
    #expect(ht.values().size() == 2)
  }

  // MARK: - entrySet

  @Test("entrySet() enthält alle MapEntry-Paare")
  func testEntrySet() {
    let ht = java.util.Hashtable<String, Int>()
    ht.put("x", 1)
    ht.put("y", 2)
    let entries = ht.entrySet()
    #expect(entries.size() == 2)
    let found = entries.contains(java.util.MapEntry("x", 1))
      && entries.contains(java.util.MapEntry("y", 2))
    #expect(found)
  }

  @Test("entrySet() ist leer für leere Hashtable")
  func testEntrySetEmpty() {
    let ht = java.util.Hashtable<String, Int>()
    #expect(ht.entrySet().isEmpty())
  }

  // MARK: - equals

  @Test("equals() gibt true für gleichwertige Hashtables")
  func testEqualsTrue() {
    let a = java.util.Hashtable<String, Int>()
    a.put("k", 1)
    let b = java.util.Hashtable<String, Int>()
    b.put("k", 1)
    #expect(a.equals(b) == true)
  }

  @Test("equals() gibt false bei unterschiedlichen Werten")
  func testEqualsFalseValue() {
    let a = java.util.Hashtable<String, Int>()
    a.put("k", 1)
    let b = java.util.Hashtable<String, Int>()
    b.put("k", 2)
    #expect(a.equals(b) == false)
  }

  @Test("equals() gibt false bei unterschiedlicher Größe")
  func testEqualsFalseSize() {
    let a = java.util.Hashtable<String, Int>()
    a.put("k", 1)
    a.put("j", 2)
    let b = java.util.Hashtable<String, Int>()
    b.put("k", 1)
    #expect(a.equals(b) == false)
  }

  // MARK: - hashCode

  @Test("hashCode() ist gleich für gleiche Hashtables")
  func testHashCodeEqual() {
    let a = java.util.Hashtable<String, Int>()
    a.put("key", 42)
    let b = java.util.Hashtable<String, Int>()
    b.put("key", 42)
    #expect(a.hashCode() == b.hashCode())
  }

  @Test("hashCode() leere Hashtable gibt 0 zurück")
  func testHashCodeEmpty() {
    let ht = java.util.Hashtable<String, Int>()
    #expect(ht.hashCode() == 0)
  }

  // MARK: - Hashtable als any java.util.Map verwendbar

  @Test("Hashtable als any java.util.Map verwendbar")
  func testAsMapProtocol() {
    let ht = java.util.Hashtable<String, Int>()
    ht.put("one", 1)
    let map: any java.util.Map<String, Int> = ht
    #expect(map.get("one") == 1)
    #expect(map.size() == 1)
  }

  @Test("getOrDefault() gibt Standardwert zurück")
  func testGetOrDefault() {
    let ht = java.util.Hashtable<String, Int>()
    ht.put("a", 10)
    #expect(ht.getOrDefault("a", 0) == 10)
    #expect(ht.getOrDefault("z", -1) == -1)
  }

  @Test("putIfAbsent() fügt nur ein wenn Schlüssel fehlt")
  func testPutIfAbsent() {
    let ht = java.util.Hashtable<String, Int>()
    ht.put("a", 1)
    _ = ht.putIfAbsent("a", 99)   // soll nicht überschreiben
    _ = ht.putIfAbsent("b", 2)    // soll einfügen
    #expect(ht.get("a") == 1)
    #expect(ht.get("b") == 2)
  }
}
