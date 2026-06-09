/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.image {

  /// Abstract base class for image filters that work pixel-by-pixel in the
  /// default RGB colour model — mirrors `java.awt.image.RGBImageFilter`.
  ///
  /// Subclasses implement `filterRGB(_:_:_:)` to transform one packed-ARGB
  /// pixel at a time.  If the transformation is position-independent, set
  /// `canFilterIndexColorModel = true` in the subclass initialiser so that
  /// `IndexColorModel` palettes are filtered once rather than every pixel.
  ///
  /// ### Usage example (Swift)
  /// ```swift
  /// class RedBlueSwap: java.awt.image.RGBImageFilter {
  ///   override init() {
  ///     super.init()
  ///     canFilterIndexColorModel = true
  ///   }
  ///   override func filterRGB(_ x: Int, _ y: Int, _ rgb: Int) -> Int {
  ///     return (rgb & 0xFF00FF00)
  ///          | ((rgb & 0xFF0000) >> 16)
  ///          | ((rgb & 0x0000FF) << 16)
  ///   }
  /// }
  /// ```
  open class RGBImageFilter: ImageFilter {

    // -------------------------------------------------------------------------
    // MARK: Fields
    // -------------------------------------------------------------------------

    /// Set to `true` if `filterRGB` does not depend on pixel coordinates.
    /// When `true` and the incoming model is an `IndexColorModel`, the palette
    /// is filtered once and all pixels pass through unmodified.
    public var canFilterIndexColorModel: Bool = false

    /// The original colour model registered by `substituteColorModel`.
    public var origmodel: ColorModel?

    /// The replacement colour model registered by `substituteColorModel`.
    public var newmodel: ColorModel?

    // -------------------------------------------------------------------------
    // MARK: Constructor
    // -------------------------------------------------------------------------

    public override init() {
      super.init()
    }

    // -------------------------------------------------------------------------
    // MARK: Abstract method — subclasses must override
    // -------------------------------------------------------------------------

    /// Transforms a single pixel in the default RGB colour model.
    ///
    /// - Parameters:
    ///   - x: X coordinate of the pixel, or -1 when filtering a palette entry.
    ///   - y: Y coordinate of the pixel, or -1 when filtering a palette entry.
    ///   - rgb: Packed ARGB value (bits 24–31 alpha, 16–23 red, 8–15 green,
    ///          0–7 blue).
    /// - Returns: The transformed packed ARGB value.
    open func filterRGB(_ x: Int, _ y: Int, _ rgb: Int) -> Int {
      return rgb   // identity — subclasses must override
    }

    // -------------------------------------------------------------------------
    // MARK: Java 1.0 API
    // -------------------------------------------------------------------------

    /// Filters every entry of `icm` through `filterRGB` (with x = y = -1).
    /// Returns a new `IndexColorModel` with the transformed palette.
    public func filterIndexColorModel(_ icm: IndexColorModel) -> IndexColorModel {
      let size = icm.getMapSize()
      var r = [UInt8](repeating: 0, count: size)
      var g = [UInt8](repeating: 0, count: size)
      var b = [UInt8](repeating: 0, count: size)
      var a = [UInt8](repeating: 0, count: size)
      icm.getReds(&r)
      icm.getGreens(&g)
      icm.getBlues(&b)
      icm.getAlphas(&a)
      var ra = [UInt8](repeating: 0, count: size)
      var ga = [UInt8](repeating: 0, count: size)
      var ba = [UInt8](repeating: 0, count: size)
      var aa = [UInt8](repeating: 0, count: size)
      for i in 0 ..< size {
        let rgb = (Int(a[i]) << 24) | (Int(r[i]) << 16) | (Int(g[i]) << 8) | Int(b[i])
        let filtered = filterRGB(-1, -1, rgb)
        aa[i] = UInt8((filtered >> 24) & 0xFF)
        ra[i] = UInt8((filtered >> 16) & 0xFF)
        ga[i] = UInt8((filtered >>  8) & 0xFF)
        ba[i] = UInt8( filtered        & 0xFF)
      }
      return IndexColorModel(icm.pixel_bits, size, ra, ga, ba, aa)
    }

    /// Filters a rectangle of packed-int RGB pixels one by one through
    /// `filterRGB` and forwards the result to the consumer.
    public func filterRGBPixels(_ x: Int, _ y: Int, _ w: Int, _ h: Int,
                                _ pixels: [Int], _ off: Int, _ scansize: Int) {
      var output = pixels
      for row in 0 ..< h {
        for col in 0 ..< w {
          let idx = off + row * scansize + col
          output[idx] = filterRGB(x + col, y + row, pixels[idx])
        }
      }
      consumer?.setPixels(x, y, w, h,
                          java.awt.image.ColorModel.getRGBdefault(),
                          output, off, scansize)
    }

    /// Registers `oldcm` → `newcm` substitution for subsequent `setPixels`
    /// calls: pixels arriving with `oldcm` are forwarded with `newcm` instead.
    public func substituteColorModel(_ oldcm: ColorModel, _ newcm: ColorModel) {
      origmodel = oldcm
      self.newmodel  = newcm
    }

    // -------------------------------------------------------------------------
    // MARK: ImageFilter overrides
    // -------------------------------------------------------------------------

    override public func setColorModel(_ model: ColorModel) {
      if canFilterIndexColorModel, let icm = model as? IndexColorModel {
        let filtered = filterIndexColorModel(icm)
        substituteColorModel(icm, filtered)
        consumer?.setColorModel(filtered)
      } else {
        consumer?.setColorModel(ColorModel.getRGBdefault())
      }
    }

    override public func setPixels(_ x: Int, _ y: Int, _ w: Int, _ h: Int,
                                   _ model: ColorModel,
                                   _ pixels: [UInt8], _ off: Int, _ scansize: Int) {
      // If model was substituted, forward with new model unchanged.
      if let orig = origmodel, orig === model, let sub = newmodel {
        consumer?.setPixels(x, y, w, h, sub, pixels, off, scansize)
        return
      }
      // Otherwise convert byte pixels → RGB ints → filterRGBPixels.
      var ints = [Int](repeating: 0, count: off + h * scansize)
      for row in 0 ..< h {
        for col in 0 ..< w {
          let idx = off + row * scansize + col
          ints[idx] = model.getRGB(Int(pixels[idx]))
        }
      }
      filterRGBPixels(x, y, w, h, ints, off, scansize)
    }

    override public func setPixels(_ x: Int, _ y: Int, _ w: Int, _ h: Int,
                                   _ model: ColorModel,
                                   _ pixels: [Int], _ off: Int, _ scansize: Int) {
      // If model was substituted, forward with new model unchanged.
      if let orig = origmodel, orig === model, let sub = newmodel {
        consumer?.setPixels(x, y, w, h, sub, pixels, off, scansize)
        return
      }
      // Convert to default RGB if needed, then filter.
      if model === ColorModel.getRGBdefault() {
        filterRGBPixels(x, y, w, h, pixels, off, scansize)
      } else {
        var rgbPixels = pixels
        for row in 0 ..< h {
          for col in 0 ..< w {
            let idx = off + row * scansize + col
            rgbPixels[idx] = model.getRGB(pixels[idx])
          }
        }
        filterRGBPixels(x, y, w, h, rgbPixels, off, scansize)
      }
    }

    // -------------------------------------------------------------------------
    // MARK: makeInstance (for getFilterInstance)
    // -------------------------------------------------------------------------

    override open func makeInstance() -> ImageFilter { RGBImageFilter() }
  }
}
