/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.image {

  // ---------------------------------------------------------------------------
  // MARK: - PackedColorModel (abstract)
  // ---------------------------------------------------------------------------

  /// Abstract `ColorModel` for pixels that pack all components into a single
  /// integer — mirrors `java.awt.image.PackedColorModel`.
  ///
  /// `DirectColorModel` is the only standard concrete subclass.
  ///
  /// - Since: Java 1.2
  open class PackedColorModel: ColorModel {

    public let colorSpaceType: Int   // 0 = TYPE_RGB (only one supported here)
    public let componentMasks: [Int]
    public let hasAlpha: Bool
    public let isAlphaPremultiplied: Bool

    public init(bits: Int, componentMasks: [Int],
                hasAlpha: Bool = false,
                isAlphaPremultiplied: Bool = false) {
      self.colorSpaceType          = 0 // TYPE_RGB
      self.componentMasks          = componentMasks
      self.hasAlpha                = hasAlpha
      self.isAlphaPremultiplied    = isAlphaPremultiplied
      super.init(bits)
    }

    public func getMask(_ index: Int) -> Int {
      guard index < componentMasks.count else { return 0 }
      return componentMasks[index]
    }
  }

  // ---------------------------------------------------------------------------
  // MARK: - ComponentColorModel
  // ---------------------------------------------------------------------------

  /// A `ColorModel` for images whose components (R, G, B, A) are stored as
  /// separate, unnormalized samples in a `DataBuffer` —
  /// mirrors `java.awt.image.ComponentColorModel`.
  ///
  /// Supports TYPE_BYTE and TYPE_USHORT data.
  ///
  /// - Since: Java 1.2
  public final class ComponentColorModel: ColorModel {

    public let numComponents: Int
    public let hasAlphaChannel: Bool
    public let isAlphaPremultiplied: Bool
    public let transferType: Int
    /// Scale factor per component (max value → 255 mapping).
    private let scales: [Double]

    /// Creates a component color model.
    ///
    /// - Parameters:
    ///   - numComponents:        Total number of components (e.g. 3 for RGB, 4 for RGBA).
    ///   - hasAlpha:             Whether the model includes an alpha channel.
    ///   - isAlphaPremultiplied: Whether alpha is pre-multiplied.
    ///   - transferType:         `DataBuffer.TYPE_BYTE` or `DataBuffer.TYPE_USHORT`.
    public init(numComponents: Int,
                hasAlpha: Bool,
                isAlphaPremultiplied: Bool,
                transferType: Int) {
      let bitsPerComp: Int
      switch transferType {
      case DataBuffer.TYPE_USHORT: bitsPerComp = 16
      case DataBuffer.TYPE_SHORT:  bitsPerComp = 15
      default:                     bitsPerComp = 8
      }
      let maxVal = Double((1 << bitsPerComp) - 1)
      self.numComponents          = numComponents
      self.hasAlphaChannel        = hasAlpha
      self.isAlphaPremultiplied   = isAlphaPremultiplied
      self.transferType           = transferType
      self.scales                 = [Double](repeating: 255.0 / maxVal, count: numComponents)
      super.init(bitsPerComp * numComponents)
    }

    // Convenience for TYPE_BYTE RGB
    public convenience init(hasAlpha: Bool = false) {
      self.init(numComponents: hasAlpha ? 4 : 3,
                hasAlpha: hasAlpha,
                isAlphaPremultiplied: false,
                transferType: DataBuffer.TYPE_BYTE)
    }

    /// Normalises a raw component value to the 0–255 range.
    public func normalize(_ component: Int, _ index: Int) -> Int {
      Int((Double(component) * scales[index]).rounded())
    }

    // -------------------------------------------------------------------------
    // MARK: ColorModel overrides
    // -------------------------------------------------------------------------

    /// Extracts the red component from a packed pixel (component index 0).
    public override func getRed(_ pixel: Int) -> Int {
      normalize((pixel >> 16) & 0xFF, 0)
    }

    /// Extracts the green component (component index 1).
    public override func getGreen(_ pixel: Int) -> Int {
      normalize((pixel >> 8) & 0xFF, 1 % numComponents)
    }

    /// Extracts the blue component (component index 2).
    public override func getBlue(_ pixel: Int) -> Int {
      normalize(pixel & 0xFF, 2 % numComponents)
    }

    /// Extracts the alpha component (last component), or 255 if no alpha.
    public override func getAlpha(_ pixel: Int) -> Int {
      guard hasAlphaChannel else { return 255 }
      return normalize((pixel >> 24) & 0xFF, numComponents - 1)
    }
  }
}
