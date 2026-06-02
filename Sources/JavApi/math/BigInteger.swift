/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: Apache-2.0
 */

import Foundation

extension java.math {

  /// Immutable arbitrary-precision integer.
  public final class BigInteger : Number, Comparable, @unchecked Sendable, AdditiveArithmetic, ExpressibleByIntegerLiteral {
    public convenience init?<T>(exactly source: T) where T : BinaryInteger {
      self.init(Int128(source))
    }
    
    
    public typealias Magnitude = java.math.BigInteger

    public typealias IntegerLiteralType = Int128
    

    // MARK: - Internal representation

    /// Little-endian array of 32-bit "digits" (stored as Int for convenience).
    var digits: [Int]
    /// Number of significant digits.
    var numberLength: Int
    /// Sign: -1, 0, or 1.
    var sign: Int

    /// Cached index of the first non-zero digit (-2 = not yet computed).
    private var _firstNonzeroDigit = -2
    /// Cached hash code.
    private var _hashCode = 0

    // MARK: - Constants

    public static let ZERO    = BigInteger(0, 0)
    public static let ONE     = BigInteger(1, 1)
    public static let TEN     = BigInteger(1, 10)
    static let MINUS_ONE      = BigInteger(-1, 1)

    /// Used for comparison results.
    static let EQUALS = 0
    static let GREATER = 1
    static let LESS = -1

    static let SMALL_VALUES: [BigInteger] = [
      ZERO, ONE, BigInteger(1, 2), BigInteger(1, 3), BigInteger(1, 4),
      BigInteger(1, 5), BigInteger(1, 6), BigInteger(1, 7), BigInteger(1, 8),
      BigInteger(1, 9), TEN
    ]

    static let TWO_POWS: [BigInteger] = {
      var arr = [BigInteger](repeating: BigInteger.ZERO, count: 32)
      for i in 0..<32 { arr[i] = BigInteger.valueOf(Int64(1) << i) }
      return arr
    }()

    // MARK: - Protocol conformances

    // AdditiveArithmetic: zero
    public static let zero = BigInteger.ZERO

    // AdditiveArithmetic: addition and subtraction
    public static func + (lhs: BigInteger, rhs: BigInteger) -> BigInteger { lhs.add(rhs) }
    public static func += (lhs: inout BigInteger, rhs: BigInteger) { lhs = lhs + rhs }
    public static func - (lhs: BigInteger, rhs: BigInteger) -> BigInteger { lhs.subtract(rhs) }
    public static func -= (lhs: inout BigInteger, rhs: BigInteger) { lhs = lhs - rhs }

    // Multiplication
    public static func * (lhs: BigInteger, rhs: BigInteger) -> BigInteger { lhs.multiply(rhs) }
    public static func *= (lhs: inout BigInteger, rhs: BigInteger) { lhs = lhs * rhs }

    // ExpressibleByIntegerLiteral: required init with concrete type
    public required convenience init(integerLiteral value: Int128) {
      self.init(value)
    }

    // Numeric: magnitude property
    public var magnitude: BigInteger { self.abs() }


    // MARK: - Initialisers (internal)

    init(_ sign: Int, _ value: Int) {
      self.sign = sign; numberLength = 1; digits = [value]
    }

    init(_ sign: Int, _ numberLength: Int, _ digits: [Int]) {
      self.sign = sign; self.numberLength = numberLength; self.digits = digits
    }

    init(_ sign: Int, _ val: Int64) {
      self.sign = sign
      if (val & Int64(bitPattern: 0xFFFFFFFF00000000)) == 0 {
        numberLength = 1; digits = [Int(val)]
      } else {
        numberLength = 2; digits = [Int(val & 0xFFFFFFFF), Int(val >> 32)]
      }
    }

    init(_ signum: Int, _ digitArray: [Int]) {
      if digitArray.isEmpty {
        sign = 0; numberLength = 1; digits = [0]
      } else {
        sign = signum; numberLength = digitArray.count; digits = digitArray
        cutOffLeadingZeroes()
      }
    }

    /// Converts an `Int128` value to BigInteger.
    convenience init(_ value: Int128) {
      if value == 0 { self.init(0, 0); return }
      let s = value < 0 ? -1 : 1
      // magnitude as UInt128
      var u: UInt128 = value < 0
        ? (~UInt128(bitPattern: value) &+ 1)   // two's complement negation
        : UInt128(bitPattern: value)
      var d: [Int] = []
      while u > 0 {
        d.append(Int(u & 0xFFFFFFFF))           // lower 32 bits as positive Int
        u >>= 32
      }
      self.init(s, d.count, d)
    }

    // MARK: - Public initialisers

    public init(_ numBits: Int, _ rnd: java.util.Random) throws(IllegalArgumentException) {
      guard numBits >= 0 else { throw IllegalArgumentException("numBits must be non-negative") }
      if numBits == 0 {
        sign = 0; numberLength = 1; digits = [0]
      } else {
        sign = 1; numberLength = (numBits + 31) >> 5
        digits = [Int](repeating: 0, count: numberLength)
        for i in 0..<numberLength { digits[i] = rnd.nextInt() }
        // Keep only the necessary bits in the top digit
        let shift = (-numBits) & 31
        if shift > 0 {
          digits[numberLength - 1] = Int(UInt32(truncatingIfNeeded: digits[numberLength - 1]) >> shift)
        }
        cutOffLeadingZeroes()
      }
    }

    public init(_ bitLength: Int, _ certainty: Int, _ rnd: java.util.Random) throws {
      guard bitLength >= 2 else { throw ArithmeticException("bitLength < 2") }
      let me = try Primality.consBigInteger(bitLength, certainty, rnd)
      sign = me.sign; numberLength = me.numberLength; digits = me.digits
    }

    public convenience init(_ val: String) throws(NumberFormatException) {
      try self.init(val, 10)
    }

    public init(_ val: String, _ radix: Int) throws(NumberFormatException) {
      guard radix >= 2 && radix <= 36 else { throw NumberFormatException("Radix out of range") }
      guard !val.isEmpty else { throw NumberFormatException("Zero length BigInteger") }
      sign = 0; numberLength = 0; digits = []
      try Conversion.setFromString(self, val, radix)
    }

    public init(_ signum: Int, _ magnitude: [UInt8]) throws(NumberFormatException) {
      guard signum >= -1 && signum <= 1 else { throw NumberFormatException("Invalid signum value") }
      if signum == 0 {
        for b in magnitude where b != 0 { throw NumberFormatException("signum-magnitude mismatch") }
      }
      if magnitude.isEmpty {
        sign = 0; numberLength = 1; digits = [0]
      } else {
        sign = signum; numberLength = 0; digits = []
        putBytesPositiveToIntegers(magnitude)
        cutOffLeadingZeroes()
      }
    }

    public init(_ val: [UInt8]) throws(NumberFormatException) {
      guard !val.isEmpty else { throw NumberFormatException("Zero length BigInteger") }
      numberLength = 0; digits = []
      if val[0] > 127 {
        sign = -1; putBytesNegativeToIntegers(val)
      } else {
        sign = 1; putBytesPositiveToIntegers(val)
      }
      cutOffLeadingZeroes()
    }

    // MARK: - Factory

    public static func valueOf(_ val: Int64) -> BigInteger {
      if val < 0 { return val != -1 ? BigInteger(-1, -val) : MINUS_ONE }
      if val <= 10 { return SMALL_VALUES[Int(val)] }
      return BigInteger(1, val)
    }

    // MARK: - Byte array

    public func toByteArray() -> [UInt8] {
      if sign == 0 { return [0] }
      let bitLen = bitLength()
      let iThis = getFirstNonzeroDigit()
      var bytesLen = (bitLen >> 3) + 1
      var bytes = [UInt8](repeating: 0, count: bytesLen)
      var firstByteNumber = 0
      let highBytes: Int
      var digitIndex: Int
      var bytesInInteger = 4
      if bytesLen - (numberLength << 2) == 1 {
        bytes[0] = sign < 0 ? 0xFF : 0
        highBytes = 4; firstByteNumber = 1
      } else {
        let hB = bytesLen & 3
        highBytes = hB == 0 ? 4 : hB
      }
      digitIndex = iThis
      bytesLen -= iThis << 2
      if sign < 0 {
        var digit = -digits[digitIndex]; digitIndex += 1
        if digitIndex == numberLength { bytesInInteger = highBytes }
        for _ in 0..<bytesInInteger { bytesLen -= 1; bytes[bytesLen] = UInt8(truncatingIfNeeded: digit); digit >>= 8 }
        while bytesLen > firstByteNumber {
          var d = ~digits[digitIndex]; digitIndex += 1
          if digitIndex == numberLength { bytesInInteger = highBytes }
          for _ in 0..<bytesInInteger { bytesLen -= 1; bytes[bytesLen] = UInt8(truncatingIfNeeded: d); d >>= 8 }
        }
      } else {
        while bytesLen > firstByteNumber {
          var digit = digits[digitIndex]; digitIndex += 1
          if digitIndex == numberLength { bytesInInteger = highBytes }
          for _ in 0..<bytesInInteger { bytesLen -= 1; bytes[bytesLen] = UInt8(truncatingIfNeeded: digit); digit >>= 8 }
        }
      }
      return bytes
    }

    // MARK: - Arithmetic

    public func abs() -> BigInteger {
      return sign < 0 ? BigInteger(1, numberLength, digits) : self
    }

    public func negate() -> BigInteger {
      return sign == 0 ? self : BigInteger(-sign, numberLength, digits)
    }

    public func add(_ val: BigInteger) -> BigInteger {
      return Elementary.add(self, val)
    }

    public func subtract(_ val: BigInteger) -> BigInteger {
      return Elementary.subtract(self, val)
    }

    public func multiply(_ val: BigInteger) -> BigInteger {
      if val.sign == 0 || sign == 0 { return BigInteger.ZERO }
      return Multiplication.multiply(self, val)
    }

    public func divide(_ divisor: BigInteger) throws(ArithmeticException) -> BigInteger {
      if divisor.sign == 0 { throw ArithmeticException("BigInteger divide by zero") }
      if divisor.isOne() { return divisor.sign > 0 ? self : self.negate() }
      let thisSign = sign, thisLen = numberLength, divisorLen = divisor.numberLength
      if thisLen + divisorLen == 2 {
        let val = (Int64(digits[0]) & 0xFFFFFFFF) / (Int64(divisor.digits[0]) & 0xFFFFFFFF)
        return BigInteger.valueOf(thisSign != divisor.sign ? -val : val)
      }
      let cmp = thisLen != divisorLen
        ? (thisLen > divisorLen ? 1 : -1)
        : Elementary.compareArrays(digits, divisor.digits, thisLen)
      if cmp == BigInteger.EQUALS { return thisSign == divisor.sign ? BigInteger.ONE : BigInteger.MINUS_ONE }
      if cmp == BigInteger.LESS { return BigInteger.ZERO }
      let resLength = thisLen - divisorLen + 1
      var resDigits = [Int](repeating: 0, count: resLength)
      let resSign = thisSign == divisor.sign ? 1 : -1
      if divisorLen == 1 {
        Division.divideArrayByInt(&resDigits, digits, thisLen, divisor.digits[0])
      } else {
        var nil_quot: [Int]? = resDigits
        Division.divide(&nil_quot, resLength, digits, thisLen, divisor.digits, divisorLen)
        resDigits = nil_quot!
      }
      let result = BigInteger(resSign, resLength, resDigits)
      result.cutOffLeadingZeroes()
      return result
    }

    public func remainder(_ divisor: BigInteger) throws(ArithmeticException) -> BigInteger {
      if divisor.sign == 0 { throw ArithmeticException("BigInteger divide by zero") }
      let thisLen = numberLength, divisorLen = divisor.numberLength
      let cmp = thisLen != divisorLen
        ? (thisLen > divisorLen ? 1 : -1)
        : Elementary.compareArrays(digits, divisor.digits, thisLen)
      if cmp == BigInteger.LESS { return self }
      var resDigits = [Int](repeating: 0, count: divisorLen)
      if divisorLen == 1 {
        resDigits[0] = Division.remainderArrayByInt(digits, thisLen, divisor.digits[0])
      } else {
        let qLen = thisLen - divisorLen + 1
        var nil_quot: [Int]? = nil
        resDigits = Division.divide(&nil_quot, qLen, digits, thisLen, divisor.digits, divisorLen)
      }
      let result = BigInteger(sign, divisorLen, resDigits)
      result.cutOffLeadingZeroes()
      return result
    }

    public func divideAndRemainder(_ divisor: BigInteger) throws(ArithmeticException) -> [BigInteger] {
      if divisor.sign == 0 { throw ArithmeticException("BigInteger divide by zero") }
      let divisorLen = divisor.numberLength
      if divisorLen == 1 {
        return Division.divideAndRemainderByInteger(self, divisor.digits[0], divisor.sign)
      }
      let cmp = numberLength != divisorLen
        ? (numberLength > divisorLen ? 1 : -1)
        : Elementary.compareArrays(digits, divisor.digits, numberLength)
      if cmp < 0 { return [BigInteger.ZERO, self] }
      let quotientLength = numberLength - divisorLen + 1
      let quotientSign = sign == divisor.sign ? 1 : -1
      var quotientDigits = [Int](repeating: 0, count: quotientLength)
      var quot: [Int]? = quotientDigits
      let remainderDigits = Division.divide(&quot, quotientLength, digits, numberLength, divisor.digits, divisorLen)
      quotientDigits = quot!
      let result0 = BigInteger(quotientSign, quotientLength, quotientDigits)
      let result1 = BigInteger(sign, divisorLen, remainderDigits)
      result0.cutOffLeadingZeroes()
      result1.cutOffLeadingZeroes()
      return [result0, result1]
    }

    public func mod(_ m: BigInteger) throws(ArithmeticException) -> BigInteger {
      if m.sign <= 0 { throw ArithmeticException("BigInteger: modulus not positive") }
      let rem = try remainder(m)
      return rem.sign < 0 ? rem.add(m) : rem
    }

    public func pow(_ exp: Int) throws(ArithmeticException) -> BigInteger {
      guard exp >= 0 else { throw ArithmeticException("Negative exponent") }
      if exp == 0 { return BigInteger.ONE }
      if exp == 1 || equals(BigInteger.ONE as AnyObject) || equals(BigInteger.ZERO as AnyObject) { return self }
      if try !testBit(0) {
        var x = 1
        while try !testBit(x) {
          x += 1
        }
        return try BigInteger.getPowerOfTwo(x * exp).multiply(self.shiftRight(x).pow(exp))
      }
      return Multiplication.pow(self, exp)
    }

    public func gcd(_ val: BigInteger) -> BigInteger {
      let val1 = self.abs()
      let val2 = val.abs()
      if val1.signum() == 0 { return val2 }
      if val2.signum() == 0 { return val1 }
      if (val1.numberLength == 1 || (val1.numberLength == 2 && val1.digits[1] > 0))
          && (val2.numberLength == 1 || (val2.numberLength == 2 && val2.digits[1] > 0)) {
        return BigInteger.valueOf(Division.gcdBinary(val1.longValue(), val2.longValue()))
      }
      return Division.gcdBinary(val1.copy(), val2.copy())
    }

    public func modInverse(_ m: BigInteger) throws  -> BigInteger {
      if m.sign <= 0 { throw ArithmeticException("BigInteger: modulus not positive") }
      let test1 = try testBit (0)
      let test2 = try m.testBit(0)
      if !((test1) || test2) { throw ArithmeticException("BigInteger not invertible.") }
      if m.isOne() { return BigInteger.ZERO }
      var res = try Division.modInverseMontgomery(try abs().mod(m), m)
      if res.sign == 0 { throw ArithmeticException("BigInteger not invertible.") }
      res = sign < 0 ? m.subtract(res) : res
      return res
    }

    public func modPow(_ exponent: BigInteger, _ m: BigInteger) throws -> BigInteger {
      var exponent = exponent
      if m.sign <= 0 { throw ArithmeticException("BigInteger: modulus not positive") }
      var base = self
      if m.isOne() || (exponent.sign > 0 && base.sign == 0) { return BigInteger.ZERO }
      if exponent.sign == 0 { return try BigInteger.ONE.mod(m) }
      if exponent.sign < 0 { base = try modInverse(m); exponent = exponent.negate() }
      let res = try m.testBit(0)
        ? try Division.oddModPow(base.abs(), exponent, m)
        : try Division.evenModPow(base.abs(), exponent, m)
      let rightTest = try exponent.testBit(0)
      if base.sign < 0 && rightTest {
        return try m.subtract(BigInteger.ONE).multiply(res).mod(m)
      }
      return res
    }

    // MARK: - Bit operations

    public func signum() -> Int { return sign }

    public func bitLength() -> Int { return BitLevel.bitLength(self) }

    public func bitCount() -> Int { return BitLevel.bitCount(self) }

    public func testBit(_ n: Int) throws (ArithmeticException) -> Bool {
      if n < 0 { throw ArithmeticException("Negative bit address") }
      if n == 0 { return (digits[0] & 1) != 0 }
      let intCount = n >> 5
      if intCount >= numberLength { return sign < 0 }
      var digit = digits[intCount]
      let bit = 1 << (n & 31)
      if sign < 0 {
        let fnz = getFirstNonzeroDigit()
        if intCount < fnz { return false }
        if fnz == intCount { digit = -digit } else { digit = ~digit }
      }
      return (digit & bit) != 0
    }

    public func setBit(_ n: Int) throws(ArithmeticException) -> BigInteger {
      if n < 0 { throw ArithmeticException("Negative bit address") }
      if try !testBit(n) { return BitLevel.flipBit(self, n) }
      return self
    }

    public func clearBit(_ n: Int) throws(ArithmeticException) -> BigInteger {
      if n < 0 { throw ArithmeticException("Negative bit address") }
      if try testBit(n) { return BitLevel.flipBit(self, n) }
      return self
    }

    public func flipBit(_ n: Int) throws(ArithmeticException) -> BigInteger {
      if n < 0 { throw ArithmeticException("Negative bit address") }
      return BitLevel.flipBit(self, n)
    }

    public func getLowestSetBit() -> Int {
      if sign == 0 { return -1 }
      let i = getFirstNonzeroDigit()
      return (i << 5) + Int64.numberOfTrailingZerosInt(digits[i])
    }

    public func shiftRight(_ n: Int) -> BigInteger {
      if n == 0 || sign == 0 { return self }
      return n > 0 ? BitLevel.shiftRight(self, n) : BitLevel.shiftLeft(self, -n)
    }

    public func shiftLeft(_ n: Int) -> BigInteger {
      if n == 0 || sign == 0 { return self }
      return n > 0 ? BitLevel.shiftLeft(self, n) : BitLevel.shiftRight(self, -n)
    }

    func shiftLeftOneBit() -> BigInteger {
      return sign == 0 ? self : BitLevel.shiftLeftOneBit(self)
    }

    // MARK: - Logical operations

    public func not() -> BigInteger { return Logical.not(self) }
    public func and(_ val: BigInteger) -> BigInteger { return Logical.and(self, val) }
    public func or(_ val: BigInteger) -> BigInteger { return Logical.or(self, val) }
    public func xor(_ val: BigInteger) -> BigInteger { return Logical.xor(self, val) }
    public func andNot(_ val: BigInteger) -> BigInteger { return Logical.andNot(self, val) }

    // MARK: - Conversion

    public func intValue() -> Int { return sign * digits[0] }

    public func longValue() -> Int64 {
      let value: Int64 = numberLength > 1
        ? (Int64(digits[1]) << 32) | (Int64(digits[0]) & 0xFFFFFFFF)
        : Int64(digits[0]) & 0xFFFFFFFF
      return Int64(sign) * value
    }

    public func floatValue() -> Float { return Float(doubleValue()) }

    public func doubleValue() -> Double { return Conversion.bigInteger2Double(self) }

    // MARK: - Comparison

    public func compareTo(_ val: BigInteger) -> Int {
      if sign > val.sign { return BigInteger.GREATER }
      if sign < val.sign { return BigInteger.LESS }
      if numberLength > val.numberLength { return sign }
      if numberLength < val.numberLength { return -val.sign }
      return sign * Elementary.compareArrays(digits, val.digits, numberLength)
    }

    public static func < (lhs: BigInteger, rhs: BigInteger) -> Bool { lhs.compareTo(rhs) < 0 }

    public func min(_ val: BigInteger) -> BigInteger {
      return compareTo(val) <= BigInteger.EQUALS ? self : val
    }

    public func max(_ val: BigInteger) -> BigInteger {
      return compareTo(val) >= BigInteger.EQUALS ? self : val
    }

    // MARK: - Equality & Hashing

    public func hashCode() -> Int {
      if _hashCode != 0 { return _hashCode }
      var h = 0
      for d in digits { h = h &* 31 &+ d }
      _hashCode = h
      return h
    }

    public func hash(into hasher: inout Hasher) {
      hasher.combine(sign)
      for i in 0..<numberLength { hasher.combine(digits[i]) }
    }

    public var hashValue: Int {
      var h = Hasher()
      hash(into: &h)
      return h.finalize()
    }

    public func equals(_ x: AnyObject) -> Bool {
      guard let other = x as? BigInteger else { return false }
      if sign != other.sign || numberLength != other.numberLength { return false }
      return equalsArrays(other.digits)
    }

    public static func == (lhs: BigInteger, rhs: BigInteger) -> Bool { lhs.equals(rhs) }

    func equalsArrays(_ b: [Int]) -> Bool {
      for i in 0..<numberLength { if digits[i] != b[i] { return false } }
      return true
    }

    // MARK: - String representation

    public func toString() -> String { return Conversion.bigInteger2String(self, 10) }

    public func toString(_ radix: Int) -> String { return Conversion.bigInteger2String(self, radix) }

    // MARK: - Primality

    public func isProbablePrime(_ certainty: Int) throws -> Bool { return try Primality.isProbablePrime(abs(), certainty)
    }

    public func nextProbablePrime() throws  -> BigInteger {
      if sign < 0 { throw ArithmeticException("start < 0: \(toString())") }
      return try Primality.nextProbablePrime(self)
    }

    public static func probablePrime(_ bitLength: Int, _ rnd: java.util.Random) -> BigInteger {
      return try! BigInteger(bitLength, 100, rnd)
    }

    // MARK: - Internal helpers

    final func cutOffLeadingZeroes() {
      while numberLength > 0 && digits[numberLength - 1] == 0 { numberLength -= 1 }
      if numberLength == 0 || digits[numberLength] == 0 { sign = 0 }
      // Ensure numberLength >= 1
      if numberLength == 0 { numberLength = 1 }
    }

    func isOne() -> Bool { return numberLength == 1 && digits[0] == 1 }

    func getFirstNonzeroDigit() -> Int {
      if _firstNonzeroDigit != -2 { return _firstNonzeroDigit }
      if sign == 0 { _firstNonzeroDigit = -1; return -1 }
      var i = 0; while digits[i] == 0 { i += 1 }
      _firstNonzeroDigit = i
      return i
    }

    func copy() -> BigInteger {
      var copyDigits = [Int](repeating: 0, count: numberLength)
      System.arraycopy(digits, 0, &copyDigits, 0, numberLength)
      return BigInteger(sign, numberLength, copyDigits)
    }

    func unCache() { _firstNonzeroDigit = -2 }

    static func getPowerOfTwo(_ exp: Int) -> BigInteger {
      if exp < TWO_POWS.count { return TWO_POWS[exp] }
      let intCount = exp >> 5, bitN = exp & 31
      var resDigits = [Int](repeating: 0, count: intCount + 1)
      resDigits[intCount] = 1 << bitN
      return BigInteger(1, intCount + 1, resDigits)
    }

    // MARK: - Private byte helpers

    private func putBytesPositiveToIntegers(_ byteValues: [UInt8]) {
      var bytesLen = byteValues.count
      let highBytes = bytesLen & 3
      numberLength = (bytesLen >> 2) + (highBytes == 0 ? 0 : 1)
      digits = [Int](repeating: 0, count: numberLength)
      var i = 0
      while bytesLen > highBytes {
        digits[i] = (Int(byteValues[bytesLen - 1]) & 0xFF)
                  | (Int(byteValues[bytesLen - 2]) & 0xFF) << 8
                  | (Int(byteValues[bytesLen - 3]) & 0xFF) << 16
                  | (Int(byteValues[bytesLen - 4]) & 0xFF) << 24
        bytesLen -= 4; i += 1
      }
      for j in 0..<highBytes {
        digits[i] = (digits[i] << 8) | (Int(byteValues[j]) & 0xFF)
      }
    }

    private func putBytesNegativeToIntegers(_ byteValues: [UInt8]) {
      var bytesLen = byteValues.count
      let highBytes = bytesLen & 3
      numberLength = (bytesLen >> 2) + (highBytes == 0 ? 0 : 1)
      digits = [Int](repeating: 0, count: numberLength)
      digits[numberLength - 1] = -1
      var i = 0
      var nonzeroFound = false
      while bytesLen > highBytes {
        let d = (Int(byteValues[bytesLen - 1]) & 0xFF)
              | (Int(byteValues[bytesLen - 2]) & 0xFF) << 8
              | (Int(byteValues[bytesLen - 3]) & 0xFF) << 16
              | (Int(byteValues[bytesLen - 4]) & 0xFF) << 24
        bytesLen -= 4
        if !nonzeroFound && d != 0 {
          digits[i] = -d; nonzeroFound = true; _firstNonzeroDigit = i; i += 1
          while bytesLen > highBytes {
            let d2 = (Int(byteValues[bytesLen - 1]) & 0xFF)
                   | (Int(byteValues[bytesLen - 2]) & 0xFF) << 8
                   | (Int(byteValues[bytesLen - 3]) & 0xFF) << 16
                   | (Int(byteValues[bytesLen - 4]) & 0xFF) << 24
            bytesLen -= 4
            digits[i] = ~d2; i += 1
          }
          break
        }
        digits[i] = d; i += 1
      }
      if highBytes != 0 {
        var d = 0
        for j in 0..<highBytes { d = (d << 8) | (Int(byteValues[j]) & 0xFF) }
        digits[i] = nonzeroFound ? ~d : -d
      }
    }
  }
}

// MARK: - Trailing zeros helper for Int64

extension Int64 {
  static func numberOfTrailingZerosInt(_ value: Int) -> Int {
    if value == 0 { return 32 }
    var v = UInt32(truncatingIfNeeded: value)
    var count = 0
    while (v & 1) == 0 { v >>= 1; count += 1 }
    return count
  }
}
