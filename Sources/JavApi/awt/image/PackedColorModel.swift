/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.image {

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
}
