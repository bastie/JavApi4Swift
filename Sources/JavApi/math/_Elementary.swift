/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com> and contributors
 * SPDX-License-Identifier: Apache-2.0
 */

extension java.math {

  /// Static library providing basic arithmetic mutable operations for BigInteger.
  struct _Elementary {

    // MARK: - Compare

    /// Compares two arrays. All elements are treated as unsigned 32-bit integers.
    /// - Returns: `BigInteger.GREATER`, `BigInteger.LESS`, or `BigInteger.EQUALS`
    static func compareArrays(_ a: [Int], _ b: [Int], _ size: Int) -> Int {
      var i = size - 1
      while i >= 0 && a[i] == b[i] { i -= 1 }
      guard i >= 0 else { return BigInteger.EQUALS }
      let ai = UInt32(truncatingIfNeeded: a[i])
      let bi = UInt32(truncatingIfNeeded: b[i])
      return ai < bi ? BigInteger.LESS : BigInteger.GREATER
    }

    // MARK: - Add (immutable)

    /// Returns `op1 + op2`.
    static func add(_ op1: BigInteger, _ op2: BigInteger) -> BigInteger {
      let op1Sign = op1.sign
      let op2Sign = op2.sign
      if op1Sign == 0 { return op2 }
      if op2Sign == 0 { return op1 }
      let op1Len = op1.numberLength
      let op2Len = op2.numberLength

      if op1Len + op2Len == 2 {
        let a = Int64(op1.digits[0]) & 0xFFFFFFFF
        let b = Int64(op2.digits[0]) & 0xFFFFFFFF
        if op1Sign == op2Sign {
          let res = a + b
          let lo = Int(UInt32(truncatingIfNeeded: res))
          let hi = Int(UInt32(truncatingIfNeeded: res >> 32))
          return hi == 0
            ? BigInteger(op1Sign, lo)
            : BigInteger(op1Sign, 2, [lo, hi])
        }
        return BigInteger.valueOf(op1Sign < 0 ? b - a : a - b)
      }

      let resSign: Int
      let resDigits: [Int]
      if op1Sign == op2Sign {
        resSign = op1Sign
        resDigits = op1Len >= op2Len
          ? addArrays(op1.digits, op1Len, op2.digits, op2Len)
          : addArrays(op2.digits, op2Len, op1.digits, op1Len)
      } else {
        let cmp = op1Len != op2Len
          ? (op1Len > op2Len ? 1 : -1)
          : compareArrays(op1.digits, op2.digits, op1Len)
        if cmp == BigInteger.EQUALS { return BigInteger.ZERO }
        if cmp == BigInteger.GREATER {
          resSign = op1Sign
          resDigits = subtractArrays(op1.digits, op1Len, op2.digits, op2Len)
        } else {
          resSign = op2Sign
          resDigits = subtractArrays(op2.digits, op2Len, op1.digits, op1Len)
        }
      }
      let result = BigInteger(resSign, resDigits.count, resDigits)
      result.cutOffLeadingZeroes()
      return result
    }

    /// Returns `op1 - op2`.
    static func subtract(_ op1: BigInteger, _ op2: BigInteger) -> BigInteger {
      let op1Sign = op1.sign
      let op2Sign = op2.sign
      if op2Sign == 0 { return op1 }
      if op1Sign == 0 { return op2.negate() }
      let op1Len = op1.numberLength
      let op2Len = op2.numberLength

      if op1Len + op2Len == 2 {
        var a = Int64(op1.digits[0]) & 0xFFFFFFFF
        var b = Int64(op2.digits[0]) & 0xFFFFFFFF
        if op1Sign < 0 { a = -a }
        if op2Sign < 0 { b = -b }
        return BigInteger.valueOf(a - b)
      }

      let cmp = op1Len != op2Len
        ? (op1Len > op2Len ? 1 : -1)
        : _Elementary.compareArrays(op1.digits, op2.digits, op1Len)

      let resSign: Int
      let resDigits: [Int]
      if cmp == BigInteger.LESS {
        resSign = -op2Sign
        resDigits = op1Sign == op2Sign
          ? subtractArrays(op2.digits, op2Len, op1.digits, op1Len)
          : addArrays(op2.digits, op2Len, op1.digits, op1Len)
      } else {
        resSign = op1Sign
        if op1Sign == op2Sign {
          if cmp == BigInteger.EQUALS { return BigInteger.ZERO }
          resDigits = subtractArrays(op1.digits, op1Len, op2.digits, op2Len)
        } else {
          resDigits = addArrays(op1.digits, op1Len, op2.digits, op2Len)
        }
      }
      let result = BigInteger(resSign, resDigits.count, resDigits)
      result.cutOffLeadingZeroes()
      return result
    }

    // MARK: - Inplace operations (mutate op1)

    /// `op1 += op2`  (PRE: op1 >= op2 > 0)
    static func inplaceAdd(_ op1: BigInteger, _ op2: BigInteger) {
      addInto(&op1.digits, op1.digits, op1.numberLength, op2.digits, op2.numberLength)
      op1.numberLength = Swift.min(
        Swift.max(op1.numberLength, op2.numberLength) + 1,
        op1.digits.count)
      op1.cutOffLeadingZeroes()
      op1.unCache()
    }

    /// Adds `addend` to array `a` of length `aSize`. Returns carry (0 or 1).
    @discardableResult
    static func inplaceAdd(_ a: inout [Int], _ aSize: Int, _ addend: Int) -> Int {
      var carry = Int64(addend) & 0xFFFFFFFF
      var i = 0
      while carry != 0 && i < aSize {
        carry += Int64(a[i]) & 0xFFFFFFFF
        a[i] = Int(UInt32(truncatingIfNeeded: carry))
        carry >>= 32
        i += 1
      }
      return Int(UInt32(truncatingIfNeeded: carry))
    }

    /// `op1 += addend`  (op1 must have room for a possible carry)
    static func inplaceAdd(_ op1: BigInteger, _ addend: Int) {
      let carry = inplaceAdd(&op1.digits, op1.numberLength, addend)
      if carry == 1 {
        op1.digits[op1.numberLength] = 1
        op1.numberLength += 1
      }
      op1.unCache()
    }

    /// `op1 -= op2`  (PRE: op1 >= op2 > 0)
    static func inplaceSubtract(_ op1: BigInteger, _ op2: BigInteger) {
      subtractInto(&op1.digits, op1.digits, op1.numberLength, op2.digits, op2.numberLength)
      op1.cutOffLeadingZeroes()
      op1.unCache()
    }

    /// `op1 -= op2` without sign restrictions. op1 must have enough space.
    static func completeInPlaceSubtract(_ op1: BigInteger, _ op2: BigInteger) {
      let resultSign = op1.compareTo(op2)
      if op1.sign == 0 {
        try! System.arraycopy(op2.digits, 0, &op1.digits, 0, op2.numberLength)
        op1.sign = -op2.sign
      } else if op1.sign != op2.sign {
        addInto(&op1.digits, op1.digits, op1.numberLength, op2.digits, op2.numberLength)
        op1.sign = resultSign
      } else {
        let sign = unsignedArraysCompare(op1.digits, op2.digits, op1.numberLength, op2.numberLength)
        if sign > 0 {
          subtractInto(&op1.digits, op1.digits, op1.numberLength, op2.digits, op2.numberLength)
        } else {
          inverseSubtract(&op1.digits, op1.digits, op1.numberLength, op2.digits, op2.numberLength)
          op1.sign = -op1.sign
        }
      }
      op1.numberLength = Swift.max(op1.numberLength, op2.numberLength) + 1
      op1.cutOffLeadingZeroes()
      op1.unCache()
    }

    /// `op1 += op2` without sign restrictions.
    static func completeInPlaceAdd(_ op1: BigInteger, _ op2: BigInteger) {
      if op1.sign == 0 {
        try! System.arraycopy(op2.digits, 0, &op1.digits, 0, op2.numberLength)
      } else if op2.sign == 0 {
        return
      } else if op1.sign == op2.sign {
        addInto(&op1.digits, op1.digits, op1.numberLength, op2.digits, op2.numberLength)
      } else {
        let sign = unsignedArraysCompare(op1.digits, op2.digits, op1.numberLength, op2.numberLength)
        if sign > 0 {
          subtractInto(&op1.digits, op1.digits, op1.numberLength, op2.digits, op2.numberLength)
        } else {
          inverseSubtract(&op1.digits, op1.digits, op1.numberLength, op2.digits, op2.numberLength)
          op1.sign = -op1.sign
        }
      }
      op1.numberLength = Swift.max(op1.numberLength, op2.numberLength) + 1
      op1.cutOffLeadingZeroes()
      op1.unCache()
    }

    // MARK: - Private helpers

    /// Fills `res = a + b` (res, a, b are digit arrays).
    private static func addInto(_ res: inout [Int], _ a: [Int], _ aSize: Int,
                                 _ b: [Int], _ bSize: Int) {
      var i: Int
      var carry = (Int64(a[0]) & 0xFFFFFFFF) + (Int64(b[0]) & 0xFFFFFFFF)
      res[0] = Int(UInt32(truncatingIfNeeded: carry))
      carry >>= 32

      if aSize >= bSize {
        for j in 1..<bSize {
          carry += (Int64(a[j]) & 0xFFFFFFFF) + (Int64(b[j]) & 0xFFFFFFFF)
          res[j] = Int(UInt32(truncatingIfNeeded: carry))
          carry >>= 32
        }
        i = bSize
        while i < aSize {
          carry += Int64(a[i]) & 0xFFFFFFFF
          res[i] = Int(UInt32(truncatingIfNeeded: carry))
          carry >>= 32
          i += 1
        }
      } else {
        for j in 1..<aSize {
          carry += (Int64(a[j]) & 0xFFFFFFFF) + (Int64(b[j]) & 0xFFFFFFFF)
          res[j] = Int(UInt32(truncatingIfNeeded: carry))
          carry >>= 32
        }
        i = aSize
        while i < bSize {
          carry += Int64(b[i]) & 0xFFFFFFFF
          res[i] = Int(UInt32(truncatingIfNeeded: carry))
          carry >>= 32
          i += 1
        }
      }
      if carry != 0 {
        res[i] = Int(UInt32(truncatingIfNeeded: carry))
      }
    }

    /// Returns `a + b` as a new array of size `aSize + 1`.
    private static func addArrays(_ a: [Int], _ aSize: Int,
                                   _ b: [Int], _ bSize: Int) -> [Int] {
      var res = [Int](repeating: 0, count: aSize + 1)
      addInto(&res, a, aSize, b, bSize)
      return res
    }

    /// Fills `res = a - b` (PRE: a >= b as unsigned magnitude).
    static func subtractInto(_ res: inout [Int], _ a: [Int], _ aSize: Int,
                              _ b: [Int], _ bSize: Int) {
      var borrow: Int64 = 0
      for i in 0..<bSize {
        borrow += (Int64(a[i]) & 0xFFFFFFFF) - (Int64(b[i]) & 0xFFFFFFFF)
        res[i] = Int(UInt32(truncatingIfNeeded: borrow))
        borrow >>= 32
      }
      for i in bSize..<aSize {
        borrow += Int64(a[i]) & 0xFFFFFFFF
        res[i] = Int(UInt32(truncatingIfNeeded: borrow))
        borrow >>= 32
      }
    }

    /// Returns `a - b` as a new array of size `aSize`.
    private static func subtractArrays(_ a: [Int], _ aSize: Int,
                                        _ b: [Int], _ bSize: Int) -> [Int] {
      var res = [Int](repeating: 0, count: aSize)
      subtractInto(&res, a, aSize, b, bSize)
      return res
    }

    /// Fills `res = b - a`.
    private static func inverseSubtract(_ res: inout [Int], _ a: [Int], _ aSize: Int,
                                         _ b: [Int], _ bSize: Int) {
      var borrow: Int64 = 0
      let minSize = Swift.min(aSize, bSize)
      for i in 0..<minSize {
        borrow += (Int64(b[i]) & 0xFFFFFFFF) - (Int64(a[i]) & 0xFFFFFFFF)
        res[i] = Int(UInt32(truncatingIfNeeded: borrow))
        borrow >>= 32
      }
      if aSize < bSize {
        for i in aSize..<bSize {
          borrow += Int64(b[i]) & 0xFFFFFFFF
          res[i] = Int(UInt32(truncatingIfNeeded: borrow))
          borrow >>= 32
        }
      } else {
        for i in bSize..<aSize {
          borrow -= Int64(a[i]) & 0xFFFFFFFF
          res[i] = Int(UInt32(truncatingIfNeeded: borrow))
          borrow >>= 32
        }
      }
    }

    private static func unsignedArraysCompare(_ a: [Int], _ b: [Int],
                                               _ aSize: Int, _ bSize: Int) -> Int {
      if aSize > bSize { return 1 }
      if aSize < bSize { return -1 }
      var i = aSize - 1
      while i >= 0 && a[i] == b[i] { i -= 1 }
      if i < 0 { return BigInteger.EQUALS }
      let ai = UInt32(truncatingIfNeeded: a[i])
      let bi = UInt32(truncatingIfNeeded: b[i])
      return ai < bi ? BigInteger.LESS : BigInteger.GREATER
    }
  }
}
