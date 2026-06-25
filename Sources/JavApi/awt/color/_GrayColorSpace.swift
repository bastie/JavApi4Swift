/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.color {
  
  /// Gray  (linear luminance, single component)
  internal final class _GrayColorSpace: ColorSpace, @unchecked Sendable {
    
    init() { super.init(ColorSpace.TYPE_GRAY, 1) }
    
    override func getName(_ idx: Int) -> String {
      return "Gray"
    }
    
    // Gray → sRGB: replicate to R, G, B
    override func toRGB(_ colorvalue: [Float]) -> [Float] {
      let v = clamp(colorvalue.first ?? 0)
      return [v, v, v]
    }
    
    // sRGB → Gray: luminance via Rec. 709 coefficients
    override func fromRGB(_ rgbvalue: [Float]) -> [Float] {
      guard rgbvalue.count >= 3 else { return [0] }
      let y = 0.2126 * clamp(rgbvalue[0]) + 0.7152 * clamp(rgbvalue[1]) + 0.0722 * clamp(rgbvalue[2])
      return [y]
    }
    
    // Gray → XYZ D50: Y = gray, X = 0.9505 * Y, Z = 1.0890 * Y  (D50 white)
    override func toCIEXYZ(_ colorvalue: [Float]) -> [Float] {
      let y = clamp(colorvalue.first ?? 0)
      return [0.9505 * y, y, 1.0890 * y]
    }
    
    // XYZ D50 → Gray: use Y channel
    override func fromCIEXYZ(_ colorvalue: [Float]) -> [Float] {
      guard colorvalue.count >= 2 else { return [0] }
      return [clamp(colorvalue[1])]
    }
    
    private func clamp(_ v: Float) -> Float { Swift.max(0, Swift.min(1, v)) }
  }
}
