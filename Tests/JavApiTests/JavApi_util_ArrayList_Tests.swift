/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

struct JavApi_util_ArrayList_Tests {

  @Test("add returns true and appends element")
  func testAdd() {
    var list = java.util.ArrayList<Int>()
    let added = list.add(42)
    #expect(added == true)
    #expect(list.count == 1)
    #expect(list[0] == 42)
  }

  @Test("add multiple elements preserves order")
  func testAddMultiple() {
    var list = java.util.ArrayList<String>()
    _ = list.add("a")
    _ = list.add("b")
    _ = list.add("c")
    #expect(list.count == 3)
    #expect(list == ["a", "b", "c"])
  }

  @Test("empty list has count 0")
  func testEmpty() {
    let list = java.util.ArrayList<Int>()
    #expect(list.isEmpty)
    #expect(list.count == 0)
  }

  @Test("contains finds existing elements")
  func testContains() {
    var list = java.util.ArrayList<Int>()
    _ = list.add(1)
    _ = list.add(2)
    #expect(list.contains(1))
    #expect(!list.contains(99))
  }
}
