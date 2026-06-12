/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com> and contributors
 * SPDX-License-Identifier: Apache-2.0
 */

extension java.math {

  struct _Logical {

    static func not(_ val: BigInteger) -> BigInteger {
      if val.sign == 0 { return BigInteger.MINUS_ONE }
      if val.equals(BigInteger.MINUS_ONE as AnyObject) { return BigInteger.ZERO }
      var resDigits = [Int](repeating: 0, count: val.numberLength + 1)
      var i: Int
      if val.sign > 0 {
        if val.digits[val.numberLength - 1] != -1 {
          i = 0; while val.digits[i] == -1 { i += 1 }
        } else {
          i = 0; while i < val.numberLength && val.digits[i] == -1 { i += 1 }
          if i == val.numberLength {
            resDigits[i] = 1
            return BigInteger(-val.sign, i + 1, resDigits)
          }
        }
      } else {
        i = 0; while val.digits[i] == 0 { resDigits[i] = -1; i += 1 }
      }
      resDigits[i] = val.digits[i] + val.sign
      var j = i + 1; while j < val.numberLength { resDigits[j] = val.digits[j]; j += 1 }
      return BigInteger(-val.sign, j, resDigits)
    }

    static func and(_ val: BigInteger, _ that: BigInteger) -> BigInteger {
      if that.sign == 0 || val.sign == 0 { return BigInteger.ZERO }
      if that.equals(BigInteger.MINUS_ONE as AnyObject) { return val }
      if val.equals(BigInteger.MINUS_ONE as AnyObject) { return that }
      if val.sign > 0 {
        return that.sign > 0 ? andPositive(val, that) : andDiffSigns(val, that)
      } else {
        if that.sign > 0 { return andDiffSigns(that, val) }
        return val.numberLength > that.numberLength ? andNegative(val, that) : andNegative(that, val)
      }
    }

    private static func andPositive(_ val: BigInteger, _ that: BigInteger) -> BigInteger {
      let resLength = Swift.min(val.numberLength, that.numberLength)
      let i0 = Swift.max(val.getFirstNonzeroDigit(), that.getFirstNonzeroDigit())
      if i0 >= resLength { return BigInteger.ZERO }
      var resDigits = [Int](repeating: 0, count: resLength)
      for i in i0..<resLength { resDigits[i] = val.digits[i] & that.digits[i] }
      let result = BigInteger(1, resLength, resDigits); result.cutOffLeadingZeroes(); return result
    }

    private static func andDiffSigns(_ positive: BigInteger, _ negative: BigInteger) -> BigInteger {
      let iPos = positive.getFirstNonzeroDigit(), iNeg = negative.getFirstNonzeroDigit()
      if iNeg >= positive.numberLength { return BigInteger.ZERO }
      let resLength = positive.numberLength
      var resDigits = [Int](repeating: 0, count: resLength)
      var i = Swift.max(iPos, iNeg)
      if i == iNeg { resDigits[i] = -negative.digits[i] & positive.digits[i]; i += 1 }
      let limit = Swift.min(negative.numberLength, positive.numberLength)
      while i < limit { resDigits[i] = ~negative.digits[i] & positive.digits[i]; i += 1 }
      if i >= negative.numberLength { while i < positive.numberLength { resDigits[i] = positive.digits[i]; i += 1 } }
      let result = BigInteger(1, resLength, resDigits); result.cutOffLeadingZeroes(); return result
    }

    private static func andNegative(_ longer: BigInteger, _ shorter: BigInteger) -> BigInteger {
      let iL = longer.getFirstNonzeroDigit(), iS = shorter.getFirstNonzeroDigit()
      if iL >= shorter.numberLength { return longer }
      var i = Swift.max(iS, iL)
      var digit: Int
      if iS > iL { digit = -shorter.digits[i] & ~longer.digits[i] }
      else if iS < iL { digit = ~shorter.digits[i] & -longer.digits[i] }
      else { digit = -shorter.digits[i] & -longer.digits[i] }
      var resLength = longer.numberLength
      var resDigits = [Int](repeating: 0, count: resLength)
      if digit == 0 {
        i += 1
        while i < shorter.numberLength { digit = ~(longer.digits[i] | shorter.digits[i]); if digit != 0 { break }; i += 1 }
        if digit == 0 {
          while i < longer.numberLength { digit = ~longer.digits[i]; if digit != 0 { break }; i += 1 }
          if digit == 0 {
            resLength = longer.numberLength + 1
            resDigits = [Int](repeating: 0, count: resLength)
            resDigits[resLength - 1] = 1
            return BigInteger(-1, resLength, resDigits)
          }
        }
      }
      resDigits[i] = -digit; i += 1
      while i < shorter.numberLength { resDigits[i] = longer.digits[i] | shorter.digits[i]; i += 1 }
      while i < longer.numberLength { resDigits[i] = longer.digits[i]; i += 1 }
      return BigInteger(-1, resLength, resDigits)
    }

    static func andNot(_ val: BigInteger, _ that: BigInteger) -> BigInteger {
      if that.sign == 0 { return val }
      if val.sign == 0 { return BigInteger.ZERO }
      if val.equals(BigInteger.MINUS_ONE as AnyObject) { return that.not() }
      if that.equals(BigInteger.MINUS_ONE as AnyObject) { return BigInteger.ZERO }
      if val.sign > 0 {
        return that.sign > 0 ? andNotPositive(val, that) : andNotPositiveNegative(val, that)
      } else {
        return that.sign > 0 ? andNotNegativePositive(val, that) : andNotNegative(val, that)
      }
    }

    private static func andNotPositive(_ val: BigInteger, _ that: BigInteger) -> BigInteger {
      var resDigits = [Int](repeating: 0, count: val.numberLength)
      let limit = Swift.min(val.numberLength, that.numberLength)
      var i = val.getFirstNonzeroDigit()
      while i < limit { resDigits[i] = val.digits[i] & ~that.digits[i]; i += 1 }
      while i < val.numberLength { resDigits[i] = val.digits[i]; i += 1 }
      let result = BigInteger(1, val.numberLength, resDigits); result.cutOffLeadingZeroes(); return result
    }

    private static func andNotPositiveNegative(_ positive: BigInteger, _ negative: BigInteger) -> BigInteger {
      let iNeg = negative.getFirstNonzeroDigit(), iPos = positive.getFirstNonzeroDigit()
      if iNeg >= positive.numberLength { return positive }
      let resLength = Swift.min(positive.numberLength, negative.numberLength)
      var resDigits = [Int](repeating: 0, count: resLength)
      var i = iPos
      while i < iNeg { resDigits[i] = positive.digits[i]; i += 1 }
      if i == iNeg { resDigits[i] = positive.digits[i] & (negative.digits[i] - 1); i += 1 }
      while i < resLength { resDigits[i] = positive.digits[i] & negative.digits[i]; i += 1 }
      let result = BigInteger(1, resLength, resDigits); result.cutOffLeadingZeroes(); return result
    }

    private static func andNotNegativePositive(_ negative: BigInteger, _ positive: BigInteger) -> BigInteger {
      let iNeg = negative.getFirstNonzeroDigit(), iPos = positive.getFirstNonzeroDigit()
      if iNeg >= positive.numberLength { return negative }
      let resLength = Swift.max(negative.numberLength, positive.numberLength)
      var resDigits = [Int](repeating: 0, count: resLength)
      var i = iNeg
      if iPos > iNeg {
        let limit = Swift.min(negative.numberLength, iPos)
        while i < limit { resDigits[i] = negative.digits[i]; i += 1 }
        if i == negative.numberLength {
          var j = iPos; while j < positive.numberLength { resDigits[j] = positive.digits[j]; j += 1 }
        }
      } else {
        var digit = -negative.digits[i] & ~positive.digits[i]
        if digit == 0 {
          let limit = Swift.min(positive.numberLength, negative.numberLength)
          i += 1
          while i < limit { digit = ~(negative.digits[i] | positive.digits[i]); if digit != 0 { break }; i += 1 }
          if digit == 0 {
            while i < positive.numberLength { digit = ~positive.digits[i]; if digit != 0 { break }; i += 1 }
            while i < negative.numberLength { digit = ~negative.digits[i]; if digit != 0 { break }; i += 1 }
            if digit == 0 {
              var rd = [Int](repeating: 0, count: resLength + 1)
              rd[resLength] = 1
              return BigInteger(-1, resLength + 1, rd)
            }
          }
        }
        resDigits[i] = -digit; i += 1
      }
      let limit = Swift.min(positive.numberLength, negative.numberLength)
      while i < limit { resDigits[i] = negative.digits[i] | positive.digits[i]; i += 1 }
      while i < negative.numberLength { resDigits[i] = negative.digits[i]; i += 1 }
      while i < positive.numberLength { resDigits[i] = positive.digits[i]; i += 1 }
      return BigInteger(-1, resLength, resDigits)
    }

    private static func andNotNegative(_ val: BigInteger, _ that: BigInteger) -> BigInteger {
      let iVal = val.getFirstNonzeroDigit(), iThat = that.getFirstNonzeroDigit()
      if iVal >= that.numberLength { return BigInteger.ZERO }
      let resLength = that.numberLength
      var resDigits = [Int](repeating: 0, count: resLength)
      var i = iVal
      if iVal < iThat {
        resDigits[i] = -val.digits[i]; i += 1
        let limit = Swift.min(val.numberLength, iThat)
        while i < limit { resDigits[i] = ~val.digits[i]; i += 1 }
        if i == val.numberLength {
          while i < iThat { resDigits[i] = -1; i += 1 }
          resDigits[i] = that.digits[i] - 1; i += 1
        } else {
          resDigits[i] = ~val.digits[i] & (that.digits[i] - 1); i += 1
        }
      } else if iThat < iVal {
        resDigits[i] = -val.digits[i] & that.digits[i]; i += 1
      } else {
        resDigits[i] = -val.digits[i] & (that.digits[i] - 1); i += 1
      }
      let limit = Swift.min(val.numberLength, that.numberLength)
      while i < limit { resDigits[i] = ~val.digits[i] & that.digits[i]; i += 1 }
      while i < that.numberLength { resDigits[i] = that.digits[i]; i += 1 }
      let result = BigInteger(1, resLength, resDigits); result.cutOffLeadingZeroes(); return result
    }

    static func or(_ val: BigInteger, _ that: BigInteger) -> BigInteger {
      if that.equals(BigInteger.MINUS_ONE as AnyObject) || val.equals(BigInteger.MINUS_ONE as AnyObject) { return BigInteger.MINUS_ONE }
      if that.sign == 0 { return val }
      if val.sign == 0 { return that }
      if val.sign > 0 {
        if that.sign > 0 {
          return val.numberLength > that.numberLength ? orPositive(val, that) : orPositive(that, val)
        }
        return orDiffSigns(val, that)
      } else {
        if that.sign > 0 { return orDiffSigns(that, val) }
        return that.getFirstNonzeroDigit() > val.getFirstNonzeroDigit() ? orNegative(that, val) : orNegative(val, that)
      }
    }

    private static func orPositive(_ longer: BigInteger, _ shorter: BigInteger) -> BigInteger {
      let resLength = longer.numberLength
      var resDigits = [Int](repeating: 0, count: resLength)
      var i = 0
      while i < shorter.numberLength { resDigits[i] = longer.digits[i] | shorter.digits[i]; i += 1 }
      while i < resLength { resDigits[i] = longer.digits[i]; i += 1 }
      return BigInteger(1, resLength, resDigits)
    }

    private static func orNegative(_ val: BigInteger, _ that: BigInteger) -> BigInteger {
      let iThat = that.getFirstNonzeroDigit(), iVal = val.getFirstNonzeroDigit()
      if iVal >= that.numberLength { return that }
      if iThat >= val.numberLength { return val }
      let resLength = Swift.min(val.numberLength, that.numberLength)
      var resDigits = [Int](repeating: 0, count: resLength)
      var i: Int
      if iThat == iVal {
        resDigits[iVal] = -(-val.digits[iVal] | -that.digits[iVal]); i = iVal
      } else {
        i = iThat; while i < iVal { resDigits[i] = that.digits[i]; i += 1 }
        resDigits[i] = that.digits[i] & (val.digits[i] - 1)
      }
      i += 1
      while i < resLength { resDigits[i] = val.digits[i] & that.digits[i]; i += 1 }
      let result = BigInteger(-1, resLength, resDigits); result.cutOffLeadingZeroes(); return result
    }

    private static func orDiffSigns(_ positive: BigInteger, _ negative: BigInteger) -> BigInteger {
      let iNeg = negative.getFirstNonzeroDigit(), iPos = positive.getFirstNonzeroDigit()
      if iPos >= negative.numberLength { return negative }
      let resLength = negative.numberLength
      var resDigits = [Int](repeating: 0, count: resLength)
      var i: Int
      if iNeg < iPos {
        i = iNeg; while i < iPos { resDigits[i] = negative.digits[i]; i += 1 }
      } else if iPos < iNeg {
        i = iPos; resDigits[i] = -positive.digits[i]; i += 1
        let limit = Swift.min(positive.numberLength, iNeg)
        while i < limit { resDigits[i] = ~positive.digits[i]; i += 1 }
        if i != positive.numberLength {
          resDigits[i] = ~(-negative.digits[i] | positive.digits[i]); i += 1
        } else {
          while i < iNeg { resDigits[i] = -1; i += 1 }
          resDigits[i] = negative.digits[i] - 1; i += 1
        }
      } else {
        i = iPos; resDigits[i] = -(-negative.digits[i] | positive.digits[i]); i += 1
      }
      let limit = Swift.min(negative.numberLength, positive.numberLength)
      while i < limit { resDigits[i] = negative.digits[i] & ~positive.digits[i]; i += 1 }
      while i < negative.numberLength { resDigits[i] = negative.digits[i]; i += 1 }
      let result = BigInteger(-1, resLength, resDigits); result.cutOffLeadingZeroes(); return result
    }

    static func xor(_ val: BigInteger, _ that: BigInteger) -> BigInteger {
      if that.sign == 0 { return val }
      if val.sign == 0 { return that }
      if that.equals(BigInteger.MINUS_ONE as AnyObject) { return val.not() }
      if val.equals(BigInteger.MINUS_ONE as AnyObject) { return that.not() }
      if val.sign > 0 {
        if that.sign > 0 {
          return val.numberLength > that.numberLength ? xorPositive(val, that) : xorPositive(that, val)
        }
        return xorDiffSigns(val, that)
      } else {
        if that.sign > 0 { return xorDiffSigns(that, val) }
        return that.getFirstNonzeroDigit() > val.getFirstNonzeroDigit() ? xorNegative(that, val) : xorNegative(val, that)
      }
    }

    private static func xorPositive(_ longer: BigInteger, _ shorter: BigInteger) -> BigInteger {
      let resLength = longer.numberLength
      var resDigits = [Int](repeating: 0, count: resLength)
      var i = Swift.min(longer.getFirstNonzeroDigit(), shorter.getFirstNonzeroDigit())
      while i < shorter.numberLength { resDigits[i] = longer.digits[i] ^ shorter.digits[i]; i += 1 }
      while i < longer.numberLength { resDigits[i] = longer.digits[i]; i += 1 }
      let result = BigInteger(1, resLength, resDigits); result.cutOffLeadingZeroes(); return result
    }

    private static func xorNegative(_ val: BigInteger, _ that: BigInteger) -> BigInteger {
      let resLength = Swift.max(val.numberLength, that.numberLength)
      var resDigits = [Int](repeating: 0, count: resLength)
      let iVal = val.getFirstNonzeroDigit(), iThat = that.getFirstNonzeroDigit()
      var i = iThat, limit: Int
      if iVal == iThat {
        resDigits[i] = -val.digits[i] ^ -that.digits[i]
      } else {
        resDigits[i] = -that.digits[i]; i += 1
        limit = Swift.min(that.numberLength, iVal)
        while i < limit { resDigits[i] = ~that.digits[i]; i += 1 }
        if i == that.numberLength {
          while i < iVal { resDigits[i] = -1; i += 1 }
          resDigits[i] = val.digits[i] - 1
        } else {
          resDigits[i] = -val.digits[i] ^ ~that.digits[i]
        }
      }
      i += 1
      limit = Swift.min(val.numberLength, that.numberLength)
      while i < limit { resDigits[i] = val.digits[i] ^ that.digits[i]; i += 1 }
      while i < val.numberLength { resDigits[i] = val.digits[i]; i += 1 }
      while i < that.numberLength { resDigits[i] = that.digits[i]; i += 1 }
      let result = BigInteger(1, resLength, resDigits); result.cutOffLeadingZeroes(); return result
    }

    private static func xorDiffSigns(_ positive: BigInteger, _ negative: BigInteger) -> BigInteger {
      let resLength = Swift.max(negative.numberLength, positive.numberLength)
      var resDigits: [Int]
      let iNeg = negative.getFirstNonzeroDigit(), iPos = positive.getFirstNonzeroDigit()
      var i: Int, limit: Int
      if iNeg < iPos {
        resDigits = [Int](repeating: 0, count: resLength)
        i = iNeg; resDigits[i] = negative.digits[i]; i += 1
        limit = Swift.min(negative.numberLength, iPos)
        while i < limit { resDigits[i] = negative.digits[i]; i += 1 }
        if i == negative.numberLength {
          while i < positive.numberLength { resDigits[i] = positive.digits[i]; i += 1 }
        }
      } else if iPos < iNeg {
        resDigits = [Int](repeating: 0, count: resLength)
        i = iPos; resDigits[i] = -positive.digits[i]; i += 1
        limit = Swift.min(positive.numberLength, iNeg)
        while i < limit { resDigits[i] = ~positive.digits[i]; i += 1 }
        if i == iNeg {
          resDigits[i] = ~(positive.digits[i] ^ -negative.digits[i]); i += 1
        } else {
          while i < iNeg { resDigits[i] = -1; i += 1 }
          while i < negative.numberLength { resDigits[i] = negative.digits[i]; i += 1 }
        }
      } else {
        i = iNeg
        var digit = positive.digits[i] ^ -negative.digits[i]
        if digit == 0 {
          limit = Swift.min(positive.numberLength, negative.numberLength)
          i += 1
          while i < limit { digit = positive.digits[i] ^ ~negative.digits[i]; if digit != 0 { break }; i += 1 }
          if digit == 0 {
            while i < positive.numberLength { digit = ~positive.digits[i]; if digit != 0 { break }; i += 1 }
            while i < negative.numberLength { digit = ~negative.digits[i]; if digit != 0 { break }; i += 1 }
            if digit == 0 {
              var rd = [Int](repeating: 0, count: resLength + 1)
              rd[resLength] = 1
              return BigInteger(-1, resLength + 1, rd)
            }
          }
        }
        resDigits = [Int](repeating: 0, count: resLength)
        resDigits[i] = -digit; i += 1
      }
      limit = Swift.min(negative.numberLength, positive.numberLength)
      while i < limit { resDigits[i] = ~(~negative.digits[i] ^ positive.digits[i]); i += 1 }
      while i < positive.numberLength { resDigits[i] = positive.digits[i]; i += 1 }
      while i < negative.numberLength { resDigits[i] = negative.digits[i]; i += 1 }
      let result = BigInteger(-1, resLength, resDigits); result.cutOffLeadingZeroes(); return result
    }
  }
}
