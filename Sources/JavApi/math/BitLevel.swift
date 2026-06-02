/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: Apache-2.0
 */

extension java.math {

  /// Static library for all bit-level operations on BigInteger.
  enum BitLevel {

    // MARK: - Bit metrics

    static func bitLength(_ val: BigInteger) -> Int {
      if val.sign == 0 { return 0 }
      var bLength = val.numberLength << 5
      var highDigit = val.digits[val.numberLength - 1]
      if val.sign < 0 {
        let i = val.getFirstNonzeroDigit()
        if i == val.numberLength - 1 { highDigit -= 1 }
      }
      bLength -= Int.numberOfLeadingZeros(highDigit)
      return bLength
    }

    static func bitCount(_ val: BigInteger) -> Int {
      if val.sign == 0 { return 0 }
      var bCount = 0
      var i = val.getFirstNonzeroDigit()
      if val.sign > 0 {
        while i < val.numberLength {
          bCount += val.digits[i].nonzeroBitCount
          i += 1
        }
      } else {
        bCount += (-val.digits[i]).nonzeroBitCount
        i += 1
        while i < val.numberLength {
          bCount += (~val.digits[i]).nonzeroBitCount
          i += 1
        }
        bCount = (val.numberLength << 5) - bCount
      }
      return bCount
    }

    /// Fast bit test for positive numbers. `n` must be in `[0, val.bitLength()-1]`.
    static func testBit(_ val: BigInteger, _ n: Int) -> Bool {
      return (val.digits[n >> 5] & (1 << (n & 31))) != 0
    }

    static func nonZeroDroppedBits(_ numberOfBits: Int, _ digits: [Int]) -> Bool {
      let intCount = numberOfBits >> 5
      let bitCount = numberOfBits & 31
      var i = 0
      while i < intCount && digits[i] == 0 { i += 1 }
      return i != intCount || (digits[i] << (32 - bitCount)) != 0
    }

    // MARK: - Shift left

    static func shiftLeft(_ source: BigInteger, _ count: Int) -> BigInteger {
      let intCount = count >> 5
      let bitCount = count & 31
      let resLength = source.numberLength + intCount + (bitCount == 0 ? 0 : 1)
      var resDigits = [Int](repeating: 0, count: resLength)
      shiftLeft(&resDigits, source.digits, intCount, bitCount)
      let result = BigInteger(source.sign, resLength, resDigits)
      result.cutOffLeadingZeroes()
      return result
    }

    static func inplaceShiftLeft(_ val: BigInteger, _ count: Int) {
      let intCount = count >> 5
      let leadingZeros = Int.numberOfLeadingZeros(val.digits[val.numberLength - 1])
      val.numberLength += intCount + (leadingZeros - (count & 31) >= 0 ? 0 : 1)
      shiftLeft(&val.digits, val.digits, intCount, count & 31)
      val.cutOffLeadingZeroes()
      val.unCache()
    }

    static func shiftLeft(_ result: inout [Int], _ source: [Int],
                           _ intCount: Int, _ count: Int) {
      if count == 0 {
        let srcStart = 0
        let dstStart = intCount
        let len = result.count - intCount
        for i in 0..<len {
          result[dstStart + i] = source[srcStart + i]
        }
      } else {
        let rightShiftCount = 32 - count
        result[result.count - 1] = 0
        var i = result.count - 1
        while i > intCount {
          result[i] |= Int(UInt32(truncatingIfNeeded: source[i - intCount - 1]) >> rightShiftCount)
          result[i - 1] = source[i - intCount - 1] << count
          i -= 1
        }
      }
      for i in 0..<intCount { result[i] = 0 }
    }

    static func shiftLeftOneBit(_ result: inout [Int], _ source: [Int], _ srcLen: Int) {
      var carry = 0
      for i in 0..<srcLen {
        let val = source[i]
        result[i] = (val << 1) | carry
        carry = Int(UInt32(truncatingIfNeeded: val) >> 31)
      }
      if carry != 0 { result[srcLen] = carry }
    }

    static func shiftLeftOneBit(_ source: BigInteger) -> BigInteger {
      let srcLen = source.numberLength
      let resLen = srcLen + 1
      var resDigits = [Int](repeating: 0, count: resLen)
      shiftLeftOneBit(&resDigits, source.digits, srcLen)
      let result = BigInteger(source.sign, resLen, resDigits)
      result.cutOffLeadingZeroes()
      return result
    }

    // MARK: - Shift right

    static func shiftRight(_ source: BigInteger, _ count: Int) -> BigInteger {
      let intCount = count >> 5
      let bitCount = count & 31
      if intCount >= source.numberLength {
        return source.sign < 0 ? BigInteger.MINUS_ONE : BigInteger.ZERO
      }
      let resLength = source.numberLength - intCount
      var resDigits = [Int](repeating: 0, count: resLength + 1)
      shiftRight(&resDigits, resLength, source.digits, intCount, bitCount)
      if source.sign < 0 {
        var i = 0
        while i < intCount && source.digits[i] == 0 { i += 1 }
        var resLen = resLength
        if i < intCount || (bitCount > 0 && (source.digits[i] << (32 - bitCount)) != 0) {
          var j = 0
          while j < resLen && resDigits[j] == -1 {
            resDigits[j] = 0
            j += 1
          }
          if j == resLen { resLen += 1 }
          resDigits[j] += 1
        }
        let result = BigInteger(source.sign, resLen, resDigits)
        result.cutOffLeadingZeroes()
        return result
      }
      let result = BigInteger(source.sign, resLength, resDigits)
      result.cutOffLeadingZeroes()
      return result
    }

    static func inplaceShiftRight(_ val: BigInteger, _ count: Int) {
      if count == 0 || val.signum() == 0 { return }
      let intCount = count >> 5
      val.numberLength -= intCount
      let allZero = shiftRight(&val.digits, val.numberLength, val.digits, intCount, count & 31)
      if !allZero && val.sign < 0 {
        var i = 0
        while i < val.numberLength && val.digits[i] == -1 {
          val.digits[i] = 0
          i += 1
        }
        if i == val.numberLength { val.numberLength += 1 }
        val.digits[i] += 1
      }
      val.cutOffLeadingZeroes()
      val.unCache()
    }

    @discardableResult
    static func shiftRight(_ result: inout [Int], _ resultLen: Int,
                            _ source: [Int], _ intCount: Int, _ count: Int) -> Bool {
      var allZero = true
      for i in 0..<intCount { allZero = allZero && source[i] == 0 }
      if count == 0 {
        for i in 0..<resultLen { result[i] = source[i + intCount] }
      } else {
        let leftShiftCount = 32 - count
        allZero = allZero && (source[intCount] << leftShiftCount) == 0
        for i in 0..<(resultLen - 1) {
          result[i] = Int(UInt32(truncatingIfNeeded: source[i + intCount]) >> count)
            | (source[i + intCount + 1] << leftShiftCount)
        }
        result[resultLen - 1] = Int(UInt32(truncatingIfNeeded: source[resultLen - 1 + intCount]) >> count)
      }
      return allZero
    }

    // MARK: - Flip bit

    static func flipBit(_ val: BigInteger, _ n: Int) -> BigInteger {
      let resSign = val.sign == 0 ? 1 : val.sign
      let intCount = n >> 5
      let bitN = n & 31
      let resLength = Swift.max(intCount + 1, val.numberLength) + 1
      var resDigits = [Int](repeating: 0, count: resLength)
      System.arraycopy(val.digits, 0, &resDigits, 0, val.numberLength)
      let bitNumber = 1 << bitN
      if val.sign < 0 {
        if intCount >= val.numberLength {
          resDigits[intCount] = bitNumber
        } else {
          let firstNonZeroDigit = val.getFirstNonzeroDigit()
          if intCount > firstNonZeroDigit {
            resDigits[intCount] ^= bitNumber
          } else if intCount < firstNonZeroDigit {
            resDigits[intCount] = -bitNumber
            for i in (intCount + 1)..<firstNonZeroDigit { resDigits[i] = -1 }
            resDigits[firstNonZeroDigit] = resDigits[firstNonZeroDigit] - 1 // --
          } else {
            resDigits[intCount] = -((-resDigits[intCount]) ^ bitNumber)
            if resDigits[intCount] == 0 {
              var i = intCount + 1
              while resDigits[i] == -1 {
                resDigits[i] = 0
                i += 1
              }
              resDigits[i] += 1
            }
          }
        }
      } else {
        resDigits[intCount] ^= bitNumber
      }
      let result = BigInteger(resSign, resLength, resDigits)
      result.cutOffLeadingZeroes()
      return result
    }
  }
}

// MARK: - Int helpers used by BitLevel

private extension Int {
  var nonzeroBitCount: Int {
    var n = self
    var count = 0
    while n != 0 { count += n & 1; n = Int(bitPattern: UInt(bitPattern: n) >> 1) }
    return count
  }
}
