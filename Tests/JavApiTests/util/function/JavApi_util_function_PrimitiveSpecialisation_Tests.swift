/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

// MARK: - Supplier-Spezialisierungen

@Suite("java.util.function — primitive Supplier specialisations")
struct PrimitiveSupplierTests {

  @Test("BooleanSupplier liefert Bool")
  func testBooleanSupplier() {
    let s: java.util.function.BooleanSupplier = java.util.function.AnySupplier<Bool> { true }
    #expect(s.get() == true)
  }

  @Test("IntSupplier liefert Int")
  func testIntSupplier() {
    let s: java.util.function.IntSupplier = java.util.function.AnySupplier<Int> { 42 }
    #expect(s.get() == 42)
  }

  @Test("LongSupplier liefert Int64")
  func testLongSupplier() {
    let s: java.util.function.LongSupplier = java.util.function.AnySupplier<Int64> { Int64.max }
    #expect(s.get() == Int64.max)
  }

  @Test("DoubleSupplier liefert Double")
  func testDoubleSupplier() {
    let s: java.util.function.DoubleSupplier = java.util.function.AnySupplier<Double> { 3.14 }
    #expect(s.get() == 3.14)
  }
}

// MARK: - Consumer-Spezialisierungen

@Suite("java.util.function — primitive Consumer specialisations")
struct PrimitiveConsumerTests {

  @Test("IntConsumer ruft accept auf")
  func testIntConsumer() {
    var result = 0
    let c: java.util.function.IntConsumer = java.util.function.AnyConsumer<Int> { result = $0 }
    c.accept(7)
    #expect(result == 7)
  }

  @Test("LongConsumer ruft accept auf")
  func testLongConsumer() {
    var result: Int64 = 0
    let c: java.util.function.LongConsumer = java.util.function.AnyConsumer<Int64> { result = $0 }
    c.accept(Int64.max)
    #expect(result == Int64.max)
  }

  @Test("DoubleConsumer ruft accept auf")
  func testDoubleConsumer() {
    var result = 0.0
    let c: java.util.function.DoubleConsumer = java.util.function.AnyConsumer<Double> { result = $0 }
    c.accept(2.718)
    #expect(result == 2.718)
  }

  @Test("IntConsumer.andThen verkettet zwei Consumer")
  func testIntConsumerAndThen() {
    var log: [Int] = []
    let first: java.util.function.IntConsumer = java.util.function.AnyConsumer<Int> { log.append($0) }
    let second: java.util.function.IntConsumer = java.util.function.AnyConsumer<Int> { log.append($0 * 2) }
    first.andThen(second).accept(3)
    #expect(log == [3, 6])
  }
}

// MARK: - Predicate-Spezialisierungen

@Suite("java.util.function — primitive Predicate specialisations")
struct PrimitivePredicateTests {

  @Test("IntPredicate testet Int")
  func testIntPredicate() {
    let p: java.util.function.IntPredicate = java.util.function.AnyPredicate<Int> { $0 > 0 }
    #expect(p.test(1) == true)
    #expect(p.test(-1) == false)
  }

  @Test("LongPredicate testet Int64")
  func testLongPredicate() {
    let p: java.util.function.LongPredicate = java.util.function.AnyPredicate<Int64> { $0 > 0 }
    #expect(p.test(Int64.max) == true)
    #expect(p.test(-1) == false)
  }

  @Test("DoublePredicate testet Double")
  func testDoublePredicate() {
    let p: java.util.function.DoublePredicate = java.util.function.AnyPredicate<Double> { $0 > 0 }
    #expect(p.test(1.5) == true)
    #expect(p.test(-1.5) == false)
  }

  @Test("IntPredicate.negate kehrt Ergebnis um")
  func testIntPredicateNegate() {
    let p: java.util.function.IntPredicate = java.util.function.AnyPredicate<Int> { $0 > 0 }
    #expect(p.negate().test(1) == false)
    #expect(p.negate().test(-1) == true)
  }
}

// MARK: - UnaryOperator-Spezialisierungen

@Suite("java.util.function — primitive UnaryOperator specialisations")
struct PrimitiveUnaryOperatorTests {

  @Test("IntUnaryOperator wendet Funktion auf Int an")
  func testIntUnaryOperator() {
    let op: java.util.function.IntUnaryOperator = java.util.function.AnyUnaryOperator<Int> { $0 * 2 }
    #expect(op.apply(5) == 10)
  }

  @Test("LongUnaryOperator wendet Funktion auf Int64 an")
  func testLongUnaryOperator() {
    let op: java.util.function.LongUnaryOperator = java.util.function.AnyUnaryOperator<Int64> { $0 + 1 }
    #expect(op.apply(Int64.max - 1) == Int64.max)
  }

  @Test("DoubleUnaryOperator wendet Funktion auf Double an")
  func testDoubleUnaryOperator() {
    let op: java.util.function.DoubleUnaryOperator = java.util.function.AnyUnaryOperator<Double> { $0 * $0 }
    #expect(op.apply(3.0) == 9.0)
  }
}

// MARK: - BinaryOperator-Spezialisierungen

@Suite("java.util.function — primitive BinaryOperator specialisations")
struct PrimitiveBinaryOperatorTests {

  @Test("IntBinaryOperator addiert zwei Int")
  func testIntBinaryOperator() {
    let op: java.util.function.IntBinaryOperator = java.util.function.AnyBinaryOperator<Int> { $0 + $1 }
    #expect(op.apply(3, 4) == 7)
  }

  @Test("LongBinaryOperator multipliziert zwei Int64")
  func testLongBinaryOperator() {
    let op: java.util.function.LongBinaryOperator = java.util.function.AnyBinaryOperator<Int64> { $0 * $1 }
    #expect(op.apply(3, 4) == 12)
  }

  @Test("DoubleBinaryOperator subtrahiert zwei Double")
  func testDoubleBinaryOperator() {
    let op: java.util.function.DoubleBinaryOperator = java.util.function.AnyBinaryOperator<Double> { $0 - $1 }
    #expect(op.apply(5.0, 3.0) == 2.0)
  }
}

// MARK: - Function-Spezialisierungen (generische Typaliase)

@Suite("java.util.function — primitive Function specialisations")
struct PrimitiveFunctionTests {

  @Test("IntFunction<String> wandelt Int in String")
  func testIntFunction() {
    let f: java.util.function.IntFunction<String> = java.util.function.AnyFunction<Int, String> { "\($0)" }
    #expect(f.apply(42) == "42")
  }

  @Test("LongFunction<Bool> prüft Int64")
  func testLongFunction() {
    let f: java.util.function.LongFunction<Bool> = java.util.function.AnyFunction<Int64, Bool> { $0 > 0 }
    #expect(f.apply(1) == true)
    #expect(f.apply(-1) == false)
  }

  @Test("DoubleFunction<Int> schneidet Nachkommastellen ab")
  func testDoubleFunction() {
    let f: java.util.function.DoubleFunction<Int> = java.util.function.AnyFunction<Double, Int> { Int($0) }
    #expect(f.apply(3.9) == 3)
  }

  @Test("ToIntFunction<String> liefert Länge als Int")
  func testToIntFunction() {
    let f: java.util.function.ToIntFunction<String> = java.util.function.AnyFunction<String, Int> { $0.count }
    #expect(f.apply("hello") == 5)
  }

  @Test("ToLongFunction<String> liefert Länge als Int64")
  func testToLongFunction() {
    let f: java.util.function.ToLongFunction<String> = java.util.function.AnyFunction<String, Int64> { Int64($0.count) }
    #expect(f.apply("hi") == 2)
  }

  @Test("ToDoubleFunction<Int> konvertiert Int zu Double")
  func testToDoubleFunction() {
    let f: java.util.function.ToDoubleFunction<Int> = java.util.function.AnyFunction<Int, Double> { Double($0) }
    #expect(f.apply(3) == 3.0)
  }
}

// MARK: - BiPredicate

@Suite("java.util.function.BiPredicate")
struct BiPredicateTests {

  @Test("AnyBiPredicate.test wertet zwei Argumente aus")
  func testTest() {
    let p = java.util.function.AnyBiPredicate<Int, Int> { $0 > 0 && $1 > 0 }
    #expect(p.test(1, 2) == true)
    #expect(p.test(1, -1) == false)
    #expect(p.test(-1, 1) == false)
  }

  @Test("BiPredicate.negate kehrt Ergebnis um")
  func testNegate() {
    let p = java.util.function.AnyBiPredicate<Int, Int> { $0 == $1 }
    #expect(p.negate().test(1, 1) == false)
    #expect(p.negate().test(1, 2) == true)
  }

  @Test("BiPredicate.and kombiniert mit UND")
  func testAnd() {
    let positive = java.util.function.AnyBiPredicate<Int, Int> { $0 > 0 && $1 > 0 }
    let sumGt5   = java.util.function.AnyBiPredicate<Int, Int> { $0 + $1 > 5 }
    let combined = positive.and(sumGt5)
    #expect(combined.test(3, 4) == true)   // beide erfüllt
    #expect(combined.test(1, 2) == false)  // sumGt5 nicht erfüllt
    #expect(combined.test(-1, 8) == false) // positive nicht erfüllt
  }

  @Test("BiPredicate.or kombiniert mit ODER")
  func testOr() {
    let bothPos = java.util.function.AnyBiPredicate<Int, Int> { $0 > 0 && $1 > 0 }
    let sumGt10 = java.util.function.AnyBiPredicate<Int, Int> { $0 + $1 > 10 }
    let combined = bothPos.or(sumGt10)
    #expect(combined.test(1, 2) == true)   // bothPos erfüllt
    #expect(combined.test(-1, 15) == true) // sumGt10 erfüllt
    #expect(combined.test(-5, -5) == false) // keines erfüllt
  }

  @Test("BiPredicate<String, Int> prüft String-Länge")
  func testStringIntBiPredicate() {
    let p = java.util.function.AnyBiPredicate<String, Int> { str, len in str.count == len }
    #expect(p.test("hello", 5) == true)
    #expect(p.test("hi", 5) == false)
  }
}

// MARK: - ObjXxxConsumer

@Suite("java.util.function — ObjXxxConsumer specialisations")
struct ObjConsumerTests {

  @Test("ObjIntConsumer akzeptiert Objekt und Int")
  func testObjIntConsumer() {
    var log: [String] = []
    let c: java.util.function.ObjIntConsumer<String> =
      java.util.function.AnyBiConsumer<String, Int> { s, n in log.append("\(s):\(n)") }
    c.accept("x", 7)
    #expect(log == ["x:7"])
  }

  @Test("ObjLongConsumer akzeptiert Objekt und Int64")
  func testObjLongConsumer() {
    var result: Int64 = 0
    let c: java.util.function.ObjLongConsumer<String> =
      java.util.function.AnyBiConsumer<String, Int64> { _, n in result = n }
    c.accept("ignored", Int64.max)
    #expect(result == Int64.max)
  }

  @Test("ObjDoubleConsumer akzeptiert Objekt und Double")
  func testObjDoubleConsumer() {
    var sum = 0.0
    let c: java.util.function.ObjDoubleConsumer<[Double]> =
      java.util.function.AnyBiConsumer<[Double], Double> { _, d in sum += d }
    c.accept([], 1.5)
    c.accept([], 2.5)
    #expect(sum == 4.0)
  }
}

// MARK: - ToXxxBiFunction

@Suite("java.util.function — ToXxxBiFunction specialisations")
struct ToXxxBiFunctionTests {

  @Test("ToIntBiFunction liefert Int aus zwei Argumenten")
  func testToIntBiFunction() {
    let f: java.util.function.ToIntBiFunction<String, String> =
      java.util.function.AnyBiFunction<String, String, Int> { a, b in a.count + b.count }
    #expect(f.apply("hi", "world") == 7)
  }

  @Test("ToLongBiFunction liefert Int64 aus zwei Argumenten")
  func testToLongBiFunction() {
    let f: java.util.function.ToLongBiFunction<Int, Int> =
      java.util.function.AnyBiFunction<Int, Int, Int64> { a, b in Int64(a) * Int64(b) }
    #expect(f.apply(1_000_000, 1_000_000) == 1_000_000_000_000)
  }

  @Test("ToDoubleBiFunction liefert Double aus zwei Argumenten")
  func testToDoubleBiFunction() {
    let f: java.util.function.ToDoubleBiFunction<Int, Int> =
      java.util.function.AnyBiFunction<Int, Int, Double> { a, b in Double(a) / Double(b) }
    #expect(f.apply(1, 4) == 0.25)
  }
}
