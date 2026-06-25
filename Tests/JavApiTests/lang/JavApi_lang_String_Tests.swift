/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

struct JavApi_lang_String_Tests {

  // ---------------------------------------------------------------------------
  // MARK: - trim / strip
  // ---------------------------------------------------------------------------

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

  // ---------------------------------------------------------------------------
  // MARK: - split
  // ---------------------------------------------------------------------------

  @Test("split on empty string yields individual characters")
  func testSplit() {
    let input: java.lang.String = "Hello World!"
    let expected = ["H","e","l","l","o"," ","W","o","r","l","d","!"]
    #expect(input.split("") == expected)
  }

  @Test("split on space separates words")
  func testSplitOnSpace() {
    let input: java.lang.String = "one two three"
    #expect(input.split(" ") == ["one", "two", "three"])
  }

  @Test("split on delimiter not present returns single-element array")
  func testSplitNoMatch() {
    let input: java.lang.String = "hello"
    #expect(input.split(",") == ["hello"])
  }

  // ---------------------------------------------------------------------------
  // MARK: - toCharArray
  // ---------------------------------------------------------------------------

  @Test("toCharArray converts string to Character array")
  func testToCharArray() {
    let input: java.lang.String = "Hello World!"
    let expected: [Character] = ["H","e","l","l","o"," ","W","o","r","l","d","!"]
    #expect(input.toCharArray() == expected)
  }

  // ---------------------------------------------------------------------------
  // MARK: - subSequence / substring
  // ---------------------------------------------------------------------------

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
    #expect(s.charAt(1) == "Ü")        // U+00DC
    #expect(s.charAt(2) == "日")       // U+65E5
    #expect(s.charAt(3) == "\u{1680}") // Ogham space
    #expect(s.charAt(4) == "😀")
  }

  // ---------------------------------------------------------------------------
  // MARK: - indexOf
  // ---------------------------------------------------------------------------

  @Test("indexOf(String) returns first occurrence position")
  func testIndexOfString() {
    let s: java.lang.String = "Hello World"
    #expect(s.indexOf("World") == 6)
    #expect(s.indexOf("Hello") == 0)
  }

  @Test("indexOf(String) returns -1 when not found")
  func testIndexOfStringNotFound() {
    let s: java.lang.String = "Hello World"
    #expect(s.indexOf("xyz") == -1)
  }

  @Test("indexOf(Character) returns first occurrence position")
  func testIndexOfCharacter() {
    let s: java.lang.String = "Hello"
    #expect(s.indexOf(Character("l")) == 2)
    #expect(s.indexOf(Character("H")) == 0)
  }

  @Test("indexOf(Character) returns -1 when not found")
  func testIndexOfCharacterNotFound() {
    let s: java.lang.String = "Hello"
    #expect(s.indexOf(Character("z")) == -1)
  }

  // ---------------------------------------------------------------------------
  // MARK: - lastIndexOf
  // ---------------------------------------------------------------------------

  @Test("lastIndexOf(Character) returns last occurrence position")
  func testLastIndexOfCharacter() {
    let s: java.lang.String = "Hello"
    // 'l' appears at index 2 and 3 — last is 3
    #expect(s.lastIndexOf(Character("l")) == 3)
  }

  @Test("lastIndexOf(Character) returns -1 when not found")
  func testLastIndexOfCharacterNotFound() {
    let s: java.lang.String = "Hello"
    #expect(s.lastIndexOf(Character("z")) == -1)
  }

  @Test("lastIndexOf(String) returns last occurrence position")
  func testLastIndexOfString() {
    let s: java.lang.String = "abcabc"
    #expect(s.lastIndexOf("abc") == 3)
    #expect(s.lastIndexOf("a") == 3)
  }

  @Test("lastIndexOf(String) returns -1 when not found")
  func testLastIndexOfStringNotFound() {
    let s: java.lang.String = "Hello"
    #expect(s.lastIndexOf("xyz") == -1)
  }

  // ---------------------------------------------------------------------------
  // MARK: - replace / replaceAll / replaceFirst
  // ---------------------------------------------------------------------------

  @Test("replace(String, String) replaces all occurrences")
  func testReplaceStringString() {
    let s: java.lang.String = "aabbaa"
    #expect(s.replace("aa", "X") == "XbbX")
  }

  @Test("replace(String, String) with no match returns original")
  func testReplaceStringStringNoMatch() {
    let s: java.lang.String = "Hello"
    #expect(s.replace("xyz", "A") == "Hello")
  }

  @Test("replaceAll replaces all occurrences (same as replace)")
  func testReplaceAll() {
    let s: java.lang.String = "aabbaa"
    #expect(s.replaceAll("aa", "X") == "XbbX")
  }

  @Test("replace(Character, Character) replaces all occurrences")
  func testReplaceCharChar() {
    let s: java.lang.String = "Hello"
    #expect(s.replace(Character("l"), Character("r")) == "Herro")
  }

  @Test("replaceFirst replaces only the first occurrence")
  func testReplaceFirst() {
    let s: java.lang.String = "aabbaa"
    #expect(s.replaceFirst("aa", "X") == "Xbbaa")
  }

  @Test("replaceFirst with no match returns original")
  func testReplaceFirstNoMatch() {
    let s: java.lang.String = "Hello"
    #expect(s.replaceFirst("xyz", "A") == "Hello")
  }

  // ---------------------------------------------------------------------------
  // MARK: - startsWith / endsWith
  // ---------------------------------------------------------------------------

  @Test("startsWith returns true for matching prefix")
  func testStartsWith() {
    let s: java.lang.String = "Hello World"
    #expect(s.startsWith("Hello"))
    #expect(!s.startsWith("World"))
  }

  @Test("endsWith returns true for matching suffix")
  func testEndsWith() {
    let s: java.lang.String = "Hello World"
    #expect(s.endsWith("World"))
    #expect(!s.endsWith("Hello"))
  }

  // ---------------------------------------------------------------------------
  // MARK: - isBlank / isEmpty
  // ---------------------------------------------------------------------------

  @Test("isBlank returns true for empty and whitespace-only strings")
  func testIsBlank() {
    #expect("".isBlank())
    #expect("   ".isBlank())
    #expect("\t\n".isBlank())
    #expect(!"Hello".isBlank())
    #expect(!" x ".isBlank())
  }

  @Test("isEmpty returns true only for zero-length strings")
  func testIsEmpty() {
    #expect("".isEmpty())
    #expect(!"  ".isEmpty())  // whitespace is not empty
    #expect(!"Hello".isEmpty())
  }

  // ---------------------------------------------------------------------------
  // MARK: - length
  // ---------------------------------------------------------------------------

  @Test("length returns grapheme cluster count")
  func testLength() {
    #expect("Hello".length() == 5)
    #expect("".length() == 0)
    #expect("Äöü".length() == 3)
    // each emoji counts as one grapheme cluster
    #expect("😀🇩🇪".length() == 2)
  }

  // ---------------------------------------------------------------------------
  // MARK: - toUpperCase / toLowerCase
  // ---------------------------------------------------------------------------

  @Test("toUpperCase converts ASCII letters to uppercase")
  func testToUpperCase() {
    #expect("hello".toUpperCase() == "HELLO")
    #expect("Hello World!".toUpperCase() == "HELLO WORLD!")
    #expect("123".toUpperCase() == "123")
  }

  @Test("toLowerCase converts ASCII letters to lowercase")
  func testToLowerCase() {
    #expect("HELLO".toLowerCase() == "hello")
    #expect("Hello World!".toLowerCase() == "hello world!")
    #expect("123".toLowerCase() == "123")
  }

  // ---------------------------------------------------------------------------
  // MARK: - equals / toString / hashCode
  // ---------------------------------------------------------------------------

  @Test("equals returns true for identical strings")
  func testEquals() {
    #expect("Hello".equals("Hello"))
    #expect(!"Hello".equals("hello"))
    #expect(!"Hello".equals("World"))
  }

  @Test("toString returns self")
  func testToString() {
    let s: java.lang.String = "Swift"
    #expect(s.toString() == s)
  }

  @Test("hashCode is stable across calls")
  func testHashCode() {
    let s: java.lang.String = "Hello"
    #expect(s.hashCode() == s.hashCode())
  }

  // ---------------------------------------------------------------------------
  // MARK: - valueOf
  // ---------------------------------------------------------------------------

  @Test("valueOf(Character) returns single-character string")
  func testValueOfChar() {
    #expect(String.valueOf(Character("A")) == "A")
    #expect(String.valueOf(Character("ü")) == "ü")
  }

  @Test("valueOf([Character], offset, count) extracts count chars starting at offset")
  func testValueOfCharArray() {
    let chars: [Character] = ["H", "e", "l", "l", "o"]
    // offset=1, count=3 → chars[1], chars[2], chars[3] = "ell"
    #expect(String.valueOf(chars, 1, 3) == "ell")
    #expect(String.valueOf(chars, 0, 5) == "Hello")
    #expect(String.valueOf(chars, 0, 1) == "H")
  }

  @Test("valueOf(Int) converts integer to decimal string")
  func testValueOfInt() {
    #expect(String.valueOf(0) == "0")
    #expect(String.valueOf(42) == "42")
    #expect(String.valueOf(-1) == "-1")
    #expect(String.valueOf(Int.max) == String(Int.max))
    #expect(String.valueOf(Int.min) == String(Int.min))
  }

  @Test("valueOf(Int64) converts long to decimal string")
  func testValueOfLong() {
    #expect(String.valueOf(Int64(0)) == "0")
    #expect(String.valueOf(Int64(9_223_372_036_854_775_807)) == "9223372036854775807")
    #expect(String.valueOf(Int64(-1)) == "-1")
  }

  @Test("valueOf(Float) converts float to string")
  func testValueOfFloat() {
    #expect(String.valueOf(Float(0.0)) == "0.0")
    #expect(String.valueOf(Float(1.5)) == "1.5")
    #expect(String.valueOf(Float(-3.14)) == String(Float(-3.14)))
  }

  @Test("valueOf(Double) converts double to string")
  func testValueOfDouble() {
    #expect(String.valueOf(0.0) == "0.0")
    #expect(String.valueOf(1.5) == "1.5")
    #expect(String.valueOf(-3.14) == String(-3.14))
    #expect(String.valueOf(Double.infinity) == String(Double.infinity))
  }

  @Test("valueOf(Bool) returns 'true' or 'false' — Java lowercase like Boolean.toString")
  func testValueOfBool() {
    #expect(String.valueOf(true)  == "true")
    #expect(String.valueOf(false) == "false")
  }

  @Test("valueOf(Any?) returns 'null' for nil, string representation otherwise")
  func testValueOfObject() {
    let nilValue: Any? = nil
    #expect(String.valueOf(nilValue) == "null")
    #expect(String.valueOf(42 as Any?) == "42")
    #expect(String.valueOf("hello" as Any?) == "hello")
  }

  // ---------------------------------------------------------------------------
  // MARK: - getBytes
  // ---------------------------------------------------------------------------

  @Test("getBytes UTF-8 encodes ASCII correctly")
  func testGetBytesUTF8() throws {
    let s: java.lang.String = "ABC"
    let bytes = try s.getBytes("UTF-8")
    #expect(bytes == [65, 66, 67])
  }

  @Test("getBytes ISO-8859-1 encodes ASCII correctly")
  func testGetBytesISO8859() throws {
    let s: java.lang.String = "ABC"
    let bytes = try s.getBytes("ISO-8859-1")
    #expect(bytes == [65, 66, 67])
  }

  @Test("getBytes falls back to UTF-8 for unknown encoding (current implementation)")
  func testGetBytesUnknownEncoding() throws {
    // Current implementation falls back to UTF-8 for unrecognised encodings
    // rather than throwing — this test documents that behaviour.
    let s: java.lang.String = "ABC"
    let bytes = try s.getBytes("UNKNOWN-42")
    #expect(bytes == [65, 66, 67]) // UTF-8 bytes for "ABC"
  }

  // ---------------------------------------------------------------------------
  // MARK: - init([UInt8])
  // ---------------------------------------------------------------------------

  @Test("init([UInt8]) decodes UTF-8 bytes")
  func testInitBytes() {
    let bytes: [UInt8] = [72, 101, 108, 108, 111] // "Hello"
    let s = String(bytes)
    #expect(s == "Hello")
  }

  @Test("init([UInt8], encoding) decodes ISO-8859-1 bytes")
  func testInitBytesEncoding() throws {
    let bytes: [UInt8] = [65, 66, 67] // "ABC"
    let s = try String(bytes, "ISO-8859-1")
    #expect(s == "ABC")
  }

  @Test("init([UInt8], start, end, encoding) decodes byte slice")
  func testInitBytesRange() throws {
    let bytes: [UInt8] = [72, 101, 108, 108, 111] // "Hello"
    let s = try String(bytes, 1, 4, "UTF-8")       // "ell"
    #expect(s == "ell")
  }
}
