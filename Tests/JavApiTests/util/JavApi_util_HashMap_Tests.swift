/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

struct JavApi_util_HashMap_Tests {

  @Test("put returns nil for new key, stores value")
  func testPutAndGet() {
    let map = java.util.HashMap<String, Int>()
    let old = map.put("key", 42)
    #expect(old == nil)
    #expect(map.get("key") == 42)
  }

  @Test("put returns previous value on overwrite")
  func testPutOverwrite() {
    let map = java.util.HashMap<String, Int>()
    _ = map.put("key", 1)
    let old = map.put("key", 2)
    #expect(old == 1)
    #expect(map.get("key") == 2)
  }

  @Test("containsKey distinguishes present and absent keys")
  func testContainsKey() {
    let map = java.util.HashMap<String, String>()
    _ = map.put("hello", "world")
    #expect(map.containsKey("hello"))
    #expect(!map.containsKey("missing"))
  }

  @Test("get returns nil for missing key")
  func testGetMissingKey() {
    let map = java.util.HashMap<Int, Int>()
    #expect(map.get(99) == nil)
  }

  @Test("multiple entries are stored independently")
  func testMultipleEntries() {
    let map = java.util.HashMap<Int, String>()
    _ = map.put(1, "one")
    _ = map.put(2, "two")
    _ = map.put(3, "three")
    #expect(map.delegate.count == 3)
    #expect(map.get(2) == "two")
  }
}
