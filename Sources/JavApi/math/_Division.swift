/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com> and contributors
 * SPDX-License-Identifier: Apache-2.0
 */

extension java.math {

  struct _Division {

    // MARK: - Core division

    /// Knuth's Algorithm D: divides `a[0..<aLength]` by `b[0..<bLength]`,
    /// stores quotient in `quot[0..<quotLength]`, returns remainder.
    @discardableResult
    static func divide(_ quot: inout [Int]?, _ quotLength: Int,
                       _ a: [Int], _ aLength: Int,
                       _ b: [Int], _ bLength: Int) -> [Int] {
      var normA = [Int](repeating: 0, count: aLength + 1)
      var normB = [Int](repeating: 0, count: bLength + 1)
      let normBLength = bLength
      let divisorShift = Int.numberOfLeadingZeros(b[bLength - 1])
      if divisorShift != 0 {
        _BitLevel.shiftLeft(&normB, b, 0, divisorShift)
        _BitLevel.shiftLeft(&normA, a, 0, divisorShift)
      }
      else {
        System.arraycopy(a, 0, &normA, 0, aLength)
        System.arraycopy(b, 0, &normB, 0, bLength)
      }
      let firstDivisorDigit = normB[normBLength - 1]
      var i = quotLength - 1
      var j = aLength

      while i >= 0 {
        var guessDigit = 0
        if normA[j] == firstDivisorDigit {
          guessDigit = -1  // max unsigned int
        } else {
          let product = ((Int64(normA[j]) & 0xFFFFFFFF) << 32)
                      + (Int64(normA[j - 1]) & 0xFFFFFFFF)
          let res = divideLongByInt(product, firstDivisorDigit)
          guessDigit = Int(truncatingIfNeeded: res)
          var rem = Int(truncatingIfNeeded: res >> 32)
          if guessDigit != 0 {
            var leftHand: Int64 = 0
            var rightHand: Int64 = 0
            var rOverflowed = false
            guessDigit += 1
            repeat {
              guessDigit -= 1
              if rOverflowed { break }
              leftHand = (Int64(guessDigit) & 0xFFFFFFFF)
                       * (Int64(normB[normBLength - 2]) & 0xFFFFFFFF)
              rightHand = (Int64(rem) << 32) + (Int64(normA[j - 2]) & 0xFFFFFFFF)
              let longR = (Int64(rem) & 0xFFFFFFFF) + (Int64(firstDivisorDigit) & 0xFFFFFFFF)
              if Int.numberOfLeadingZeros(Int(truncatingIfNeeded: longR >> 32)) < 32 {
                rOverflowed = true
              } else {
                rem = Int(truncatingIfNeeded: longR)
              }
            } while (leftHand ^ Int64(bitPattern: 0x8000000000000000))
                  > (rightHand ^ Int64(bitPattern: 0x8000000000000000))
          }
        }
        if guessDigit != 0 {
          let borrow = multiplyAndSubtract(&normA, j - normBLength, normB, normBLength, guessDigit)
          if borrow != 0 {
            guessDigit -= 1
            var carry: Int64 = 0
            for k in 0..<normBLength {
              carry += (Int64(normA[j - normBLength + k]) & 0xFFFFFFFF)
                     + (Int64(normB[k]) & 0xFFFFFFFF)
              normA[j - normBLength + k] = Int(truncatingIfNeeded: carry)
              carry = Int64(bitPattern: UInt64(bitPattern: carry) >> 32)
            }
          }
        }
        if quot != nil { quot![i] = guessDigit }
        j -= 1
        i -= 1
      }
      if divisorShift != 0 {
        _BitLevel.shiftRight(&normB, normBLength, normA, 0, divisorShift)
        return normB
      }
      System.arraycopy(normA, 0, &normB, 0, bLength)
      return normA
    }

    /// Divides `src[0..<srcLength]` by `divisor`, stores quotient in `dest`.
    /// Returns remainder.
    @discardableResult
    static func divideArrayByInt(_ dest: inout [Int], _ src: [Int],
                                  _ srcLength: Int, _ divisor: Int) -> Int {
      var rem: Int64 = 0
      let bLong = Int64(divisor) & 0xFFFFFFFF
      var i = srcLength - 1
      while i >= 0 {
        let temp = (rem << 32) | (Int64(src[i]) & 0xFFFFFFFF)
        var quot: Int64
        if temp >= 0 {
          quot = temp / bLong
          rem  = temp % bLong
        } else {
          let aPos = Int64(bitPattern: UInt64(bitPattern: temp) >> 1)
          let bPos = Int64(bitPattern: UInt64(bitPattern: Int64(divisor)) >> 1)
          quot = aPos / bPos
          rem  = aPos % bPos
          rem = (rem << 1) + (temp & 1)
          if (divisor & 1) != 0 {
            if quot <= rem {
              rem -= quot
            } else if quot - rem <= bLong {
              rem += bLong - quot
              quot -= 1
            } else {
              rem += (bLong << 1) - quot
              quot -= 2
            }
          }
        }
        dest[i] = Int(truncatingIfNeeded: quot & 0xFFFFFFFF)
        i -= 1
      }
      return Int(truncatingIfNeeded: rem)
    }

    /// Divides `src[0..<srcLength]` by `divisor`, returns remainder only.
    static func remainderArrayByInt(_ src: [Int], _ srcLength: Int, _ divisor: Int) -> Int {
      var result: Int64 = 0
      var i = srcLength - 1
      while i >= 0 {
        let temp = (result << 32) + (Int64(src[i]) & 0xFFFFFFFF)
        let res = divideLongByInt(temp, divisor)
        result = res >> 32
        i -= 1
      }
      return Int(truncatingIfNeeded: result)
    }

    static func remainder(_ dividend: BigInteger, _ divisor: Int) -> Int {
      return remainderArrayByInt(dividend.digits, dividend.numberLength, divisor)
    }

    /// Returns `(remainder << 32) | quotient` for unsigned `a / b`.
    static func divideLongByInt(_ a: Int64, _ b: Int) -> Int64 {
      let bLong = Int64(b) & 0xFFFFFFFF
      var quot: Int64
      var rem: Int64
      if a >= 0 {
        quot = a / bLong
        rem  = a % bLong
      } else {
        let aPos = Int64(bitPattern: UInt64(bitPattern: a) >> 1)
        let bPos = Int64(bitPattern: UInt64(bitPattern: Int64(b)) >> 1)
        quot = aPos / bPos
        rem  = aPos % bPos
        rem = (rem << 1) + (a & 1)
        if (b & 1) != 0 {
          if quot <= rem {
            rem -= quot
          } else if quot - rem <= bLong {
            rem += bLong - quot
            quot -= 1
          } else {
            rem += (bLong << 1) - quot
            quot -= 2
          }
        }
      }
      return (rem << 32) | (quot & 0xFFFFFFFF)
    }

    static func divideAndRemainderByInteger(_ val: BigInteger,
                                             _ divisor: Int,
                                             _ divisorSign: Int) -> [BigInteger] {
      let valDigits = val.digits
      let valLen = val.numberLength
      let valSign = val.sign
      if valLen == 1 {
        let a = Int64(valDigits[0]) & 0xFFFFFFFF
        let b = Int64(divisor) & 0xFFFFFFFF
        var quo = a / b
        var rem = a % b
        if valSign != divisorSign { quo = -quo }
        if valSign < 0 { rem = -rem }
        return [BigInteger.valueOf(quo), BigInteger.valueOf(rem)]
      }
      let quotientSign = valSign == divisorSign ? 1 : -1
      var quotientDigits = [Int](repeating: 0, count: valLen)
      let remainderDigits = [divideArrayByInt(&quotientDigits, valDigits, valLen, divisor)]
      let result0 = BigInteger(quotientSign, valLen, quotientDigits)
      let result1 = BigInteger(valSign, 1, remainderDigits)
      result0.cutOffLeadingZeroes()
      result1.cutOffLeadingZeroes()
      return [result0, result1]
    }

    static func multiplyAndSubtract(_ a: inout [Int], _ start: Int,
                                     _ b: [Int], _ bLen: Int, _ c: Int) -> Int {
      var carry0: Int64 = 0
      var carry1: Int64 = 0
      for i in 0..<bLen {
        carry0 = _Multiplication.unsignedMultAddAdd(b[i], c, Int(truncatingIfNeeded: carry0), 0)
        carry1 = (Int64(a[start + i]) & 0xFFFFFFFF) - (carry0 & 0xFFFFFFFF) + carry1
        a[start + i] = Int(truncatingIfNeeded: carry1)
        carry1 >>= 32
        carry0 = Int64(bitPattern: UInt64(bitPattern: carry0) >> 32)
      }
      carry1 = (Int64(a[start + bLen]) & 0xFFFFFFFF) - carry0 + carry1
      a[start + bLen] = Int(truncatingIfNeeded: carry1)
      return Int(truncatingIfNeeded: carry1 >> 32)
    }

    // MARK: - GCD

    static func gcdBinary(_ op1: BigInteger, _ op2: BigInteger) -> BigInteger {
      var op1 = op1, op2 = op2
      let lsb1 = op1.getLowestSetBit()
      let lsb2 = op2.getLowestSetBit()
      let pow2Count = Swift.min(lsb1, lsb2)
      _BitLevel.inplaceShiftRight(op1, lsb1)
      _BitLevel.inplaceShiftRight(op2, lsb2)
      if op1.compareTo(op2) == BigInteger.GREATER { swap(&op1, &op2) }
      repeat {
        if op2.numberLength == 1
          || (op2.numberLength == 2 && op2.digits[1] > 0) {
          op2 = BigInteger.valueOf(gcdBinary(op1.longValue(), op2.longValue()))
          break
        }
        if Double(op2.numberLength) > Double(op1.numberLength) * 1.2 {
          op2 = try! op2.remainder(op1)
          if op2.signum() != 0 {
            _BitLevel.inplaceShiftRight(op2, op2.getLowestSetBit())
          }
        } else {
          repeat {
            _Elementary.inplaceSubtract(op2, op1)
            _BitLevel.inplaceShiftRight(op2, op2.getLowestSetBit())
          } while op2.compareTo(op1) >= BigInteger.EQUALS
        }
        swap(&op1, &op2)
      } while op1.sign != 0
      return op2.shiftLeft(pow2Count)
    }

    static func gcdBinary(_ op1: Int64, _ op2: Int64) -> Int64 {
      var op1 = op1, op2 = op2
      let lsb1 = Int64.numberOfTrailingZeros(op1)
      let lsb2 = Int64.numberOfTrailingZeros(op2)
      let pow2Count = Swift.min(lsb1, lsb2)
      if lsb1 != 0 { op1 = Int64(bitPattern: UInt64(bitPattern: op1) >> UInt64(lsb1)) }
      if lsb2 != 0 { op2 = Int64(bitPattern: UInt64(bitPattern: op2) >> UInt64(lsb2)) }
      repeat {
        if op1 >= op2 {
          op1 -= op2
          let tz = Int64.numberOfTrailingZeros(op1)
          op1 = Int64(bitPattern: UInt64(bitPattern: op1) >> UInt64(tz))
        } else {
          op2 -= op1
          let tz = Int64.numberOfTrailingZeros(op2)
          op2 = Int64(bitPattern: UInt64(bitPattern: op2) >> UInt64(tz))
        }
      } while op1 != 0
      return op2 << Int64(pow2Count)
    }

    // MARK: - Modular inverse

    static func modInverseMontgomery(_ a: BigInteger, _ p: BigInteger) throws -> BigInteger {
      if a.sign == 0 { throw ArithmeticException("BigInteger not invertible") }
      if try !p.testBit(0) { return modInverseHars(a, p) }

      let m = p.numberLength * 32
      let u = p.copy()
      let v = a.copy()
      let maxLen = Swift.max(v.numberLength, u.numberLength)
      let r = BigInteger(1, 1, [Int](repeating: 0, count: maxLen + 1))
      let s = BigInteger(1, 1, [Int](repeating: 0, count: maxLen + 1))
      s.digits[0] = 1
      var k = 0

      let lsbu = u.getLowestSetBit()
      let lsbv = v.getLowestSetBit()

      if lsbu > lsbv {
        _BitLevel.inplaceShiftRight(u, lsbu)
        _BitLevel.inplaceShiftRight(v, lsbv)
        _BitLevel.inplaceShiftLeft(r, lsbv)
        k += lsbu - lsbv
      }
      else {
        _BitLevel.inplaceShiftRight(u, lsbu)
        _BitLevel.inplaceShiftRight(v, lsbv)
        _BitLevel.inplaceShiftLeft(s, lsbu)
        k += lsbv - lsbu
      }
      r.sign = 1

      while v.signum() > 0 {
        while u.compareTo(v) > BigInteger.EQUALS {
          _Elementary.inplaceSubtract(u, v)
          let toShift = u.getLowestSetBit()
          _BitLevel.inplaceShiftRight(u, toShift)
          _Elementary.inplaceAdd(r, s)
          _BitLevel.inplaceShiftLeft(s, toShift)
          k += toShift
        }
        while u.compareTo(v) <= BigInteger.EQUALS {
          _Elementary.inplaceSubtract(v, u)
          if v.signum() == 0 { break }
          let toShift = v.getLowestSetBit()
          _BitLevel.inplaceShiftRight(v, toShift)
          _Elementary.inplaceAdd(s, r)
          _BitLevel.inplaceShiftLeft(r, toShift)
          k += toShift
        }
      }
      if !u.isOne() { throw ArithmeticException("BigInteger not invertible.") }
      var result = r.compareTo(p) >= BigInteger.EQUALS
        ? { _Elementary.inplaceSubtract(r, p); return r }()
        : r
      result = p.subtract(result)

      let n1 = calcN(p)
      if k > m {
        result = monPro(result, BigInteger.ONE, p, n1)
        k -= m
      }
      return monPro(result, BigInteger.getPowerOfTwo(m - k), p, n1)
    }

    private static func calcN(_ a: BigInteger) -> Int {
      let m0 = Int64(a.digits[0]) & 0xFFFFFFFF
      var n2 : Int64 = 1
      var powerOfTwo : Int64 = 2
      repeat {
        if ((m0 * n2) & powerOfTwo) != 0 { n2 |= powerOfTwo }
        powerOfTwo <<= 1
      } while powerOfTwo < 0x100000000
      n2 = -n2
      return Int(truncatingIfNeeded: n2 & 0xFFFFFFFF)
    }

    static func squareAndMultiply(_ x2: BigInteger, _ a2: BigInteger,
                                   _ exponent: BigInteger, _ modulus: BigInteger,
                                   _ n2: Int) -> BigInteger {
      var res = x2
      var i = exponent.bitLength() - 1
      while i >= 0 {
        res = monPro(res, res, modulus, n2)
        if _BitLevel.testBit(exponent, i) {
          res = monPro(res, a2, modulus, n2)
        }
        i -= 1
      }
      return res
    }

    static func modInverseHars(_ a: BigInteger, _ m: BigInteger) -> BigInteger {
      var u: BigInteger, v: BigInteger, r: BigInteger, s: BigInteger
      if a.compareTo(m) == BigInteger.LESS {
        u = m; v = a; r = BigInteger.ZERO; s = BigInteger.ONE
      } else {
        v = m; u = a; s = BigInteger.ZERO; r = BigInteger.ONE
      }
      var uLen = u.bitLength()
      var vLen = v.bitLength()
      var f = uLen - vLen
      while vLen > 1 {
        if u.sign == v.sign {
          u = u.subtract(v.shiftLeft(f)); r = r.subtract(s.shiftLeft(f))
        } else {
          u = u.add(v.shiftLeft(f)); r = r.add(s.shiftLeft(f))
        }
        uLen = u.abs().bitLength()
        vLen = v.abs().bitLength()
        f = uLen - vLen
        if f < 0 {
          swap(&u, &v); swap(&r, &s); f = -f; vLen = uLen
        }
      }
      if v.sign == 0 { return BigInteger.ZERO }
      if v.sign < 0 { s = s.negate() }
      if s.compareTo(m) == BigInteger.GREATER { return s.subtract(m) }
      if s.sign < 0 { return s.add(m) }
      return s
    }

    static func slidingWindow(_ x2: BigInteger, _ a2: BigInteger,
                               _ exponent: BigInteger, _ modulus: BigInteger,
                               _ n2: Int) -> BigInteger {
      var pows = [BigInteger](repeating: BigInteger.ZERO, count: 8)
      var res = x2
      pows[0] = a2
      let x3 = monPro(a2, a2, modulus, n2)
      for i in 1...7 { pows[i] = monPro(pows[i - 1], x3, modulus, n2) }

      var i = exponent.bitLength() - 1
      while i >= 0 {
        if _BitLevel.testBit(exponent, i) {
          var lowexp = 1, acc3 = i
          let jMin = Swift.max(i - 3, 0)
          for j in jMin..<i {
            if _BitLevel.testBit(exponent, j) {
              if j < acc3 {
                acc3 = j; lowexp = (lowexp << (i - j)) ^ 1
              } else {
                lowexp ^= (1 << (j - acc3))
              }
            }
          }
          for _ in acc3...i { res = monPro(res, res, modulus, n2) }
          res = monPro(pows[(lowexp - 1) >> 1], res, modulus, n2)
          i = acc3
        } else {
          res = monPro(res, res, modulus, n2)
        }
        i -= 1
      }
      return res
    }

    static func oddModPow(_ base: BigInteger, _ exponent: BigInteger,
                           _ modulus: BigInteger) throws -> BigInteger {
      let k = modulus.numberLength << 5
      let a2 = try base.shiftLeft(k).mod(modulus)
      let x2 = try BigInteger.getPowerOfTwo(k).mod(modulus)
      let n2 = calcN(modulus)
      let res = modulus.numberLength == 1
        ? squareAndMultiply(x2, a2, exponent, modulus, n2)
        : slidingWindow(x2, a2, exponent, modulus, n2)
      return monPro(res, BigInteger.ONE, modulus, n2)
    }

    static func evenModPow(_ base: BigInteger, _ exponent: BigInteger,
                            _ modulus: BigInteger) throws -> BigInteger {
      let j = modulus.getLowestSetBit()
      let q = modulus.shiftRight(j)
      let x1 = try oddModPow(base, exponent, q)
      let x2 = try pow2ModPow(base, exponent, j)
      let qInv = modPow2Inverse(q, j)
      var y = x2.subtract(x1).multiply(qInv)
      inplaceModPow2(y, j)
      if y.sign < 0 { y = y.add(BigInteger.getPowerOfTwo(j)) }
      return x1.add(q.multiply(y))
    }

    static func pow2ModPow(_ base: BigInteger, _ exponent: BigInteger, _ j: Int) throws -> BigInteger {
      var res = BigInteger.ONE
      let e = exponent.copy()
      let baseMod = base.copy()
      if try base.testBit(0) { inplaceModPow2(e, j - 1) }
      inplaceModPow2(baseMod, j)
      var i = e.bitLength() - 1
      while i >= 0 {
        let res2 = res.copy()
        inplaceModPow2(res2, j)
        res = res.multiply(res2)
        if _BitLevel.testBit(e, i) {
          res = res.multiply(baseMod)
          inplaceModPow2(res, j)
        }
        i -= 1
      }
      inplaceModPow2(res, j)
      return res
    }

    private static func monReduction(_ res: inout [Int], _ modulus: BigInteger, _ n2: Int) {
      let modulusDigits = modulus.digits
      let modulusLen = modulus.numberLength
      var outerCarry: Int64 = 0
      for i in 0..<modulusLen {
        var innerCarry: Int64 = 0
        let m = Int(truncatingIfNeeded: _Multiplication.unsignedMultAddAdd(res[i], n2, 0, 0))
        for j in 0..<modulusLen {
          innerCarry = _Multiplication.unsignedMultAddAdd(m, modulusDigits[j], res[i + j], Int(truncatingIfNeeded: innerCarry))
          res[i + j] = Int(truncatingIfNeeded: innerCarry)
          innerCarry = Int64(bitPattern: UInt64(bitPattern: innerCarry) >> 32)
        }
        outerCarry += (Int64(res[i + modulusLen]) & 0xFFFFFFFF) + innerCarry
        res[i + modulusLen] = Int(truncatingIfNeeded: outerCarry)
        outerCarry = Int64(bitPattern: UInt64(bitPattern: outerCarry) >> 32)
      }
      res[modulusLen << 1] = Int(truncatingIfNeeded: outerCarry)
      for j in 0...(modulusLen) { res[j] = res[j + modulusLen] }
    }

    static func monPro(_ a: BigInteger, _ b: BigInteger,
                        _ modulus: BigInteger, _ n2: Int) -> BigInteger {
      let modulusLen = modulus.numberLength
      var res = [Int](repeating: 0, count: (modulusLen << 1) + 1)
      _Multiplication.multArraysPAP(a.digits, Swift.min(modulusLen, a.numberLength),
                                   b.digits, Swift.min(modulusLen, b.numberLength), &res)
      monReduction(&res, modulus, n2)
      return finalSubtraction(&res, modulus)
    }

    static func finalSubtraction(_ res: inout [Int], _ modulus: BigInteger) -> BigInteger {
      let modulusLen = modulus.numberLength
      var doSub = res[modulusLen] != 0
      if !doSub {
        let modulusDigits = modulus.digits
        doSub = true
        var i = modulusLen - 1
        while i >= 0 {
          if res[i] != modulusDigits[i] {
            doSub = res[i] != 0 && (UInt32(truncatingIfNeeded: res[i]) > UInt32(truncatingIfNeeded: modulusDigits[i]))
            break
          }
          i -= 1
        }
      }
      let result = BigInteger(1, modulusLen + 1, res)
      if doSub {
        _Elementary.inplaceSubtract(result, modulus)
      }
      result.cutOffLeadingZeroes()
      return result
    }

    static func modPow2Inverse(_ x: BigInteger, _ n: Int) -> BigInteger {
      let y = BigInteger(1, [Int](repeating: 0, count: 1 << n))
      y.numberLength = 1
      y.digits[0] = 1
      y.sign = 1
      for i in 1..<n {
        if _BitLevel.testBit(x.multiply(y), i) {
          y.digits[i >> 5] |= (1 << (i & 31))
        }
      }
      return y
    }

    static func inplaceModPow2(_ x: BigInteger, _ n: Int) {
      let fd = n >> 5
      if x.numberLength < fd || x.bitLength() <= n { return }
      let leadingZeros = 32 - (n & 31)
      x.numberLength = fd + 1
      x.digits[fd] &= leadingZeros < 32 ? (-1 >> leadingZeros) : 0
      // Swift: -1 >> n is arithmetic right shift (implementation-defined in C but defined in Swift)
      // We want unsigned mask: (1 << (32-leadingZeros)) - 1 equivalent
      x.digits[fd] &= leadingZeros < 32 ? Int(bitPattern: UInt(bitPattern: -1) >> leadingZeros) : 0
      x.cutOffLeadingZeroes()
    }

    static func mod(_ dividend: BigInteger, _ m: BigInteger) throws (ArithmeticException) -> BigInteger {
      if m.sign <= 0 { throw ArithmeticException("BigInteger: modulus not positive") }
      let rem = try dividend.remainder(m)
      return rem.sign < 0 ? rem.add(m) : rem
    }
  }
}

// MARK: - Int64 trailing zeros helper

private extension Int64 {
  static func numberOfTrailingZeros(_ value: Int64) -> Int {
    if value == 0 { return 64 }
    var v = UInt64(bitPattern: value)
    var count = 0
    while (v & 1) == 0 { v >>= 1; count += 1 }
    return count
  }
}
