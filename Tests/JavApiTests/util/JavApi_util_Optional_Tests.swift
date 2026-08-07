/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

@Suite("java.util.Optional")
struct JavApi_util_Optional_Tests {

  // MARK: - Factory methods

  @Test("empty() creates an Optional with no value")
  func testEmpty() {
    let opt = java.util.Optional<Int>.empty()
    #expect(opt.isPresent() == false)
    #expect(opt.isEmpty() == true)
  }

  @Test("of() creates an Optional with the given value")
  func testOf() throws {
    let opt = java.util.Optional<Int>.of(42)
    #expect(opt.isPresent() == true)
    #expect(opt.isEmpty() == false)
    #expect(try opt.get() == 42)
  }

  @Test("ofNullable() with non-nil creates a present Optional")
  func testOfNullablePresent() throws {
    let opt = java.util.Optional<String>.ofNullable("hello")
    #expect(opt.isPresent() == true)
    #expect(try opt.get() == "hello")
  }

  @Test("ofNullable() with nil creates an empty Optional")
  func testOfNullableNil() {
    let opt = java.util.Optional<String>.ofNullable(nil)
    #expect(opt.isEmpty() == true)
  }

  // MARK: - get()

  @Test("get() on present Optional returns the value")
  func testGetPresent() throws {
    let opt = java.util.Optional<Double>.of(3.14)
    #expect(try opt.get() == 3.14)
  }

  @Test("get() on empty Optional throws NoSuchElementException")
  func testGetEmpty() {
    let opt = java.util.Optional<Int>.empty()
    #expect(throws: java.util.NoSuchElementException.self) { try opt.get() }
  }

  // MARK: - orElse / orElseGet

  @Test("orElse() returns value when present")
  func testOrElsePresent() {
    let opt = java.util.Optional<Int>.of(7)
    #expect(opt.orElse(99) == 7)
  }

  @Test("orElse() returns fallback when empty")
  func testOrElseEmpty() {
    let opt = java.util.Optional<Int>.empty()
    #expect(opt.orElse(99) == 99)
  }

  @Test("orElseGet() invokes supplier when empty")
  func testOrElseGet() {
    var called = false
    let opt = java.util.Optional<Int>.empty()
    let result = opt.orElseGet { called = true; return 42 }
    #expect(result == 42)
    #expect(called == true)
  }

  @Test("orElseGet() does not invoke supplier when present")
  func testOrElseGetNotCalled() {
    var called = false
    let opt = java.util.Optional<Int>.of(5)
    let result = opt.orElseGet { called = true; return 99 }
    #expect(result == 5)
    #expect(called == false)
  }

  // MARK: - orElseThrow

  @Test("orElseThrow() returns value when present")
  func testOrElseThrowPresent() throws {
    let opt = java.util.Optional<String>.of("ok")
    #expect(try opt.orElseThrow() == "ok")
  }

  @Test("orElseThrow() throws NoSuchElementException when empty")
  func testOrElseThrowEmpty() {
    let opt = java.util.Optional<Int>.empty()
    #expect(throws: java.util.NoSuchElementException.self) { try opt.orElseThrow() }
  }

  @Test("orElseThrow(supplier:) throws supplied exception when empty")
  func testOrElseThrowWithSupplier() {
    let opt = java.util.Optional<Int>.empty()
    #expect(throws: java.lang.IllegalArgumentException.self) {
      _ = try opt.orElseThrow { java.lang.IllegalArgumentException("test") }
    }
  }

  // MARK: - ifPresent / ifPresentOrElse

  @Test("ifPresent() calls consumer when value is present")
  func testIfPresent() {
    var received: Int? = nil
    let opt = java.util.Optional<Int>.of(10)
    opt.ifPresent { received = $0 }
    #expect(received == 10)
  }

  @Test("ifPresent() does not call consumer when empty")
  func testIfPresentEmpty() {
    var called = false
    let opt = java.util.Optional<Int>.empty()
    opt.ifPresent { _ in called = true }
    #expect(called == false)
  }

  @Test("ifPresentOrElse() calls emptyAction when empty")
  func testIfPresentOrElseEmpty() {
    var emptyCalled = false
    var valueCalled = false
    let opt = java.util.Optional<Int>.empty()
    opt.ifPresentOrElse(
      { _ in valueCalled = true },
      { emptyCalled = true }
    )
    #expect(emptyCalled == true)
    #expect(valueCalled == false)
  }

  // MARK: - map / flatMap / filter

  @Test("map() transforms present value")
  func testMap() throws {
    let opt = java.util.Optional<Int>.of(5)
    let mapped = opt.map { $0 * 2 }
    #expect(try mapped.get() == 10)
  }

  @Test("map() returns empty when original is empty")
  func testMapEmpty() {
    let opt = java.util.Optional<Int>.empty()
    let mapped = opt.map { $0 * 2 }
    #expect(mapped.isEmpty() == true)
  }

  @Test("map() returns empty when mapper returns nil")
  func testMapToNil() {
    let opt = java.util.Optional<Int>.of(5)
    let mapped = opt.map { (_: Int) -> String? in nil }
    #expect(mapped.isEmpty() == true)
  }

  @Test("flatMap() chains Optional transformations")
  func testFlatMap() throws {
    let opt = java.util.Optional<String>.of("42")
    let result = opt.flatMap { s -> java.util.Optional<Int> in
      guard let n = Int(s) else { return java.util.Optional<Int>.empty() }
      return java.util.Optional<Int>.of(n)
    }
    #expect(try result.get() == 42)
  }

  @Test("flatMap() returns empty when original is empty")
  func testFlatMapEmpty() {
    let opt = java.util.Optional<String>.empty()
    let result = opt.flatMap { _ in java.util.Optional<Int>.of(99) }
    #expect(result.isEmpty() == true)
  }

  @Test("filter() retains value when predicate matches")
  func testFilterMatch() throws {
    let opt = java.util.Optional<Int>.of(10)
    let filtered = opt.filter { $0 > 5 }
    #expect(filtered.isPresent() == true)
    #expect(try filtered.get() == 10)
  }

  @Test("filter() returns empty when predicate does not match")
  func testFilterNoMatch() {
    let opt = java.util.Optional<Int>.of(3)
    let filtered = opt.filter { $0 > 5 }
    #expect(filtered.isEmpty() == true)
  }

  @Test("filter() on empty Optional returns empty")
  func testFilterEmpty() {
    let opt = java.util.Optional<Int>.empty()
    let filtered = opt.filter { _ in true }
    #expect(filtered.isEmpty() == true)
  }

  // MARK: - or()

  @Test("or() returns self when present")
  func testOrPresent() throws {
    let opt = java.util.Optional<Int>.of(1)
    let result = opt.or { java.util.Optional<Int>.of(99) }
    #expect(try result.get() == 1)
  }

  @Test("or() calls supplier when empty")
  func testOrEmpty() throws {
    let opt = java.util.Optional<Int>.empty()
    let result = opt.or { java.util.Optional<Int>.of(99) }
    #expect(try result.get() == 99)
  }

  // MARK: - Equatable

  @Test("two present Optionals with equal values are equal")
  func testEquality() {
    let a = java.util.Optional<Int>.of(5)
    let b = java.util.Optional<Int>.of(5)
    #expect(a == b)
  }

  @Test("two empty Optionals are equal")
  func testEqualityEmpty() {
    let a = java.util.Optional<Int>.empty()
    let b = java.util.Optional<Int>.empty()
    #expect(a == b)
  }

  @Test("present Optional is not equal to empty Optional")
  func testInequalityPresentEmpty() {
    let a = java.util.Optional<Int>.of(5)
    let b = java.util.Optional<Int>.empty()
    #expect(a != b)
  }

  // MARK: - Description / Swift interop

  @Test("description of present Optional contains the value")
  func testDescriptionPresent() {
    let opt = java.util.Optional<Int>.of(42)
    #expect(opt.description.contains("42"))
  }

  @Test("description of empty Optional mentions empty")
  func testDescriptionEmpty() {
    let opt = java.util.Optional<Int>.empty()
    #expect(opt.description.lowercased().contains("empty"))
  }

  @Test("swiftOptional() bridges to Swift Optional")
  func testSwiftOptional() {
    let present = java.util.Optional<Int>.of(7)
    let empty   = java.util.Optional<Int>.empty()
    #expect(present.swiftOptional() == 7)
    #expect(empty.swiftOptional()   == nil)
  }
}
