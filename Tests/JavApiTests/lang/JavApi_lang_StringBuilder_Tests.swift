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
}
