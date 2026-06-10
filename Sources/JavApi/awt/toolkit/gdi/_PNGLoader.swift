/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

// =============================================================================
// Minimal PNG loader — pure Swift, zero external dependencies.
//
// Supported colour types: 0 (grey), 2 (RGB), 3 (indexed), 4 (grey+α), 6 (RGBA)
// Bit depths: 8 and 16 (16-bit channels are truncated to 8 bits)
// PNG filter types 0–4, DEFLATE decompression written in pure Swift.
// Output: java.awt.image.BufferedImage (TYPE_INT_ARGB).
// =============================================================================

#if os(Windows)
import WinSDK
import Foundation

struct _PNGLoader {

  // ---------------------------------------------------------------------------
  // MARK: Public entry
  // ---------------------------------------------------------------------------

  /// Load a PNG from the file system.
  static func load(path: String) -> java.awt.image.BufferedImage? {
    guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else { return nil }
    return decode([UInt8](data))
  }

  /// Load a PNG embedded as an `RT_RCDATA` resource in the running executable.
  ///
  /// - Parameter resourceId: The integer resource ID used when embedding
  ///   (e.g. 256 for the logo PNG embedded by `build-exe.ps1`).
  /// - Returns: A decoded `BufferedImage`, or `nil` if the resource is absent.
  static func loadFromResource(id resourceId: Int) -> java.awt.image.BufferedImage? {
    // FindResourceW(nil, …) looks in the module of the running executable.
    // MAKEINTRESOURCEW(n) = UnsafePointer(bitPattern: n) — the Win32 macro.
    // MAKEINTRESOURCEW(n): cast integer ID to LPCWSTR (UnsafePointer<WCHAR>)
    let resName = UnsafePointer<WCHAR>(bitPattern: resourceId)
    let resType = UnsafePointer<WCHAR>(bitPattern: 10)  // RT_RCDATA = 10

    guard let hRes = FindResourceW(nil, resName, resType) else { return nil }

    let size = SizeofResource(nil, hRes)
    guard size > 0 else { return nil }

    guard let hGlobal = LoadResource(nil, hRes) else { return nil }
    let ptr = LockResource(hGlobal)
    guard let ptr else { return nil }
    // LockResource memory is owned by the OS — do not free it.
    let bytes = Array(UnsafeBufferPointer(
      start: ptr.assumingMemoryBound(to: UInt8.self),
      count: Int(size)))
    return decode(bytes)
  }

  // ---------------------------------------------------------------------------
  // MARK: PNG decode
  // ---------------------------------------------------------------------------

  private static func decode(_ b: [UInt8]) -> java.awt.image.BufferedImage? {
    let sig: [UInt8] = [137,80,78,71,13,10,26,10]
    guard b.count > 8, Array(b[0..<8]) == sig else { return nil }

    var off = 8
    var width=0, height=0, bitDepth=0, colorType=0
    var palette: [(UInt8,UInt8,UInt8)] = []
    var idat = [UInt8]()

    while off + 12 <= b.count {
      let len = Int(u32be(b, off))
      let tag = String(bytes: b[(off+4)..<(off+8)], encoding: .ascii) ?? ""
      let ds=off+8, de=ds+len
      guard de+4 <= b.count else { break }
      let c = Array(b[ds..<de])
      switch tag {
      case "IHDR":
        guard c.count >= 13 else { return nil }
        width=Int(u32be(c,0)); height=Int(u32be(c,4))
        bitDepth=Int(c[8]); colorType=Int(c[9])
        if c[12] != 0 { return nil }   // interlaced unsupported
      case "PLTE":
        for i in stride(from:0, to:c.count-2, by:3) {
          palette.append((c[i],c[i+1],c[i+2]))
        }
      case "IDAT": idat += c
      default: break
      }
      off = de + 4
    }

    guard width>0, height>0, !idat.isEmpty else { return nil }

    let cpp: Int   // channels per pixel
    switch colorType {
    case 0: cpp=1; case 2: cpp=3; case 3: cpp=1
    case 4: cpp=2; case 6: cpp=4; default: return nil
    }
    let bps = bitDepth > 8 ? 2 : 1
    let bpp = cpp * bps
    let rowBytes = 1 + width * bpp

    guard let raw = zlibInflate(idat), raw.count >= rowBytes * height else { return nil }

    let bi = java.awt.image.BufferedImage(width, height,
               java.awt.image.BufferedImage.TYPE_INT_ARGB)
    var prev = [UInt8](repeating: 0, count: width * bpp)

    for row in 0..<height {
      let base = row * rowBytes
      var line = Array(raw[(base+1)..<(base+rowBytes)])
      unfilter(&line, prev: prev, bpp: bpp, ft: Int(raw[base]))

      for col in 0..<width {
        let b0 = col * bpp
        var r,g,bl,a: UInt8
        switch colorType {
        case 0: let v=s8(line,b0,0,bitDepth); r=v;g=v;bl=v;a=255
        case 2: r=s8(line,b0,0,bitDepth);g=s8(line,b0,1,bitDepth);bl=s8(line,b0,2,bitDepth);a=255
        case 3:
          let idx=Int(line[b0])
          if idx<palette.count {r=palette[idx].0;g=palette[idx].1;bl=palette[idx].2}
          else {r=0;g=0;bl=0}; a=255
        case 4: let v=s8(line,b0,0,bitDepth);r=v;g=v;bl=v;a=s8(line,b0,1,bitDepth)
        case 6: r=s8(line,b0,0,bitDepth);g=s8(line,b0,1,bitDepth);bl=s8(line,b0,2,bitDepth);a=s8(line,b0,3,bitDepth)
        default: r=0;g=0;bl=0;a=255
        }
        bi.setRGB(col, row, (Int(a)<<24)|(Int(r)<<16)|(Int(g)<<8)|Int(bl))
      }
      prev = line
    }
    return bi
  }

  // ---------------------------------------------------------------------------
  // MARK: PNG helpers
  // ---------------------------------------------------------------------------

  private static func u32be(_ b:[UInt8],_ i:Int)->UInt32 {
    (UInt32(b[i])<<24)|(UInt32(b[i+1])<<16)|(UInt32(b[i+2])<<8)|UInt32(b[i+3])
  }
  private static func s8(_ l:[UInt8],_ base:Int,_ ch:Int,_ depth:Int)->UInt8 {
    depth>8 ? l[base+ch*2] : l[base+ch]
  }
  private static func paeth(_ a:Int,_ b:Int,_ c:Int)->Int {
    let p=a+b-c; let pa=abs(p-a),pb=abs(p-b),pc=abs(p-c)
    return pa<=pb&&pa<=pc ? a : pb<=pc ? b : c
  }
  private static func unfilter(_ l: inout [UInt8], prev:[UInt8], bpp:Int, ft:Int) {
    switch ft {
    case 1: for i in bpp..<l.count { l[i]=l[i]&+l[i-bpp] }
    case 2: for i in 0..<l.count   { l[i]=l[i]&+prev[i]  }
    case 3: for i in 0..<l.count {
      let a=i>=bpp ? Int(l[i-bpp]):0
      l[i]=l[i]&+UInt8((a+Int(prev[i]))/2)
    }
    case 4: for i in 0..<l.count {
      let a=i>=bpp ? Int(l[i-bpp]):0
      let c=i>=bpp ? Int(prev[i-bpp]):0
      l[i]=l[i]&+UInt8(paeth(a,Int(prev[i]),c))
    }
    default: break
    }
  }

  // ---------------------------------------------------------------------------
  // MARK: zlib + DEFLATE decoder (pure Swift)
  // ---------------------------------------------------------------------------

  private static func zlibInflate(_ data: [UInt8]) -> [UInt8]? {
    // Skip 2-byte zlib header; last 4 bytes are Adler-32 (ignored).
    guard data.count >= 6 else { return nil }
    var r = BitReader(data, start: 2)
    var out = [UInt8](); out.reserveCapacity(65536)
    guard deflate(&r, into: &out) else { return nil }
    return out
  }

  private static func deflate(_ r: inout BitReader, into out: inout [UInt8]) -> Bool {
    repeat {
      let bFinal = r.bit() == 1
      let bType  = r.bits(2)
      switch bType {
      case 0:   // stored
        r.align()
        let len  = Int(r.u16le())
        let nlen = Int(r.u16le())
        guard len == (~nlen & 0xFFFF) else { return false }
        for _ in 0..<len { out.append(r.byte()) }
      case 1:   // fixed Huffman
        let (ll,dd) = fixedTrees()
        guard huffBlock(&r, ll:ll, dd:dd, out:&out) else { return false }
      case 2:   // dynamic Huffman
        guard let (ll,dd) = dynTrees(&r) else { return false }
        guard huffBlock(&r, ll:ll, dd:dd, out:&out) else { return false }
      default: return false
      }
      if bFinal { break }
    } while true
    return true
  }

  // Fixed Huffman lengths (RFC 1951 §3.2.6)
  private static func fixedTrees() -> (HuffTree, HuffTree) {
    var ll = [Int](repeating:0, count:288)
    for i in   0...143 { ll[i]=8 }
    for i in 144...255 { ll[i]=9 }
    for i in 256...279 { ll[i]=7 }
    for i in 280...287 { ll[i]=8 }
    let dd = [Int](repeating:5, count:32)
    return (HuffTree(ll), HuffTree(dd))
  }

  // Dynamic Huffman (RFC 1951 §3.2.7)
  private static func dynTrees(_ r: inout BitReader) -> (HuffTree, HuffTree)? {
    let hlit=r.bits(5)+257, hdist=r.bits(5)+1, hclen=r.bits(4)+4
    let order=[16,17,18,0,8,7,9,6,10,5,11,4,12,3,13,2,14,1,15]
    var cl=[Int](repeating:0, count:19)
    for i in 0..<hclen { cl[order[i]]=r.bits(3) }
    let clTree=HuffTree(cl)
    var lens=[Int]()
    while lens.count < hlit+hdist {
      let s=clTree.decode(&r)
      switch s {
      case 0...15: lens.append(s)
      case 16:
        guard let last=lens.last else { return nil }
        lens+=Array(repeating:last, count:r.bits(2)+3)
      case 17: lens+=Array(repeating:0, count:r.bits(3)+3)
      case 18: lens+=Array(repeating:0, count:r.bits(7)+11)
      default: return nil
      }
    }
    guard lens.count >= hlit+hdist else { return nil }
    return (HuffTree(Array(lens[0..<hlit])), HuffTree(Array(lens[hlit..<hlit+hdist])))
  }

  // Decode a Huffman-coded block
  private static func huffBlock(_ r: inout BitReader,
                                  ll: HuffTree, dd: HuffTree,
                                  out: inout [UInt8]) -> Bool {
    let lenBase  = [3,4,5,6,7,8,9,10,11,13,15,17,19,23,27,31,
                    35,43,51,59,67,83,99,115,131,163,195,227,258]
    let lenExtra = [0,0,0,0,0,0,0,0,1,1,1,1,2,2,2,2,
                    3,3,3,3,4,4,4,4,5,5,5,5,0]
    let dstBase  = [1,2,3,4,5,7,9,13,17,25,33,49,65,97,129,193,
                    257,385,513,769,1025,1537,2049,3073,4097,6145,
                    8193,12289,16385,24577]
    let dstExtra = [0,0,0,0,1,1,2,2,3,3,4,4,5,5,6,6,
                    7,7,8,8,9,9,10,10,11,11,12,12,13,13]
    while true {
      let sym=ll.decode(&r)
      if sym < 256 { out.append(UInt8(sym)) }
      else if sym == 256 { return true }
      else {
        let li=sym-257
        guard li<lenBase.count else { return false }
        let length=lenBase[li]+r.bits(lenExtra[li])
        let di=dd.decode(&r)
        guard di<dstBase.count else { return false }
        let dist=dstBase[di]+r.bits(dstExtra[di])
        let start=out.count-dist
        guard start>=0 else { return false }
        for i in 0..<length { out.append(out[start+i%dist]) }
      }
    }
  }
}

// ---------------------------------------------------------------------------
// MARK: - BitReader
// ---------------------------------------------------------------------------

private struct BitReader {
  private let data: [UInt8]
  private var pos: Int    // byte position
  private var bp:  Int    // bit position within byte (0=LSB)

  init(_ data: [UInt8], start: Int=0) { self.data=data; pos=start; bp=0 }

  mutating func bit() -> Int {
    guard pos < data.count else { return 0 }
    let v=(Int(data[pos])>>bp)&1; bp+=1
    if bp==8 { bp=0; pos+=1 }
    return v
  }
  mutating func bits(_ n: Int) -> Int {
    var v=0; for i in 0..<n { v|=bit()<<i }; return v
  }
  mutating func align() { if bp != 0 { bp=0; pos+=1 } }
  mutating func byte() -> UInt8 { guard pos<data.count else{return 0}; let v=data[pos];pos+=1;return v }
  mutating func u16le() -> UInt16 { let lo=UInt16(byte()); return lo|(UInt16(byte())<<8) }
}

// ---------------------------------------------------------------------------
// MARK: - HuffTree  (canonical Huffman)
// ---------------------------------------------------------------------------

private struct HuffTree {
  // Canonical Huffman decode: sorted symbols per bit-length.
  private let syms:      [Int]   // symbols sorted by (len, canonical order)
  private let counts:    [Int]   // counts[len] = number of symbols with that length
  private let offsets:   [Int]   // offsets[len] = start index in syms[]
  private let firstCode: [Int]   // firstCode[len] = smallest code of that length
  private let maxLen:    Int

  init(_ lengths: [Int]) {
    var bl = [Int](repeating:0, count:16)
    for l in lengths where l>0 { bl[l]+=1 }

    // Compute first codes (RFC 1951 §3.2.2)
    var fc = [Int](repeating:0, count:16)
    var code = 0
    for bits in 1...15 {
      code = (code + bl[bits-1]) << 1
      fc[bits] = code
    }

    // Build sorted symbol list per length
    var offs = [Int](repeating:0, count:16)
    var acc = 0
    for bits in 1...15 { offs[bits]=acc; acc+=bl[bits] }

    var s = [Int](repeating:0, count: max(1, acc))
    var placed = [Int](repeating:0, count:16)
    for (sym,l) in lengths.enumerated() where l>0 {
      s[offs[l]+placed[l]] = sym; placed[l]+=1
    }

    self.syms      = s
    self.counts    = bl
    self.offsets   = offs
    self.firstCode = fc
    self.maxLen    = bl.indices.last(where:{bl[$0]>0}) ?? 0
  }

  func decode(_ r: inout BitReader) -> Int {
    var code=0
    for bits in 1...max(1,maxLen) {
      code=(code<<1)|r.bit()
      if bits > maxLen { break }
      if counts[bits] == 0 { continue }
      let idx = code - firstCode[bits]
      if idx >= 0 && idx < counts[bits] {
        return syms[offsets[bits]+idx]
      }
    }
    return -1
  }
}
#endif  // os(Windows)
