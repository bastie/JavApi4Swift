/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
import Foundation
@testable import JavApi

struct JavApi_math_BigInteger_Tests {

  // MARK: - Constants

  @Test("ZERO, ONE, TEN constants")
  func testConstants() throws {
    #expect(java.math.BigInteger.ZERO == (try java.math.BigInteger("0")))
    #expect(java.math.BigInteger.ONE  == (try java.math.BigInteger("1")))
    #expect(java.math.BigInteger.TEN  == (try java.math.BigInteger("10")))
  }

  @Test("ZERO equals zero string")
  func testZeroEqualsString() throws {
    #expect(java.math.BigInteger.ZERO == (try java.math.BigInteger("0")))
    #expect(java.math.BigInteger.ZERO.signum() == 0)
  }

  // MARK: - init(String)

  @Test("init(String) parses positive, negative, and zero")
  func testInitString() throws {
    let pos  = try java.math.BigInteger("12345")
    let neg  = try java.math.BigInteger("-12345")
    let zero = try java.math.BigInteger("0")
    #expect(pos.toString()  == "12345")
    #expect(neg.toString()  == "-12345")
    #expect(zero.toString() == "0")
  }

  @Test("init(String) throws on invalid input")
  func testInitStringInvalid() {
    #expect(throws: NumberFormatException.self) { try java.math.BigInteger("abc") }
    #expect(throws: NumberFormatException.self) { try java.math.BigInteger("")    }
  }

  @Test("init(String) throws on decimal point in string")
  func testInitStringDecimalInvalid() {
    #expect(throws: NumberFormatException.self) { try java.math.BigInteger("1.5") }
  }

  @Test("init(String radix) parses hex and binary")
  func testInitStringRadix() throws {
    let hex = try java.math.BigInteger("FF", 16)
    #expect(hex == (try java.math.BigInteger("255")))
    let bin = try java.math.BigInteger("1010", 2)
    #expect(bin == (try java.math.BigInteger("10")))
  }

  @Test("init(String radix) parses octal")
  func testInitStringOctal() throws {
    let oct = try java.math.BigInteger("17", 8)  // 1*8 + 7 = 15
    #expect(oct == (try java.math.BigInteger("15")))
  }

  @Test("init(String radix) negative hex")
  func testInitStringNegativeHex() throws {
    let v = try java.math.BigInteger("-FF", 16)
    #expect(v == (try java.math.BigInteger("-255")))
  }

  // MARK: - valueOf

  @Test("valueOf(Int64) matches String init")
  func testValueOf() throws {
    let v   = java.math.BigInteger.valueOf(999)
    #expect(v == (try java.math.BigInteger("999")))
    let neg = java.math.BigInteger.valueOf(-1)
    #expect(neg == (try java.math.BigInteger("-1")))
  }

  @Test("valueOf(Int64) zero")
  func testValueOfZero() {
    #expect(java.math.BigInteger.valueOf(0) == java.math.BigInteger.ZERO)
  }

  @Test("valueOf(Int64) Long.MIN_VALUE")
  func testValueOfLongMin() {
    let v = java.math.BigInteger.valueOf(Int64.min)
    #expect(v.toString() == "-9223372036854775808")
  }

  // MARK: - Basic arithmetic

  @Test("add, subtract, multiply")
  func testArithmetic() throws {
    let a = try java.math.BigInteger("100")
    let b = try java.math.BigInteger("37")
    #expect(a.add(b)      == (try java.math.BigInteger("137")))
    #expect(a.subtract(b) == (try java.math.BigInteger("63")))
    #expect(a.multiply(b) == (try java.math.BigInteger("3700")))
  }

  @Test("add negative to positive")
  func testAddNegative() throws {
    let a = try java.math.BigInteger("10")
    let b = try java.math.BigInteger("-3")
    #expect(a.add(b) == (try java.math.BigInteger("7")))
  }

  @Test("subtract producing negative result")
  func testSubtractNegativeResult() throws {
    let a = try java.math.BigInteger("3")
    let b = try java.math.BigInteger("10")
    #expect(a.subtract(b) == (try java.math.BigInteger("-7")))
  }

  @Test("multiply negative by negative gives positive")
  func testMultiplyNegativeNegative() throws {
    let a = try java.math.BigInteger("-7")
    let b = try java.math.BigInteger("-6")
    #expect(a.multiply(b) == (try java.math.BigInteger("42")))
  }

  @Test("multiply by zero gives zero")
  func testMultiplyByZero() throws {
    let a = try java.math.BigInteger("999999")
    #expect(a.multiply(java.math.BigInteger.ZERO) == java.math.BigInteger.ZERO)
  }

  @Test("operator overloads +, -, * are consistent with methods")
  func testOperators() throws {
    let a = try java.math.BigInteger("50")
    let b = try java.math.BigInteger("50")
    #expect(a + b == (try java.math.BigInteger("100")))
    #expect(a - b == java.math.BigInteger.ZERO)
    #expect(a * b == (try java.math.BigInteger("2500")))
  }

  @Test("operator += and -= mutate correctly")
  func testCompoundOperators() throws {
    var a = try java.math.BigInteger("10")
    a += java.math.BigInteger.valueOf(5)
    #expect(a == java.math.BigInteger.valueOf(15))
    a -= java.math.BigInteger.valueOf(3)
    #expect(a == java.math.BigInteger.valueOf(12))
  }

  // MARK: - divide / remainder

  @Test("divide and remainder")
  func testDivideRemainder() throws {
    let a = try java.math.BigInteger("17")
    let b = try java.math.BigInteger("5")
    #expect((try a.divide(b))    == (try java.math.BigInteger("3")))
    #expect((try a.remainder(b)) == (try java.math.BigInteger("2")))
  }

  @Test("divide truncates towards zero for negative dividend")
  func testDivideNegativeDividend() throws {
    let a = try java.math.BigInteger("-17")
    let b = try java.math.BigInteger("5")
    #expect((try a.divide(b)) == (try java.math.BigInteger("-3")))
  }

  @Test("divide truncates towards zero for negative divisor")
  func testDivideNegativeDivisor() throws {
    let a = try java.math.BigInteger("17")
    let b = try java.math.BigInteger("-5")
    #expect((try a.divide(b)) == (try java.math.BigInteger("-3")))
  }

  @Test("remainder sign follows dividend")
  func testRemainderSign() throws {
    let a = try java.math.BigInteger("-17")
    let b = try java.math.BigInteger("5")
    #expect((try a.remainder(b)) == (try java.math.BigInteger("-2")))
  }

  @Test("divide by zero throws ArithmeticException")
  func testDivideByZero() throws {
    let a = try java.math.BigInteger("1")
    #expect(throws: ArithmeticException.self) { try a.divide(java.math.BigInteger.ZERO) }
  }

  @Test("remainder by zero throws ArithmeticException")
  func testRemainderByZero() throws {
    let a = try java.math.BigInteger("5")
    #expect(throws: ArithmeticException.self) { try a.remainder(java.math.BigInteger.ZERO) }
  }

  @Test("divideAndRemainder returns two-element array")
  func testDivideAndRemainder() throws {
    let a      = try java.math.BigInteger("23")
    let b      = try java.math.BigInteger("7")
    let result = try a.divideAndRemainder(b)
    #expect(result.count == 2)
    #expect(result[0] == (try java.math.BigInteger("3")))
    #expect(result[1] == (try java.math.BigInteger("2")))
  }

  @Test("divideAndRemainder with negative dividend")
  func testDivideAndRemainderNegative() throws {
    let a      = try java.math.BigInteger("-23")
    let b      = try java.math.BigInteger("7")
    let result = try a.divideAndRemainder(b)
    #expect(result[0] == (try java.math.BigInteger("-3")))
    #expect(result[1] == (try java.math.BigInteger("-2")))
  }

  // MARK: - abs / negate / signum

  @Test("abs, negate, signum")
  func testAbsNegateSignum() throws {
    let pos  = try java.math.BigInteger("42")
    let neg  = try java.math.BigInteger("-42")
    let zero = java.math.BigInteger.ZERO
    #expect(neg.abs()     == pos)
    #expect(pos.negate()  == neg)
    #expect(pos.signum()  ==  1)
    #expect(neg.signum()  == -1)
    #expect(zero.signum() ==  0)
  }

  @Test("abs of zero is zero")
  func testAbsZero() {
    #expect(java.math.BigInteger.ZERO.abs() == java.math.BigInteger.ZERO)
  }

  @Test("double negate returns original")
  func testDoubleNegate() throws {
    let v = try java.math.BigInteger("12345")
    #expect(v.negate().negate() == v)
  }

  // MARK: - pow / gcd / mod

  @Test("pow: 2^10 = 1024")
  func testPow() throws {
    let two = try java.math.BigInteger("2")
    #expect((try two.pow(10)) == (try java.math.BigInteger("1024")))
  }

  @Test("pow(0) = 1 for any base")
  func testPowZero() throws {
    let v = try java.math.BigInteger("999")
    #expect((try v.pow(0)) == java.math.BigInteger.ONE)
  }

  @Test("pow(1) returns self")
  func testPowOne() throws {
    let v = try java.math.BigInteger("42")
    #expect((try v.pow(1)) == v)
  }

  @Test("pow with negative exponent throws ArithmeticException")
  func testPowNegativeExp() throws {
    let v = try java.math.BigInteger("2")
    #expect(throws: ArithmeticException.self) { try v.pow(-1) }
  }

  @Test("gcd of 12 and 8 is 4")
  func testGcd() throws {
    let a = try java.math.BigInteger("12")
    let b = try java.math.BigInteger("8")
    #expect(a.gcd(b) == (try java.math.BigInteger("4")))
  }

  @Test("gcd with zero returns abs of other")
  func testGcdWithZero() throws {
    let v = try java.math.BigInteger("42")
    #expect(v.gcd(java.math.BigInteger.ZERO) == v)
    #expect(java.math.BigInteger.ZERO.gcd(v) == v)
  }

  @Test("gcd of negative numbers uses absolute values")
  func testGcdNegative() throws {
    let a = try java.math.BigInteger("-12")
    let b = try java.math.BigInteger("8")
    #expect(a.gcd(b) == (try java.math.BigInteger("4")))
  }

  @Test("gcd of coprime numbers is 1")
  func testGcdCoprime() throws {
    let a = try java.math.BigInteger("13")
    let b = try java.math.BigInteger("7")
    #expect(a.gcd(b) == java.math.BigInteger.ONE)
  }

  @Test("mod: 17 mod 5 = 2")
  func testMod() throws {
    let a = try java.math.BigInteger("17")
    let m = try java.math.BigInteger("5")
    #expect((try a.mod(m)) == (try java.math.BigInteger("2")))
  }

  @Test("mod result is always non-negative")
  func testModNonNegative() throws {
    let a = try java.math.BigInteger("-17")
    let m = try java.math.BigInteger("5")
    // Java mod: result is non-negative unlike remainder
    let r = try a.mod(m)
    #expect(r.signum() >= 0)
    #expect(r == (try java.math.BigInteger("3")))
  }

  @Test("mod with zero modulus throws ArithmeticException")
  func testModByZero() throws {
    let a = try java.math.BigInteger("5")
    #expect(throws: ArithmeticException.self) { try a.mod(java.math.BigInteger.ZERO) }
  }

  // MARK: - modInverse / modPow

  @Test("modInverse: 3 mod 11 = 4")
  func testModInverse() throws {
    // 3 * 4 = 12 ≡ 1 (mod 11)
    let a = try java.math.BigInteger("3")
    let m = try java.math.BigInteger("11")
    #expect((try a.modInverse(m)) == (try java.math.BigInteger("4")))
  }

  @Test("modPow: 3^4 mod 5 = 1 (odd modulus)")
  func testModPowOdd() throws {
    // 5 is odd → oddModPow path; 81 mod 5 = 1
    let base = try java.math.BigInteger("3")
    let exp  = try java.math.BigInteger("4")
    let mod  = try java.math.BigInteger("5")
    #expect((try base.modPow(exp, mod)) == (try java.math.BigInteger("1")))
  }

  @Test("modPow: 2^10 mod 1000 = 24 (even modulus)")
  func testModPowEven() throws {
    // 1000 is even → evenModPow path; 1024 mod 1000 = 24
    let base = try java.math.BigInteger("2")
    let exp  = try java.math.BigInteger("10")
    let mod  = try java.math.BigInteger("1000")
    let result = try base.modPow(exp, mod)
    #expect(result.toString() == "24")
  }

  // MARK: - compareTo / min / max

  @Test("compareTo, min, max")
  func testCompare() throws {
    let small = try java.math.BigInteger("1")
    let large = try java.math.BigInteger("1000")
    #expect(small.compareTo(large) < 0)
    #expect(large.compareTo(small) > 0)
    #expect(small.compareTo(small) == 0)
    #expect(small.min(large) == small)
    #expect(small.max(large) == large)
  }

  @Test("compareTo equal values returns zero")
  func testCompareToEqual() throws {
    let a = try java.math.BigInteger("42")
    let b = try java.math.BigInteger("42")
    #expect(a.compareTo(b) == 0)
  }

  @Test("compareTo negative vs positive")
  func testCompareToNegativePositive() throws {
    let neg = try java.math.BigInteger("-1")
    let pos = try java.math.BigInteger("1")
    #expect(neg.compareTo(pos) < 0)
    #expect(pos.compareTo(neg) > 0)
  }

  @Test("Swift < operator works")
  func testLessThanOperator() throws {
    let a = try java.math.BigInteger("5")
    let b = try java.math.BigInteger("10")
    #expect(a < b)
    #expect(!(b < a))
  }

  // MARK: - Bit operations

  @Test("bitLength")
  func testBitLength() throws {
    #expect(java.math.BigInteger.ZERO.bitLength()              == 0)
    #expect(java.math.BigInteger.ONE.bitLength()               == 1)
    #expect((try java.math.BigInteger("255")).bitLength()      == 8)
    #expect((try java.math.BigInteger("256")).bitLength()      == 9)
  }

  @Test("bitLength of negative number equals bitLength of abs")
  func testBitLengthNegative() throws {
    let pos = try java.math.BigInteger("255")
    let neg = try java.math.BigInteger("-255")
    #expect(neg.bitLength() == pos.bitLength())
  }

  @Test("bitCount counts set bits")
  func testBitCount() throws {
    // 5 = 101 in binary → 2 set bits
    let v = try java.math.BigInteger("5")
    #expect(v.bitCount() == 2)
    // 255 = 11111111 → 8 set bits
    let w = try java.math.BigInteger("255")
    #expect(w.bitCount() == 8)
  }

  @Test("testBit, setBit, clearBit, flipBit")
  func testBitManipulation() throws {
    let v = try java.math.BigInteger("5")   // binary: 101
    #expect((try v.testBit(0)) == true)
    #expect((try v.testBit(1)) == false)
    #expect((try v.testBit(2)) == true)
    #expect((try v.setBit(1))   == (try java.math.BigInteger("7")))  // 111
    #expect((try v.clearBit(2)) == (try java.math.BigInteger("1")))  // 001
    #expect((try v.flipBit(1))  == (try java.math.BigInteger("7")))  // 111
  }

  @Test("getLowestSetBit for power of two")
  func testGetLowestSetBit() throws {
    // 16 = 10000 → lowest set bit is at index 4
    let v = try java.math.BigInteger("16")
    #expect(v.getLowestSetBit() == 4)
    // 1 → lowest set bit at index 0
    #expect(java.math.BigInteger.ONE.getLowestSetBit() == 0)
  }

  @Test("getLowestSetBit of zero returns -1")
  func testGetLowestSetBitZero() {
    #expect(java.math.BigInteger.ZERO.getLowestSetBit() == -1)
  }

  @Test("shiftLeft and shiftRight")
  func testShift() throws {
    let v = try java.math.BigInteger("1")
    #expect(v.shiftLeft(4)  == (try java.math.BigInteger("16")))
    #expect(v.shiftLeft(8)  == (try java.math.BigInteger("256")))
    let w = try java.math.BigInteger("256")
    #expect(w.shiftRight(4) == (try java.math.BigInteger("16")))
  }

  @Test("shiftLeft by zero returns same value")
  func testShiftLeftZero() throws {
    let v = try java.math.BigInteger("42")
    #expect(v.shiftLeft(0) == v)
  }

  @Test("shiftRight of positive towards zero")
  func testShiftRightTowardsZero() throws {
    let v = try java.math.BigInteger("7")   // 111 >> 1 = 11 = 3
    #expect(v.shiftRight(1) == (try java.math.BigInteger("3")))
  }

  @Test("shiftRight of negative extends sign")
  func testShiftRightNegative() throws {
    // Java: -1 >> 1 = -1 (arithmetic right shift)
    let neg = try java.math.BigInteger("-4")
    #expect(neg.shiftRight(1) == (try java.math.BigInteger("-2")))
  }

  @Test("and, or, xor, andNot")
  func testLogical() throws {
    let a = try java.math.BigInteger("12")  // 1100
    let b = try java.math.BigInteger("10")  // 1010
    #expect(a.and(b)    == (try java.math.BigInteger("8")))   // 1000
    #expect(a.or(b)     == (try java.math.BigInteger("14")))  // 1110
    #expect(a.xor(b)    == (try java.math.BigInteger("6")))   // 0110
    #expect(a.andNot(b) == (try java.math.BigInteger("4")))   // 0100
  }

  @Test("not: bitwise complement")
  func testNot() throws {
    // Java not: ~x = -(x+1)
    let v = try java.math.BigInteger("5")
    #expect(v.not() == (try java.math.BigInteger("-6")))
    let neg = try java.math.BigInteger("-1")
    #expect(neg.not() == java.math.BigInteger.ZERO)
  }

  // MARK: - toString(radix)

  @Test("toString() default is decimal")
  func testToStringDefault() throws {
    let v = try java.math.BigInteger("12345")
    #expect(v.toString() == "12345")
  }

  @Test("toString(radix) for hex and binary")
  func testToStringRadix() throws {
    let v = try java.math.BigInteger("255")
    #expect(v.toString(16).lowercased() == "ff")
    #expect(v.toString(2)               == "11111111")
    #expect(v.toString(10)              == "255")
  }

  @Test("toString(radix) for negative hex")
  func testToStringNegativeHex() throws {
    let v = try java.math.BigInteger("-255")
    #expect(v.toString(16).lowercased() == "-ff")
  }

  // MARK: - toByteArray / init([UInt8])

  @Test("toByteArray round-trips through init([UInt8])")
  func testToByteArrayRoundTrip() throws {
    let original = try java.math.BigInteger("123456789")
    let bytes    = original.toByteArray()
    let restored = try java.math.BigInteger(bytes)
    #expect(restored == original)
  }

  @Test("toByteArray of ZERO produces single zero byte")
  func testToByteArrayZero() {
    let bytes = java.math.BigInteger.ZERO.toByteArray()
    #expect(bytes == [0])
  }

  @Test("toByteArray of negative round-trips")
  func testToByteArrayNegativeRoundTrip() throws {
    let original = try java.math.BigInteger("-256")
    let bytes    = original.toByteArray()
    let restored = try java.math.BigInteger(bytes)
    #expect(restored == original)
  }

  // MARK: - intValue / longValue / doubleValue / floatValue

  @Test("intValue and longValue for small numbers")
  func testConversionToInt() throws {
    let v = try java.math.BigInteger("42")
    #expect(v.intValue()  == 42)
    #expect(v.longValue() == 42)
  }

  @Test("intValue for negative number")
  func testIntValueNegative() throws {
    let v = try java.math.BigInteger("-99")
    #expect(v.intValue()  == -99)
    #expect(v.longValue() == -99)
  }

  @Test("doubleValue for large power of two")
  func testDoubleValue() throws {
    let two   = try java.math.BigInteger("2")
    let pow30 = try two.pow(30)   // 2^30 = 1_073_741_824
    #expect(pow30.doubleValue() == Double(1 << 30))
  }

  @Test("floatValue for small number")
  func testFloatValue() throws {
    let v = try java.math.BigInteger("42")
    #expect(v.floatValue() == Float(42))
  }

  // MARK: - Equatable / Hashable

  @Test("equal BigIntegers have equal hash")
  func testEquatableHashable() throws {
    let a = try java.math.BigInteger("999")
    let b = try java.math.BigInteger("999")
    #expect(a == b)
    #expect(a.hashValue == b.hashValue)
  }

  @Test("hashCode() is stable and consistent")
  func testHashCode() throws {
    let a = try java.math.BigInteger("42")
    let b = try java.math.BigInteger("42")
    #expect(a.hashCode() == b.hashCode())
  }

  @Test("unequal BigIntegers are not equal")
  func testNotEqual() throws {
    let a = try java.math.BigInteger("1")
    let b = try java.math.BigInteger("2")
    #expect(a != b)
  }

  @Test("equals(AnyObject) works correctly")
  func testEqualsAnyObject() throws {
    let a = try java.math.BigInteger("42")
    let b = try java.math.BigInteger("42")
    let c = try java.math.BigInteger("99")
    #expect(a.equals(b))
    #expect(!a.equals(c))
  }

  @Test("BigInteger can be used as Dictionary key")
  func testUsableAsDictionaryKey() throws {
    var dict: [java.math.BigInteger: String] = [:]
    let key = try java.math.BigInteger("7")
    dict[key] = "seven"
    #expect(dict[java.math.BigInteger.valueOf(7)] == "seven")
  }

  // MARK: - isProbablePrime / nextProbablePrime

  @Test("isProbablePrime for known primes and composites")
  func testIsProbablePrime() throws {
    let two   = try java.math.BigInteger("2")
    let three = try java.math.BigInteger("3")
    let four  = try java.math.BigInteger("4")
    let prime = try java.math.BigInteger("97")
    #expect((try two.isProbablePrime(10))   == true)
    #expect((try three.isProbablePrime(10)) == true)
    #expect((try four.isProbablePrime(10))  == false)
    #expect((try prime.isProbablePrime(10)) == true)
  }

  @Test("nextProbablePrime after 2 is 3")
  func testNextProbablePrime() throws {
    let two  = try java.math.BigInteger("2")
    let next = try two.nextProbablePrime()
    #expect(next == (try java.math.BigInteger("3")))
  }

  @Test("nextProbablePrime after 10 is 11")
  func testNextProbablePrimeAfterTen() throws {
    let ten  = java.math.BigInteger.TEN
    let next = try ten.nextProbablePrime()
    #expect(next == (try java.math.BigInteger("11")))
  }

  // MARK: - Swiftify: convenience initialisers

  @Test("init(int:) named parameter creates correct value")
  func testSwiftifyInitInt() {
    let v = java.math.BigInteger(int: 42)
    #expect(v == java.math.BigInteger.valueOf(42))
  }

  @Test("init(int:) negative value")
  func testSwiftifyInitIntNegative() {
    let v = java.math.BigInteger(int: -100)
    #expect(v == java.math.BigInteger.valueOf(-100))
  }

  @Test("init(long:) named parameter creates correct value")
  func testSwiftifyInitLong() {
    let v = java.math.BigInteger(long: Int64(1_000_000_000_000))
    #expect(v == java.math.BigInteger.valueOf(Int64(1_000_000_000_000)))
  }

  @Test("init(long:) Int64.min")
  func testSwiftifyInitLongMin() {
    let v = java.math.BigInteger(long: Int64.min)
    #expect(v == java.math.BigInteger.valueOf(Int64.min))
  }

  // MARK: - Swiftify: toBigDecimal

  @Test("toBigDecimal produces correct value")
  func testToBigDecimal() throws {
    let bi = try java.math.BigInteger("12345")
    let bd = bi.toBigDecimal()
    #expect(bd == (try java.math.BigDecimal("12345")))
  }

  @Test("toBigDecimal of negative")
  func testToBigDecimalNegative() throws {
    let bi = try java.math.BigInteger("-99")
    let bd = bi.toBigDecimal()
    #expect(bd == (try java.math.BigDecimal("-99")))
  }

  @Test("toBigDecimal of zero")
  func testToBigDecimalZero() {
    let bd = java.math.BigInteger.ZERO.toBigDecimal()
    #expect(bd == java.math.BigDecimal.ZERO)
  }

  // MARK: - Swiftify: BigDecimal.toBigInteger

  @Test("BigDecimal.toBigInteger truncates fractional part")
  func testBigDecimalToBigInteger() throws {
    let bd = try java.math.BigDecimal("3.99")
    #expect(bd.toBigInteger() == (try java.math.BigInteger("3")))
  }

  @Test("BigDecimal.toBigInteger of negative truncates towards zero")
  func testBigDecimalToBigIntegerNegative() throws {
    let bd = try java.math.BigDecimal("-3.99")
    #expect(bd.toBigInteger() == (try java.math.BigInteger("-3")))
  }

  // MARK: - Swiftify: Decimal.toBigInteger

  @Test("Decimal.toBigInteger converts correctly")
  func testDecimalToBigInteger() {
    let d = Decimal(42)
    #expect(d.toBigInteger() == java.math.BigInteger.valueOf(42))
  }

  // MARK: - Round-trip: BigInteger → BigDecimal → BigInteger

  @Test("BigInteger round-trip through BigDecimal preserves value")
  func testRoundTripBigDecimal() throws {
    let original = try java.math.BigInteger("987654321")
    let bd       = original.toBigDecimal()
    let restored = bd.toBigInteger()
    #expect(restored == original)
  }

  @Test("BigInteger negative round-trip through BigDecimal")
  func testRoundTripBigDecimalNegative() throws {
    let original = try java.math.BigInteger("-123456789")
    let bd       = original.toBigDecimal()
    let restored = bd.toBigInteger()
    #expect(restored == original)
  }

  // MARK: - Karatsuba regression tests

  // Regression test for WASM/32-bit overflow in Multiplication.karatsuba:
  // (op1.numberLength & 0xFFFFFFFE) << 4 overflowed Int32 on 32-bit targets.
  // Fixed by replacing 0xFFFFFFFE with ~1 (portable even-mask).
  // Note: karatsuba is only used when numberLength >= 63 (2048-bit / ~617 decimal digits).
  @Test("karatsuba multiplication does not overflow on large operands")
  func testKaratsubaLargeMultiply() throws {
    // 2048-bit operands (64 limbs each) — large enough to trigger the karatsuba path
    let a        = try java.math.BigInteger("14847236547190140739230016305701124268623922562854865046864577782021603020715755415700994755848136103324531702029791603021788700644662154729125736196800229639985828258515784678598591587122006563832907906242850158799430239946247127304266093110947840444233965310135498621078937080191117747177812330996592975476364478639579158075868855638600562757004552396582307557904843475954986656995461522673480068211205344799034612562266886464714913963230881142550969211043051109722659417729368883189242813436231864845634387538484776882578600131923535414156336617288584610582035259961099285880792615405455737505840082690095369517469")
    let b        = try java.math.BigInteger("10479847132386395849188132154762211281877868437078704432125508968762890205115159286156133021254307276346173688250448268225099182886524236896920233664944055116801218799747040676495110360450491092193925467811663734712929005464778401644898459688858733514915013016823213000354191798824555137080655509826587863774933616353680103629293959052057312235314670380584783658390711590699059907534983689537278837859456664361354663115577737358541524213893425421299237207651399230808702697414247246945616101528213601932277984967449082400303018946977574293700002755597900297945891111837049482799771218186790521144072189816032975011461")
    let expected = try java.math.BigInteger("155596769352933089658444651868866567198251471644039193398550168773148843073690962539096329080349488318250474081270200708672673918410675204418008999729837315056835043480158025911165296449483725088157114612387076568777276406824344374007606558639500473575769962491936309994228132580030599858081960690564408251387046897656367658132087800830589656624980956398251124327972060250958254563515391813007778079222840701634458925643199066534058569598484925962537905780458921541987521585804560923178013744336891406397198874090147036368532210085520660272314495025070172932826610077750168811332564449809867020718484422337191525104757165763857848226364140829607768588017112587103607005184791986746281438251403137773435532466063052601892073669001547522174267792223392226165487954855419091229117221502649936788004217864322846027969291322240959519691908658921647096656312804881041630091317718039474758208538666172052428761447021275647277176301173605736156826995125354885769396095130494469318513513272537974913920277842242175964056548520092231003230299659459306653036430767625405840120611731258478076759996630507527282092302163376855833292891466847545226007962076112760643254470308798960228398016199280399072470671889072292375893593178416725570314712209")

    let result = a.multiply(b)
    #expect(result == expected)
  }

  @Test("karatsuba multiplication is correct for powers of two")
  func testKaratsubaPowersOfTwo() throws {
    // 2^1024 * 2^1024 = 2^2048 — both operands have 33 limbs, triggers karatsuba
    let two    = try java.math.BigInteger("2")
    let pow1024 = try two.pow(1024)
    let pow2048 = try two.pow(2048)
    #expect(pow1024.multiply(pow1024) == pow2048)
  }

  // MARK: - Additional arithmetic edge cases

  @Test("add of two large negative numbers")
  func testAddLargeNegatives() throws {
    let a = try java.math.BigInteger("-999999999999")
    let b = try java.math.BigInteger("-1")
    #expect(a.add(b) == (try java.math.BigInteger("-1000000000000")))
  }

  @Test("subtract equal values yields zero")
  func testSubtractEqualValues() throws {
    let a = try java.math.BigInteger("12345678901234567890")
    #expect(a.subtract(a) == java.math.BigInteger.ZERO)
  }

  @Test("multiply ONE leaves value unchanged")
  func testMultiplyOne() throws {
    let v = try java.math.BigInteger("999")
    #expect(v.multiply(java.math.BigInteger.ONE) == v)
  }

  @Test("add ZERO leaves value unchanged")
  func testAddZero() throws {
    let v = try java.math.BigInteger("12345")
    #expect(v.add(java.math.BigInteger.ZERO) == v)
  }

  // MARK: - Additional bit operation edge cases

  @Test("xor of equal values is zero")
  func testXorEqual() throws {
    let v = try java.math.BigInteger("255")
    #expect(v.xor(v) == java.math.BigInteger.ZERO)
  }

  @Test("or with zero returns self")
  func testOrWithZero() throws {
    let v = try java.math.BigInteger("42")
    #expect(v.or(java.math.BigInteger.ZERO) == v)
  }

  @Test("and with zero returns zero")
  func testAndWithZero() throws {
    let v = try java.math.BigInteger("255")
    #expect(v.and(java.math.BigInteger.ZERO) == java.math.BigInteger.ZERO)
  }

  @Test("setBit idempotent when bit already set")
  func testSetBitAlreadySet() throws {
    let v = try java.math.BigInteger("5")   // bit 0 and bit 2 are set
    #expect((try v.setBit(0)) == v)
    #expect((try v.setBit(2)) == v)
  }

  @Test("clearBit on unset bit leaves value unchanged")
  func testClearBitUnset() throws {
    let v = try java.math.BigInteger("5")   // bit 1 is not set
    #expect((try v.clearBit(1)) == v)
  }

  // MARK: - Additional conversion edge cases

  @Test("intValue of zero is zero")
  func testIntValueZero() {
    #expect(java.math.BigInteger.ZERO.intValue() == 0)
  }

  @Test("longValue of Int64.max")
  func testLongValueMax() {
    let v = java.math.BigInteger.valueOf(Int64.max)
    #expect(v.longValue() == Int64.max)
  }

  @Test("floatValue of zero is zero")
  func testFloatValueZero() {
    #expect(java.math.BigInteger.ZERO.floatValue() == Float(0))
  }

  @Test("doubleValue of negative")
  func testDoubleValueNegative() throws {
    let v = try java.math.BigInteger("-1024")
    #expect(v.doubleValue() == -1024.0)
  }

  // MARK: - Additional init / radix edge cases

  @Test("init(String radix) base 36")
  func testInitStringBase36() throws {
    // "z" in base 36 = 35
    let v = try java.math.BigInteger("z", 36)
    #expect(v == java.math.BigInteger.valueOf(35))
  }

  @Test("init(String) with leading whitespace throws")
  func testInitStringLeadingSpace() {
    #expect(throws: NumberFormatException.self) { try java.math.BigInteger(" 1") }
  }

  // MARK: - Additional gcd / modInverse edge cases

  @Test("gcd of equal values is self")
  func testGcdEqual() throws {
    let v = try java.math.BigInteger("42")
    #expect(v.gcd(v) == v)
  }

  @Test("modInverse throws when not coprime")
  func testModInverseNotCoprime() throws {
    // gcd(4, 6) = 2 ≠ 1, no inverse exists
    let a = try java.math.BigInteger("4")
    let m = try java.math.BigInteger("6")
    #expect(throws: (any Error).self) { try a.modInverse(m) }
  }

  // MARK: - Magnitude property

  @Test("magnitude of negative equals abs")
  func testMagnitude() throws {
    let neg = try java.math.BigInteger("-42")
    let pos = try java.math.BigInteger("42")
    #expect(neg.magnitude == pos)
  }

  @Test("magnitude of positive equals self")
  func testMagnitudePositive() throws {
    let v = try java.math.BigInteger("100")
    #expect(v.magnitude == v)
  }

  // MARK: - Large number operations

  @Test("add two 100-digit numbers")
  func testAddLargeNumbers() throws {
    let a = try java.math.BigInteger("9999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999")
    let b = java.math.BigInteger.ONE
    let expected = try java.math.BigInteger("10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000")
    #expect(a.add(b) == expected)
  }

  @Test("multiply large numbers is commutative")
  func testMultiplyCommutative() throws {
    let a = try java.math.BigInteger("123456789012345678901234567890")
    let b = try java.math.BigInteger("987654321098765432109876543210")
    #expect(a.multiply(b) == b.multiply(a))
  }

  // MARK: - compareTo edge cases

  @Test("compareTo large negative vs small positive")
  func testCompareToLargeNeg() throws {
    let big  = try java.math.BigInteger("-99999999999")
    let small = java.math.BigInteger.ONE
    #expect(big.compareTo(small) < 0)
  }

  @Test("min/max with equal values returns either")
  func testMinMaxEqual() throws {
    let a = try java.math.BigInteger("42")
    let b = try java.math.BigInteger("42")
    #expect(a.min(b) == a)
    #expect(a.max(b) == a)
  }

  // MARK: - Swiftify: ExpressibleByIntegerLiteral

  @Test("ExpressibleByIntegerLiteral works for BigInteger")
  func testExpressibleByIntegerLiteral() {
    let v: java.math.BigInteger = 42
    #expect(v == java.math.BigInteger.valueOf(42))
  }

  @Test("ExpressibleByIntegerLiteral negative literal")
  func testExpressibleByIntegerLiteralNegative() {
    let v: java.math.BigInteger = -7
    #expect(v == java.math.BigInteger.valueOf(-7))
  }

  @Test("ExpressibleByIntegerLiteral zero literal")
  func testExpressibleByIntegerLiteralZero() {
    let v: java.math.BigInteger = 0
    #expect(v == java.math.BigInteger.ZERO)
  }

  // MARK: - Harmony-inspired: divide edge cases

  @Test("divide negative by negative gives positive")
  func testDivideNegNeg() throws {
    let a = try java.math.BigInteger("-20")
    let b = try java.math.BigInteger("-4")
    #expect((try a.divide(b)) == java.math.BigInteger.valueOf(5))
  }

  @Test("divide where result is zero")
  func testDivideResultZero() throws {
    let a = try java.math.BigInteger("3")
    let b = try java.math.BigInteger("10")
    #expect((try a.divide(b)) == java.math.BigInteger.ZERO)
  }

  @Test("remainder of multiple divides correctly")
  func testRemainderExact() throws {
    let a = try java.math.BigInteger("20")
    let b = try java.math.BigInteger("4")
    #expect((try a.remainder(b)) == java.math.BigInteger.ZERO)
  }

  // MARK: - Harmony-inspired: shift edge cases

  @Test("shiftLeft large value")
  func testShiftLeftLarge() throws {
    let one = java.math.BigInteger.ONE
    let shifted = one.shiftLeft(64)
    // 2^64
    let expected = try java.math.BigInteger("18446744073709551616")
    #expect(shifted == expected)
  }

  @Test("shiftRight larger than bitLength returns zero for positive")
  func testShiftRightBeyondBitLength() throws {
    let v = try java.math.BigInteger("255")   // 8 bits
    #expect(v.shiftRight(8) == java.math.BigInteger.ZERO)
  }

  // MARK: - Harmony-inspired: pow edge cases

  @Test("pow of ZERO is ZERO for any positive exp")
  func testPowOfZero() throws {
    #expect((try java.math.BigInteger.ZERO.pow(5)) == java.math.BigInteger.ZERO)
  }

  @Test("pow of ONE is always ONE")
  func testPowOfOne() throws {
    #expect((try java.math.BigInteger.ONE.pow(100)) == java.math.BigInteger.ONE)
  }

  @Test("3^5 = 243")
  func testPowThreeFive() throws {
    let three = try java.math.BigInteger("3")
    #expect((try three.pow(5)) == (try java.math.BigInteger("243")))
  }

  // MARK: - Harmony-inspired: mod edge cases

  @Test("mod equals zero when dividend divisible")
  func testModDivisible() throws {
    let a = try java.math.BigInteger("21")
    let m = try java.math.BigInteger("7")
    #expect((try a.mod(m)) == java.math.BigInteger.ZERO)
  }

  @Test("mod of zero is zero")
  func testModOfZero() throws {
    let m = try java.math.BigInteger("7")
    #expect((try java.math.BigInteger.ZERO.mod(m)) == java.math.BigInteger.ZERO)
  }

  // MARK: - Harmony-inspired: large comparisons

  @Test("large positive compared to large negative")
  func testLargePositiveVsNegative() throws {
    let pos = try java.math.BigInteger("99999999999999999999999999999")
    let neg = try java.math.BigInteger("-99999999999999999999999999999")
    #expect(pos.compareTo(neg) > 0)
    #expect(neg.compareTo(pos) < 0)
    #expect(neg < pos)
  }

  // MARK: - Harmony-inspired: number parsing

  @Test("very large decimal string parses and toString round-trips")
  func testLargeDecimalStringRoundTrip() throws {
    let s = "123456789012345678901234567890123456789012345678901234567890"
    let v = try java.math.BigInteger(s)
    #expect(v.toString() == s)
  }

  @Test("init with plus sign prefix is accepted")
  func testInitWithPlusSign() throws {
    // Note: unlike Java, our Swift implementation accepts "+" prefix via Int(string, radix:)
    let v = try java.math.BigInteger("+123")
    #expect(v == (try java.math.BigInteger("123")))
  }

  // MARK: - Harmony-inspired: double/float precision

  @Test("doubleValue of 2^53 is exact")
  func testDoubleValueLargePrime() throws {
    // 2^53 = 9007199254740992 is the largest integer exactly representable as Double
    let two   = try java.math.BigInteger("2")
    let pow53 = try two.pow(53)
    #expect(pow53.doubleValue() == 9007199254740992.0)
  }

  @Test("floatValue of negative")
  func testFloatValueNegative() throws {
    let v = try java.math.BigInteger("-100")
    #expect(v.floatValue() == Float(-100))
  }

  // MARK: - Harmony-inspired: hashCode stability

  @Test("hashCode is stable across multiple calls")
  func testHashCodeStable() throws {
    let v = try java.math.BigInteger("99999999999")
    let h1 = v.hashCode()
    let h2 = v.hashCode()
    #expect(h1 == h2)
  }

  @Test("equal values have same hashCode")
  func testHashCodeEqualValues() throws {
    let a = try java.math.BigInteger("12345678901234567890")
    let b = try java.math.BigInteger("12345678901234567890")
    #expect(a.hashCode() == b.hashCode())
  }
}
