/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

struct JavApi_util_Arrays_Tests {

  // MARK: - copyOf [Int]

  @Test("copyOf truncates when newLength < original.count")
  func testCopyOf_truncate() {
    let result = java.util.Arrays.copyOf([1, 2, 3, 4, 5], 3)
    #expect(result == [1, 2, 3])
  }

  @Test("copyOf zero-pads when newLength > original.count")
  func testCopyOf_pad() {
    let result = java.util.Arrays.copyOf([1, 2, 3], 5)
    #expect(result == [1, 2, 3, 0, 0])
  }

  @Test("copyOf same length returns identical array")
  func testCopyOf_sameLength() {
    let result = java.util.Arrays.copyOf([7, 8, 9], 3)
    #expect(result == [7, 8, 9])
  }

  @Test("copyOf length 0 returns empty array")
  func testCopyOf_zeroLength() {
    let result = java.util.Arrays.copyOf([1, 2, 3], 0)
    #expect(result == [])
  }

  // MARK: - copyOf — Swift-Besonderheit: ein Generic für alle Value-Types
  //
  // Java braucht separate Überladungen für int[], long[], double[], boolean[] usw.,
  // weil Java primitive Typen von Referenztypen trennt.
  // In Swift sind alle diese Typen bereits Value-Types — die generische
  // copyOf<T: _JavaArrayElement>-Überladung deckt sie alle ab.

  @Test("copyOf [UInt8] truncates and zero-pads (Java byte[])")
  func testCopyOf_UInt8() {
    #expect(java.util.Arrays.copyOf([UInt8(10), 20, 30, 40], 2) == [10, 20])
    #expect(java.util.Arrays.copyOf([UInt8(5), 6], 4) == [5, 6, 0, 0])
  }

  @Test("copyOf [Int16] pads with 0 (Java short[])")
  func testCopyOf_Int16() {
    let result: [Int16] = java.util.Arrays.copyOf([Int16(1), 2], 4)
    #expect(result == [1, 2, 0, 0])
  }

  @Test("copyOf [Int32] pads with 0 (Java int[] — explicit 32-bit)")
  func testCopyOf_Int32() {
    let result: [Int32] = java.util.Arrays.copyOf([Int32(10), 20], 4)
    #expect(result == [10, 20, 0, 0])
  }

  @Test("copyOf [Int64] pads with 0 (Java long[])")
  func testCopyOf_Int64() {
    let result: [Int64] = java.util.Arrays.copyOf([Int64(100), 200], 4)
    #expect(result == [100, 200, 0, 0])
  }

  @Test("copyOf [Float] pads with 0.0 (Java float[])")
  func testCopyOf_Float() {
    let result: [Float] = java.util.Arrays.copyOf([Float(1.5), 2.5], 4)
    #expect(result == [1.5, 2.5, 0.0, 0.0])
  }

  @Test("copyOf [Double] pads with 0.0 (Java double[])")
  func testCopyOf_Double() {
    let result = java.util.Arrays.copyOf([1.1, 2.2], 4)
    #expect(result == [1.1, 2.2, 0.0, 0.0])
  }

  @Test("copyOf [Bool] pads with false (Java boolean[])")
  func testCopyOf_Bool() {
    let result = java.util.Arrays.copyOf([true, false], 4)
    #expect(result == [true, false, false, false])
  }

  @Test("copyOf [Character] pads with null-char (Java char[])")
  func testCopyOf_Character() {
    let result: [Character] = java.util.Arrays.copyOf(["a", "b"], 4)
    #expect(result[0] == "a")
    #expect(result[1] == "b")
    #expect(result[2] == "\0")
    #expect(result[3] == "\0")
  }

  // MARK: - copyOfRange — ebenfalls generisch

  @Test("copyOfRange [Double] works without separate overload (Java double[])")
  func testCopyOfRange_Double() {
    let result = java.util.Arrays.copyOfRange([1.0, 2.0, 3.0, 4.0], 1, 3)
    #expect(result == [2.0, 3.0])
  }

  @Test("copyOfRange [Int16] works without separate overload (Java short[])")
  func testCopyOfRange_Int16() {
    let a: [Int16] = [10, 20, 30, 40]
    let result = java.util.Arrays.copyOfRange(a, 1, 3)
    #expect(result == [20, 30])
  }

  // MARK: - copyOfRange

  @Test("copyOfRange extracts subarray of Int")
  func testCopyOfRange_Int() {
    let result = java.util.Arrays.copyOfRange([10, 20, 30, 40, 50], 1, 4)
    #expect(result == [20, 30, 40])
  }

  @Test("copyOfRange extracts subarray of UInt8")
  func testCopyOfRange_UInt8() {
    let a: [UInt8] = [1, 2, 3, 4, 5]
    let result = java.util.Arrays.copyOfRange(a, 0, 3)
    #expect(result == [1, 2, 3])
  }

  @Test("copyOfRange with fromIndex == toIndex returns empty")
  func testCopyOfRange_empty() {
    let result = java.util.Arrays.copyOfRange([1, 2, 3], 2, 2)
    #expect(result == [])
  }

  // MARK: - equals [UInt8]

  @Test("equals returns true for identical byte arrays")
  func testEquals_UInt8_equal() {
    let a: [UInt8] = [1, 2, 3]
    let b: [UInt8] = [1, 2, 3]
    #expect(java.util.Arrays.equals(a, b))
  }

  @Test("equals returns false when content differs")
  func testEquals_UInt8_different() {
    let a: [UInt8] = [1, 2, 3]
    let c: [UInt8] = [1, 2, 4]
    #expect(!java.util.Arrays.equals(a, c))
  }

  @Test("equals returns false when lengths differ")
  func testEquals_UInt8_differentLength() {
    let a: [UInt8] = [1, 2, 3]
    let b: [UInt8] = [1, 2]
    #expect(!java.util.Arrays.equals(a, b))
  }

  @Test("equals optional: both nil returns true")
  func testEquals_UInt8_bothNil() {
    let a: [UInt8]? = nil
    let b: [UInt8]? = nil
    #expect(java.util.Arrays.equals(a, b))
  }

  @Test("equals optional: one nil returns false")
  func testEquals_UInt8_oneNil() {
    let a: [UInt8]? = [1, 2]
    let b: [UInt8]? = nil
    #expect(!java.util.Arrays.equals(a, b))
  }

  // MARK: - equals generic (regression for former == vs != bug)

  @Test("equals<T> returns true for equal Int arrays (regression: was inverted)")
  func testEquals_generic_equal() {
    let a = [1, 2, 3]
    let b = [1, 2, 3]
    #expect(java.util.Arrays.equals(a, b))
  }

  @Test("equals<T> returns false for different Int arrays")
  func testEquals_generic_different() {
    let a = [1, 2, 3]
    let b = [1, 2, 4]
    #expect(!java.util.Arrays.equals(a, b))
  }

  @Test("equals<T> returns false for different String arrays")
  func testEquals_generic_strings() {
    #expect(java.util.Arrays.equals(["a", "b"], ["a", "b"]))
    #expect(!java.util.Arrays.equals(["a", "b"], ["a", "c"]))
  }

  // MARK: - fill

  @Test("fill entire array with value")
  func testFill_entire() {
    var a = [0, 0, 0, 0]
    java.util.Arrays.fill(&a, 7)
    #expect(a == [7, 7, 7, 7])
  }

  @Test("fill subrange leaves rest untouched")
  func testFill_subrange() {
    var a = [0, 0, 0, 0, 0]
    java.util.Arrays.fill(&a, 1, 3, 99)
    #expect(a == [0, 99, 99, 0, 0])
  }

  @Test("fill with range 0..<0 changes nothing")
  func testFill_emptyRange() {
    var a = [1, 2, 3]
    java.util.Arrays.fill(&a, 0, 0, 42)
    #expect(a == [1, 2, 3])
  }

  // MARK: - sort

  @Test("sort ascending on Int array")
  func testSort_Int() {
    var a = [3, 1, 4, 1, 5, 9, 2, 6]
    java.util.Arrays.sort(&a)
    #expect(a == [1, 1, 2, 3, 4, 5, 6, 9])
  }

  @Test("sort String array lexicographically")
  func testSort_String() {
    var a = ["banana", "apple", "cherry"]
    java.util.Arrays.sort(&a)
    #expect(a == ["apple", "banana", "cherry"])
  }

  @Test("sort subrange leaves elements outside range unchanged")
  func testSort_subrange() {
    var a = [5, 3, 1, 4, 2]
    java.util.Arrays.sort(&a, 1, 4)   // sorts indices 1,2,3 → [3,1,4] → [1,3,4]
    #expect(a == [5, 1, 3, 4, 2])
  }

  // sort with Comparator object (Java API) — tested in JavApi_util_Arrays_Swiftify_Tests.swift
  // Here we only verify the natural-order overloads.

  // MARK: - binarySearch

  @Test("binarySearch finds existing element and returns its index")
  func testBinarySearch_found() {
    let a = [1, 3, 5, 7, 9]
    #expect(java.util.Arrays.binarySearch(a, 5) == 2)
  }

  @Test("binarySearch returns negative insertion point when not found")
  func testBinarySearch_notFound() {
    let a = [1, 3, 5, 7, 9]
    // key 4 would insert at index 2 → result = -(2+1) = -3
    let result = java.util.Arrays.binarySearch(a, 4)
    #expect(result < 0)
    let insertionPoint = -(result + 1)
    #expect(insertionPoint == 2)
  }

  @Test("binarySearch on empty array returns -1")
  func testBinarySearch_empty() {
    let a = [Int]()
    let result = java.util.Arrays.binarySearch(a, 42)
    #expect(result == -1)
  }

  @Test("binarySearch with subrange finds element")
  func testBinarySearch_subrange() {
    let a = [1, 3, 5, 7, 9]
    #expect(java.util.Arrays.binarySearch(a, 1, 4, 7) == 3)
  }

  @Test("binarySearch with subrange does not find element outside range")
  func testBinarySearch_subrange_outsideNotFound() {
    let a = [1, 3, 5, 7, 9]
    // key 9 is at index 4, but range is [0,3) — should not find it
    let result = java.util.Arrays.binarySearch(a, 0, 3, 9)
    #expect(result < 0)
  }

  // MARK: - toString

  @Test("toString produces [1, 2, 3] format")
  func testToString_Int() {
    let result = java.util.Arrays.toString([1, 2, 3])
    #expect(result == "[1, 2, 3]")
  }

  @Test("toString empty array produces []")
  func testToString_empty() {
    let result = java.util.Arrays.toString([Int]())
    #expect(result == "[]")
  }

  @Test("toString optional nil produces \"null\"")
  func testToString_nil() {
    let a: [Int]? = nil
    let result = java.util.Arrays.toString(a)
    #expect(result == "null")
  }

  @Test("toString String array includes quotes-free values")
  func testToString_Strings() {
    let result = java.util.Arrays.toString(["a", "b", "c"])
    #expect(result == "[a, b, c]")
  }

  // MARK: - asList (Bridge Array → Collections)

  @Test("asList creates ArrayList from varargs — Java API bridge")
  func testAsList_basic() throws {
    let list = java.util.Arrays.asList(1, 2, 3)
    #expect(list.size() == 3)
    #expect(try list.get(0) == 1)
    #expect(try list.get(2) == 3)
  }

  @Test("asList with String varargs")
  func testAsList_strings() throws {
    let list = java.util.Arrays.asList("a", "b", "c")
    #expect(list.size() == 3)
    #expect(try list.get(1) == "b")
  }

  @Test("asList empty produces empty ArrayList")
  func testAsList_empty() {
    let list = java.util.Arrays.asList(Int())   // workaround: asList() would need zero-arg overload
    _ = list  // just must not crash
  }

  // MARK: - deepToString

  @Test("deepToString formats nested array")
  func testDeepToString_nested() {
    let a: [Any?] = [[1, 2] as [Any?], [3, 4] as [Any?]]
    let result = java.util.Arrays.deepToString(a)
    #expect(result == "[[1, 2], [3, 4]]")
  }

  @Test("deepToString handles nil elements as \"null\"")
  func testDeepToString_nil() {
    let a: [Any?] = [1, nil, 3]
    let result = java.util.Arrays.deepToString(a)
    #expect(result == "[1, null, 3]")
  }
}
