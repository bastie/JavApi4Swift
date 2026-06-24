/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

struct JavApi_util_BitSet_Tests {

  // MARK: - init

  @Test("init() creates BitSet with size 64")
  func testInitDefault() {
    let bs = java.util.BitSet()
    #expect(bs.size() == 64)
    #expect(bs.get(0) == false)
  }

  @Test("init(nbits) rounds up to next multiple of 64")
  func testInitNbits() {
    #expect(java.util.BitSet(1).size()   == 64)
    #expect(java.util.BitSet(64).size()  == 64)
    #expect(java.util.BitSet(65).size()  == 128)
    #expect(java.util.BitSet(128).size() == 128)
    #expect(java.util.BitSet(129).size() == 192)
  }

  @Test("init(0) and init(-1) produce size 64")
  func testInitZeroOrNegative() {
    #expect(java.util.BitSet(0).size()  == 64)
  }

  // MARK: - set / get / clear

  @Test("set and get single bit")
  func testSetGet() {
    let bs = java.util.BitSet()
    #expect(bs.get(0) == false)
    bs.set(0)
    #expect(bs.get(0) == true)
    #expect(bs.get(1) == false)
  }

  @Test("set multiple bits independently")
  func testSetMultiple() {
    let bs = java.util.BitSet()
    bs.set(0)
    bs.set(3)
    bs.set(7)
    #expect(bs.get(0) == true)
    #expect(bs.get(1) == false)
    #expect(bs.get(3) == true)
    #expect(bs.get(7) == true)
    #expect(bs.get(8) == false)
  }

  @Test("clear resets a set bit")
  func testClear() {
    let bs = java.util.BitSet()
    bs.set(5)
    #expect(bs.get(5) == true)
    bs.clear(5)
    #expect(bs.get(5) == false)
  }

  @Test("clear on already-clear bit is a no-op")
  func testClearAlreadyClear() {
    let bs = java.util.BitSet()
    bs.clear(10)
    #expect(bs.get(10) == false)
  }

  @Test("get beyond capacity returns false")
  func testGetBeyondCapacity() {
    let bs = java.util.BitSet(8)
    #expect(bs.get(1000) == false)
  }

  @Test("set beyond initial capacity grows the BitSet")
  func testSetGrows() {
    let bs = java.util.BitSet(8)
    #expect(bs.size() == 64)
    bs.set(64)   // triggers growth to 2 words
    #expect(bs.size() == 128)
    #expect(bs.get(64) == true)
  }

  @Test("set and clear across word boundary (bit 63 and 64)")
  func testWordBoundary() {
    let bs = java.util.BitSet()
    bs.set(63)
    bs.set(64)
    #expect(bs.get(63) == true)
    #expect(bs.get(64) == true)
    bs.clear(63)
    #expect(bs.get(63) == false)
    #expect(bs.get(64) == true)
  }

  // MARK: - Logical operations

  @Test("and: result has only bits set in both")
  func testAnd() {
    let a = java.util.BitSet()
    a.set(0); a.set(1); a.set(2)
    let b = java.util.BitSet()
    b.set(1); b.set(2); b.set(3)
    a.and(b)
    #expect(a.get(0) == false)
    #expect(a.get(1) == true)
    #expect(a.get(2) == true)
    #expect(a.get(3) == false)
  }

  @Test("and with shorter set clears extra bits")
  func testAndShorter() {
    let a = java.util.BitSet(128)
    a.set(0); a.set(70)
    let b = java.util.BitSet(64)
    b.set(0)
    a.and(b)
    #expect(a.get(0)  == true)
    #expect(a.get(70) == false)
  }

  @Test("or: result has bits set in either")
  func testOr() {
    let a = java.util.BitSet()
    a.set(0); a.set(1)
    let b = java.util.BitSet()
    b.set(1); b.set(2)
    a.or(b)
    #expect(a.get(0) == true)
    #expect(a.get(1) == true)
    #expect(a.get(2) == true)
    #expect(a.get(3) == false)
  }

  @Test("or with larger set grows receiver")
  func testOrGrows() {
    let a = java.util.BitSet(64)
    let b = java.util.BitSet(128)
    b.set(70)
    a.or(b)
    #expect(a.get(70) == true)
    #expect(a.size()  == 128)
  }

  @Test("xor: result has bits set in exactly one")
  func testXor() {
    let a = java.util.BitSet()
    a.set(0); a.set(1)
    let b = java.util.BitSet()
    b.set(1); b.set(2)
    a.xor(b)
    #expect(a.get(0) == true)   // only in a
    #expect(a.get(1) == false)  // in both → cancelled
    #expect(a.get(2) == true)   // only in b
  }

  @Test("xor with itself produces empty set")
  func testXorSelf() {
    let a = java.util.BitSet()
    a.set(0); a.set(5); a.set(63)
    let b = a.clone()
    a.xor(b)
    #expect(a.get(0)  == false)
    #expect(a.get(5)  == false)
    #expect(a.get(63) == false)
  }

  // MARK: - clone

  @Test("clone produces independent copy")
  func testClone() {
    let a = java.util.BitSet()
    a.set(1); a.set(5)
    let b = a.clone()
    #expect(b.get(1) == true)
    #expect(b.get(5) == true)
    // Mutating clone does not affect original
    b.set(10)
    #expect(a.get(10) == false)
    // Mutating original does not affect clone
    a.clear(1)
    #expect(b.get(1) == true)
  }

  // MARK: - equals

  @Test("equals: same bits → true")
  func testEqualsTrue() {
    let a = java.util.BitSet()
    let b = java.util.BitSet()
    a.set(3); b.set(3)
    #expect(a.equals(b))
  }

  @Test("equals: different bits → false")
  func testEqualsFalse() {
    let a = java.util.BitSet()
    let b = java.util.BitSet()
    a.set(3); b.set(4)
    #expect(!a.equals(b))
  }

  @Test("equals: empty sets are equal regardless of capacity")
  func testEqualsEmpty() {
    let a = java.util.BitSet(64)
    let b = java.util.BitSet(128)
    #expect(a.equals(b))
  }

  @Test("equals: set with extra capacity but same bits")
  func testEqualsDifferentCapacity() {
    let a = java.util.BitSet(64)
    let b = java.util.BitSet(128)
    a.set(0); b.set(0)
    #expect(a.equals(b))
  }

  // MARK: - Equatable (Swift ==)

  @Test("== operator mirrors equals()")
  func testEquatableOperator() {
    let a = java.util.BitSet()
    let b = java.util.BitSet()
    a.set(7); b.set(7)
    #expect(a == b)
    b.set(8)
    #expect(a != b)
  }

  // MARK: - Hashable

  @Test("equal BitSets have same hash")
  func testHashable() {
    let a = java.util.BitSet()
    let b = java.util.BitSet()
    a.set(42); b.set(42)
    #expect(a.hashValue == b.hashValue)
  }

  @Test("BitSet can be used as Dictionary key")
  func testUsableAsDictionaryKey() {
    var dict: [java.util.BitSet: String] = [:]
    let key = java.util.BitSet()
    key.set(1)
    dict[key] = "one"
    let lookup = java.util.BitSet()
    lookup.set(1)
    #expect(dict[lookup] == "one")
  }

  // MARK: - toString / description

  @Test("toString of empty set is {}")
  func testToStringEmpty() {
    let bs = java.util.BitSet()
    #expect(bs.toString() == "{}")
  }

  @Test("toString lists set bit indices in ascending order")
  func testToString() {
    let bs = java.util.BitSet()
    bs.set(0); bs.set(3); bs.set(7)
    #expect(bs.toString() == "{0, 3, 7}")
  }

  @Test("description matches toString")
  func testDescription() {
    let bs = java.util.BitSet()
    bs.set(2); bs.set(5)
    #expect(bs.description == bs.toString())
  }

  // MARK: - hashCode (Java API)

  @Test("hashCode is consistent across calls")
  func testHashCode() {
    let bs = java.util.BitSet()
    bs.set(10)
    let h1 = bs.hashCode()
    let h2 = bs.hashCode()
    #expect(h1 == h2)
  }
}
