/*
 * SPDX-FileCopyrightText: 2024 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

struct JavApi_lang_Class_Tests {

  @Test("getName returns simple class name without module prefix")
  func testGetName() {
    // Swift Testing uses structs, so we need a class instance as AnyObject.
    // The helper class name must match the expected string exactly.
    class JavApi_lang_Class_Tests_Helper {}
    let name = java.lang.Class.getName(of: JavApi_lang_Class_Tests_Helper())
    #expect(name == "JavApi_lang_Class_Tests_Helper")
  }
}
