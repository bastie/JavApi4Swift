/*
 * SPDX-FileCopyrightText: 2023, 2025 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

struct JavApi_util_LinkedHashMap_Tests {

  @Test("empty constructor creates map with size 0")
  func testInitEmpty() {
    let map = java.util.LinkedHashMap<Int, Int>()
    #expect(map.size() == 0)
  }

  @Test("constructor with initial capacity creates map with size 0")
  func testInitWithCapacity() {
    let map = java.util.LinkedHashMap<Int, Int>(12)
    #expect(map.size() == 0)
  }

  @Test("copy constructor from empty map produces size 0")
  func testInitCopyEmpty() {
    let source = java.util.LinkedHashMap<Int, Int>()
    let copy   = java.util.LinkedHashMap<Int, Int>(source)
    #expect(copy.size() == 0)
  }

  @Test("copy constructor from non-empty map copies entries")
  func testInitCopyWithEntries() {
    let source = java.util.LinkedHashMap<Int, Int>()
    _ = source.put(0, 1)
    let copy = java.util.LinkedHashMap<Int, Int>(source)
    #expect(copy.size() == 1)
    let content = copy[0]
    #expect(content != nil)
    #expect(content == 1)
  }
}
