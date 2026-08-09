/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation
import Testing
@testable import JavApi

// MARK: - Predicate<T>

@Suite("java.util.function.Predicate")
struct PredicateTests {
  @Test func testPredicateTest() {
    let isPositive = java.util.function.AnyPredicate<Int> { $0 > 0 }
    #expect(isPositive.test(5) == true)
    #expect(isPositive.test(-1) == false)
    #expect(isPositive.test(0) == false)
  }

  @Test func testPredicateAnd() {
    let isPositive = java.util.function.AnyPredicate<Int> { $0 > 0 }
    let isEven     = java.util.function.AnyPredicate<Int> { $0 % 2 == 0 }
    let both       = isPositive.and(isEven)
    #expect(both.test(4) == true)
    #expect(both.test(3) == false)
    #expect(both.test(-2) == false)
  }

  @Test func testPredicateOr() {
    let isNeg  = java.util.function.AnyPredicate<Int> { $0 < 0 }
    let isZero = java.util.function.AnyPredicate<Int> { $0 == 0 }
    let either = isNeg.or(isZero)
    #expect(either.test(-1) == true)
    #expect(either.test(0) == true)
    #expect(either.test(1) == false)
  }

  @Test func testPredicateNegate() {
    let isEmpty    = java.util.function.AnyPredicate<String> { $0.isEmpty }
    let isNotEmpty = isEmpty.negate()
    #expect(isNotEmpty.test("") == false)
    #expect(isNotEmpty.test("hello") == true)
  }

  @Test func testPredicateNot() {
    let isBlank  = java.util.function.AnyPredicate<String> { $0.trimmingCharacters(in: .whitespaces).isEmpty }
    let notBlank = java.util.function.AnyPredicate<String>.not(isBlank)
    #expect(notBlank.test("   ") == false)
    #expect(notBlank.test("hi") == true)
  }
}

// MARK: - Function<T,R>

@Suite("java.util.function.Function")
struct FunctionTests {
  @Test func testFunctionApply() {
    let toLength = java.util.function.AnyFunction<String, Int> { $0.count }
    #expect(toLength.apply("hello") == 5)
    #expect(toLength.apply("") == 0)
  }

  @Test func testFunctionAndThen() {
    let toLength  = java.util.function.AnyFunction<String, Int> { $0.count }
    let isLong    = toLength.andThen(java.util.function.AnyFunction<Int, Bool> { $0 > 3 })
    #expect(isLong.apply("hi") == false)
    #expect(isLong.apply("hello") == true)
  }

  @Test func testFunctionCompose() {
    let addExclaim  = java.util.function.AnyFunction<String, String> { $0 + "!" }
    let toUpper     = java.util.function.AnyFunction<String, String> { $0.uppercased() }
    // toUpper.compose(addExclaim) = addExclaim first, then toUpper
    let composed    = toUpper.compose(addExclaim)
    #expect(composed.apply("hello") == "HELLO!")
  }

  @Test func testFunctionIdentity() {
    let id = java.util.function.AnyFunction<String, String>.identity()
    #expect(id.apply("test") == "test")
  }
}

// MARK: - Consumer<T>

@Suite("java.util.function.Consumer")
struct ConsumerTests {
  @Test func testConsumerAccept() {
    var result = [Int]()
    let collect = java.util.function.AnyConsumer<Int> { result.append($0) }
    collect.accept(1)
    collect.accept(2)
    collect.accept(3)
    #expect(result == [1, 2, 3])
  }

  @Test func testConsumerAndThen() {
    var log1 = [String]()
    var log2 = [String]()
    let c1   = java.util.function.AnyConsumer<String> { log1.append($0) }
    let c2   = java.util.function.AnyConsumer<String> { log2.append($0) }
    let both = c1.andThen(c2)
    both.accept("hello")
    #expect(log1 == ["hello"])
    #expect(log2 == ["hello"])
  }
}

// MARK: - BiConsumer<T,U>

@Suite("java.util.function.BiConsumer")
struct BiConsumerTests {
  @Test func testBiConsumerAccept() {
    var result = [(String, Int)]()
    let record = java.util.function.AnyBiConsumer<String, Int> { k, v in result.append((k, v)) }
    record.accept("age", 42)
    record.accept("score", 100)
    #expect(result.count == 2)
    #expect(result[0].0 == "age" && result[0].1 == 42)
  }

  @Test func testBiConsumerAndThen() {
    var count1 = 0
    var count2 = 0
    let c1   = java.util.function.AnyBiConsumer<Int, Int> { _, _ in count1 += 1 }
    let c2   = java.util.function.AnyBiConsumer<Int, Int> { _, _ in count2 += 1 }
    let both = c1.andThen(c2)
    both.accept(1, 2)
    both.accept(3, 4)
    #expect(count1 == 2)
    #expect(count2 == 2)
  }
}

// MARK: - BiFunction<T,U,R>

@Suite("java.util.function.BiFunction")
struct BiFunctionTests {
  @Test func testBiFunctionApply() {
    let concat = java.util.function.AnyBiFunction<String, String, String> { a, b in a + b }
    #expect(concat.apply("Hello, ", "World!") == "Hello, World!")
  }

  @Test func testBiFunctionAndThen() {
    let add     = java.util.function.AnyBiFunction<Int, Int, Int> { $0 + $1 }
    let asStr   = java.util.function.AnyFunction<Int, String> { String($0) }
    let composed = add.andThen(asStr)
    #expect(composed.apply(3, 4) == "7")
  }
}

// MARK: - UnaryOperator<T>

@Suite("java.util.function.UnaryOperator")
struct UnaryOperatorTests {
  @Test func testUnaryOperatorApply() {
    let negate = java.util.function.AnyUnaryOperator<Int> { -$0 }
    #expect(negate.apply(5) == -5)
    #expect(negate.apply(0) == 0)
  }

  @Test func testUnaryOperatorIdentityViaFunction() {
    // UnaryOperator inherits identity() from Function<T,T>
    let id = java.util.function.AnyFunction<String, String>.identity()
    #expect(id.apply("swift") == "swift")
  }

  @Test func testUnaryOperatorAndThen() {
    let times2   = java.util.function.AnyUnaryOperator<Int> { $0 * 2 }
    let plus1    = java.util.function.AnyFunction<Int, Int> { $0 + 1 }
    let composed = times2.andThen(plus1)
    // (3 * 2) + 1 = 7
    #expect(composed.apply(3) == 7)
  }
}

// MARK: - BinaryOperator<T>

@Suite("java.util.function.BinaryOperator")
struct BinaryOperatorTests {
  @Test func testBinaryOperatorApply() {
    let add = java.util.function.AnyBinaryOperator<Int> { $0 + $1 }
    #expect(add.apply(3, 4) == 7)
    #expect(add.apply(0, 0) == 0)
  }

  private struct IntComparator: java.util.Comparator {
    typealias T = Int
    var order: SortOrder = .forward
    func compare(_ a: Int, _ b: Int) -> Int { a < b ? -1 : (a > b ? 1 : 0) }
    static func == (l: IntComparator, r: IntComparator) -> Bool { true }
    func hash(into hasher: inout Hasher) { hasher.combine(0) }
  }

  @Test func testBinaryOperatorMinBy() {
    let minOp = java.util.function.AnyBinaryOperator<Int>.minBy(IntComparator())
    #expect(minOp.apply(3, 7) == 3)
    #expect(minOp.apply(10, 2) == 2)
  }

  @Test func testBinaryOperatorMaxBy() {
    let maxOp = java.util.function.AnyBinaryOperator<Int>.maxBy(IntComparator())
    #expect(maxOp.apply(3, 7) == 7)
    #expect(maxOp.apply(10, 2) == 10)
  }
}
