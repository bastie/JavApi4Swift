/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.image {

  /// A `ColorModel` that encodes RGB(A) components as bit-fields in a packed
  /// `int` pixel value — mirrors `java.awt.image.DirectColorModel`.
  ///
  /// Example: the default sRGB model uses
  /// - red   mask `0x00FF0000`
  /// - green mask `0x0000FF00`
  /// - blue  mask `0x000000FF`
  /// - alpha mask `0xFF000000`
  public final class DirectColorModel: ColorModel {

    // -------------------------------------------------------------------------
    // MARK: Fields
    // -------------------------------------------------------------------------

    public let red_mask:   Int
    public let green_mask: Int
    public let blue_mask:  Int
    public let alpha_mask: Int

    private let red_offset:   Int
    private let green_offset: Int
    private let blue_offset:  Int
    private let alpha_offset: Int

    public let red_bits:   Int
    public let green_bits: Int
    public let blue_bits:  Int
    public let alpha_bits: Int

    // -------------------------------------------------------------------------
    // MARK: Constructors
    // -------------------------------------------------------------------------

    /// Creates a model with separate masks for each channel and an explicit
    /// alpha mask.
    public init(_ bits: Int, _ redMask: Int, _ greenMask: Int, _ blueMask: Int, _ alphaMask: Int = 0) {
      self.red_mask   = redMask
      self.green_mask = greenMask
      self.blue_mask  = blueMask
      self.alpha_mask = alphaMask

      func countBits(_ mask: Int) -> Int {
        var m = mask, count = 0
        while m != 0 { count += m & 1; m = m >> 1 }
        return count
      }
      func trailingZeros(_ mask: Int) -> Int {
        guard mask != 0 else { return 0 }
        var m = mask, count = 0
        while m & 1 == 0 { count += 1; m = m >> 1 }
        return count
      }

      red_offset   = trailingZeros(redMask)
      green_offset = trailingZeros(greenMask)
      blue_offset  = trailingZeros(blueMask)
      alpha_offset = alphaMask != 0 ? trailingZeros(alphaMask) : 0

      red_bits   = countBits(redMask)
      green_bits = countBits(greenMask)
      blue_bits  = countBits(blueMask)
      alpha_bits = alphaMask != 0 ? countBits(alphaMask) : 0

      super.init(bits)
    }

    /// Opaque RGB model (no alpha channel).
    public convenience init(_ bits: Int,
                             redMask: Int, greenMask: Int, blueMask: Int) {
      self.init(bits, redMask, greenMask, blueMask, 0)
    }

    // -------------------------------------------------------------------------
    // MARK: Channel extraction
    // -------------------------------------------------------------------------

    override public func getRed(_ pixel: Int) -> Int {
      scale((pixel & red_mask) >> red_offset, bits: red_bits)
    }
    override public func getGreen(_ pixel: Int) -> Int {
      scale((pixel & green_mask) >> green_offset, bits: green_bits)
    }
    override public func getBlue(_ pixel: Int) -> Int {
      scale((pixel & blue_mask) >> blue_offset, bits: blue_bits)
    }
    override public func getAlpha(_ pixel: Int) -> Int {
      guard alpha_mask != 0 else { return 255 }
      return scale((pixel & alpha_mask) >> alpha_offset, bits: alpha_bits)
    }

    // -------------------------------------------------------------------------
    // MARK: Accessors
    // -------------------------------------------------------------------------

    public func getRedMask()   -> Int { red_mask   }
    public func getGreenMask() -> Int { green_mask }
    public func getBlueMask()  -> Int { blue_mask  }
    public func getAlphaMask() -> Int { alpha_mask }

    // -------------------------------------------------------------------------
    // MARK: Private helpers
    // -------------------------------------------------------------------------

    /// Scale a `bits`-wide value to the 0–255 range.
    private func scale(_ value: Int, bits: Int) -> Int {
      guard bits > 0 else { return 0 }
      if bits == 8 { return value & 0xFF }
      // Scale: value * 255 / ((1 << bits) - 1)
      let maxVal = (1 << bits) - 1
      return (value * 255) / maxVal
    }
  }
}
