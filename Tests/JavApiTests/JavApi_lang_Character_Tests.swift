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
  
  func testGetNumericValue () {
    let A : Character = "A"
    XCTAssertTrue(10 == Character.getNumericValue(A))
    
    let _1fract : Character = "\u{215f}"
    XCTAssertTrue(1 == Character.getNumericValue(_1fract))
    
    let _1fract4 : Character = "\u{00BC}"
    XCTAssertTrue(-2 == Character.getNumericValue(_1fract4))
  }
  
  func testConvertToInt () {
    let A : Character = "A"
    XCTAssertTrue(65 == Int(A))
    
    let 𝄞 : Character = "𝄞" // Beispiel: Musikalisches Symbol ( außerhalb der BMP)
    XCTAssertTrue(119070 == Int (𝄞))
  }
}
