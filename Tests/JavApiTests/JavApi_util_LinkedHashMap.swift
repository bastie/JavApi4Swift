/*
 * SPDX-FileCopyrightText: 2023, 2025 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import XCTest
@testable import JavApi

final class JavApi_util_LinkedHashMap_Tests: XCTestCase {
  // Test constructors
  func testInit () {
    do { // empty
      let empty = java.util.LinkedHashMap<Int, Int>()
      XCTAssertNotNil(empty, "LinkedHashMap ist nil, erwartet wurde eine leere Collection")
      let expected = 0
      let actually = empty.size()
      XCTAssertEqual(expected, actually, "LinkedHashMap hat eine Länge von \(actually) obwohl \(expected) erwartet wurde")
    }
    do { // default size
      let empty = java.util.LinkedHashMap<Int, Int>(12)
      XCTAssertNotNil(empty, "LinkedHashMap ist nil, erwartet wurde eine leere Collection")
      let expected = 0
      let actually = empty.size()
      XCTAssertEqual(expected, actually, "LinkedHashMap hat eine Länge von \(actually) obwohl \(expected) erwartet wurde")
    }
    do { // copy
      let param = java.util.LinkedHashMap<Int,Int>()
      let copy = java.util.LinkedHashMap<Int, Int>(param)
      XCTAssertNotNil(copy, "LinkedHashMap ist nil, erwartet wurde eine leere Collection")
      let expected = 0
      let actually = copy.size()
      XCTAssertEqual(expected, actually, "LinkedHashMap hat eine Länge von \(actually) obwohl \(expected) erwartet wurde")
    }
    do { // extended copy
      let param = java.util.LinkedHashMap<Int,Int>()
      _ = param.put(0,1)
      let copy = java.util.LinkedHashMap<Int, Int>(param)
      XCTAssertNotNil(copy, "LinkedHashMap ist nil, erwartet wurde eine leere Collection")
      let expected = 1
      let actually = copy.size()
      XCTAssertEqual(expected, actually, "LinkedHashMap hat eine Länge von \(actually) obwohl \(expected) erwartet wurde")
      let content = copy[0]
      XCTAssertNotNil(content, "LinkedHashMap enthält nicht das erwartete Element [0:1]")
      if let content {
        XCTAssertEqual(1, content, "LinkedHashMap hat ein Element \(content) obwohl 0 erwartet wurde")
      }
    }
  }
  
}
