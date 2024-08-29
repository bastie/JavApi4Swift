/*
 * SPDX-FileCopyrightText: 2024 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import XCTest
@testable import JavApi

final class JavApi_lang_Long_Tests: XCTestCase {
  
  func testNumberOfLeadingZeros () {
    XCTAssertEqual(64, Long.numberOfLeadingZeros(0))
    XCTAssertEqual(63, Long.numberOfLeadingZeros(1))
    XCTAssertEqual(0, Long.numberOfLeadingZeros(-1))
    XCTAssertEqual(1, Long.numberOfLeadingZeros(Long.MAX_VALUE))
    XCTAssertEqual(0, Long.numberOfLeadingZeros(Long.MIN_VALUE))
  }
  
  
  func testNumberOfTrailingZeros () {
    XCTAssertEqual(64, Long.numberOfTrailingZeros(0))
    XCTAssertEqual(0, Long.numberOfTrailingZeros(1))
    XCTAssertEqual(0, Long.numberOfTrailingZeros(-1))
    XCTAssertEqual(0, Long.numberOfTrailingZeros(Long.MAX_VALUE))
    XCTAssertEqual(63, Long.numberOfTrailingZeros(Long.MIN_VALUE))
  }
}
