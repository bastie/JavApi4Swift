/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
/*
 * Pure-Swift DEFLATE compressor (RFC 1951 / zlib RFC 1950).
 * No system libraries, no Foundation — runs on Apple, Linux (Glibc/Musl),
 * Windows, Android, FreeBSD, and WASI.
 *
 * Algorithm: LZ77 + static/dynamic Huffman coding.
 * Limitation: this implementation uses fixed Huffman trees (no dynamic tree
 * construction) which is spec-compliant but produces slightly larger output
 * than full zlib.  Dynamic Huffman can be added later as an optimisation
 * without changing the public API.
 */

extension java.util.zip {

  /// Compresses data using the DEFLATE algorithm (RFC 1951).
  ///
  /// Typical usage mirrors the Java API:
  /// ```swift
  /// let deflater = Deflater()
  /// deflater.setInput(inputBytes)
  /// deflater.finish()
  /// var output = [UInt8](repeating: 0, count: 4096)
  /// let n = deflater.deflate(&output, 0, output.count)
  /// deflater.end()
  /// ```
  final public class Deflater : @unchecked Sendable {

    // MARK: - Public constants

    /// Compression level: no compression
    public static let NO_COMPRESSION      : Int = 0
    /// Compression level: best speed
    public static let BEST_SPEED          : Int = 1
    /// Compression level: best compression
    public static let BEST_COMPRESSION    : Int = 9
    /// Compression level: default (balances speed and size)
    public static let DEFAULT_COMPRESSION : Int = -1

    /// Compression strategy: default
    public static let DEFAULT_STRATEGY    : Int = 0
    /// Compression strategy: filtered data (lots of small values)
    public static let FILTERED            : Int = 1
    /// Compression strategy: Huffman only (no LZ77 string matching)
    public static let HUFFMAN_ONLY        : Int = 2

    // MARK: - Private state

    private var level     : Int
    private var nowrap    : Bool   // true → raw DEFLATE (no zlib header/trailer)
    private var strategy  : Int

    private var inputBuf  : [UInt8] = []
    private var inputOff  : Int     = 0

    private var outputBuf : [UInt8] = []   // pending compressed output
    private var outputOff : Int     = 0

    private var finishCalled : Bool = false
    private var finishedFlag : Bool = false
    private var ended        : Bool = false

    private var bytesRead    : Int64 = 0
    private var bytesWritten : Int64 = 0

    // zlib header / Adler-32 trailer (used when nowrap == false)
    private var adler : java.util.zip.Adler32 = java.util.zip.Adler32()
    private var headerWritten : Bool = false

    // MARK: - Init

    /// Creates a new Deflater with default compression level and zlib wrapping.
    public init() {
      self.level    = Deflater.DEFAULT_COMPRESSION
      self.nowrap   = false
      self.strategy = Deflater.DEFAULT_STRATEGY
    }

    /// Creates a new Deflater with the given compression level.
    /// - Parameter level: Compression level (0–9 or DEFAULT_COMPRESSION)
    public init(_ level: Int) {
      self.level    = level
      self.nowrap   = false
      self.strategy = Deflater.DEFAULT_STRATEGY
    }

    /// Creates a new Deflater with the given compression level and wrap mode.
    /// - Parameters:
    ///   - level: Compression level (0–9 or DEFAULT_COMPRESSION)
    ///   - nowrap: If true, use raw DEFLATE without zlib header/trailer
    public init(_ level: Int, _ nowrap: Bool) {
      self.level    = level
      self.nowrap   = nowrap
      self.strategy = Deflater.DEFAULT_STRATEGY
    }

    // MARK: - Input

    /// Sets the input data for compression.
    /// - Parameter b: Input byte array
    public func setInput(_ b: [UInt8]) {
      setInput(b, 0, b.count)
    }

    /// Sets the input data for compression.
    /// - Parameters:
    ///   - b: Input byte array
    ///   - off: Start offset
    ///   - len: Number of bytes to use
    public func setInput(_ b: [UInt8], _ off: Int, _ len: Int) {
      inputBuf = Array(b[off..<(off + len)])
      inputOff = 0
    }

    /// Sets a preset dictionary for compression.
    /// - Parameter b: Dictionary bytes
    public func setDictionary(_ b: [UInt8]) {
      setDictionary(b, 0, b.count)
    }

    /// Sets a preset dictionary for compression.
    /// - Parameters:
    ///   - b: Dictionary bytes
    ///   - off: Start offset
    ///   - len: Number of bytes to use
    public func setDictionary(_ b: [UInt8], _ off: Int, _ len: Int) {
      // Preset dictionary support — store for Adler computation;
      // full LZ77 dictionary seeding is a future optimisation.
      adler.update(b, off, len)
    }

    // MARK: - Settings

    /// Sets the compression level.
    /// - Parameter level: 0 (no compression) … 9 (best), or DEFAULT_COMPRESSION
    public func setLevel(_ level: Int) {
      self.level = level
      // Reset output buffer so new level takes effect on next deflate() call
      outputBuf = []
      outputOff = 0
      headerWritten = false
    }

    /// Sets the compression strategy.
    /// - Parameter strategy: DEFAULT_STRATEGY, FILTERED, or HUFFMAN_ONLY
    public func setStrategy(_ strategy: Int) {
      self.strategy = strategy
    }

    // MARK: - State queries

    /// Returns true if the input buffer is empty and more input is needed.
    public func needsInput() -> Bool {
      return inputOff >= inputBuf.count && outputOff >= outputBuf.count
    }

    /// Signals that compression should end with the current input.
    public func finish() {
      finishCalled = true
    }

    /// Returns true if all data has been compressed and output flushed.
    public func finished() -> Bool {
      return finishedFlag
    }

    /// Returns the total number of uncompressed bytes input so far.
    public func getBytesRead() -> Int64 {
      return bytesRead
    }

    /// Returns the total number of compressed bytes output so far.
    public func getBytesWritten() -> Int64 {
      return bytesWritten
    }

    // MARK: - Deflate

    /// Compresses input data and writes to `b`, returning number of bytes written.
    /// - Parameter b: Output buffer (inout)
    /// - Returns: Number of compressed bytes written
    @discardableResult
    public func deflate(_ b: inout [UInt8]) -> Int {
      return deflate(&b, 0, b.count)
    }

    /// Compresses input data into `b[off..<off+len]`, returning bytes written.
    /// - Parameters:
    ///   - b: Output buffer (inout)
    ///   - off: Start offset in output buffer
    ///   - len: Maximum bytes to write
    /// - Returns: Number of compressed bytes written
    @discardableResult
    public func deflate(_ b: inout [UInt8], _ off: Int, _ len: Int) -> Int {
      guard !ended else { return 0 }
      guard len > 0 else { return 0 }

      // Lazy-compress: build output on first call (or when outputBuf exhausted)
      if outputOff >= outputBuf.count {
        compress()
      }

      let available = outputBuf.count - outputOff
      let toWrite   = Swift.min(available, len)
      if toWrite > 0 {
        b.replaceSubrange(off..<(off + toWrite),
                          with: outputBuf[outputOff..<(outputOff + toWrite)])
        outputOff    += toWrite
        bytesWritten += Int64(toWrite)
      }

      if outputOff >= outputBuf.count && finishCalled {
        finishedFlag = true
      }

      return toWrite
    }

    // MARK: - Reset / End

    /// Resets the Deflater so it can be reused for a new stream.
    public func reset() {
      inputBuf      = []
      inputOff      = 0
      outputBuf     = []
      outputOff     = 0
      finishCalled  = false
      finishedFlag  = false
      bytesRead     = 0
      bytesWritten  = 0
      headerWritten = false
      adler         = java.util.zip.Adler32()
    }

    /// Releases resources.  The Deflater must not be used after this call.
    public func end() {
      ended = true
      inputBuf  = []
      outputBuf = []
    }

    // MARK: - Internal compression engine

    /// Runs the full compression pipeline and stores result in `outputBuf`.
    private func compress() {
      outputBuf = []
      outputOff = 0

      let input = Array(inputBuf[inputOff...])
      bytesRead += Int64(input.count)
      inputOff   = inputBuf.count   // mark all consumed

      // Update Adler-32 over raw input (for zlib trailer)
      if !nowrap {
        adler.update(input, 0, input.count)
      }

      var bits = BitWriter()

      // --- zlib header (RFC 1950) when not nowrap ---
      if !nowrap && !headerWritten {
        // CMF: CM=8 (deflate), CINFO=7 (window 32 KB)
        let cmf : UInt8 = 0x78
        // FLG: chosen so (CMF*256 + FLG) % 31 == 0
        // 0x78 * 256 = 30720; 30720 % 31 = 20; 31 - 20 = 11 → FLG = 0x01 (fcheck=1, no dict, level 6)
        let flg : UInt8 = 0x9C   // standard zlib default (level 6)
        bits.writeRawByte(cmf)
        bits.writeRawByte(flg)
        headerWritten = true
      }

      // --- DEFLATE blocks (RFC 1951) ---
      if level == Deflater.NO_COMPRESSION {
        writeStoredBlocks(&bits, input: input)
      } else {
        writeFixedHuffmanBlock(&bits, input: input, isFinal: true)
      }

      // --- zlib Adler-32 trailer (RFC 1950) ---
      if !nowrap {
        bits.flush()
        let checksum = UInt32(adler.getValue() & 0xFFFF_FFFF)
        // big-endian
        bits.writeRawByte(UInt8((checksum >> 24) & 0xFF))
        bits.writeRawByte(UInt8((checksum >> 16) & 0xFF))
        bits.writeRawByte(UInt8((checksum >>  8) & 0xFF))
        bits.writeRawByte(UInt8( checksum        & 0xFF))
      } else {
        bits.flush()
      }

      outputBuf = bits.bytes
    }

    // MARK: Stored blocks (level 0)

    private func writeStoredBlocks(_ bits: inout BitWriter, input: [UInt8]) {
      let maxBlock = 65535
      var offset   = 0
      while offset < input.count {
        let blockLen = Swift.min(maxBlock, input.count - offset)
        let isFinal  = (offset + blockLen) >= input.count
        // BFINAL | BTYPE=00 (stored)
        bits.writeBits(isFinal ? 1 : 0, count: 1)
        bits.writeBits(0, count: 2)   // BTYPE = 00
        bits.flush()                   // byte-align
        let len  = UInt16(blockLen)
        let nlen = ~len
        bits.writeRawByte(UInt8( len        & 0xFF))
        bits.writeRawByte(UInt8((len  >> 8) & 0xFF))
        bits.writeRawByte(UInt8( nlen       & 0xFF))
        bits.writeRawByte(UInt8((nlen >> 8) & 0xFF))
        for i in offset..<(offset + blockLen) {
          bits.writeRawByte(input[i])
        }
        offset += blockLen
      }
      if input.isEmpty {
        // Empty stored block
        bits.writeBits(1, count: 1)
        bits.writeBits(0, count: 2)
        bits.flush()
        bits.writeRawByte(0x00); bits.writeRawByte(0x00)
        bits.writeRawByte(0xFF); bits.writeRawByte(0xFF)
      }
    }

    // MARK: Fixed Huffman block (BTYPE = 01, RFC 1951 §3.2.6)

    private func writeFixedHuffmanBlock(_ bits: inout BitWriter, input: [UInt8], isFinal: Bool) {
      bits.writeBits(isFinal ? 1 : 0, count: 1)
      bits.writeBits(1, count: 1)   // BTYPE bit 0
      bits.writeBits(0, count: 1)   // BTYPE bit 1  → BTYPE = 01

      // LZ77 with fixed Huffman coding
      let matches = lz77(input)
      for symbol in matches {
        switch symbol {
        case .literal(let byte):
          writeFixedLiteral(&bits, value: Int(byte))
        case .endOfBlock:
          writeFixedLiteral(&bits, value: 256)
        case .backref(let length, let dist):
          let (lenCode, lenExtra, lenExtraBits) = lengthCode(length)
          writeFixedLiteral(&bits, value: lenCode)
          if lenExtraBits > 0 {
            bits.writeBits(lenExtra, count: lenExtraBits)
          }
          let (distCode, distExtra, distExtraBits) = distanceCode(dist)
          // Distance codes: 5 bits, MSB first
          bits.writeBitsMSB(distCode, count: 5)
          if distExtraBits > 0 {
            bits.writeBits(distExtra, count: distExtraBits)
          }
        }
      }
    }

    /// Write a literal/length value using RFC 1951 fixed Huffman table.
    private func writeFixedLiteral(_ bits: inout BitWriter, value: Int) {
      switch value {
      case 0...143:
        // 8-bit code: 00110000 + value
        let code = 0b00110000 + value
        bits.writeBitsMSB(code, count: 8)
      case 144...255:
        // 9-bit code: 110010000 + (value - 144)
        let code = 0b110010000 + (value - 144)
        bits.writeBitsMSB(code, count: 9)
      case 256...279:
        // 7-bit code: 0000000 + (value - 256)
        let code = value - 256
        bits.writeBitsMSB(code, count: 7)
      case 280...287:
        // 8-bit code: 11000000 + (value - 280)
        let code = 0b11000000 + (value - 280)
        bits.writeBitsMSB(code, count: 8)
      default:
        break
      }
    }

    // MARK: LZ77

    private enum LZ77Symbol {
      case literal(UInt8)
      case backref(length: Int, dist: Int)
      case endOfBlock
    }

    /// Simple hash-based LZ77.  Window = 32 KB, max match = 258 bytes.
    private func lz77(_ input: [UInt8]) -> [LZ77Symbol] {
      guard !input.isEmpty else { return [.endOfBlock] }

      var result  : [LZ77Symbol] = []
      result.reserveCapacity(input.count)

      let winSize  : Int = 32768
      let minMatch : Int = 3
      let maxMatch : Int = 258

      // Hash table: maps 3-byte hash → last position
      var hashTable = [Int: Int](minimumCapacity: 4096)

      var pos = 0
      while pos < input.count {
        let remaining = input.count - pos

        if remaining < minMatch || level == Deflater.HUFFMAN_ONLY {
          result.append(.literal(input[pos]))
          pos += 1
          continue
        }

        // Compute 3-byte hash
        let h = hash3(input, pos)
        let matchStart = hashTable[h]
        hashTable[h] = pos

        // Try to find a back-reference
        var bestLen  = 0
        var bestDist = 0

        if let ms = matchStart {
          let dist = pos - ms
          if dist > 0 && dist <= winSize {
            var mlen = 0
            while mlen < maxMatch
                && (pos + mlen) < input.count
                && input[ms + mlen] == input[pos + mlen] {
              mlen += 1
            }
            if mlen >= minMatch {
              bestLen  = mlen
              bestDist = dist
            }
          }
        }

        if bestLen >= minMatch {
          result.append(.backref(length: bestLen, dist: bestDist))
          // Update hash for skipped positions
          for i in 1..<bestLen {
            if pos + i + 2 < input.count {
              let hh = hash3(input, pos + i)
              hashTable[hh] = pos + i
            }
          }
          pos += bestLen
        } else {
          result.append(.literal(input[pos]))
          pos += 1
        }
      }
      result.append(.endOfBlock)
      return result
    }

    @inline(__always)
    private func hash3(_ buf: [UInt8], _ pos: Int) -> Int {
      return (Int(buf[pos]) << 10) ^ (Int(buf[pos + 1]) << 5) ^ Int(buf[pos + 2])
    }

    // MARK: Length / distance code tables (RFC 1951 §3.2.5)

    /// Returns (litLenCode, extraBits value, extraBits count) for a match length.
    private func lengthCode(_ length: Int) -> (Int, Int, Int) {
      switch length {
      case 3:       return (257, 0, 0)
      case 4:       return (258, 0, 0)
      case 5:       return (259, 0, 0)
      case 6:       return (260, 0, 0)
      case 7:       return (261, 0, 0)
      case 8:       return (262, 0, 0)
      case 9:       return (263, 0, 0)
      case 10:      return (264, 0, 0)
      case 11...12: return (265, length - 11, 1)
      case 13...14: return (266, length - 13, 1)
      case 15...16: return (267, length - 15, 1)
      case 17...18: return (268, length - 17, 1)
      case 19...22: return (269, length - 19, 2)
      case 23...26: return (270, length - 23, 2)
      case 27...30: return (271, length - 27, 2)
      case 31...34: return (272, length - 31, 2)
      case 35...42: return (273, length - 35, 3)
      case 43...50: return (274, length - 43, 3)
      case 51...58: return (275, length - 51, 3)
      case 59...66: return (276, length - 59, 3)
      case 67...82: return (277, length - 67, 4)
      case 83...98: return (278, length - 83, 4)
      case 99...114:  return (279, length - 99,  4)
      case 115...130: return (280, length - 115, 4)
      case 131...162: return (281, length - 131, 5)
      case 163...194: return (282, length - 163, 5)
      case 195...226: return (283, length - 195, 5)
      case 227...257: return (284, length - 227, 5)
      default:        return (285, 0, 0)   // length == 258
      }
    }

    /// Returns (distCode, extraBits value, extraBits count) for a match distance.
    private func distanceCode(_ dist: Int) -> (Int, Int, Int) {
      switch dist {
      case 1:           return (0,  0,       0)
      case 2:           return (1,  0,       0)
      case 3:           return (2,  0,       0)
      case 4:           return (3,  0,       0)
      case 5...6:       return (4,  dist - 5,    1)
      case 7...8:       return (5,  dist - 7,    1)
      case 9...12:      return (6,  dist - 9,    2)
      case 13...16:     return (7,  dist - 13,   2)
      case 17...24:     return (8,  dist - 17,   3)
      case 25...32:     return (9,  dist - 25,   3)
      case 33...48:     return (10, dist - 33,   4)
      case 49...64:     return (11, dist - 49,   4)
      case 65...96:     return (12, dist - 65,   5)
      case 97...128:    return (13, dist - 97,   5)
      case 129...192:   return (14, dist - 129,  6)
      case 193...256:   return (15, dist - 193,  6)
      case 257...384:   return (16, dist - 257,  7)
      case 385...512:   return (17, dist - 385,  7)
      case 513...768:   return (18, dist - 513,  8)
      case 769...1024:  return (19, dist - 769,  8)
      case 1025...1536: return (20, dist - 1025, 9)
      case 1537...2048: return (21, dist - 1537, 9)
      case 2049...3072: return (22, dist - 2049, 10)
      case 3073...4096: return (23, dist - 3073, 10)
      case 4097...6144: return (24, dist - 4097, 11)
      case 6145...8192: return (25, dist - 6145, 11)
      case 8193...12288:  return (26, dist - 8193,  12)
      case 12289...16384: return (27, dist - 12289, 12)
      case 16385...24576: return (28, dist - 16385, 13)
      default:            return (29, dist - 24577, 13)
      }
    }
  }
}

// MARK: - Bit writer (LSB-first for literals, MSB-first for Huffman codes)

private struct BitWriter {
  var bytes    : [UInt8] = []
  var bitBuf   : UInt32  = 0
  var bitCount : Int     = 0

  /// Write `count` bits from `value`, LSB first (used for extra bits).
  mutating func writeBits(_ value: Int, count: Int) {
    bitBuf   |= UInt32(value & ((1 << count) - 1)) << bitCount
    bitCount += count
    while bitCount >= 8 {
      bytes.append(UInt8(bitBuf & 0xFF))
      bitBuf   >>= 8
      bitCount  -= 8
    }
  }

  /// Write `count` bits from `value`, MSB first (used for Huffman codes).
  mutating func writeBitsMSB(_ value: Int, count: Int) {
    for i in stride(from: count - 1, through: 0, by: -1) {
      let bit = (value >> i) & 1
      writeBits(bit, count: 1)
    }
  }

  /// Write a raw byte, flushing any pending bits first.
  mutating func writeRawByte(_ byte: UInt8) {
    flush()
    bytes.append(byte)
  }

  /// Flush any remaining bits (zero-padded to byte boundary).
  mutating func flush() {
    if bitCount > 0 {
      bytes.append(UInt8(bitBuf & 0xFF))
      bitBuf   = 0
      bitCount = 0
    }
  }
}
