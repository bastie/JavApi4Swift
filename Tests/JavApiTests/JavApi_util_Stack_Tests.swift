/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import XCTest
@testable import JavApi

final class JavApi_util_Stack_Tests: XCTestCase {
  
  
  func testSearch () {
    var stack = java.util.Stack<String>()
    _ = stack.add("HALLO")
    XCTAssertEqual(1, stack.search ("HALLO"))
    
    stack = java.util.Stack()
    _ = stack.add("HALLO")
    _ = stack.add("Welt")
    _ = stack.add("!")
    _ = stack.add("!")
    _ = stack.add("!")
    XCTAssertEqual(4, stack.search ("Welt"))

    stack = java.util.Stack()
    _ = stack.add("HALLO")
    _ = stack.add("Welt")
    _ = stack.add("!")
    _ = stack.add("!")
    _ = stack.add("!")
    XCTAssertEqual(-1, stack.search ("Bastie"))

  }
  
  
}

