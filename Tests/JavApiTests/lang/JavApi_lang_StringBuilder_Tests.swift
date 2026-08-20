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
}
