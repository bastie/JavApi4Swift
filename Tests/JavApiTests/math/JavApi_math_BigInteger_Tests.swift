/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

struct JavApi_math_BigInteger_Tests {

  // MARK: - Constants

  @Test("ZERO, ONE, TEN constants")
  func testConstants() throws {
    #expect(java.math.BigInteger.ZERO == (try java.math.BigInteger("0")))
    #expect(java.math.BigInteger.ONE  == (try java.math.BigInteger("1")))
    #expect(java.math.BigInteger.TEN  == (try java.math.BigInteger("10")))
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

  @Test("init(String radix) parses hex and binary")
  func testInitStringRadix() throws {
    let hex = try java.math.BigInteger("FF", 16)
    #expect(hex == (try java.math.BigInteger("255")))
    let bin = try java.math.BigInteger("1010", 2)
    #expect(bin == (try java.math.BigInteger("10")))
  }

  // MARK: - valueOf

  @Test("valueOf(Int64) matches String init")
  func testValueOf() throws {
    let v   = java.math.BigInteger.valueOf(999)
    #expect(v == (try java.math.BigInteger("999")))
    let neg = java.math.BigInteger.valueOf(-1)
    #expect(neg == (try java.math.BigInteger("-1")))
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

  @Test("operator overloads +, -, * are consistent with methods")
  func testOperators() throws {
    let a = try java.math.BigInteger("50")
    let b = try java.math.BigInteger("50")
    #expect(a + b == (try java.math.BigInteger("100")))
    #expect(a - b == java.math.BigInteger.ZERO)
    #expect(a * b == (try java.math.BigInteger("2500")))
  }

  @Test("divide and remainder")
  func testDivideRemainder() throws {
    let a = try java.math.BigInteger("17")
    let b = try java.math.BigInteger("5")
    #expect((try a.divide(b))    == (try java.math.BigInteger("3")))
    #expect((try a.remainder(b)) == (try java.math.BigInteger("2")))
  }

  @Test("divide by zero throws ArithmeticException")
  func testDivideByZero() throws {
    let a = try java.math.BigInteger("1")
    #expect(throws: ArithmeticException.self) { try a.divide(java.math.BigInteger.ZERO) }
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

  // MARK: - pow / gcd / mod

  @Test("pow: 2^10 = 1024")
  func testPow() throws {
    let two = try java.math.BigInteger("2")
    #expect((try two.pow(10)) == (try java.math.BigInteger("1024")))
  }

  @Test("gcd of 12 and 8 is 4")
  func testGcd() throws {
    let a = try java.math.BigInteger("12")
    let b = try java.math.BigInteger("8")
    #expect(a.gcd(b) == (try java.math.BigInteger("4")))
  }

  @Test("mod: 17 mod 5 = 2")
  func testMod() throws {
    let a = try java.math.BigInteger("17")
    let m = try java.math.BigInteger("5")
    #expect((try a.mod(m)) == (try java.math.BigInteger("2")))
  }

  @Test("mod with zero modulus throws ArithmeticException")
  func testModByZero() throws {
    let a = try java.math.BigInteger("5")
    #expect(throws: ArithmeticException.self) { try a.mod(java.math.BigInteger.ZERO) }
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

  // MARK: - Bit operations

  @Test("bitLength")
  func testBitLength() throws {
    #expect(java.math.BigInteger.ZERO.bitLength()              == 0)
    #expect(java.math.BigInteger.ONE.bitLength()               == 1)
    #expect((try java.math.BigInteger("255")).bitLength()      == 8)
    #expect((try java.math.BigInteger("256")).bitLength()      == 9)
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

  @Test("shiftLeft and shiftRight")
  func testShift() throws {
    let v = try java.math.BigInteger("1")
    #expect(v.shiftLeft(4)  == (try java.math.BigInteger("16")))
    #expect(v.shiftLeft(8)  == (try java.math.BigInteger("256")))
    let w = try java.math.BigInteger("256")
    #expect(w.shiftRight(4) == (try java.math.BigInteger("16")))
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

  // MARK: - toString(radix)

  @Test("toString(radix) for hex and binary")
  func testToStringRadix() throws {
    let v = try java.math.BigInteger("255")
    #expect(v.toString(16).lowercased() == "ff")
    #expect(v.toString(2)               == "11111111")
    #expect(v.toString(10)              == "255")
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

  // MARK: - intValue / longValue / doubleValue

  @Test("intValue and longValue for small numbers")
  func testConversionToInt() throws {
    let v = try java.math.BigInteger("42")
    #expect(v.intValue()  == 42)
    #expect(v.longValue() == 42)
  }

  @Test("doubleValue for large power of two")
  func testDoubleValue() throws {
    let two   = try java.math.BigInteger("2")
    let pow30 = try two.pow(30)   // 2^30 = 1_073_741_824
    #expect(pow30.doubleValue() == Double(1 << 30))
  }

  // MARK: - Equatable / Hashable

  @Test("equal BigIntegers have equal hash")
  func testEquatableHashable() throws {
    let a = try java.math.BigInteger("999")
    let b = try java.math.BigInteger("999")
    #expect(a == b)
    #expect(a.hashValue == b.hashValue)
  }

  @Test("BigInteger can be used as Dictionary key")
  func testUsableAsDictionaryKey() throws {
    var dict: [java.math.BigInteger: String] = [:]
    let key = try java.math.BigInteger("7")
    dict[key] = "seven"
    #expect(dict[java.math.BigInteger.valueOf(7)] == "seven")
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
}
