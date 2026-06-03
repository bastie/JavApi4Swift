/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

struct JavApi_lang_String_Tests {

  @Test("trim removes only ASCII space (0x20) from ends, not Unicode spaces")
  func testTrim() {
    // nothing to trim
    let plain: java.lang.String = "JavApi the Java API in 100% pure Swift."
    #expect(plain.trim() == plain)

    // only trailing ASCII space is removed; leading Unicode 0x2002 stays
    let withSpaces: java.lang.String = "\u{2002}Sͬeͥbͭaͭsͤtͬian "
    #expect(withSpaces.trim() == "\u{2002}Sͬeͥbͭaͭsͤtͬian")
  }

  @Test("strip removes Unicode whitespace from both ends")
  func testStrip() {
    // nothing to strip
    let plain: java.lang.String = "JavApi the Java API in 100% pure Swift."
    #expect(plain.strip() == plain)

    // leading Unicode 0x2002 and trailing ASCII space are both removed
    let withSpaces: java.lang.String = "\u{2002}Sͬeͥbͭaͭsͤtͬian "
    #expect(withSpaces.strip() == "Sͬeͥbͭaͭsͤtͬian")
  }

  @Test("split on empty string yields individual characters")
  func testSplit() {
    let input: java.lang.String = "Hello World!"
    let expected = ["H","e","l","l","o"," ","W","o","r","l","d","!"]
    #expect(input.split("") == expected)
  }

  @Test("toCharArray converts string to Character array")
  func testToCharArray() {
    let input: java.lang.String = "Hello World!"
    let expected: [Character] = ["H","e","l","l","o"," ","W","o","r","l","d","!"]
    #expect(input.toCharArray() == expected)
  }

  @Test("subSequence and substring extract correct ranges")
  func testSubsequence() {
    let input = "Die Würde des Menschen ist unantastbar. Sie zu achten und zu schützen ist Verpflichtung aller staatlichen Gewalt."
    #expect(input.subSequence(0, 39) == "Die Würde des Menschen ist unantastbar.")
    #expect(input.substring(40) == "Sie zu achten und zu schützen ist Verpflichtung aller staatlichen Gewalt.")
  }
}
