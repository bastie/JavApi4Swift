/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.color {

  /// An ICC profile that describes an RGB colour space —
  /// mirrors `java.awt.color.ICC_ProfileRGB`.
  ///
  /// Provides the standard ICC RGB profile entries: media white point,
  /// colorant primaries (as XYZ values), and the transfer-curve (TRC) gamma.
  ///
  /// - Since: Java 1.2
  public final class ICC_ProfileRGB: ICC_Profile, @unchecked Sendable {

    // ICC tag constants for the three channels
    public static let REDCOMPONENT:   Int = 0
    public static let GREENCOMPONENT: Int = 1
    public static let BLUECOMPONENT:  Int = 2

    /// Returns the media white point [X, Y, Z] of this profile.
    ///
    /// For sRGB and linear-RGB the D50 white point is returned:
    /// (0.9642, 1.0000, 0.8249).
    public func getMediaWhitePoint() -> [Float] {
      [0.9642, 1.0000, 0.8249]   // D50
    }

    /// Returns the 3×3 colorant matrix that transforms linear RGB values to
    /// CIE XYZ D50.  The matrix is stored in row-major order:
    /// `[[Xr,Xg,Xb],[Yr,Yg,Yb],[Zr,Zg,Zb]]`.
    public func getMatrix() -> [[Float]] {
      // sRGB primaries → XYZ D50 (adapted via Bradford)
      [
        [ 0.4360747, 0.3850649, 0.1430804 ],
        [ 0.2225045, 0.7168786, 0.0606169 ],
        [ 0.0139322, 0.0971045, 0.7141733 ]
      ]
    }

    /// Returns the gamma value of the transfer curve for the given channel.
    ///
    /// For sRGB this is approximately 2.2 (the simplified power-law
    /// representation).  For `CS_LINEAR_RGB` it is 1.0.
    ///
    /// - Parameter component: `REDCOMPONENT`, `GREENCOMPONENT`, or
    ///   `BLUECOMPONENT`.
    public func getGamma(_ component: Int) -> Float {
      colorSpaceID == ColorSpace.CS_LINEAR_RGB ? 1.0 : 2.2
    }
  }
}
