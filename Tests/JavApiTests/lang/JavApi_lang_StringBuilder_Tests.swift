/*
 * SPDX-FileCopyrightText: 2024 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

struct JavApi_lang_StringBuilder_Tests {

  @Test("=== is false for distinct objects, == compares by value")
  func testEquals() {
    let a = StringBuilder("1")
    let b = StringBuilder("2")
    let c = StringBuilder("1")
    #expect(!(a === b))
    #expect(!(a == b))   // different content
    #expect(a == a)      // same instance
    #expect(!(a === c))  // different instances
    #expect(!(a == c))   // same content but different objects → Java identity semantics
  }

  @Test("hashCode is stable and differs for different content")
  func testHashCode() {
    let a = StringBuilder("1")
    let b = StringBuilder("2")
    let c = StringBuilder("1")
    // stable across two calls on the same instance
    #expect(a.hashCode() == a.hashCode())
    // different content → different hash
    #expect(a.hashCode() != b.hashCode())
    // same content but different instances → different hash (identity-based)
    #expect(a.hashCode() != c.hashCode())
  }

  // Regression test for a bug where `deleteCharAt` used
  // `Array.removeFirst(offset)` (removes the FIRST `offset` elements)
  // instead of removing the single element AT index `offset`.
  // "abcde".deleteCharAt(2) must remove only 'c' -> "abde",
  // not the first two characters ("cde", the old buggy result).
  @Test("deleteCharAt removes only the character at the given index")
  func testDeleteCharAtRemovesCorrectCharacter() throws {
    let sb = StringBuilder("abcde")
    try sb.deleteCharAt(2)
    #expect(sb.toString() == "abde")
  }

  @Test("deleteCharAt mutates the receiver in place and returns self (fluent)")
  func testDeleteCharAtMutatesInPlace() throws {
    let sb = StringBuilder("abcde")
    let returned = try sb.deleteCharAt(0)
    #expect(returned === sb)
    #expect(sb.toString() == "bcde")
  }

  @Test("deleteCharAt at the last valid index removes the last character")
  func testDeleteCharAtLastIndex() throws {
    let sb = StringBuilder("abcde")
    try sb.deleteCharAt(sb.count - 1)
    #expect(sb.toString() == "abcd")
  }

  @Test("deleteCharAt throws IndexOutOfBoundsException for negative or too large offsets")
  func testDeleteCharAtOutOfBounds() {
    let sb = StringBuilder("abc")
    #expect(throws: IndexOutOfBoundsException.self) {
      try sb.deleteCharAt(-1)
    }
    #expect(throws: IndexOutOfBoundsException.self) {
      try sb.deleteCharAt(sb.count)
    }
  }

  @Test("setLength to a shorter length truncates the content (regression: it used to silently do nothing)")
  func testSetLengthTruncates() throws {
    let sb = StringBuilder("abcdef")
    try sb.setLength(3)
    #expect(sb.toString() == "abc")
    #expect(sb.length() == 3)
  }

  @Test("setLength to a longer length pads with null characters")
  func testSetLengthPads() throws {
    let sb = StringBuilder("ab")
    try sb.setLength(4)
    #expect(sb.length() == 4)
    #expect(sb.toString() == "ab\u{0000}\u{0000}")
  }

  @Test("setLength(0) empties the builder")
  func testSetLengthZero() throws {
    let sb = StringBuilder("abcdef")
    try sb.setLength(0)
    #expect(sb.toString() == "")
  }

  @Test("capacity()/ensureCapacity()/trimToSize() do not affect content")
  func testCapacityIsAdvisoryOnly() {
    let sb = StringBuilder("abc")
    #expect(sb.capacity() >= sb.length())
    sb.ensureCapacity(100)
    #expect(sb.toString() == "abc")
    sb.trimToSize()
    #expect(sb.toString() == "abc")
  }

  @Test("setLength to the current length is a no-op")
  func testSetLengthUnchanged() throws {
    let sb = StringBuilder("abc")
    try sb.setLength(3)
    #expect(sb.toString() == "abc")
  }

  @Test("ensureCapacity with a non-positive value does not affect content or crash")
  func testEnsureCapacityNonPositiveIsNoOp() {
    let sb = StringBuilder("abc")
    sb.ensureCapacity(0)
    sb.ensureCapacity(-5)
    #expect(sb.toString() == "abc")
  }
}
