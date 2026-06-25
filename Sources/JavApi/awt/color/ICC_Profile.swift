/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.color {

  /// Represents an ICC colour profile — mirrors `java.awt.color.ICC_Profile`.
  ///
  /// Only the predefined profiles (sRGB, linear RGB, CIEXYZ, gray) are
  /// supported.  Full ICC byte-stream parsing is outside scope; the
  /// implementation is pure Swift and platform-independent.
  ///
  /// Obtain instances via ``getInstance(_:)`` (predefined) or
  /// ``getInstance(_:)-data`` (raw bytes — returns a stub sRGB profile).
  ///
  /// - Since: Java 1.2
  open class ICC_Profile: @unchecked Sendable {

    // =========================================================================
    // MARK: - Colour-space type constants  (mirrors ColorSpace.TYPE_*)
    // =========================================================================

    public static let icSigXYZData:   Int = 0x58595A20  // 'XYZ '
    public static let icSigRgbData:   Int = 0x52474220  // 'RGB '
    public static let icSigGrayData:  Int = 0x47524159  // 'GRAY'
    public static let icSigLabData:   Int = 0x4C616220  // 'Lab '

    // =========================================================================
    // MARK: - Internal state
    // =========================================================================

    /// The `ColorSpace` constant this profile corresponds to.
    internal let colorSpaceID: Int

    // =========================================================================
    // MARK: - Designated initialiser (internal)
    // =========================================================================

    internal init(colorSpaceID: Int) {
      self.colorSpaceID = colorSpaceID
    }

    // =========================================================================
    // MARK: - Factory — predefined profiles
    // =========================================================================

    /// Returns a predefined `ICC_Profile` for the given colour-space constant.
    ///
    /// - Parameter cspace: One of `ColorSpace.CS_sRGB`, `CS_LINEAR_RGB`,
    ///   `CS_CIEXYZ`, or `CS_GRAY`.
    /// - Returns: The corresponding profile.  `CS_sRGB` is returned for
    ///   unrecognised constants.
    public static func getInstance(_ cspace: Int) -> ICC_Profile {
      switch cspace {
      case ColorSpace.CS_sRGB:
        return ICC_ProfileRGB(colorSpaceID: ColorSpace.CS_sRGB)
      case ColorSpace.CS_LINEAR_RGB:
        return ICC_ProfileRGB(colorSpaceID: ColorSpace.CS_LINEAR_RGB)
      case ColorSpace.CS_CIEXYZ:
        return ICC_Profile(colorSpaceID: ColorSpace.CS_CIEXYZ)
      case ColorSpace.CS_GRAY:
        return ICC_ProfileGray(colorSpaceID: ColorSpace.CS_GRAY)
      default:
        return ICC_ProfileRGB(colorSpaceID: ColorSpace.CS_sRGB)
      }
    }

    /// Creates an `ICC_Profile` from raw ICC profile bytes.
    ///
    /// Full byte-stream parsing is not implemented; this factory returns a
    /// stub sRGB profile regardless of the byte content.
    ///
    /// - Parameter data: Raw ICC profile bytes (ignored in current implementation).
    /// - Returns: An sRGB stub profile.
    public static func getInstance(_ data: [UInt8]) -> ICC_Profile {
      return ICC_ProfileRGB(colorSpaceID: ColorSpace.CS_sRGB)
    }

    // =========================================================================
    // MARK: - Public API
    // =========================================================================

    /// Returns the colour-space type of this profile (e.g. `ColorSpace.TYPE_RGB`).
    public func getColorSpaceType() -> Int {
      switch colorSpaceID {
      case ColorSpace.CS_sRGB, ColorSpace.CS_LINEAR_RGB:
        return ColorSpace.TYPE_RGB
      case ColorSpace.CS_CIEXYZ:
        return ColorSpace.TYPE_XYZ
      case ColorSpace.CS_GRAY:
        return ColorSpace.TYPE_GRAY
      default:
        return ColorSpace.TYPE_RGB
      }
    }

    /// Returns the number of colour components described by this profile.
    public func getNumComponents() -> Int {
      switch getColorSpaceType() {
      case ColorSpace.TYPE_GRAY: return 1
      default:                   return 3
      }
    }

    /// Returns the profile class tag.  Always `icSigRgbData` or `icSigGrayData`
    /// for the predefined profiles.
    public func getProfileClass() -> Int {
      getColorSpaceType() == ColorSpace.TYPE_GRAY ? ICC_Profile.icSigGrayData : ICC_Profile.icSigRgbData
    }
  }
}
