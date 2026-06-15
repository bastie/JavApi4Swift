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

  // ---------------------------------------------------------------------------
  // MARK: - charAt Unicode tests
  // ---------------------------------------------------------------------------

  @Test("charAt returns correct character for ASCII input")
  func testCharAtASCII() {
    let s: java.lang.String = "Hello"
    #expect(s.charAt(0) == "H")
    #expect(s.charAt(1) == "e")
    #expect(s.charAt(4) == "o")
  }

  @Test("charAt handles German umlauts (multi-byte UTF-8, single Swift.Character)")
  func testCharAtGerman() {
    // Ä ö ü ß are each one Swift.Character (Unicode scalar)
    let s: java.lang.String = "Äöüß"
    #expect(s.charAt(0) == "Ä")
    #expect(s.charAt(1) == "ö")
    #expect(s.charAt(2) == "ü")
    #expect(s.charAt(3) == "ß")
  }

  @Test("charAt handles CJK ideographs (Chinese / Japanese)")
  func testCharAtCJK() {
    // 日本語 = Japanese; 汉字 = Chinese characters
    let s: java.lang.String = "日本語汉字"
    #expect(s.charAt(0) == "日")
    #expect(s.charAt(1) == "本")
    #expect(s.charAt(2) == "語")
    #expect(s.charAt(3) == "汉")
    #expect(s.charAt(4) == "字")
  }

  @Test("charAt handles Emoji (multi-scalar grapheme clusters count as one Character)")
  func testCharAtEmoji() {
    // Each emoji is one Swift.Character regardless of its UTF-16 surrogate pair or ZWJ sequence length
    let s: java.lang.String = "😀🇩🇪👨‍👩‍👧"
    #expect(s.charAt(0) == "😀")   // single scalar emoji
    #expect(s.charAt(1) == "🇩🇪")  // flag: regional indicator pair
    #expect(s.charAt(2) == "👨‍👩‍👧") // ZWJ family sequence
  }

  @Test("charAt handles Ogham Space Mark (U+1680)")
  func testCharAtOghamSpace() {
    // U+1680 OGHAM SPACE MARK — a historic whitespace character
    let s: java.lang.String = "A\u{1680}B"
    #expect(s.charAt(0) == "A")
    #expect(s.charAt(1) == "\u{1680}")
    #expect(s.charAt(2) == "B")
  }

  @Test("charAt handles mixed Unicode script string")
  func testCharAtMixed() {
    // ASCII + German + CJK + Emoji + Ogham space in one string
    let s: java.lang.String = "A\u{00DC}\u{65E5}\u{1680}😀"
    #expect(s.charAt(0) == "A")
    #expect(s.charAt(1) == "Ü")       // U+00DC
    #expect(s.charAt(2) == "日")      // U+65E5
    #expect(s.charAt(3) == "\u{1680}") // Ogham space
    #expect(s.charAt(4) == "😀")
  }
}
