/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: Apache-2.0
 */

extension java.math {

  enum Conversion {

    /// Max exponent for each radix such that radix^digitFitInInt[radix] fits in Int32.
    static let digitFitInInt: [Int] = [
      -1, -1, 31, 19, 15, 13, 11, 11, 10, 9, 9, 8, 8, 8, 8, 7, 7, 7, 7, 7,
      7, 7, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 5
    ]

    /// Precomputed maximal powers of radices 2..36 that fit in unsigned Int32.
    static let bigRadices: [Int] = [
      -2147483648, 1162261467, 1073741824, 1220703125, 362797056,
      1977326743, 1073741824, 387420489, 1000000000, 214358881, 429981696,
      815730721, 1475789056, 170859375, 268435456, 410338673, 612220032,
      893871739, 1280000000, 1801088541, 113379904, 148035889, 191102976,
      244140625, 308915776, 387420489, 481890304, 594823321, 729000000,
      887503681, 1073741824, 1291467969, 1544804416, 1838265625, 60466176
    ]

    // MARK: - String conversion

    static func bigInteger2String(_ val: BigInteger, _ radix: Int) -> String {
      if val.sign == 0 { return "0" }
      if val.numberLength == 1 {
        let v = val.sign < 0
          ? -(Int64(val.digits[0]) & 0xFFFFFFFF)
          :  (Int64(val.digits[0]) & 0xFFFFFFFF)
        return String(v, radix: radix)
      }
      if radix == 10 || radix < 2 || radix > 36 { return bigInteger2DecimalString(val) }
      let bitsForRadixDigit = Math.log(Double(radix)) / Math.log(2.0)
      let resLen = Int(Double(val.abs().bitLength()) / bitsForRadixDigit + (val.sign < 0 ? 1 : 0)) + 1
      var result = [Character](repeating: "0", count: resLen)
      var currentChar = resLen
      if radix == 16 {
        for i in 0..<val.numberLength {
          for j in 0..<8 {
            guard currentChar > 0 else { break }
            let resDigit = (val.digits[i] >> (j << 2)) & 0xf
            currentChar -= 1
            result[currentChar] = Character(String(resDigit, radix: 16))
          }
        }
      } else {
        var temp = val.digits
        var tempLen = val.numberLength
        let charsPerInt = digitFitInInt[radix]
        let bigRadix = bigRadices[radix - 2]
        while true {
          var resDigit = Division.divideArrayByInt(&temp, temp, tempLen, bigRadix)
          let previous = currentChar
          repeat {
            currentChar -= 1
            result[currentChar] = Character(String(resDigit % radix, radix: radix))
            resDigit /= radix
          } while resDigit != 0 && currentChar != 0
          let delta = charsPerInt - previous + currentChar
          var i = 0; while i < delta && currentChar > 0 { result[currentChar - 1] = "0"; currentChar -= 1; i += 1 }
          var j = tempLen - 1; while j > 0 && temp[j] == 0 { j -= 1 }
          tempLen = j + 1
          if tempLen == 1 && temp[0] == 0 { break }
        }
      }
      while result[currentChar] == "0" { currentChar += 1 }
      if val.sign == -1 { currentChar -= 1; result[currentChar] = "-" }
      return String(result[currentChar...])
    }

    private static func bigInteger2DecimalString(_ val: BigInteger) -> String {
      if val.sign == 0 { return "0" }
      let resLen = val.numberLength * 10 + 1
      var result = [Character](repeating: "0", count: resLen)
      var currentChar = resLen
      var temp = val.digits
      var tempLen = val.numberLength
      while true {
        var result11: Int64 = 0
        for i1 in stride(from: tempLen - 1, through: 0, by: -1) {
          let t1 = (result11 << 32) + (Int64(temp[i1]) & 0xFFFFFFFF)
          let res = divideLongByBillion(t1)
          temp[i1] = Int(truncatingIfNeeded: res)
          result11 = res >> 32
        }
        var resDigit = Int(truncatingIfNeeded: result11)
        repeat {
          currentChar -= 1
          result[currentChar] = Character(String(resDigit % 10))
          resDigit /= 10
        } while resDigit != 0 && currentChar != 0
        let delta = 9 - (resLen - currentChar) % 9
        var i = 0; while i < delta && currentChar > 0 { currentChar -= 1; result[currentChar] = "0"; i += 1 }
        var j = tempLen - 1; while j > 0 && temp[j] == 0 { j -= 1 }
        if j == 0 && temp[0] == 0 { break }
        tempLen = j + 1
      }
      while result[currentChar] == "0" { currentChar += 1 }
      if val.sign < 0 { currentChar -= 1; result[currentChar] = "-" }
      return String(result[currentChar...])
    }

    static func divideLongByBillion(_ a: Int64) -> Int64 {
      let bLong: Int64 = 1_000_000_000
      var quot: Int64, rem: Int64
      if a >= 0 {
        quot = a / bLong; rem = a % bLong
      } else {
        let aPos = Int64(bitPattern: UInt64(bitPattern: a) >> 1)
        let bPos: Int64 = 1_000_000_000 >> 1
        quot = aPos / bPos; rem = aPos % bPos
        rem = (rem << 1) + (a & 1)
      }
      return (rem << 32) | (quot & 0xFFFFFFFF)
    }

    static func toDecimalScaledString(_ val: BigInteger, _ scale: Int) -> String {
      // Used by BigDecimal
      if val.sign == 0 {
        if scale == 0 { return "0" }
        if scale > 0 { return "0." + String(repeating: "0", count: scale) }
        return "0E+" + String(-scale)
      }
      let raw = bigInteger2DecimalString(val.abs())
      let digits = Array(raw)
      let negative = val.sign < 0
      var result = ""
      if negative { result = "-" }
      let intDigits = digits.count
      let exponent = intDigits - scale - 1
      if scale <= 0 {
        result += raw
        if scale < 0 { result += "E+" + String(-scale) }
      } else if exponent >= 0 {
        result += String(digits[0]) + "." + String(digits[1...]) + (scale > 0 ? "" : "")
        // simplified: just insert decimal point
        let dotPos = intDigits - scale
        if dotPos >= intDigits {
          result = (negative ? "-" : "") + raw
        } else if dotPos <= 0 {
          result = (negative ? "-" : "") + "0." + String(repeating: "0", count: -dotPos) + raw
        } else {
          result = (negative ? "-" : "") + String(digits[..<dotPos]) + "." + String(digits[dotPos...])
        }
      } else {
        result = (negative ? "-" : "") + "0." + String(repeating: "0", count: -exponent - 1) + raw
      }
      return result
    }

    // MARK: - Parsing

    static func setFromString(_ bi: BigInteger, _ val: String, _ radix: Int) throws(NumberFormatException) {
      var stringLength = val.count
      let startChar: Int
      let sign: Int
      if val.first == "-" {
        sign = -1; startChar = 1; stringLength -= 1
      } else {
        sign = 1; startChar = 0
      }
      let charsPerInt = digitFitInInt[radix]
      var bigRadixDigitsLength = stringLength / charsPerInt
      let topChars = stringLength % charsPerInt
      if topChars != 0 { bigRadixDigitsLength += 1 }
      var digits = [Int](repeating: 0, count: bigRadixDigitsLength)
      let bigRadix = bigRadices[radix - 2]
      var digitIndex = 0
      let chars = Array(val)
      var substrStart = startChar
      let substrStep = charsPerInt
      let firstChunk = topChars == 0 ? charsPerInt : topChars
      var substrEnd = startChar + firstChunk
      while substrStart < startChar + stringLength {
        let chunk = String(chars[substrStart..<substrEnd])
        guard let bigRadixDigit = Int(chunk, radix: radix) else {
          throw NumberFormatException("Invalid character in BigInteger string")
        }
        var newDigit = Multiplication.multiplyByInt(&digits, digitIndex, bigRadix)
        newDigit += Elementary.inplaceAdd(&digits, digitIndex, bigRadixDigit)
        digits[digitIndex] = newDigit
        digitIndex += 1
        substrStart = substrEnd
        substrEnd = substrStart + substrStep
      }
      bi.sign = sign
      bi.numberLength = digitIndex
      bi.digits = digits
      bi.cutOffLeadingZeroes()
    }

    // MARK: - Double conversion

    static func bigInteger2Double(_ val: BigInteger) -> Double {
      if val.numberLength < 2 || (val.numberLength == 2 && val.digits[1] > 0) {
        return Double(val.longValue())
      }
      if val.numberLength > 32 {
        return val.sign > 0 ? Double.infinity : -Double.infinity
      }
      let bitLen = val.abs().bitLength()
      let exponent = Int64(bitLen - 1)
      let delta = bitLen - 54
      let lVal = val.abs().shiftRight(delta).longValue()
      var mantissa = lVal & Int64(0x1FFFFFFFFFFFFF)
      if exponent == 1023 {
        if mantissa == Int64(0x1FFFFFFFFFFFFF) { return val.sign > 0 ? Double.infinity : -Double.infinity }
        if mantissa == Int64(0x1FFFFFFFFFFFFE) { return val.sign > 0 ? Double.greatestFiniteMagnitude : -Double.greatestFiniteMagnitude }
      }
      if ((mantissa & 1) == 1) && (((mantissa & 2) == 2) || BitLevel.nonZeroDroppedBits(delta, val.digits)) {
        mantissa += 2
      }
      mantissa = mantissa >> 1
      let resSign: Int64 = val.sign < 0 ? Int64(bitPattern: 0x8000000000000000) : 0
      let exp = ((1023 + exponent) << 52) & 0x7FF0000000000000
      let bits = resSign | exp | mantissa
      return Double(bitPattern: UInt64(bitPattern: bits))
    }
  }
}
