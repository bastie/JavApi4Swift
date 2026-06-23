/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

/// Tests for `System.arraycopy` — grouped here alongside `java.util.Arrays`
/// tests because both deal with array-copying semantics.
struct JavApi_lang_System_arraycopy_Tests {

  // MARK: - arraycopy [UInt8]

  @Test("arraycopy [UInt8]: basic slice copy")
  func testArraycopyUInt8_basic() throws {
    let src: [UInt8] = [1, 2, 3, 4, 5]
    var dest: [UInt8] = [0, 0, 0, 0, 0]
    try System.arraycopy(src, 1, &dest, 0, 3)
    #expect(dest == [2, 3, 4, 0, 0])
  }

  @Test("arraycopy [UInt8]: copy into destPos > 0")
  func testArraycopyUInt8_destOffset() throws {
    let src: [UInt8] = [10, 20, 30]
    var dest: [UInt8] = [0, 0, 0, 0, 0]
    try System.arraycopy(src, 0, &dest, 2, 3)
    #expect(dest == [0, 0, 10, 20, 30])
  }

  @Test("arraycopy [UInt8]: length 0 copies nothing")
  func testArraycopyUInt8_zeroLength() throws {
    let src: [UInt8] = [1, 2, 3]
    var dest: [UInt8] = [9, 9, 9]
    try System.arraycopy(src, 0, &dest, 0, 0)
    #expect(dest == [9, 9, 9])
  }

  @Test("arraycopy [UInt8]: full array copy")
  func testArraycopyUInt8_full() throws {
    let src: [UInt8] = [7, 8, 9]
    var dest: [UInt8] = [0, 0, 0]
    try System.arraycopy(src, 0, &dest, 0, 3)
    #expect(dest == [7, 8, 9])
  }

  @Test("arraycopy [UInt8]?: optional dest — copies when non-nil")
  func testArraycopyUInt8_optionals() throws {
    let src: [UInt8] = [5, 6, 7]
    var dest: [UInt8]? = [0, 0, 0]
    try System.arraycopy(src, 0, &dest, 0, 3)
    #expect(dest == [5, 6, 7])
  }

  @Test("arraycopy [UInt8]?: nil dest throws NullPointerException")
  func testArraycopyUInt8_nilDestThrows() {
    let src: [UInt8] = [1, 2, 3]
    var dest: [UInt8]? = nil
    #expect(throws: NullPointerException.self) {
      try System.arraycopy(src, 0, &dest, 0, 3)
    }
  }

  @Test("arraycopy [UInt8]?: nil dest with length 0 throws NullPointerException")
  func testArraycopyUInt8_nilDestZeroLength() {
    let src: [UInt8] = [1, 2, 3]
    var dest: [UInt8]? = nil
    // nil dest is always invalid, regardless of length
    #expect(throws: NullPointerException.self) {
      try System.arraycopy(src, 0, &dest, 0, 0)
    }
  }

  // MARK: - arraycopy [Int]

  @Test("arraycopy [Int]: basic slice copy")
  func testArraycopyInt_basic() throws {
    let src: [Int] = [10, 20, 30, 40]
    var dest: [Int] = [0, 0, 0, 0]
    try System.arraycopy(src, 0, &dest, 1, 2)
    #expect(dest == [0, 10, 20, 0])
  }

  @Test("arraycopy [Int]: srcPos > 0 and destPos > 0")
  func testArraycopyInt_bothOffsets() throws {
    let src: [Int] = [1, 2, 3, 4, 5]
    var dest: [Int] = [0, 0, 0, 0, 0]
    try System.arraycopy(src, 2, &dest, 1, 2)
    #expect(dest == [0, 3, 4, 0, 0])
  }

  @Test("arraycopy [Int]: length 0 copies nothing")
  func testArraycopyInt_zeroLength() throws {
    let src: [Int] = [1, 2, 3]
    var dest: [Int] = [9, 9, 9]
    try System.arraycopy(src, 0, &dest, 0, 0)
    #expect(dest == [9, 9, 9])
  }

  // MARK: - arraycopy [UInt8] → [Int]  (widening type-converting overload)

  @Test("arraycopy [UInt8] to [Int]: widens values correctly")
  func testArraycopyUInt8_toInt() throws {
    let src: [UInt8] = [100, 200, 255]
    var dest: [Int] = [0, 0, 0]
    try System.arraycopy(src, 0, &dest, 0, 3)
    #expect(dest == [100, 200, 255])
  }

  // MARK: - arraycopy [Int16]

  @Test("arraycopy [Int16]: basic copy")
  func testArraycopyInt16_basic() throws {
    let src: [Int16] = [100, 200, 300]
    var dest: [Int16] = [0, 0, 0]
    try System.arraycopy(src, 0, &dest, 0, 3)
    #expect(dest == [100, 200, 300])
  }

  @Test("arraycopy [Int16]: srcPos and destPos offset")
  func testArraycopyInt16_offsets() throws {
    let src: [Int16] = [1, 2, 3, 4]
    var dest: [Int16] = [0, 0, 0, 0]
    try System.arraycopy(src, 1, &dest, 2, 2)
    #expect(dest == [0, 0, 2, 3])
  }

  // MARK: - arraycopy [Int16] → [UInt8] (narrowing conversion)

  @Test("arraycopy [Int16] to [UInt8]: converts values via UInt8 truncation")
  func testArraycopyInt16_toUInt8() throws {
    let src: [Int16] = [65, 66, 67]  // 'A', 'B', 'C' in ASCII
    var dest: [UInt8] = [0, 0, 0, 0, 0]
    try System.arraycopy(src, 0, &dest, 1, 3)
    #expect(dest[0] == 0)   // untouched
    #expect(dest[1] == 65)
    #expect(dest[2] == 66)
    #expect(dest[3] == 67)
    #expect(dest[4] == 0)   // untouched
  }

  @Test("arraycopy [Int16] to [UInt8]?: optional dest variant")
  func testArraycopyInt16_toUInt8_optional() throws {
    let src: [Int16] = [1, 2, 3]
    var dest: [UInt8]? = [0, 0, 0]
    try System.arraycopy(src, 0, &dest, 0, 3)
    #expect(dest == [1, 2, 3])
  }

  // MARK: - arraycopy [UInt16]

  @Test("arraycopy [UInt16]: basic copy")
  func testArraycopyUInt16_basic() throws {
    let src: [UInt16] = [1000, 2000, 3000]
    var dest: [UInt16] = [0, 0, 0]
    try System.arraycopy(src, 0, &dest, 0, 3)
    #expect(dest == [1000, 2000, 3000])
  }

  @Test("arraycopy [UInt16]: srcPos and destPos offset")
  func testArraycopyUInt16_offsets() throws {
    let src: [UInt16] = [10, 20, 30, 40]
    var dest: [UInt16] = [0, 0, 0, 0]
    try System.arraycopy(src, 1, &dest, 2, 2)
    #expect(dest == [0, 0, 20, 30])
  }

  @Test("arraycopy [UInt16]?: optional dest variant")
  func testArraycopyUInt16_optional() throws {
    let src: [UInt16] = [7, 8, 9]
    var dest: [UInt16]? = [0, 0, 0]
    try System.arraycopy(src, 0, &dest, 0, 3)
    #expect(dest == [7, 8, 9])
  }

  // MARK: - arraycopy [Character]

  @Test("arraycopy [Character]: basic copy")
  func testArraycopyCharacter_basic() throws {
    let src: [Character] = ["a", "b", "c", "d"]
    var dest: [Character] = [" ", " ", " ", " "]
    try System.arraycopy(src, 1, &dest, 0, 3)
    #expect(dest == ["b", "c", "d", " "])
  }

  @Test("arraycopy [Character]: copy into destPos offset")
  func testArraycopyCharacter_destOffset() throws {
    let src: [Character] = ["x", "y", "z"]
    var dest: [Character] = [".", ".", ".", "."]
    try System.arraycopy(src, 0, &dest, 1, 2)
    #expect(dest == [".", "x", "y", "."])
  }

  @Test("arraycopy [Character]: length 0 changes nothing")
  func testArraycopyCharacter_zeroLength() throws {
    let src: [Character] = ["a", "b"]
    var dest: [Character] = ["x", "y"]
    try System.arraycopy(src, 0, &dest, 0, 0)
    #expect(dest == ["x", "y"])
  }

  // MARK: - Bounds checks

  @Test("arraycopy: negative length throws")
  func testArraycopyBounds_negativeLength() {
    let src: [Int] = [1, 2, 3]
    var dest: [Int] = [0, 0, 0]
    #expect(throws: ArrayIndexOutOfBoundsException.self) {
      try System.arraycopy(src, 0, &dest, 0, -1)
    }
  }

  @Test("arraycopy: negative srcPos throws")
  func testArraycopyBounds_negativeSrcPos() {
    let src: [Int] = [1, 2, 3]
    var dest: [Int] = [0, 0, 0]
    #expect(throws: ArrayIndexOutOfBoundsException.self) {
      try System.arraycopy(src, -1, &dest, 0, 1)
    }
  }

  @Test("arraycopy: negative destPos throws")
  func testArraycopyBounds_negativeDestPos() {
    let src: [Int] = [1, 2, 3]
    var dest: [Int] = [0, 0, 0]
    #expect(throws: ArrayIndexOutOfBoundsException.self) {
      try System.arraycopy(src, 0, &dest, -1, 1)
    }
  }

  @Test("arraycopy: srcPos + length exceeds src bounds throws")
  func testArraycopyBounds_srcOverflow() {
    let src: [Int] = [1, 2, 3]
    var dest: [Int] = [0, 0, 0, 0, 0]
    #expect(throws: ArrayIndexOutOfBoundsException.self) {
      try System.arraycopy(src, 2, &dest, 0, 2)   // 2+2=4 > src.count=3
    }
  }

  @Test("arraycopy: destPos + length exceeds dest bounds throws")
  func testArraycopyBounds_destOverflow() {
    let src: [Int] = [1, 2, 3, 4, 5]
    var dest: [Int] = [0, 0, 0]
    #expect(throws: ArrayIndexOutOfBoundsException.self) {
      try System.arraycopy(src, 0, &dest, 2, 3)   // 2+3=5 > dest.count=3
    }
  }
}
