/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Testing
@testable import JavApi

@Suite("java.util.StringJoiner")
struct JavApi_util_StringJoiner_Tests {

  // MARK: - Constructors

  @Test("delimiter-only constructor: empty returns empty string")
  func testDelimiterOnlyEmpty() {
    let sj = java.util.StringJoiner(", ")
    #expect(sj.toString() == "")
  }

  @Test("prefix+suffix constructor: empty returns prefix+suffix")
  func testPrefixSuffixEmpty() {
    let sj = java.util.StringJoiner(", ", "[", "]")
    #expect(sj.toString() == "[]")
  }

  // MARK: - add

  @Test("add single element")
  func testAddSingle() {
    let sj = java.util.StringJoiner(", ")
    sj.add("hello")
    #expect(sj.toString() == "hello")
  }

  @Test("add multiple elements with delimiter")
  func testAddMultiple() {
    let sj = java.util.StringJoiner(", ")
    sj.add("a").add("b").add("c")
    #expect(sj.toString() == "a, b, c")
  }

  @Test("add with prefix and suffix")
  func testAddWithPrefixSuffix() {
    let sj = java.util.StringJoiner(", ", "[", "]")
    sj.add("x").add("y").add("z")
    #expect(sj.toString() == "[x, y, z]")
  }

  @Test("add returns self for chaining")
  func testAddChaining() {
    let sj = java.util.StringJoiner("-")
    let returned = sj.add("1")
    #expect(returned === sj)
  }

  // MARK: - setEmptyValue

  @Test("setEmptyValue used when no elements added")
  func testSetEmptyValue() {
    let sj = java.util.StringJoiner(", ")
    sj.setEmptyValue("(none)")
    #expect(sj.toString() == "(none)")
  }

  @Test("setEmptyValue ignored when elements exist")
  func testSetEmptyValueIgnoredWhenNonEmpty() {
    let sj = java.util.StringJoiner(", ")
    sj.setEmptyValue("(none)")
    sj.add("a")
    #expect(sj.toString() == "a")
  }

  @Test("setEmptyValue with prefix+suffix: empty still uses emptyValue")
  func testSetEmptyValueOverridesPrefixSuffix() {
    let sj = java.util.StringJoiner(", ", "[", "]")
    sj.setEmptyValue("EMPTY")
    #expect(sj.toString() == "EMPTY")
  }

  @Test("setEmptyValue returns self for chaining")
  func testSetEmptyValueChaining() {
    let sj = java.util.StringJoiner(", ")
    let returned = sj.setEmptyValue("x")
    #expect(returned === sj)
  }

  // MARK: - merge

  @Test("merge non-empty joiner appends its content")
  func testMergeNonEmpty() {
    let sj1 = java.util.StringJoiner(", ")
    sj1.add("a").add("b")
    let sj2 = java.util.StringJoiner(", ")
    sj2.add("c").add("d")
    sj1.merge(sj2)
    #expect(sj1.toString() == "a, b, c, d")
  }

  @Test("merge empty joiner has no effect")
  func testMergeEmpty() {
    let sj1 = java.util.StringJoiner(", ")
    sj1.add("a")
    let sj2 = java.util.StringJoiner(", ")
    sj1.merge(sj2)
    #expect(sj1.toString() == "a")
  }

  @Test("merge joiner with different delimiter uses other's delimiter internally")
  func testMergeDifferentDelimiter() {
    let sj1 = java.util.StringJoiner(", ")
    sj1.add("a").add("b")
    let sj2 = java.util.StringJoiner(";")
    sj2.add("c").add("d")
    sj1.merge(sj2)
    // other's content is "c;d", appended as one segment
    #expect(sj1.toString() == "a, b, c;d")
  }

  @Test("merge ignores other's prefix and suffix")
  func testMergeIgnoresPrefixSuffix() {
    let sj1 = java.util.StringJoiner(", ")
    sj1.add("a")
    let sj2 = java.util.StringJoiner(", ", "[", "]")
    sj2.add("b").add("c")
    sj1.merge(sj2)
    // prefix "[" and suffix "]" of sj2 must NOT appear
    #expect(sj1.toString() == "a, b, c")
  }

  @Test("merge returns self for chaining")
  func testMergeChaining() {
    let sj = java.util.StringJoiner(", ")
    let other = java.util.StringJoiner(", ")
    other.add("x")
    let returned = sj.merge(other)
    #expect(returned === sj)
  }

  // MARK: - length

  @Test("length of empty joiner (no prefix/suffix)")
  func testLengthEmpty() {
    let sj = java.util.StringJoiner(", ")
    #expect(sj.length() == 0)
  }

  @Test("length of empty joiner with prefix+suffix")
  func testLengthEmptyWithPrefixSuffix() {
    let sj = java.util.StringJoiner(", ", "[", "]")
    #expect(sj.length() == 2) // "[]"
  }

  @Test("length matches toString().count")
  func testLengthMatchesToString() {
    let sj = java.util.StringJoiner("-", "<", ">")
    sj.add("one").add("two").add("three")
    #expect(sj.length() == sj.toString().count)
  }

  // MARK: - CustomStringConvertible

  @Test("description equals toString()")
  func testDescription() {
    let sj = java.util.StringJoiner(", ", "[", "]")
    sj.add("1").add("2")
    #expect(sj.description == sj.toString())
    #expect(sj.description == "[1, 2]")
  }
}
