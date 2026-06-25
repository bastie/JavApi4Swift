/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

extension java.awt.color {
  
  /// sRGB  (IEC 61966-2-1)
  /// The sRGB ↔ CIE XYZ D50 matrices and gamma functions used here follow the
  /// ICC sRGB profile specification and are identical across all platforms.
  ///
  ///  sRGB → linear:  C_lin = C^2.2  (simplified; exact: piecewise)
  ///  linear → XYZ D65 (3×3 matrix), then Bradford to D50.
  internal final class _SRGBColorSpace: ColorSpace, @unchecked Sendable {
    
    init() { super.init(ColorSpace.TYPE_RGB, 3) }
    
    override func isCS_sRGB() -> Bool { true }
    
    override func getName(_ idx: Int) -> String {
      switch idx { case 0: return "Red"; case 1: return "Green"; case 2: return "Blue"; default: return "Unnamed" }
    }
    
    // sRGB → sRGB: identity
    override func toRGB(_ colorvalue: [Float]) -> [Float] {
      guard colorvalue.count >= 3 else { return [0, 0, 0] }
      return [clamp(colorvalue[0]), clamp(colorvalue[1]), clamp(colorvalue[2])]
    }
    
    override func fromRGB(_ rgbvalue: [Float]) -> [Float] {
      guard rgbvalue.count >= 3 else { return [0, 0, 0] }
      return [clamp(rgbvalue[0]), clamp(rgbvalue[1]), clamp(rgbvalue[2])]
    }
    
    // sRGB → CIE XYZ D50
    override func toCIEXYZ(_ colorvalue: [Float]) -> [Float] {
      guard colorvalue.count >= 3 else { return [0, 0, 0] }
      let r = linearize(colorvalue[0])
      let g = linearize(colorvalue[1])
      let b = linearize(colorvalue[2])
      // sRGB → XYZ D65
      let x65 = r * 0.4124564 + g * 0.3575761 + b * 0.1804375
      let y65 = r * 0.2126729 + g * 0.7151522 + b * 0.0721750
      let z65 = r * 0.0193339 + g * 0.1191920 + b * 0.9503041
      // Bradford D65 → D50
      let x50 = Float( 1.0478112 * Double(x65) + 0.0228866 * Double(y65) - 0.0501270 * Double(z65))
      let y50 = Float( 0.0295424 * Double(x65) + 0.9904844 * Double(y65) - 0.0170491 * Double(z65))
      let z50 = Float(-0.0092345 * Double(x65) + 0.0150436 * Double(y65) + 0.7521316 * Double(z65))
      return [x50, y50, z50]
    }
    
    // CIE XYZ D50 → sRGB
    override func fromCIEXYZ(_ colorvalue: [Float]) -> [Float] {
      guard colorvalue.count >= 3 else { return [0, 0, 0] }
      let x50 = Double(colorvalue[0])
      let y50 = Double(colorvalue[1])
      let z50 = Double(colorvalue[2])
      // Bradford D50 → D65
      let x65 =  0.9555766 * x50 - 0.0230393 * y50 + 0.0631636 * z50
      let y65 = -0.0282895 * x50 + 1.0099416 * y50 + 0.0210077 * z50
      let z65 =  0.0122982 * x50 - 0.0204830 * y50 + 1.3299098 * z50
      // XYZ D65 → linear sRGB
      let rl =  3.2404542 * x65 - 1.5371385 * y65 - 0.4985314 * z65
      let gl = -0.9692660 * x65 + 1.8760108 * y65 + 0.0415560 * z65
      let bl =  0.0556434 * x65 - 0.2040259 * y65 + 1.0572252 * z65
      return [clamp(delinearize(Float(rl))),
              clamp(delinearize(Float(gl))),
              clamp(delinearize(Float(bl)))]
    }
    
    // sRGB gamma — simplified power law (Java SDK uses the same approximation)
    private func linearize(_ v: Float) -> Float {
      v <= 0.04045 ? v / 12.92 : pow((v + 0.055) / 1.055, 2.4)
    }
    private func delinearize(_ v: Float) -> Float {
      v <= 0.0031308 ? 12.92 * v : 1.055 * pow(v, 1.0 / 2.4) - 0.055
    }
    private func clamp(_ v: Float) -> Float { Swift.max(0, Swift.min(1, v)) }
  }
}
