/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import XCTest
@testable import JavApi

final class JavApi_lang_String_Tests: XCTestCase {
  // Test constructors
  func testTrim () {
    do { // none to trim
      let input : java.lang.String = "JavApi the Java API in 100% pure Swift."
      let expected = input
      let actually : String = input.trim()
      XCTAssertEqual(expected, actually, "String \(expected) wurde geändert in \(actually) obwohl keine Änderung durch trim() erwartet wurde")
    }
    do { // 0x20 to trim
      let input : java.lang.String = "\u{2002}Sͬeͥbͭaͭsͤtͬian "
      let expected = "\u{2002}Sͬeͥbͭaͭsͤtͬian"
      let actually : String = input.trim()
      XCTAssertEqual(expected, actually, "String \(expected) wurde geändert in \(actually) obwohl durch trim() nur die Entfernung des letzten Space erwartet wurde")
    }
  }
  
  func testStrip (){
    do { // none to trim
      let input : java.lang.String = "JavApi the Java API in 100% pure Swift."
      let expected = input
      let actually : String = input.trim()
      XCTAssertEqual(expected, actually, "String \(expected) wurde geändert in \(actually) obwohl keine Änderung durch strip() erwartet wurde")
    }
    do { // 0x20 to trim
      let input : java.lang.String = "\u{2002}Sͬeͥbͭaͭsͤtͬian "
      let expected = "Sͬeͥbͭaͭsͤtͬian"
      let actually : String = input.strip()
      XCTAssertEqual(expected, actually, "String \(expected) wurde geändert in \(actually) obwohl durch strip() die Entfernung des Unicode 0x2002 und des letzten Space erwartet wurde")
    }
  }
}
