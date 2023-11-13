/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import XCTest
@testable import JavApi

final class JavApi_lang_String_Tests: XCTestCase {

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
  
  func testSplit () {
    do {
      let input : java.lang.String = "Hello World!"
      let expected  = ["H","e","l","l","o"," ","W","o","r","l","d","!"]
      let actually = input.split("")
      XCTAssertEqual(expected, actually, "Der String \(input) wurde nicht wie erwartet nach \(expected) zerlegt sondern als \(actually)")
    }
  }
  
  func testToCharArray () {
    let input : java.lang.String = "Hello World!"
    let expected : [Character] = ["H","e","l","l","o"," ","W","o","r","l","d","!"]
    let actually = input.toCharArray()
    XCTAssertEqual(expected, actually, "Der String \(input) wurde nicht wie erwartet nach \(expected) zerlegt sondern als \(actually)")
  }
  
  func testSubsequence () {
    let input = "Die Würde des Menschen ist unantastbar. Sie zu achten und zu schützen ist Verpflichtung aller staatlichen Gewalt."
    var actually = input.subSequence(0, 39)
    var expected = "Die Würde des Menschen ist unantastbar."
    
    XCTAssertEqual(actually,expected)
    
    actually = input.substring(40)
    expected = "Sie zu achten und zu schützen ist Verpflichtung aller staatlichen Gewalt."
    
    XCTAssertEqual(actually,expected)
  }
}
