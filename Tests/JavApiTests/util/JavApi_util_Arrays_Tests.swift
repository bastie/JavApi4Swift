/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

struct JavApi_util_Arrays_Tests {

  @Test("copyOf truncates and zero-pads correctly")
  func testCopyOf() {
    let original = [1, 2, 3, 4, 5]
    let shorter = java.util.Arrays.copyOf(original, 3)
    #expect(shorter == [1, 2, 3])

    let longer = java.util.Arrays.copyOf(original, 7)
    #expect(longer == [1, 2, 3, 4, 5, 0, 0])
  }

  @Test("copyOfRange extracts subarray of Int")
  func testCopyOfRange() {
    let a = [10, 20, 30, 40, 50]
    let result = java.util.Arrays.copyOfRange(a, 1, 4)
    #expect(result == [20, 30, 40])
  }

  @Test("copyOfRange extracts subarray of UInt8")
  func testCopyOfRangeBytes() {
    let a: [UInt8] = [1, 2, 3, 4, 5]
    let result = java.util.Arrays.copyOfRange(a, 0, 3)
    #expect(result == [1, 2, 3])
  }

  @Test("equals returns true for identical byte arrays, false for different")
  func testEqualsBytes() {
    let a: [UInt8] = [1, 2, 3]
    let b: [UInt8] = [1, 2, 3]
    let c: [UInt8] = [1, 2, 4]
    #expect(java.util.Arrays.equals(a, b))
    #expect(!java.util.Arrays.equals(a, c))
  }

  @Test("fill sets range to given value, leaving rest untouched")
  func testFill() {
    var a = [0, 0, 0, 0, 0]
    java.util.Arrays.fill(&a, 1, 3, 99)
    #expect(a == [0, 99, 99, 0, 0])
  }
}
