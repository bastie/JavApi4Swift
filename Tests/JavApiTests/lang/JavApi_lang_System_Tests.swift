/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

struct JavApi_lang_System_Tests {

  @Test("currentTimeMillis returns positive, non-decreasing values")
  func testCurrentTimeMillis() {
    let t1 = System.currentTimeMillis()
    #expect(t1 > 0)
    let t2 = System.currentTimeMillis()
    #expect(t2 >= t1)
  }

  @Test("identityHashCode is stable for same object")
  func testIdentityHashCode() {
    class Dummy {}
    let obj = Dummy()
    #expect(System.identityHashCode(obj) == System.identityHashCode(obj))
  }

  @Test("arraycopy copies byte slice into destination")
  func testArraycopyBytes() {
    let src: [UInt8] = [1, 2, 3, 4, 5]
    var dest: [UInt8] = [0, 0, 0, 0, 0]
    System.arraycopy(src, 1, &dest, 0, 3)
    #expect(dest[0] == 2)
    #expect(dest[1] == 3)
    #expect(dest[2] == 4)
    #expect(dest[3] == 0) // untouched
  }

  @Test("arraycopy copies Int slice with offset into destination")
  func testArraycopyInts() {
    let src: [Int] = [10, 20, 30, 40]
    var dest: [Int] = [0, 0, 0, 0]
    System.arraycopy(src, 0, &dest, 1, 2)
    #expect(dest[0] == 0)
    #expect(dest[1] == 10)
    #expect(dest[2] == 20)
    #expect(dest[3] == 0)
  }
}
