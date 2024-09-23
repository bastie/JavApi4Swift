/*
 * SPDX-FileCopyrightText: 2024 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import XCTest
@testable import JavApi

final class JavApi_lang_Class_Tests: XCTestCase {

  public func test_getName() {
    
//    let myClass = try! java.lang.Class.loadClass(named: "JavApi.java.io.File")
//    let myObject = java.lang.Class(delegate: String.self as! AnyClass)
    let name = java.lang.Class.getName(of: self)
    XCTAssertEqual("JavApi_lang_Class_Tests", name)
    
  }
}
