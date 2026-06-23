/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

// Tests for the Swift-friendly Arrays+Swiftify extensions.
// These use closure-based comparators (by:) which are NOT part of the Java API.
// Java-compatible code uses Arrays.sort(_:_:) with a Comparator object.

struct JavApi_util_Arrays_Swiftify_Tests {

  @Test("sort(by:) closure — descending order")
  func testSort_closure_descending() {
    var a = [1, 5, 3, 2, 4]
    java.util.Arrays.sort(&a, by: { $1 - $0 })
    #expect(a == [5, 4, 3, 2, 1])
  }

  @Test("sort(by:) closure — ascending (same result as natural order)")
  func testSort_closure_ascending() {
    var a = [3, 1, 2]
    java.util.Arrays.sort(&a, by: { $0 - $1 })
    #expect(a == [1, 2, 3])
  }

  @Test("sort subrange with closure — only subrange is sorted")
  func testSort_subrange_closure() {
    var a = [5, 3, 1, 4, 2]
    java.util.Arrays.sort(&a, 1, 4, by: { $1 - $0 })  // indices 1..3 descending
    #expect(a[0] == 5)   // untouched
    #expect(a[4] == 2)   // untouched
    #expect(a[1...3].sorted(by: >) == [4, 3, 1])
  }
}
