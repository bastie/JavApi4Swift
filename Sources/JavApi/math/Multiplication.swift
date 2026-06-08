/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: Apache-2.0
 */

extension java.math {

  enum Multiplication {

    // MARK: - Constants

    static let whenUseKaratsuba = 63

    static let tenPows: [Int] = [
      1, 10, 100, 1000, 10000, 100000, 1000000, 10000000, 100000000, 1000000000
    ]

    static let fivePows: [Int] = [
      1, 5, 25, 125, 625, 3125, 15625, 78125, 390625,
      1953125, 9765625, 48828125, 244140625, 1220703125
    ]

    static let bigTenPows: [BigInteger] = {
      var arr = [BigInteger](repeating: BigInteger.ZERO, count: 32)
      var fivePow: Int64 = 1
      for i in 0...18 {
        arr[i] = BigInteger.valueOf(fivePow << Int64(i))
        if i < 18 { fivePow *= 5 }
      }
      // fivePow already multiplied 18 times at this point; recalc bigFivePows[1]
      // We need bigFivePows[1] = 5, bigFivePows[i] = 5^i
      // Use: bigTenPows[i] = bigTenPows[i-1] * 10 for i >= 19
      for i in 19..<32 {
        arr[i] = arr[i - 1].multiply(BigInteger.TEN)
      }
      return arr
    }()

    static let bigFivePows: [BigInteger] = {
      var arr = [BigInteger](repeating: BigInteger.ZERO, count: 32)
      var fivePow: Int64 = 1
      for i in 0...18 {
        arr[i] = BigInteger.valueOf(fivePow)
        fivePow *= 5
      }
      for i in 19..<32 {
        arr[i] = arr[i - 1].multiply(arr[1])
      }
      return arr
    }()

    // MARK: - Multiply

    static func multiply(_ x: BigInteger, _ y: BigInteger) -> BigInteger {
      return karatsuba(x, y)
    }

    static func karatsuba(_ op1: BigInteger, _ op2: BigInteger) -> BigInteger {
      var op1 = op1, op2 = op2
      if op2.numberLength > op1.numberLength { swap(&op1, &op2) }
      if op2.numberLength < whenUseKaratsuba { return multiplyPAP(op1, op2) }

      let ndiv2 = (op1.numberLength & ~1) << 4
      let upperOp1 = op1.shiftRight(ndiv2)
      let upperOp2 = op2.shiftRight(ndiv2)
      let lowerOp1 = op1.subtract(upperOp1.shiftLeft(ndiv2))
      let lowerOp2 = op2.subtract(upperOp2.shiftLeft(ndiv2))

      let upper  = karatsuba(upperOp1, upperOp2)
      let lower  = karatsuba(lowerOp1, lowerOp2)
      var middle = karatsuba(upperOp1.subtract(lowerOp1), lowerOp2.subtract(upperOp2))
      middle = middle.add(upper).add(lower)
      middle = middle.shiftLeft(ndiv2)
      let upperShifted = upper.shiftLeft(ndiv2 << 1)
      return upperShifted.add(middle).add(lower)
    }

    static func multiplyPAP(_ a: BigInteger, _ b: BigInteger) -> BigInteger {
      let aLen = a.numberLength
      let bLen = b.numberLength
      let resLength = aLen + bLen
      let resSign = a.sign != b.sign ? -1 : 1
      if resLength == 2 {
        let val = unsignedMultAddAdd(a.digits[0], b.digits[0], 0, 0)
        let lo = Int(UInt32(truncatingIfNeeded: val))
        let hi = Int(UInt32(truncatingIfNeeded: val >> 32))
        return hi == 0
          ? BigInteger(resSign, lo)
          : BigInteger(resSign, 2, [lo, hi])
      }
      var resDigits = [Int](repeating: 0, count: resLength)
      multArraysPAP(a.digits, aLen, b.digits, bLen, &resDigits)
      let result = BigInteger(resSign, resLength, resDigits)
      result.cutOffLeadingZeroes()
      return result
    }

    static func multArraysPAP(_ aDigits: [Int], _ aLen: Int,
                               _ bDigits: [Int], _ bLen: Int,
                               _ resDigits: inout [Int]) {
      if aLen == 0 || bLen == 0 { return }
      if aLen == 1 {
        resDigits[bLen] = multiplyByInt(&resDigits, bDigits, bLen, aDigits[0])
      } else if bLen == 1 {
        resDigits[aLen] = multiplyByInt(&resDigits, aDigits, aLen, bDigits[0])
      } else {
        multPAP(aDigits, bDigits, &resDigits, aLen, bLen)
      }
    }

    static func multPAP(_ a: [Int], _ b: [Int], _ t: inout [Int],
                         _ aLen: Int, _ bLen: Int) {
      if a as AnyObject === b as AnyObject && aLen == bLen {
        square(a, aLen, &t)
        return
      }
      for i in 0..<aLen {
        var carry: Int64 = 0
        let aI = a[i]
        for j in 0..<bLen {
          carry = unsignedMultAddAdd(aI, b[j], t[i + j], Int(truncatingIfNeeded: carry))
          t[i + j] = Int(UInt32(truncatingIfNeeded: carry))
          carry = Int64(bitPattern: UInt64(bitPattern: carry) >> 32)
        }
        t[i + bLen] = Int(UInt32(truncatingIfNeeded: carry))
      }
    }

    @discardableResult
    private static func multiplyByInt(_ res: inout [Int], _ a: [Int],
                                       _ aSize: Int, _ factor: Int) -> Int {
      var carry: Int64 = 0
      for i in 0..<aSize {
        carry = unsignedMultAddAdd(a[i], factor, Int(truncatingIfNeeded: carry), 0)
        res[i] = Int(UInt32(truncatingIfNeeded: carry))
        carry = Int64(bitPattern: UInt64(bitPattern: carry) >> 32)
      }
      return Int(UInt32(truncatingIfNeeded: carry))
    }

    @discardableResult
    static func multiplyByInt(_ a: inout [Int], _ aSize: Int, _ factor: Int) -> Int {
      return multiplyByInt(&a, a, aSize, factor)
    }

    static func multiplyByPositiveInt(_ val: BigInteger, _ factor: Int) -> BigInteger {
      let resSign = val.sign
      if resSign == 0 { return BigInteger.ZERO }
      let aLen = val.numberLength
      if aLen == 1 {
        let res = unsignedMultAddAdd(val.digits[0], factor, 0, 0)
        let lo = Int(UInt32(truncatingIfNeeded: res))
        let hi = Int(UInt32(truncatingIfNeeded: res >> 32))
        return hi == 0
          ? BigInteger(resSign, lo)
          : BigInteger(resSign, 2, [lo, hi])
      }
      var resDigits = [Int](repeating: 0, count: aLen + 1)
      resDigits[aLen] = multiplyByInt(&resDigits, val.digits, aLen, factor)
      let result = BigInteger(resSign, aLen + 1, resDigits)
      result.cutOffLeadingZeroes()
      return result
    }

    static func pow(_ base: BigInteger, _ exponent: Int) -> BigInteger {
      var exponent = exponent
      var res = BigInteger.ONE
      var acc = base
      while exponent > 1 {
        if (exponent & 1) != 0 { res = res.multiply(acc) }
        if acc.numberLength == 1 {
          acc = acc.multiply(acc)
        } else {
          var sq = [Int](repeating: 0, count: acc.numberLength << 1)
          sq = square(acc.digits, acc.numberLength, &sq)
          acc = BigInteger(1, sq.count, sq)
        }
        exponent >>= 1
      }
      return res.multiply(acc)
    }

    @discardableResult
    static func square(_ a: [Int], _ aLen: Int, _ res: inout [Int]) -> [Int] {
      for i in 0..<aLen {
        var carry: Int64 = 0
        for j in (i + 1)..<aLen {
          carry = unsignedMultAddAdd(a[i], a[j], res[i + j], Int(truncatingIfNeeded: carry))
          res[i + j] = Int(UInt32(truncatingIfNeeded: carry))
          carry = Int64(bitPattern: UInt64(bitPattern: carry) >> 32)
        }
        res[i + aLen] = Int(UInt32(truncatingIfNeeded: carry))
      }
      BitLevel.shiftLeftOneBit(&res, res, aLen << 1)
      var carry: Int64 = 0
      var index = 0
      for i in 0..<aLen {
        carry = unsignedMultAddAdd(a[i], a[i], res[index], Int(truncatingIfNeeded: carry))
        res[index] = Int(UInt32(truncatingIfNeeded: carry))
        carry = Int64(bitPattern: UInt64(bitPattern: carry) >> 32)
        index += 1
        carry += Int64(res[index]) & 0xFFFFFFFF
        res[index] = Int(UInt32(truncatingIfNeeded: carry))
        carry = Int64(bitPattern: UInt64(bitPattern: carry) >> 32)
        index += 1
      }
      return res
    }

    static func multiplyByTenPow(_ val: BigInteger, _ exp: Int64) -> BigInteger {
      return exp < Int64(tenPows.count)
        ? multiplyByPositiveInt(val, tenPows[Int(exp)])
        : val.multiply(powerOf10(exp))
    }

    static func powerOf10(_ exp: Int64) -> BigInteger {
      let intExp = Int(exp)
      if exp < Int64(bigTenPows.count) { return bigTenPows[intExp] }
      if exp <= 50 { return try! BigInteger.TEN.pow(intExp) }
      if exp <= 1000 { return try! bigFivePows[1].pow(intExp).shiftLeft(intExp) }
      // Very large: 5^exp * 2^exp
      return try! bigFivePows[1].pow(Int(exp % Int64(Int.max))).shiftLeft(intExp)
    }

    static func multiplyByFivePow(_ val: BigInteger, _ exp: Int) -> BigInteger {
      if exp < fivePows.count { return multiplyByPositiveInt(val, fivePows[exp]) }
      if exp < bigFivePows.count { return val.multiply(bigFivePows[exp]) }
      return try! val.multiply(bigFivePows[1].pow(exp))
    }

    /// Computes `(a & 0xFFFFFFFF) * (b & 0xFFFFFFFF) + (c & 0xFFFFFFFF) + (d & 0xFFFFFFFF)`
    /// Uses UInt64 arithmetic to avoid signed overflow: max result is UInt64.max, which fits in UInt64.
    static func unsignedMultAddAdd(_ a: Int, _ b: Int, _ c: Int, _ d: Int) -> Int64 {
      let ua = UInt64(bitPattern: Int64(a)) & 0xFFFFFFFF
      let ub = UInt64(bitPattern: Int64(b)) & 0xFFFFFFFF
      let uc = UInt64(bitPattern: Int64(c)) & 0xFFFFFFFF
      let ud = UInt64(bitPattern: Int64(d)) & 0xFFFFFFFF
      return Int64(bitPattern: ua * ub + uc + ud)
    }
  }
}
