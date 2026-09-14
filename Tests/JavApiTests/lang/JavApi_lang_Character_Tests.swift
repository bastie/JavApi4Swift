/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

struct JavApi_lang_Character_Tests {

  @Test("Character == Int compares by Unicode scalar value")
  func testOperator() {
    let A: Character = "A"
    let aValue = 65
    #expect(A == aValue)
    #expect(aValue == A)

    let B: Character = "B"
    #expect(!(B == aValue))
    #expect(!(aValue == B))
  }

  @Test("isLetter returns true for letter characters and their code points")
  func testIsLetter() {
    let A: Character = "A"
    #expect(Character.isLetter(A))
    #expect(Character.isLetter(65))
  }

  @Test("getNumericValue returns hex digit value, fraction numerator, or -2 for non-digit fractions")
  func testGetNumericValue() {
    let A: Character = "A"
    #expect(Character.getNumericValue(A) == 10)

    let fract1: Character = "\u{215F}"   // ⅟ (1/1 fraction — numerator 1)
    #expect(Character.getNumericValue(fract1) == 1)

    let fract14: Character = "\u{00BC}"  // ¼ — not a simple digit fraction
    #expect(Character.getNumericValue(fract14) == -2)
  }

  @Test("Int(Character) converts to Unicode scalar value")
  func testConvertToInt() {
    let A: Character = "A"
    #expect(Int(A) == 65)

    let musicalSymbol: Character = "𝄞"  // outside BMP
    #expect(Int(musicalSymbol) == 119_070)
  }

  @Test("Character.toString(_:) static facade matches the instance method")
  func testStaticToString() {
    let A: Character = "A"
    #expect(Character.toString(A) == "A")
    #expect(Character.toString(A) == A.toString())
  }

  @Test("Character.toString(_:) matches the instance method even for a multi-scalar grapheme cluster")
  func testStaticToStringMultiScalarGrapheme() {
    // A flag emoji is one Swift `Character` built from two Unicode scalars
    // (regional indicator symbols) -- toString must round-trip it exactly.
    let flag: Character = "\u{1F1E9}\u{1F1EA}"  // 🇩🇪
    #expect(Character.toString(flag) == "\(flag)")
    #expect(Character.toString(flag) == flag.toString())
  }

  @Test("isJavaIdentifierStart accepts letters, letter-numbers, currency symbols, and connecting punctuation")
  func testIsJavaIdentifierStart() {
    #expect(Character.isJavaIdentifierStart("a"))
    #expect(Character.isJavaIdentifierStart("_"))
    #expect(Character.isJavaIdentifierStart("$"))
    #expect(Character.isJavaIdentifierStart("\u{2160}"))  // Ⅰ ROMAN NUMERAL ONE (Nl)
    #expect(!Character.isJavaIdentifierStart("5"))
    #expect(!Character.isJavaIdentifierStart(" "))
  }

  @Test("isJavaIdentifierPart additionally accepts digits, combining marks, and ignorable control characters")
  func testIsJavaIdentifierPart() {
    #expect(Character.isJavaIdentifierPart("a"))
    #expect(Character.isJavaIdentifierPart("5"))
    #expect(Character.isJavaIdentifierPart("_"))
    #expect(Character.isJavaIdentifierPart("$"))
    #expect(Character.isJavaIdentifierPart("\u{0301}"))  // COMBINING ACUTE ACCENT (Mn)
    #expect(Character.isJavaIdentifierPart("\u{0007}"))  // BEL -- ignorable control, not whitespace
    #expect(!Character.isJavaIdentifierPart(" "))
    #expect(!Character.isJavaIdentifierPart("\t"))  // whitespace control, not ignorable
  }

  @Test("isUnicodeIdentifierStart accepts letters and letter-numbers but not currency symbols or connecting punctuation")
  func testIsUnicodeIdentifierStart() {
    #expect(Character.isUnicodeIdentifierStart("a"))
    #expect(Character.isUnicodeIdentifierStart("\u{2160}"))  // Ⅰ ROMAN NUMERAL ONE (Nl)
    #expect(!Character.isUnicodeIdentifierStart("_"))
    #expect(!Character.isUnicodeIdentifierStart("$"))
    #expect(!Character.isUnicodeIdentifierStart("5"))
  }

  @Test("isUnicodeIdentifierPart accepts digits, connecting punctuation and combining marks but not currency symbols")
  func testIsUnicodeIdentifierPart() {
    #expect(Character.isUnicodeIdentifierPart("a"))
    #expect(Character.isUnicodeIdentifierPart("5"))
    #expect(Character.isUnicodeIdentifierPart("_"))
    #expect(Character.isUnicodeIdentifierPart("\u{0301}"))  // COMBINING ACUTE ACCENT (Mn)
    #expect(Character.isUnicodeIdentifierPart("\u{0903}"))  // DEVANAGARI SIGN VISARGA (Mc)
    #expect(!Character.isUnicodeIdentifierPart("$"))
    #expect(!Character.isUnicodeIdentifierPart(" "))
  }

  @Test("isIdentifierIgnorable matches non-whitespace ISO control characters and FORMAT-category characters")
  func testIsIdentifierIgnorable() {
    #expect(Character.isIdentifierIgnorable("\u{0007}"))  // BEL
    #expect(Character.isIdentifierIgnorable("\u{000F}"))  // SI, inside 0x000E...0x001B
    #expect(Character.isIdentifierIgnorable("\u{200E}"))  // LEFT-TO-RIGHT MARK (Cf)
    #expect(!Character.isIdentifierIgnorable("\t"))  // whitespace control -- not ignorable
    #expect(!Character.isIdentifierIgnorable("\n"))
    #expect(!Character.isIdentifierIgnorable("a"))
  }
}
