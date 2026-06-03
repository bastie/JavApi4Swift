/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

struct JavApi_util_Stack_Tests {

  @Test("search finds element at position 1 in single-element stack")
  func testSearchSingleElement() {
    let stack = java.util.Stack<String>()
    _ = stack.add("HALLO")
    #expect(stack.search("HALLO") == 1)
  }

  @Test("search returns 1-based distance from top")
  func testSearchMultipleElements() {
    let stack = java.util.Stack<String>()
    _ = stack.add("HALLO")
    _ = stack.add("Welt")
    _ = stack.add("!")
    _ = stack.add("!")
    _ = stack.add("!")
    #expect(stack.search("Welt") == 4)
  }

  @Test("search returns -1 for absent element")
  func testSearchMissing() {
    let stack = java.util.Stack<String>()
    _ = stack.add("HALLO")
    _ = stack.add("Welt")
    _ = stack.add("!")
    _ = stack.add("!")
    _ = stack.add("!")
    #expect(stack.search("Bastie") == -1)
  }
}
