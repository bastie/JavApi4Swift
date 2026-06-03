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
}
