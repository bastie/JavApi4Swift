/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Foundation
import Testing
@testable import JavApi

private typealias Objects = java.util.Objects

@Suite("java.util.Objects")
struct JavApi_util_Objects_Tests {

  // MARK: - equals (Java 7)

  @Test("equals: equal values returns true")
  func testEqualsEqual() {
    #expect(Objects.equals(42, 42))
    #expect(Objects.equals("hello", "hello"))
  }

  @Test("equals: different values returns false")
  func testEqualsNotEqual() {
    #expect(!Objects.equals(1, 2))
    #expect(!Objects.equals("a", "b"))
  }

  @Test("equals: both nil returns true")
  func testEqualsBothNil() {
    #expect(Objects.equals(nil as Int?, nil as Int?))
  }

  @Test("equals: one nil returns false")
  func testEqualsOneNil() {
    #expect(!Objects.equals(nil as Int?, 1))
    #expect(!Objects.equals(1, nil as Int?))
  }

  // MARK: - deepEquals (Java 7)

  @Test("deepEquals: both nil returns true")
  func testDeepEqualsBothNil() {
    #expect(Objects.deepEquals(nil, nil))
  }

  @Test("deepEquals: one nil returns false")
  func testDeepEqualsOneNil() {
    #expect(!Objects.deepEquals(nil, 42))
    #expect(!Objects.deepEquals(42, nil))
  }

  @Test("deepEquals: equal scalars returns true")
  func testDeepEqualsScalars() {
    #expect(Objects.deepEquals(42, 42))
    #expect(Objects.deepEquals("x", "x"))
  }

  @Test("deepEquals: equal arrays returns true")
  func testDeepEqualsArrays() {
    #expect(Objects.deepEquals([1, 2, 3] as [AnyHashable], [1, 2, 3] as [AnyHashable]))
  }

  @Test("deepEquals: different arrays returns false")
  func testDeepEqualsDifferentArrays() {
    #expect(!Objects.deepEquals([1, 2] as [AnyHashable], [1, 3] as [AnyHashable]))
    #expect(!Objects.deepEquals([1] as [AnyHashable], [1, 2] as [AnyHashable]))
  }

  // MARK: - hashCode (Java 7)

  @Test("hashCode: nil returns 0")
  func testHashCodeNil() {
    #expect(Objects.hashCode(nil as Int?) == 0)
  }

  @Test("hashCode: non-nil returns same result as object's hashValue")
  func testHashCodeValue() {
    let i: Int = 42
    #expect(Objects.hashCode(i) == i.hashValue)
    // String.hashValue now derives from hash(into:) — both paths must agree
    let s: String = "hello"
    #expect(Objects.hashCode(s) == s.hashValue)
  }

  // MARK: - hash (Java 7)

  @Test("hash: empty produces consistent value")
  func testHashEmpty() {
    let h1 = Objects.hash()
    let h2 = Objects.hash()
    #expect(h1 == h2)
  }

  @Test("hash: same values produce same hash")
  func testHashSameValues() {
    let h1 = Objects.hash(1, "a", true)
    let h2 = Objects.hash(1, "a", true)
    #expect(h1 == h2)
  }

  @Test("hash: different values produce different hashes")
  func testHashDifferentValues() {
    let h1 = Objects.hash(1, 2)
    let h2 = Objects.hash(2, 1)
    // Order matters — different order should (very likely) differ
    #expect(h1 != h2)
  }

  @Test("hash: nil values are handled")
  func testHashWithNils() {
    let h1 = Objects.hash(nil as Int?, 1)
    let h2 = Objects.hash(nil as Int?, 1)
    #expect(h1 == h2)
  }

  // MARK: - toString (Java 7)

  @Test("toString: nil returns 'null'")
  func testToStringNil() {
    #expect(Objects.toString(nil) == "null")
  }

  @Test("toString: value returns description")
  func testToStringValue() {
    #expect(Objects.toString(42) == "42")
    #expect(Objects.toString("hello") == "hello")
  }

  @Test("toString with default: nil returns nullDefault")
  func testToStringDefault() {
    #expect(Objects.toString(nil, "default") == "default")
  }

  @Test("toString with default: non-nil ignores default")
  func testToStringDefaultNonNil() {
    #expect(Objects.toString(99, "default") == "99")
  }

  // MARK: - compare (Java 7)

  @Test("compare: delegates to comparator")
  func testCompare() {
    let cmp = _IntComparator()
    #expect(Objects.compare(1, 2, cmp) < 0)
    #expect(Objects.compare(2, 1, cmp) > 0)
    #expect(Objects.compare(5, 5, cmp) == 0)
  }

  // MARK: - requireNonNull (Java 7)

  @Test("requireNonNull: non-nil passes through")
  func testRequireNonNullPasses() throws {
    let result = try Objects.requireNonNull(42)
    #expect(result == 42)
  }

  @Test("requireNonNull: nil throws NullPointerException")
  func testRequireNonNullThrows() {
    #expect(throws: NullPointerException.self) {
      try Objects.requireNonNull(nil as String?)
    }
  }

  @Test("requireNonNull with message: nil throws with message")
  func testRequireNonNullMessageThrows() {
    #expect(throws: NullPointerException.self) {
      try Objects.requireNonNull(nil as Int?, "must not be nil")
    }
  }

  @Test("requireNonNull with message: non-nil passes through")
  func testRequireNonNullMessagePasses() throws {
    let result = try Objects.requireNonNull("ok", "must not be nil")
    #expect(result == "ok")
  }

  // MARK: - isNull / nonNull (Java 8)

  @Test("isNull: nil returns true")
  func testIsNullTrue() {
    #expect(Objects.isNull(nil))
  }

  @Test("isNull: non-nil returns false")
  func testIsNullFalse() {
    #expect(!Objects.isNull(42))
  }

  @Test("nonNull: non-nil returns true")
  func testNonNullTrue() {
    #expect(Objects.nonNull("x"))
  }

  @Test("nonNull: nil returns false")
  func testNonNullFalse() {
    #expect(!Objects.nonNull(nil))
  }

  // MARK: - requireNonNullElse (Java 9)

  @Test("requireNonNullElse: non-nil returns obj")
  func testRequireNonNullElseObj() {
    #expect(Objects.requireNonNullElse(42, 99) == 42)
  }

  @Test("requireNonNullElse: nil returns defaultObj")
  func testRequireNonNullElseDefault() {
    #expect(Objects.requireNonNullElse(nil, 99) == 99)
  }

  // MARK: - requireNonNullElseGet (Java 9)

  @Test("requireNonNullElseGet: non-nil does not call supplier")
  func testRequireNonNullElseGetObj() {
    var called = false
    let result = Objects.requireNonNullElseGet(42) { called = true; return 99 }
    #expect(result == 42)
    #expect(!called)
  }

  @Test("requireNonNullElseGet: nil calls supplier")
  func testRequireNonNullElseGetSupplier() {
    let result = Objects.requireNonNullElseGet(nil as Int?) { 99 }
    #expect(result == 99)
  }

  // MARK: - requireNonNull with Supplier (Java 9)

  @Test("requireNonNull(supplier): nil throws with lazy message")
  func testRequireNonNullSupplierThrows() {
    var evaluated = false
    #expect(throws: NullPointerException.self) {
      try Objects.requireNonNull(nil as String?) { evaluated = true; return "lazy message" }
    }
    #expect(evaluated)
  }

  @Test("requireNonNull(supplier): non-nil does not evaluate supplier")
  func testRequireNonNullSupplierPasses() throws {
    var evaluated = false
    let result = try Objects.requireNonNull("ok") { evaluated = true; return "never" }
    #expect(result == "ok")
    #expect(!evaluated)
  }

  // MARK: - checkIndex (Java 9, Int)

  @Test("checkIndex: valid index returns index")
  func testCheckIndexValid() throws {
    #expect(try Objects.checkIndex(0, 5) == 0)
    #expect(try Objects.checkIndex(4, 5) == 4)
  }

  @Test("checkIndex: negative index throws")
  func testCheckIndexNegative() {
    #expect(throws: IndexOutOfBoundsException.self) {
      try Objects.checkIndex(-1, 5)
    }
  }

  @Test("checkIndex: index == length throws")
  func testCheckIndexEqualLength() {
    #expect(throws: IndexOutOfBoundsException.self) {
      try Objects.checkIndex(5, 5)
    }
  }

  @Test("checkIndex: negative length throws")
  func testCheckIndexNegativeLength() {
    #expect(throws: IndexOutOfBoundsException.self) {
      try Objects.checkIndex(0, -1)
    }
  }

  // MARK: - checkFromToIndex (Java 9, Int)

  @Test("checkFromToIndex: valid range returns fromIndex")
  func testCheckFromToIndexValid() throws {
    #expect(try Objects.checkFromToIndex(1, 3, 5) == 1)
    #expect(try Objects.checkFromToIndex(0, 5, 5) == 0)
  }

  @Test("checkFromToIndex: fromIndex > toIndex throws")
  func testCheckFromToIndexFromGtTo() {
    #expect(throws: IndexOutOfBoundsException.self) {
      try Objects.checkFromToIndex(3, 2, 5)
    }
  }

  @Test("checkFromToIndex: toIndex > length throws")
  func testCheckFromToIndexToGtLength() {
    #expect(throws: IndexOutOfBoundsException.self) {
      try Objects.checkFromToIndex(0, 6, 5)
    }
  }

  // MARK: - checkFromIndexSize (Java 9, Int)

  @Test("checkFromIndexSize: valid range returns fromIndex")
  func testCheckFromIndexSizeValid() throws {
    #expect(try Objects.checkFromIndexSize(1, 3, 5) == 1)
    #expect(try Objects.checkFromIndexSize(0, 5, 5) == 0)
  }

  @Test("checkFromIndexSize: fromIndex + size > length throws")
  func testCheckFromIndexSizeOverflow() {
    #expect(throws: IndexOutOfBoundsException.self) {
      try Objects.checkFromIndexSize(3, 3, 5)
    }
  }

  @Test("checkFromIndexSize: negative size throws")
  func testCheckFromIndexSizeNegativeSize() {
    #expect(throws: IndexOutOfBoundsException.self) {
      try Objects.checkFromIndexSize(0, -1, 5)
    }
  }

  // MARK: - checkIndex long overloads (Java 16)

  @Test("checkIndex(Int64): valid index returns index")
  func testCheckIndexLongValid() throws {
    let result: Int64 = try Objects.checkIndex(Int64(0), Int64(100))
    #expect(result == 0)
  }

  @Test("checkIndex(Int64): out of bounds throws")
  func testCheckIndexLongThrows() {
    #expect(throws: IndexOutOfBoundsException.self) {
      try Objects.checkIndex(Int64(100), Int64(100))
    }
  }

  @Test("checkFromToIndex(Int64): valid range returns fromIndex")
  func testCheckFromToIndexLongValid() throws {
    let result: Int64 = try Objects.checkFromToIndex(Int64(0), Int64(50), Int64(100))
    #expect(result == 0)
  }

  @Test("checkFromIndexSize(Int64): valid range returns fromIndex")
  func testCheckFromIndexSizeLongValid() throws {
    let result: Int64 = try Objects.checkFromIndexSize(Int64(10), Int64(20), Int64(100))
    #expect(result == 10)
  }
}

// MARK: - Test helpers

/// Minimal Comparator<Int> for testing Objects.compare.
private struct _IntComparator: java.util.Comparator {
  typealias T = Int
  var order: SortOrder = .forward
  func compare(_ lhs: Int, _ rhs: Int) -> Int { lhs < rhs ? -1 : lhs > rhs ? 1 : 0 }
  static func == (lhs: _IntComparator, rhs: _IntComparator) -> Bool { true }
  func hash(into hasher: inout Hasher) { hasher.combine(0) }
}
