/*
 * SPDX-FileCopyrightText: 2024 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import XCTest
@testable import JavApi

final class JavApi_lang_StringBuilder_Tests: XCTestCase {
  
  func testEquals () {
    let a = StringBuilder("1")
    let b = StringBuilder("2")
    let c = StringBuilder("1")
    XCTAssertFalse(a===b);
    XCTAssertFalse(a == b) // false
    XCTAssertTrue(a == a) // true
    XCTAssertFalse(a===c) // false
    XCTAssertFalse(a==c) // false
  }
  
  func testHashCode () {
    let a = StringBuilder("1")
    let b = StringBuilder("2")
    let c = StringBuilder("1")
    // call twice with same result
    XCTAssertEqual(a.hashCode(), a.hashCode())
    // two objects with different content creates different hashCode
    XCTAssertNotEqual(a.hashCode(), b.hashCode())
    // two objects with same content creates different hashCode
    XCTAssertNotEqual(a.hashCode(), c.hashCode())
  }
}
