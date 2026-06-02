/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: Apache-2.0
 */

extension java.math {

  enum Primality {

    // MARK: - Tables

    private static let primes: [Int] = [
      2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61,
      67, 71, 73, 79, 83, 89, 97, 101, 103, 107, 109, 113, 127, 131, 137,
      139, 149, 151, 157, 163, 167, 173, 179, 181, 191, 193, 197, 199, 211,
      223, 227, 229, 233, 239, 241, 251, 257, 263, 269, 271, 277, 281, 283,
      293, 307, 311, 313, 317, 331, 337, 347, 349, 353, 359, 367, 373, 379,
      383, 389, 397, 401, 409, 419, 421, 431, 433, 439, 443, 449, 457, 461,
      463, 467, 479, 487, 491, 499, 503, 509, 521, 523, 541, 547, 557, 563,
      569, 571, 577, 587, 593, 599, 601, 607, 613, 617, 619, 631, 641, 643,
      647, 653, 659, 661, 673, 677, 683, 691, 701, 709, 719, 727, 733, 739,
      743, 751, 757, 761, 769, 773, 787, 797, 809, 811, 821, 823, 827, 829,
      839, 853, 857, 859, 863, 877, 881, 883, 887, 907, 911, 919, 929, 937,
      941, 947, 953, 967, 971, 977, 983, 991, 997, 1009, 1013, 1019, 1021
    ]

    private static let BIprimes: [BigInteger] = primes.map { BigInteger.valueOf(Int64($0)) }

    /// Miller-Rabin iteration counts for error ≤ 2^(-100).
    private static let BITS: [Int] = [
      0, 0, 1854, 1233, 927, 747, 627, 543, 480, 431, 393, 361, 335, 314,
      295, 279, 265, 253, 242, 232, 223, 216, 181, 169, 158, 150, 145, 140,
      136, 132, 127, 123, 119, 114, 110, 105, 101, 96, 92, 87, 83, 78, 73,
      69, 64, 59, 54, 49, 44, 38, 32, 26, 1
    ]

    /// `offsetPrimes[i]` = (startIndex, count) of i-bit primes in the table.
    private static let offsetPrimes: [(Int, Int)?] = [
      nil, nil, (0, 2), (2, 2), (4, 2), (6, 5), (11, 7),
      (18, 13), (31, 23), (54, 43), (97, 75)
    ]

    // MARK: - Public API

    static func nextProbablePrime(_ n: BigInteger) throws -> BigInteger {
      if n.numberLength == 1 && n.digits[0] >= 0
          && n.digits[0] < primes[primes.count - 1] {
        var i = 0
        while n.digits[0] >= primes[i] { i += 1 }
        return BIprimes[i]
      }
      let gapSize = 1024
      var modules = [Int](repeating: 0, count: primes.count)
      var isDivisible = [Bool](repeating: false, count: gapSize)
      let startPoint = BigInteger(1, n.numberLength, [Int](repeating: 0, count: n.numberLength + 1))
      System.arraycopy(n.digits, 0, &startPoint.digits, 0, n.numberLength)
      if try n.testBit(0) {
        Elementary.inplaceAdd(startPoint, 2)
      } else {
        startPoint.digits[0] |= 1
      }
      var j = startPoint.bitLength()
      var certainty = 2
      while j < BITS[certainty] { certainty += 1 }
      for i in 0..<primes.count {
        modules[i] = Division.remainder(startPoint, primes[i]) - gapSize
      }
      while true {
        for i in 0..<gapSize { isDivisible[i] = false }
        for i in 0..<primes.count {
          modules[i] = (modules[i] + gapSize) % primes[i]
          j = modules[i] == 0 ? 0 : (primes[i] - modules[i])
          while j < gapSize {
            isDivisible[j] = true
            j += primes[i]
          }
        }
        for j in 0..<gapSize {
          if !isDivisible[j] {
            let probPrime = startPoint.copy()
            Elementary.inplaceAdd(probPrime, j)
            if try millerRabin(probPrime, certainty) { return probPrime }
          }
        }
        Elementary.inplaceAdd(startPoint, gapSize)
      }
    }

    static func consBigInteger(_ bitLength: Int, _ certainty: Int,
                                _ rnd: java.util.Random) throws -> BigInteger {
      if bitLength <= 10 {
        let rp = offsetPrimes[bitLength]!
        let next = try rnd.nextInt(rp.1)
        return BIprimes[rp.0 + next]
      }
      let shiftCount = (-bitLength) & 31
      let last = (bitLength + 31) >> 5
      let n = BigInteger(1, last, [Int](repeating: 0, count: last))
      repeat {
        for i in 0..<n.numberLength { n.digits[i] = rnd.nextInt() }
        n.digits[last - 1] |= Int(bitPattern: 0x80000000)
        if shiftCount != 0 {
          n.digits[last - 1] = Int(bitPattern: UInt(bitPattern: n.digits[last - 1]) >> shiftCount)
        }
        n.digits[0] |= 1
      } while try !isProbablePrime(n, certainty)
      return n
    }

    static func isProbablePrime(_ n: BigInteger, _ certainty: Int) throws -> Bool {
      if certainty <= 0 || (n.numberLength == 1 && n.digits[0] == 2) { return true }
      if try !n.testBit(0) { return false }
      if n.numberLength == 1 && (n.digits[0] & 0x7FFFFC00) == 0 {
        return primes.binarySearch(n.digits[0]) >= 0
      }
      for i in 1..<primes.count {
        if Division.remainderArrayByInt(n.digits, n.numberLength, primes[i]) == 0 { return false }
      }
      let bitLength = n.bitLength()
      var i = 2
      while bitLength < BITS[i] { i += 1 }
      let cert = Swift.min(i, 1 + ((certainty - 1) >> 1))
      return try millerRabin(n, cert)
    }

    // MARK: - Miller-Rabin

    private static func millerRabin(_ n: BigInteger, _ t: Int) throws -> Bool {
      let nMinus1 = n.subtract(BigInteger.ONE)
      let bitLength = nMinus1.bitLength()
      let k = nMinus1.getLowestSetBit()
      let q = nMinus1.shiftRight(k)
      let rnd = java.util.Random()
      for i in 0..<t {
        let x: BigInteger
        if i < primes.count {
          x = BIprimes[i]
        } else {
          var candidate: BigInteger
          repeat {
            candidate = try BigInteger(bitLength, rnd)
          } while candidate.compareTo(n) >= BigInteger.EQUALS || candidate.sign == 0 || candidate.isOne()
          x = candidate
        }
        var y = try! x.modPow(q, n)
        if y.isOne() || y.equals(nMinus1 as AnyObject) { continue }
        var j = 1
        while j < k {
          if y.equals(nMinus1 as AnyObject) { break }
          y = try! y.multiply(y).mod(n)
          if y.isOne() { return false }
          j += 1
        }
        if !y.equals(nMinus1 as AnyObject) { return false }
      }
      return true
    }
  }
}

// MARK: - Helpers

private extension Array where Element == Int {
  func binarySearch(_ value: Int) -> Int {
    var lo = 0, hi = count - 1
    while lo <= hi {
      let mid = (lo + hi) >> 1
      if self[mid] == value { return mid }
      if self[mid] < value { lo = mid + 1 } else { hi = mid - 1 }
    }
    return -1
  }
}
