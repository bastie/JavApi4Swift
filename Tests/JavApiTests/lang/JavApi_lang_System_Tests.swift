/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

struct JavApi_lang_System_Tests {

  // MARK: - currentTimeMillis

  @Test("currentTimeMillis returns positive, non-decreasing values")
  func testCurrentTimeMillis() {
    let t1 = System.currentTimeMillis()
    #expect(t1 > 0)
    let t2 = System.currentTimeMillis()
    #expect(t2 >= t1)
  }

  // MARK: - identityHashCode

  @Test("identityHashCode is stable for same object")
  func testIdentityHashCode() {
    class Dummy {}
    let obj = Dummy()
    #expect(System.identityHashCode(obj) == System.identityHashCode(obj))
  }

  @Test("identityHashCode returns 0 for nil")
  func testIdentityHashCodeNil() {
    #expect(System.identityHashCode(nil) == 0)
  }

  @Test("identityHashCode differs for two distinct objects")
  func testIdentityHashCodeDistinct() {
    class Dummy {}
    let a = Dummy()
    let b = Dummy()
    // Not guaranteed to differ in theory, but always true for two separately
    // allocated objects in the same process run.
    #expect(System.identityHashCode(a) != System.identityHashCode(b))
  }
}
