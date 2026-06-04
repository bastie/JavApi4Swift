/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
#if canImport(CryptoKit)
#else

import Foundation

extension Insecure {

  /// Pure-Swift SHA-1 implementation for platforms without CryptoKit (e.g. Linux).
  /// Provides an incremental API compatible with `CryptoKit.Insecure.SHA1`.
  public struct SHA1 {

    // MARK: - Initial hash values (SHA-1 spec)
    private var h0: UInt32 = 0x67452301
    private var h1: UInt32 = 0xEFCDAB89
    private var h2: UInt32 = 0x98BADCFE
    private var h3: UInt32 = 0x10325476
    private var h4: UInt32 = 0xC3D2E1F0

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

      // Padding: append 0x80 then zeros, then 64-bit big-endian bit count
      padded.append(0x80)
      while padded.count % 64 != 56 { padded.append(0x00) }
      for i in stride(from: 56, through: 0, by: -8) {
        padded.append(UInt8((bitLength >> i) & 0xFF))
      }

      var h = (h0, h1, h2, h3, h4)
      for blockStart in stride(from: 0, to: padded.count, by: 64) {
        h = processBlock(Array(padded[blockStart..<blockStart + 64]), state: h)
      }

      var result = [UInt8](repeating: 0, count: 20)
      for (i, word) in [h.0, h.1, h.2, h.3, h.4].enumerated() {
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
        let state = (h0, h1, h2, h3, h4)
        let next = processBlock(block, state: state)
        (h0, h1, h2, h3, h4) = next
      }
    }

    private func processBlock(_ block: [UInt8],
                               state: (UInt32, UInt32, UInt32, UInt32, UInt32)
    ) -> (UInt32, UInt32, UInt32, UInt32, UInt32) {
      // Expand 16 x 32-bit words to 80
      var w = [UInt32](repeating: 0, count: 80)
      for i in 0..<16 {
        w[i] = (UInt32(block[i*4]) << 24)
             | (UInt32(block[i*4+1]) << 16)
             | (UInt32(block[i*4+2]) <<  8)
             |  UInt32(block[i*4+3])
      }
      for i in 16..<80 {
        w[i] = leftRotate(w[i-3] ^ w[i-8] ^ w[i-14] ^ w[i-16], by: 1)
      }

      var (a, b, c, d, e) = state

      for i in 0..<80 {
        let (f, k): (UInt32, UInt32)
        switch i {
        case  0..<20: f = (b & c) | (~b & d);           k = 0x5A827999
        case 20..<40: f = b ^ c ^ d;                    k = 0x6ED9EBA1
        case 40..<60: f = (b & c) | (b & d) | (c & d); k = 0x8F1BBCDC
        default:      f = b ^ c ^ d;                    k = 0xCA62C1D6
        }
        let temp = leftRotate(a, by: 5) &+ f &+ e &+ k &+ w[i]
        e = d; d = c; c = leftRotate(b, by: 30); b = a; a = temp
      }

      return (state.0 &+ a, state.1 &+ b, state.2 &+ c, state.3 &+ d, state.4 &+ e)
    }

    @inline(__always)
    private func leftRotate(_ value: UInt32, by n: UInt32) -> UInt32 {
      return (value << n) | (value >> (32 - n))
    }
  }
}

#endif
