/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.image {

  /// A `ColorModel` that maps pixel values to ARGB colours via a fixed palette
  /// (colour lookup table) — mirrors `java.awt.image.IndexColorModel`.
  ///
  /// Each pixel is an index into the palette.  The palette has at most
  /// `map_size` entries.  An optional transparent index designates one palette
  /// entry as fully transparent (alpha = 0).
  ///
  public final class IndexColorModel: ColorModel {

    // -------------------------------------------------------------------------
    // MARK: Public fields (Java API)
    // -------------------------------------------------------------------------

    /// Number of entries in the colour map.
    public let map_size: Int

    /// Index of the transparent colour entry, or -1 if none.
    public private(set) var transparent_index: Int

    // -------------------------------------------------------------------------
    // MARK: Private palette storage
    // -------------------------------------------------------------------------

    private let reds:   [UInt8]
    private let greens: [UInt8]
    private let blues:  [UInt8]
    private let alphas: [UInt8]   // 255 = opaque, 0 = fully transparent

    // -------------------------------------------------------------------------
    // MARK: Constructors
    // -------------------------------------------------------------------------

    /// Creates an opaque palette from separate R, G, B byte arrays.
    ///
    /// - Parameters:
    ///   - bits: Number of bits per pixel (determines max index range).
    ///   - size: Number of entries to use from the arrays.
    ///   - r: Red components (length ≥ `size`).
    ///   - g: Green components (length ≥ `size`).
    ///   - b: Blue components (length ≥ `size`).
    public init(_ bits: Int, _ size: Int,
                _ r: [UInt8], _ g: [UInt8], _ b: [UInt8]) {
      let clamped = min(size, min(r.count, min(g.count, b.count)))
      self.map_size         = clamped
      self.transparent_index = -1
      self.reds   = Array(r.prefix(clamped))
      self.greens = Array(g.prefix(clamped))
      self.blues  = Array(b.prefix(clamped))
      self.alphas = [UInt8](repeating: 255, count: clamped)
      super.init(bits)
    }

    /// Creates a palette with one designated transparent index.
    ///
    /// - Parameters:
    ///   - bits: Number of bits per pixel.
    ///   - size: Number of entries to use from the arrays.
    ///   - r: Red components.
    ///   - g: Green components.
    ///   - b: Blue components.
    ///   - trans: Index of the transparent colour entry (-1 for none).
    public init(_ bits: Int, _ size: Int,
                _ r: [UInt8], _ g: [UInt8], _ b: [UInt8],
                _ trans: Int) {
      let clamped  = min(size, min(r.count, min(g.count, b.count)))
      let transIdx = (trans >= 0 && trans < clamped) ? trans : -1
      self.map_size          = clamped
      self.transparent_index = transIdx
      self.reds   = Array(r.prefix(clamped))
      self.greens = Array(g.prefix(clamped))
      self.blues  = Array(b.prefix(clamped))
      var a = [UInt8](repeating: 255, count: clamped)
      if transIdx >= 0 { a[transIdx] = 0 }
      self.alphas = a
      super.init(bits)
    }

    /// Creates a palette with per-entry alpha values.
    ///
    /// - Parameters:
    ///   - bits: Number of bits per pixel.
    ///   - size: Number of entries to use from the arrays.
    ///   - r: Red components.
    ///   - g: Green components.
    ///   - b: Blue components.
    ///   - a: Alpha components (255 = opaque).
    public init(_ bits: Int, _ size: Int,
                _ r: [UInt8], _ g: [UInt8], _ b: [UInt8], _ a: [UInt8]) {
      let clamped = min(size, min(r.count, min(g.count, min(b.count, a.count))))
      self.map_size          = clamped
      self.transparent_index = -1
      self.reds   = Array(r.prefix(clamped))
      self.greens = Array(g.prefix(clamped))
      self.blues  = Array(b.prefix(clamped))
      self.alphas = Array(a.prefix(clamped))
      super.init(bits)
    }

    /// Creates a palette from a single interleaved `byte` array (Java §2.6.4).
    ///
    /// The layout of `cmap` depends on `hasalpha`:
    /// - `false`: each entry occupies 3 bytes — R, G, B — starting at
    ///   `cmap[start + 3*i]`.
    /// - `true`:  each entry occupies 4 bytes — R, G, B, A — starting at
    ///   `cmap[start + 4*i]`.
    ///
    /// - Parameters:
    ///   - bits: Number of bits per pixel.
    ///   - size: Number of colour entries.
    ///   - cmap: Interleaved colour component array.
    ///   - start: Offset of the first component in `cmap`.
    ///   - hasalpha: Whether every entry includes an alpha byte.
    public init(_ bits: Int, _ size: Int,
                _ cmap: [UInt8], _ start: Int, _ hasalpha: Bool) {
      let stride  = hasalpha ? 4 : 3
      let avail   = (cmap.count - start) / stride
      let clamped = max(0, min(size, avail))
      self.map_size          = clamped
      self.transparent_index = -1
      var r = [UInt8](), g = [UInt8](), b = [UInt8](), a = [UInt8]()
      for i in 0 ..< clamped {
        let base = start + i * stride
        r.append(cmap[base])
        g.append(cmap[base + 1])
        b.append(cmap[base + 2])
        a.append(hasalpha ? cmap[base + 3] : 255)
      }
      self.reds   = r
      self.greens = g
      self.blues  = b
      self.alphas = a
      super.init(bits)
    }

    /// Creates a palette from a single interleaved `byte` array with a
    /// designated transparent index (Java §2.6.5).
    ///
    /// Same layout as `init(_:_:_:_:_:)` above; in addition the entry at
    /// `trans` is treated as fully transparent regardless of its stored alpha.
    ///
    /// - Parameters:
    ///   - bits: Number of bits per pixel.
    ///   - size: Number of colour entries.
    ///   - cmap: Interleaved colour component array.
    ///   - start: Offset of the first component in `cmap`.
    ///   - hasalpha: Whether every entry includes an alpha byte.
    ///   - trans: Index of the fully transparent pixel (-1 for none).
    public init(_ bits: Int, _ size: Int,
                _ cmap: [UInt8], _ start: Int, _ hasalpha: Bool, _ trans: Int) {
      let stride  = hasalpha ? 4 : 3
      let avail   = (cmap.count - start) / stride
      let clamped = max(0, min(size, avail))
      let transIdx = (trans >= 0 && trans < clamped) ? trans : -1
      self.map_size          = clamped
      self.transparent_index = transIdx
      var r = [UInt8](), g = [UInt8](), b = [UInt8](), a = [UInt8]()
      for i in 0 ..< clamped {
        let base = start + i * stride
        r.append(cmap[base])
        g.append(cmap[base + 1])
        b.append(cmap[base + 2])
        let alpha: UInt8 = (i == transIdx) ? 0 : (hasalpha ? cmap[base + 3] : 255)
        a.append(alpha)
      }
      self.reds   = r
      self.greens = g
      self.blues  = b
      self.alphas = a
      super.init(bits)
    }

    // -------------------------------------------------------------------------
    // MARK: Java 1.0 API
    // -------------------------------------------------------------------------

    /// Returns the number of entries in the colour map.
    public func getMapSize() -> Int { map_size }

    /// Returns the index of the transparent entry, or -1 if none.
    public func getTransparentPixel() -> Int { transparent_index }

    /// Copies the red components of the palette into `r`.
    public func getReds(_ r: inout [UInt8]) {
      for i in 0 ..< min(map_size, r.count) { r[i] = reds[i] }
    }

    /// Copies the green components of the palette into `g`.
    public func getGreens(_ g: inout [UInt8]) {
      for i in 0 ..< min(map_size, g.count) { g[i] = greens[i] }
    }

    /// Copies the blue components of the palette into `b`.
    public func getBlues(_ b: inout [UInt8]) {
      for i in 0 ..< min(map_size, b.count) { b[i] = blues[i] }
    }

    /// Copies the alpha components of the palette into `a`.
    public func getAlphas(_ a: inout [UInt8]) {
      for i in 0 ..< min(map_size, a.count) { a[i] = alphas[i] }
    }

    // -------------------------------------------------------------------------
    // MARK: ColorModel overrides
    // -------------------------------------------------------------------------

    override public func getRed(_ pixel: Int) -> Int {
      guard pixel >= 0 && pixel < map_size else { return 0 }
      return Int(reds[pixel])
    }

    override public func getGreen(_ pixel: Int) -> Int {
      guard pixel >= 0 && pixel < map_size else { return 0 }
      return Int(greens[pixel])
    }

    override public func getBlue(_ pixel: Int) -> Int {
      guard pixel >= 0 && pixel < map_size else { return 0 }
      return Int(blues[pixel])
    }

    override public func getAlpha(_ pixel: Int) -> Int {
      guard pixel >= 0 && pixel < map_size else { return 255 }
      return Int(alphas[pixel])
    }

    override public func getRGB(_ pixel: Int) -> Int {
      guard pixel >= 0 && pixel < map_size else { return 0 }
      return (Int(alphas[pixel]) << 24)
           | (Int(reds[pixel])   << 16)
           | (Int(greens[pixel]) <<  8)
           |  Int(blues[pixel])
    }
  }
}
