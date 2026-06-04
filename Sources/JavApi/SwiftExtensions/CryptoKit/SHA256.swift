/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
#if canImport(CryptoKit)
#else

import Foundation

/// Pure-Swift SHA-256 implementation for platforms without CryptoKit (e.g. Linux).
/// Provides an incremental API compatible with `CryptoKit.SHA256`.
public struct SHA256 {

  // MARK: - Initial hash values (first 32 bits of fractional parts of sqrt of first 8 primes)
  private var h0: UInt32 = 0x6a09e667
  private var h1: UInt32 = 0xbb67ae85
  private var h2: UInt32 = 0x3c6ef372
  private var h3: UInt32 = 0xa54ff53a
  private var h4: UInt32 = 0x510e527f
  private var h5: UInt32 = 0x9b05688c
  private var h6: UInt32 = 0x1f83d9ab
  private var h7: UInt32 = 0x5be0cd19

  // Round constants (first 32 bits of fractional parts of cbrt of first 64 primes)
  private static let k: [UInt32] = [
    0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5,
    0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
    0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3,
    0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
    0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc,
    0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
    0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7,
    0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
    0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13,
    0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
    0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3,
    0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
    0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5,
    0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
    0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208,
    0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2
  ]

  private var byteCount: UInt64 = 0
  private var buffer: [UInt8] = []

  public init() {}

  // MARK: - Digest type

  public struct Digest: Sequence {
    let bytes: [UInt8]
    public func makeIterator() -> IndexingIterator<[UInt8]> { bytes.makeIterator() }
  }

  // MARK: - Public API

  public mutating func update(data: Data) {
    buffer.append(contentsOf: data)
    byteCount += UInt64(data.count)
    processFullBlocks()
  }

  public mutating func finalize() -> Digest {
    var padded = buffer
    let bitLength = byteCount * 8

    // Padding: append 0x80, then zeros, then 64-bit big-endian bit count
    padded.append(0x80)
    while padded.count % 64 != 56 { padded.append(0x00) }
    for i in stride(from: 56, through: 0, by: -8) {
      padded.append(UInt8((bitLength >> i) & 0xFF))
    }

    var state = (h0, h1, h2, h3, h4, h5, h6, h7)
    for blockStart in stride(from: 0, to: padded.count, by: 64) {
      state = processBlock(Array(padded[blockStart..<blockStart + 64]), state: state)
    }

    var result = [UInt8](repeating: 0, count: 32)
    for (i, word) in [state.0, state.1, state.2, state.3,
                      state.4, state.5, state.6, state.7].enumerated() {
      result[i * 4]     = UInt8((word >> 24) & 0xFF)
      result[i * 4 + 1] = UInt8((word >> 16) & 0xFF)
      result[i * 4 + 2] = UInt8((word >>  8) & 0xFF)
      result[i * 4 + 3] = UInt8( word        & 0xFF)
    }
    return Digest(bytes: result)
  }

  // MARK: - Private helpers

  private mutating func processFullBlocks() {
    while buffer.count >= 64 {
      let block = Array(buffer.prefix(64))
      buffer.removeFirst(64)
      let state = (h0, h1, h2, h3, h4, h5, h6, h7)
      let next = processBlock(block, state: state)
      (h0, h1, h2, h3, h4, h5, h6, h7) = next
    }
  }

  private func processBlock(
    _ block: [UInt8],
    state: (UInt32, UInt32, UInt32, UInt32, UInt32, UInt32, UInt32, UInt32)
  ) -> (UInt32, UInt32, UInt32, UInt32, UInt32, UInt32, UInt32, UInt32) {
    // Expand 16 x 32-bit words to 64
    var w = [UInt32](repeating: 0, count: 64)
    for i in 0..<16 {
      w[i] = (UInt32(block[i*4]) << 24)
           | (UInt32(block[i*4+1]) << 16)
           | (UInt32(block[i*4+2]) <<  8)
           |  UInt32(block[i*4+3])
    }
    for i in 16..<64 {
      let s0 = rightRotate(w[i-15], by: 7) ^ rightRotate(w[i-15], by: 18) ^ (w[i-15] >> 3)
      let s1 = rightRotate(w[i-2],  by: 17) ^ rightRotate(w[i-2],  by: 19) ^ (w[i-2]  >> 10)
      w[i] = w[i-16] &+ s0 &+ w[i-7] &+ s1
    }

    var (a, b, c, d, e, f, g, h) = state

    for i in 0..<64 {
      let S1    = rightRotate(e, by: 6) ^ rightRotate(e, by: 11) ^ rightRotate(e, by: 25)
      let ch    = (e & f) ^ (~e & g)
      let temp1 = h &+ S1 &+ ch &+ Self.k[i] &+ w[i]
      let S0    = rightRotate(a, by: 2) ^ rightRotate(a, by: 13) ^ rightRotate(a, by: 22)
      let maj   = (a & b) ^ (a & c) ^ (b & c)
      let temp2 = S0 &+ maj

      h = g; g = f; f = e
      e = d &+ temp1
      d = c; c = b; b = a
      a = temp1 &+ temp2
    }

    return (
      state.0 &+ a, state.1 &+ b, state.2 &+ c, state.3 &+ d,
      state.4 &+ e, state.5 &+ f, state.6 &+ g, state.7 &+ h
    )
  }

  @inline(__always)
  private func rightRotate(_ value: UInt32, by n: UInt32) -> UInt32 {
    return (value >> n) | (value << (32 - n))
  }
}

#endif
