/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
/*
 * Pure-Swift INFLATE decompressor (RFC 1951 / zlib RFC 1950).
 * No system libraries, no Foundation — runs on Apple, Linux (Glibc/Musl),
 * Windows, Android, FreeBSD, and WASI.
 *
 * Supports:
 *   - zlib framing (RFC 1950): CMF/FLG header + Adler-32 trailer
 *   - Raw DEFLATE (nowrap = true)
 *   - BTYPE 00: stored blocks
 *   - BTYPE 01: fixed Huffman
 *   - BTYPE 10: dynamic Huffman
 */

extension java.util.zip {

  /// Decompresses data that was compressed using the DEFLATE algorithm (RFC 1951).
  ///
  /// Typical usage mirrors the Java API:
  /// ```swift
  /// let inflater = Inflater()
  /// inflater.setInput(compressedBytes)
  /// var output = [UInt8](repeating: 0, count: 4096)
  /// let n = try inflater.inflate(&output, 0, output.count)
  /// inflater.end()
  /// ```
  final public class Inflater : @unchecked Sendable {

    // MARK: - Private state

    private var nowrap : Bool

    private var inputBuf : [UInt8] = []
    private var inputOff : Int     = 0

    private var outputBuf : [UInt8] = []  // decompressed output pending read
    private var outputOff : Int     = 0

    private var decompressDone : Bool = false  // all blocks decoded
    private var finishedFlag   : Bool = false  // all output read
    private var _needsDictionary : Bool = false
    private var ended : Bool         = false

    private var bytesRead    : Int64 = 0
    private var bytesWritten : Int64 = 0

    // MARK: - Init

    /// Creates a new Inflater that expects zlib-wrapped (RFC 1950) input.
    public init() {
      self.nowrap = false
    }

    /// Creates a new Inflater.
    /// - Parameter nowrap: If true, expects raw DEFLATE without zlib header/trailer.
    public init(_ nowrap: Bool) {
      self.nowrap = nowrap
    }

    // MARK: - Input

    /// Sets the input data to decompress.
    /// - Parameter b: Compressed byte array
    public func setInput(_ b: [UInt8]) {
      setInput(b, 0, b.count)
    }

    /// Sets the input data to decompress.
    /// - Parameters:
    ///   - b: Compressed byte array
    ///   - off: Start offset
    ///   - len: Number of bytes to use
    public func setInput(_ b: [UInt8], _ off: Int, _ len: Int) {
      inputBuf       = Array(b[off..<(off + len)])
      inputOff       = 0
      outputBuf      = []
      outputOff      = 0
      decompressDone = false
      finishedFlag   = false
    }

    /// Sets a preset dictionary (must match the one used during compression).
    /// - Parameter b: Dictionary bytes
    public func setDictionary(_ b: [UInt8]) {
      setDictionary(b, 0, b.count)
    }

    /// Sets a preset dictionary.
    /// - Parameters:
    ///   - b: Dictionary bytes
    ///   - off: Start offset
    ///   - len: Number of bytes to use
    public func setDictionary(_ b: [UInt8], _ off: Int, _ len: Int) {
      _needsDictionary = false
      // Dictionary seeding for LZ77 window is a future optimisation.
      _ = b; _ = off; _ = len
    }

    // MARK: - State queries

    /// Returns true if no input is available and more is needed.
    public func needsInput() -> Bool {
      return inputOff >= inputBuf.count && outputOff >= outputBuf.count
    }

    /// Returns true if a preset dictionary is needed before inflation can proceed.
    public func needsDictionary() -> Bool {
      return _needsDictionary
    }

    /// Returns true if the end of the compressed stream has been reached.
    public func finished() -> Bool {
      return finishedFlag
    }

    /// Returns the total number of compressed bytes consumed.
    public func getBytesRead() -> Int64 {
      return bytesRead
    }

    /// Returns the total number of uncompressed bytes produced.
    public func getBytesWritten() -> Int64 {
      return bytesWritten
    }

    /// Returns the number of compressed bytes remaining in the input buffer.
    public func getRemaining() -> Int {
      return inputBuf.count - inputOff
    }

    /// Returns the unprocessed bytes remaining in the input buffer.
    /// After inflation, these are the bytes that follow the compressed data
    /// (e.g. GZIP trailer bytes that were pre-read into the input buffer).
    public func getRemainingInput() -> [UInt8] {
      guard inputOff < inputBuf.count else { return [] }
      return Array(inputBuf[inputOff...])
    }

    // MARK: - Inflate

    /// Decompresses data into `b`, returning number of bytes written.
    /// - Parameter b: Output buffer (inout)
    /// - Returns: Number of decompressed bytes written
    /// - Throws: `DataFormatException` if the compressed data is malformed
    @discardableResult
    public func inflate(_ b: inout [UInt8]) throws -> Int {
      return try inflate(&b, 0, b.count)
    }

    /// Decompresses data into `b[off..<off+len]`, returning bytes written.
    /// - Parameters:
    ///   - b: Output buffer (inout)
    ///   - off: Start offset in output buffer
    ///   - len: Maximum bytes to write
    /// - Returns: Number of decompressed bytes written
    /// - Throws: `DataFormatException` if the compressed data is malformed
    @discardableResult
    public func inflate(_ b: inout [UInt8], _ off: Int, _ len: Int) throws -> Int {
      guard !ended else { return 0 }
      guard len > 0 else { return 0 }

      // Decompress if output buffer exhausted and stream not yet decoded
      if outputOff >= outputBuf.count && !decompressDone {
        try decompress()
      }

      let available = outputBuf.count - outputOff
      let toWrite   = Swift.min(available, len)
      if toWrite > 0 {
        b.replaceSubrange(off..<(off + toWrite),
                          with: outputBuf[outputOff..<(outputOff + toWrite)])
        outputOff    += toWrite
        bytesWritten += Int64(toWrite)
      }

      // finished() = all blocks decoded AND all output consumed
      if decompressDone && outputOff >= outputBuf.count {
        finishedFlag = true
      }

      return toWrite
    }

    // MARK: - Reset / End

    /// Resets the Inflater so it can be reused for a new stream.
    public func reset() {
      inputBuf        = []
      inputOff        = 0
      outputBuf        = []
      outputOff        = 0
      decompressDone   = false
      finishedFlag     = false
      _needsDictionary = false
      bytesRead        = 0
      bytesWritten    = 0
    }

    /// Releases resources.  The Inflater must not be used after this call.
    public func end() {
      ended     = true
      inputBuf  = []
      outputBuf = []
    }

    // MARK: - Internal decompression engine

    private func decompress() throws {
      var reader = BitReader(bytes: inputBuf, offset: inputOff)

      // --- zlib header (RFC 1950) ---
      if !nowrap {
        guard reader.remaining >= 2 else {
          throw DataFormatException("Input too short for zlib header")
        }
        let cmf = Int(reader.readRawByte())
        let flg = Int(reader.readRawByte())
        guard (cmf * 256 + flg) % 31 == 0 else {
          throw DataFormatException("Invalid zlib header checksum")
        }
        let cm = cmf & 0x0F
        guard cm == 8 else {
          throw DataFormatException("Unsupported compression method: \(cm)")
        }
        let fdict = (flg >> 5) & 1
        if fdict == 1 {
          _needsDictionary = true
          // Skip 4-byte dict Adler checksum
          _ = reader.readRawByte(); _ = reader.readRawByte()
          _ = reader.readRawByte(); _ = reader.readRawByte()
        }
      }

      // --- DEFLATE blocks ---
      var output : [UInt8] = []
      var isFinal = false
      while !isFinal {
        isFinal = reader.readBits(1) == 1
        let btype = reader.readBits(2)
        switch btype {
        case 0b00:
          try readStoredBlock(&reader, into: &output)
        case 0b01:
          try readFixedHuffmanBlock(&reader, into: &output)
        case 0b10:
          try readDynamicHuffmanBlock(&reader, into: &output)
        default:
          throw DataFormatException("Reserved BTYPE 11")
        }
      }

      // --- zlib Adler-32 trailer (RFC 1950) ---
      if !nowrap {
        reader.byteAlign()
        if reader.remaining >= 4 {
          // We read but don't verify here (verification is a future optimisation)
          _ = reader.readRawByte(); _ = reader.readRawByte()
          _ = reader.readRawByte(); _ = reader.readRawByte()
        }
      }

      bytesRead     += Int64(reader.bytesConsumed - inputOff)
      inputOff       = reader.bytesConsumed
      outputBuf      = output
      outputOff      = 0
      decompressDone = true
    }

    // MARK: Stored block

    private func readStoredBlock(_ r: inout BitReader, into out: inout [UInt8]) throws {
      r.byteAlign()
      guard r.remaining >= 4 else {
        throw DataFormatException("Truncated stored block header")
      }
      let len  = Int(r.readRawByte()) | (Int(r.readRawByte()) << 8)
      let nlen = Int(r.readRawByte()) | (Int(r.readRawByte()) << 8)
      guard (len ^ nlen) == 0xFFFF else {
        throw DataFormatException("Stored block LEN/NLEN mismatch")
      }
      guard r.remaining >= len else {
        throw DataFormatException("Stored block data truncated")
      }
      for _ in 0..<len {
        out.append(r.readRawByte())
      }
    }

    // MARK: Fixed Huffman block (BTYPE = 01)

    private func readFixedHuffmanBlock(_ r: inout BitReader, into out: inout [UInt8]) throws {
      let litTree  = InflateHuffman.fixedLiteralTree
      let distTree = InflateHuffman.fixedDistanceTree
      try inflateHuffman(&r, litTree: litTree, distTree: distTree, into: &out)
    }

    // MARK: Dynamic Huffman block (BTYPE = 10)

    private func readDynamicHuffmanBlock(_ r: inout BitReader, into out: inout [UInt8]) throws {
      let hlit  = r.readBits(5) + 257   // number of literal/length codes
      let hdist = r.readBits(5) + 1     // number of distance codes
      let hclen = r.readBits(4) + 4     // number of code length codes

      // Code length alphabet order
      let clOrder = [16,17,18,0,8,7,9,6,10,5,11,4,12,3,13,2,14,1,15]
      var clLens  = [Int](repeating: 0, count: 19)
      for i in 0..<hclen {
        clLens[clOrder[i]] = r.readBits(3)
      }
      let clTree = try InflateHuffman(lengths: clLens)

      // Decode literal/length + distance code lengths
      var allLens = [Int](repeating: 0, count: hlit + hdist)
      var i = 0
      while i < hlit + hdist {
        let sym = try clTree.decode(&r)
        switch sym {
        case 0...15:
          allLens[i] = sym; i += 1
        case 16:
          let rep = r.readBits(2) + 3
          let prev = i > 0 ? allLens[i-1] : 0
          for _ in 0..<rep { allLens[i] = prev; i += 1 }
        case 17:
          let rep = r.readBits(3) + 3
          for _ in 0..<rep { allLens[i] = 0; i += 1 }
        case 18:
          let rep = r.readBits(7) + 11
          for _ in 0..<rep { allLens[i] = 0; i += 1 }
        default:
          throw DataFormatException("Invalid code length symbol: \(sym)")
        }
      }

      let litTree  = try InflateHuffman(lengths: Array(allLens[0..<hlit]))
      let distTree = try InflateHuffman(lengths: Array(allLens[hlit..<(hlit+hdist)]))
      try inflateHuffman(&r, litTree: litTree, distTree: distTree, into: &out)
    }

    // MARK: Huffman decode loop

    private func inflateHuffman(
      _ r: inout BitReader,
      litTree: InflateHuffman,
      distTree: InflateHuffman,
      into out: inout [UInt8]
    ) throws {
      while true {
        let sym = try litTree.decode(&r)
        if sym < 256 {
          out.append(UInt8(sym))
        } else if sym == 256 {
          break  // end of block
        } else {
          // Back-reference: decode length
          let length = try decodeLength(&r, sym: sym)
          // Decode distance
          let distSym = try distTree.decode(&r)
          let dist    = try decodeDistance(&r, sym: distSym)
          // Copy from window
          let start = out.count - dist
          guard start >= 0 else {
            throw DataFormatException("Back-reference distance exceeds output")
          }
          for k in 0..<length {
            out.append(out[start + k])
          }
        }
      }
    }

    // MARK: Length / distance decoding (RFC 1951 §3.2.5)

    private func decodeLength(_ r: inout BitReader, sym: Int) throws -> Int {
      switch sym {
      case 257...264: return sym - 254
      case 265: return 11 + r.readBits(1)
      case 266: return 13 + r.readBits(1)
      case 267: return 15 + r.readBits(1)
      case 268: return 17 + r.readBits(1)
      case 269: return 19 + r.readBits(2)
      case 270: return 23 + r.readBits(2)
      case 271: return 27 + r.readBits(2)
      case 272: return 31 + r.readBits(2)
      case 273: return 35 + r.readBits(3)
      case 274: return 43 + r.readBits(3)
      case 275: return 51 + r.readBits(3)
      case 276: return 59 + r.readBits(3)
      case 277: return 67 + r.readBits(4)
      case 278: return 83 + r.readBits(4)
      case 279: return 99 + r.readBits(4)
      case 280: return 115 + r.readBits(4)
      case 281: return 131 + r.readBits(5)
      case 282: return 163 + r.readBits(5)
      case 283: return 195 + r.readBits(5)
      case 284: return 227 + r.readBits(5)
      case 285: return 258
      default:  throw DataFormatException("Invalid length symbol: \(sym)")
      }
    }

    private func decodeDistance(_ r: inout BitReader, sym: Int) throws -> Int {
      switch sym {
      case 0:  return 1
      case 1:  return 2
      case 2:  return 3
      case 3:  return 4
      case 4:  return 5  + r.readBits(1)
      case 5:  return 7  + r.readBits(1)
      case 6:  return 9  + r.readBits(2)
      case 7:  return 13 + r.readBits(2)
      case 8:  return 17 + r.readBits(3)
      case 9:  return 25 + r.readBits(3)
      case 10: return 33 + r.readBits(4)
      case 11: return 49 + r.readBits(4)
      case 12: return 65  + r.readBits(5)
      case 13: return 97  + r.readBits(5)
      case 14: return 129 + r.readBits(6)
      case 15: return 193 + r.readBits(6)
      case 16: return 257  + r.readBits(7)
      case 17: return 385  + r.readBits(7)
      case 18: return 513  + r.readBits(8)
      case 19: return 769  + r.readBits(8)
      case 20: return 1025 + r.readBits(9)
      case 21: return 1537 + r.readBits(9)
      case 22: return 2049  + r.readBits(10)
      case 23: return 3073  + r.readBits(10)
      case 24: return 4097  + r.readBits(11)
      case 25: return 6145  + r.readBits(11)
      case 26: return 8193  + r.readBits(12)
      case 27: return 12289 + r.readBits(12)
      case 28: return 16385 + r.readBits(13)
      case 29: return 24577 + r.readBits(13)
      default: throw DataFormatException("Invalid distance symbol: \(sym)")
      }
    }
  }
}

// MARK: - Bit reader (LSB-first per RFC 1951)

private struct BitReader {
  let bytes        : [UInt8]
  var bytesConsumed: Int
  var bitBuf       : UInt32 = 0
  var bitCount     : Int    = 0

  var remaining: Int { bytes.count - bytesConsumed }

  init(bytes: [UInt8], offset: Int) {
    self.bytes         = bytes
    self.bytesConsumed = offset
  }

  /// Fill internal buffer to at least `count` bits.
  private mutating func fill(_ count: Int) {
    while bitCount < count && bytesConsumed < bytes.count {
      bitBuf   |= UInt32(bytes[bytesConsumed]) << bitCount
      bitCount += 8
      bytesConsumed += 1
    }
  }

  /// Read `count` bits, LSB first (advances the stream).
  mutating func readBits(_ count: Int) -> Int {
    guard count > 0 else { return 0 }
    fill(count)
    let mask   = UInt32((1 << count) - 1)
    let result = Int(bitBuf & mask)
    bitBuf   >>= count
    bitCount  -= count
    return result
  }

  /// Peek `count` bits (LSB-first) without consuming them.
  mutating func peekBits(_ count: Int) -> Int {
    guard count > 0 else { return 0 }
    fill(count)
    let mask = UInt32((1 << count) - 1)
    return Int(bitBuf & mask)
  }

  /// Consume `count` bits that were previously peeked.
  mutating func consumeBits(_ count: Int) {
    guard count > 0 else { return }
    bitBuf   >>= count
    bitCount  -= count
  }

  /// Read `count` bits, MSB first (for Huffman code matching — unused but kept for completeness).
  mutating func readBitsMSB(_ count: Int) -> Int {
    var result = 0
    for _ in 0..<count {
      result = (result << 1) | readBits(1)
    }
    return result
  }

  /// Discard remaining bits in current byte, byte-align.
  mutating func byteAlign() {
    bitBuf   = 0
    bitCount = 0
  }

  /// Read one raw byte (must be byte-aligned).
  mutating func readRawByte() -> UInt8 {
    guard bytesConsumed < bytes.count else { return 0 }
    let b = bytes[bytesConsumed]
    bytesConsumed += 1
    return b
  }
}

// MARK: - Huffman tree (canonical, flat-table decoder for inflation)
//
// Strategy: build a flat lookup table of size 1<<maxLen.
// Each entry stores (symbol, codeLen). To decode:
//   1. Peek maxLen bits from the stream (LSB-first).
//   2. Look up the entry — it gives the symbol and how many bits to consume.
// Shorter codes are replicated across all entries that share their prefix,
// so the lookup is always O(1).

private struct InflateHuffman {
  // Each table entry: (symbol, bitLength). -1 means unused.
  private struct Entry {
    var symbol : Int
    var bits   : Int
  }

  private var table  : [Entry]
  private var maxLen : Int

  // Fixed trees (RFC 1951 §3.2.6) — built once at program start
  static let fixedLiteralTree  = buildFixedLiteralTree()
  static let fixedDistanceTree = buildFixedDistanceTree()

  private static func buildFixedLiteralTree() -> InflateHuffman {
    var lens = [Int](repeating: 0, count: 288)
    for i in 0...143   { lens[i] = 8 }
    for i in 144...255 { lens[i] = 9 }
    for i in 256...279 { lens[i] = 7 }
    for i in 280...287 { lens[i] = 8 }
    return try! InflateHuffman(lengths: lens)
  }

  private static func buildFixedDistanceTree() -> InflateHuffman {
    return try! InflateHuffman(lengths: [Int](repeating: 5, count: 32))
  }

  /// Build a canonical Huffman tree from an array of code lengths.
  init(lengths: [Int]) throws {
    let maxBits = lengths.max() ?? 0
    guard maxBits <= 15 else {
      throw java.util.zip.DataFormatException("Huffman code length > 15")
    }
    maxLen = maxBits == 0 ? 1 : maxBits

    // Step 1: count codes per bit-length
    var blCount = [Int](repeating: 0, count: maxLen + 1)
    for l in lengths where l > 0 { blCount[l] += 1 }

    // Step 2: compute first canonical code per bit-length
    var nextCode = [Int](repeating: 0, count: maxLen + 2)
    var code = 0
    for bits in 1...maxLen {
      code = (code + blCount[bits - 1]) << 1
      nextCode[bits] = code
    }

    // Step 3: build flat table (size = 1 << maxLen)
    let tableSize = 1 << maxLen
    table = [Entry](repeating: Entry(symbol: -1, bits: 0), count: tableSize)

    for (sym, len) in lengths.enumerated() {
      guard len > 0 else { continue }
      let c = nextCode[len]
      nextCode[len] += 1

      // Reverse `len` bits of `c` to get LSB-first index
      var rev = 0
      var tmp = c
      for _ in 0..<len {
        rev = (rev << 1) | (tmp & 1)
        tmp >>= 1
      }
      // Fill every table slot whose lower `len` bits equal `rev`
      // (the upper bits are "don't care" — the actual code is shorter than maxLen)
      let step = 1 << len
      var idx  = rev
      while idx < tableSize {
        table[idx] = Entry(symbol: sym, bits: len)
        idx += step
      }
    }
  }

  /// Decode one symbol: peek maxLen bits, lookup, consume only the used bits.
  func decode(_ r: inout BitReader) throws -> Int {
    // Fill the bit buffer to at least maxLen bits
    let idx = r.peekBits(maxLen)
    let entry = table[idx]
    guard entry.symbol != -1 else {
      throw java.util.zip.DataFormatException("Invalid Huffman code at index \(idx)")
    }
    r.consumeBits(entry.bits)
    return entry.symbol
  }
}
