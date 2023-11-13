/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import XCTest
@testable import JavApi

final class JavApi_lang_Character_Tests: XCTestCase {
  
  
  func testOperator () {
    let A : Character = "A"
    let aValue = 65
    
    XCTAssertTrue(A == aValue)
    XCTAssertTrue(aValue == A)
    
    let B : Character = "B"
    
    XCTAssertFalse(B == aValue)
    XCTAssertFalse(aValue == B)
  }
  
  func testIsLetter () {
    let A : Character = "A"
    
    XCTAssertTrue(Character.isLetter(A))
    
    let aValue = 65
    XCTAssertTrue(Character.isLetter(aValue))

  }
  
}
