/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
#if canImport(CryptoKit)
#else

import Foundation

/// Pure-Swift SHA-384 implementation for platforms without CryptoKit (e.g. Linux).
/// Provides an incremental API compatible with `CryptoKit.SHA384`.
/// SHA-384 is SHA-512 with different initial values and output truncated to 48 bytes.
public struct SHA384 {

  // MARK: - Initial hash values (SHA-384 spec)
  private var h0: UInt64 = 0xcbbb9d5dc1059ed8
  private var h1: UInt64 = 0x629a292a367cd507
  private var h2: UInt64 = 0x9159015a3070dd17
  private var h3: UInt64 = 0x152fecd8f70e5939
  private var h4: UInt64 = 0x67332667ffc00b31
  private var h5: UInt64 = 0x8eb44a8768581511
  private var h6: UInt64 = 0xdb0c2e0d64f98fa7
  private var h7: UInt64 = 0x47b5481dbefa4fa4

  // Round constants (same as SHA-512)
  private static let k: [UInt64] = [
    0x428a2f98d728ae22, 0x7137449123ef65cd, 0xb5c0fbcfec4d3b2f, 0xe9b5dba58189dbbc,
    0x3956c25bf348b538, 0x59f111f1b605d019, 0x923f82a4af194f9b, 0xab1c5ed5da6d8118,
    0xd807aa98a3030242, 0x12835b0145706fbe, 0x243185be4ee4b28c, 0x550c7dc3d5ffb4e2,
    0x72be5d74f27b896f, 0x80deb1fe3b1696b1, 0x9bdc06a725c71235, 0xc19bf174cf692694,
    0xe49b69c19ef14ad2, 0xefbe4786384f25e3, 0x0fc19dc68b8cd5b5, 0x240ca1cc77ac9c65,
    0x2de92c6f592b0275, 0x4a7484aa6ea6e483, 0x5cb0a9dcbd41fbd4, 0x76f988da831153b5,
    0x983e5152ee66dfab, 0xa831c66d2db43210, 0xb00327c898fb213f, 0xbf597fc7beef0ee4,
    0xc6e00bf33da88fc2, 0xd5a79147930aa725, 0x06ca6351e003826f, 0x142929670a0e6e70,
    0x27b70a8546d22ffc, 0x2e1b21385c26c926, 0x4d2c6dfc5ac42aed, 0x53380d139d95b3df,
    0x650a73548baf63de, 0x766a0abb3c77b2a8, 0x81c2c92e47edaee6, 0x92722c851482353b,
    0xa2bfe8a14cf10364, 0xa81a664bbc423001, 0xc24b8b70d0f89791, 0xc76c51a30654be30,
    0xd192e819d6ef5218, 0xd69906245565a910, 0xf40e35855771202a, 0x106aa07032bbd1b8,
    0x19a4c116b8d2d0c8, 0x1e376c085141ab53, 0x2748774cdf8eeb99, 0x34b0bcb5e19b48a8,
    0x391c0cb3c5c95a63, 0x4ed8aa4ae3418acb, 0x5b9cca4f7763e373, 0x682e6ff3d6b2b8a3,
    0x748f82ee5defb2fc, 0x78a5636f43172f60, 0x84c87814a1f0ab72, 0x8cc702081a6439ec,
    0x90befffa23631e28, 0xa4506cebde82bde9, 0xbef9a3f7b2c67915, 0xc67178f2e372532b,
    0xca273eceea26619c, 0xd186b8c721c0c207, 0xeada7dd6cde0eb1e, 0xf57d4f7fee6ed178,
    0x06f067aa72176fba, 0x0a637dc5a2c898a6, 0x113f9804bef90dae, 0x1b710b35131c471b,
    0x28db77f523047d84, 0x32caab7b40c72493, 0x3c9ebe0a15c9bebc, 0x431d67c49c100d4c,
    0x4cc5d4becb3e42b6, 0x597f299cfc657e2a, 0x5fcb6fab3ad6faec, 0x6c44198c4a475817
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

    // SHA-512 padding: append 0x80, zeros, then 128-bit big-endian bit count
    // (high 64 bits are always 0 for practical inputs)
    padded.append(0x80)
    while padded.count % 128 != 112 { padded.append(0x00) }
    // High 64 bits of bit length (always 0)
    for _ in 0..<8 { padded.append(0x00) }
    // Low 64 bits of bit length
    for i in stride(from: 56, through: 0, by: -8) {
      padded.append(UInt8((bitLength >> i) & 0xFF))
    }

    var state = (h0, h1, h2, h3, h4, h5, h6, h7)
    for blockStart in stride(from: 0, to: padded.count, by: 128) {
      state = processBlock(Array(padded[blockStart..<blockStart + 128]), state: state)
    }

    // SHA-384: first 6 x 64-bit words = 48 bytes
    var result = [UInt8](repeating: 0, count: 48)
    for (i, word) in [state.0, state.1, state.2, state.3, state.4, state.5].enumerated() {
      for j in 0..<8 {
        result[i * 8 + j] = UInt8((word >> (56 - j * 8)) & 0xFF)
      }
    }
    return Digest(bytes: result)
  }

  // MARK: - Private helpers

  private mutating func processFullBlocks() {
    while buffer.count >= 128 {
      let block = Array(buffer.prefix(128))
      buffer.removeFirst(128)
      let state = (h0, h1, h2, h3, h4, h5, h6, h7)
      let next = processBlock(block, state: state)
      (h0, h1, h2, h3, h4, h5, h6, h7) = next
    }
  }

  private func processBlock(
    _ block: [UInt8],
    state: (UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64)
  ) -> (UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64) {
    // Expand 16 x 64-bit words to 80
    var w = [UInt64](repeating: 0, count: 80)
    for i in 0..<16 {
      w[i] = (UInt64(block[i*8])   << 56) | (UInt64(block[i*8+1]) << 48)
           | (UInt64(block[i*8+2]) << 40) | (UInt64(block[i*8+3]) << 32)
           | (UInt64(block[i*8+4]) << 24) | (UInt64(block[i*8+5]) << 16)
           | (UInt64(block[i*8+6]) <<  8) |  UInt64(block[i*8+7])
    }
    for i in 16..<80 {
      let s0 = rightRotate(w[i-15], by: 1)  ^ rightRotate(w[i-15], by: 8)  ^ (w[i-15] >> 7)
      let s1 = rightRotate(w[i-2],  by: 19) ^ rightRotate(w[i-2],  by: 61) ^ (w[i-2]  >> 6)
      w[i] = w[i-16] &+ s0 &+ w[i-7] &+ s1
    }

    var (a, b, c, d, e, f, g, h) = state

    for i in 0..<80 {
      let S1    = rightRotate(e, by: 14) ^ rightRotate(e, by: 18) ^ rightRotate(e, by: 41)
      let ch    = (e & f) ^ (~e & g)
      let temp1 = h &+ S1 &+ ch &+ Self.k[i] &+ w[i]
      let S0    = rightRotate(a, by: 28) ^ rightRotate(a, by: 34) ^ rightRotate(a, by: 39)
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
  private func rightRotate(_ value: UInt64, by n: UInt64) -> UInt64 {
    return (value >> n) | (value << (64 - n))
  }
}

#endif
