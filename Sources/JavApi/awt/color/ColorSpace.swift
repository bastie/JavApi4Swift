/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

extension java.awt.color {

  /// Abstract base class for colour spaces — mirrors `java.awt.color.ColorSpace`.
  ///
  /// A `ColorSpace` describes the set of colours that can be produced by a
  /// given device or mathematical model and provides conversion to/from the
  /// device-independent sRGB and CIE XYZ colour spaces.
  ///
  /// The four predefined instances are obtained via ``getInstance(_:)``:
  /// - `CS_sRGB`       — the standard sRGB colour space (IEC 61966-2-1)
  /// - `CS_LINEAR_RGB` — linear-light sRGB (no gamma)
  /// - `CS_CIEXYZ`     — CIE XYZ D50 reference colour space
  /// - `CS_GRAY`       — linear grey scale
  ///
  /// All conversions are pure Swift — no platform SDK is required, so this
  /// class works identically on Apple, Linux, Windows, Android and WASI.
  ///
  /// - Since: Java 1.2
  open class ColorSpace: @unchecked Sendable {

    // =========================================================================
    // MARK: - Colour-space type constants  (getType())
    // =========================================================================

    /// XYZ colour space type.
    public static let TYPE_XYZ:   Int = 0
    /// Lab colour space type.
    public static let TYPE_Lab:   Int = 1
    /// Luv colour space type.
    public static let TYPE_Luv:   Int = 2
    /// YCbCr colour space type.
    public static let TYPE_YCbCr: Int = 3
    /// Yxy colour space type.
    public static let TYPE_Yxy:   Int = 4
    /// RGB colour space type.
    public static let TYPE_RGB:   Int = 5
    /// Gray colour space type.
    public static let TYPE_GRAY:  Int = 6
    /// HSV colour space type.
    public static let TYPE_HSV:   Int = 7
    /// HLS colour space type.
    public static let TYPE_HLS:   Int = 8
    /// CMYK colour space type.
    public static let TYPE_CMYK:  Int = 9
    /// CMY colour space type.
    public static let TYPE_CMY:   Int = 11
    /// Generic 2-component colour space type.
    public static let TYPE_2CLR:  Int = 12
    /// Generic 3-component colour space type.
    public static let TYPE_3CLR:  Int = 13
    /// Generic 4-component colour space type.
    public static let TYPE_4CLR:  Int = 14
    /// Generic 5-component colour space type.
    public static let TYPE_5CLR:  Int = 15
    /// Generic 6-component colour space type.
    public static let TYPE_6CLR:  Int = 16
    /// Generic 7-component colour space type.
    public static let TYPE_7CLR:  Int = 17
    /// Generic 8-component colour space type.
    public static let TYPE_8CLR:  Int = 18
    /// Generic 9-component colour space type.
    public static let TYPE_9CLR:  Int = 19
    /// Generic 10-component colour space type.
    public static let TYPE_ACLR:  Int = 20
    /// Generic 11-component colour space type.
    public static let TYPE_BCLR:  Int = 21
    /// Generic 12-component colour space type.
    public static let TYPE_CCLR:  Int = 22
    /// Generic 13-component colour space type.
    public static let TYPE_DCLR:  Int = 23
    /// Generic 14-component colour space type.
    public static let TYPE_ECLR:  Int = 24
    /// Generic 15-component colour space type.
    public static let TYPE_FCLR:  Int = 25

    // =========================================================================
    // MARK: - Predefined colour-space identifiers  (getInstance())
    // =========================================================================

    /// sRGB colour space (IEC 61966-2-1).
    public static let CS_sRGB:       Int = 1000
    /// Linear-light sRGB (no gamma encoding).
    public static let CS_LINEAR_RGB: Int = 1001
    /// CIE XYZ colour space, D50 white point.
    public static let CS_CIEXYZ:     Int = 1002
    /// Linear grey-scale colour space.
    public static let CS_GRAY:       Int = 1003
    /// PYCC photo YCC colour space.
    public static let CS_PYCC:       Int = 1004

    // =========================================================================
    // MARK: - Cached singleton instances
    // =========================================================================

    // Swift guarantees that `static let` in an enum is initialised exactly
    // once, lazily, and thread-safely — no lock needed.
    private enum Singletons {
      static let sRGB:      ColorSpace = _SRGBColorSpace()
      static let linearRGB: ColorSpace = _LinearRGBColorSpace()
      static let ciexyz:    ColorSpace = _CIEXYZColorSpace()
      static let gray:      ColorSpace = _GrayColorSpace()
    }

    // =========================================================================
    // MARK: - Stored properties
    // =========================================================================

    private let _type:          Int
    private let _numComponents: Int

    // =========================================================================
    // MARK: - Initialiser (protected)
    // =========================================================================

    /// Creates a colour space of the given type with the given number of
    /// components.  Subclasses must call this initialiser.
    public init(_ type: Int, _ numcomponents: Int) {
      self._type          = type
      self._numComponents = numcomponents
    }

    // =========================================================================
    // MARK: - Factory
    // =========================================================================

    /// Returns a predefined `ColorSpace` instance.
    ///
    /// - Parameter colorspace: One of `CS_sRGB`, `CS_LINEAR_RGB`,
    ///   `CS_CIEXYZ`, `CS_GRAY`, or `CS_PYCC`.
    /// - Returns: The corresponding `ColorSpace`.
    public static func getInstance(_ colorspace: Int) throws (IllegalArgumentException) -> ColorSpace {
      switch colorspace {
      case CS_sRGB:      return Singletons.sRGB
      case CS_LINEAR_RGB:return Singletons.linearRGB
      case CS_CIEXYZ:    return Singletons.ciexyz
      case CS_GRAY:      return Singletons.gray
      case CS_PYCC:
        throw IllegalArgumentException("CS_PYCC is not yet supported", UnsupportedOperationException())
      default:
        return Singletons.sRGB
      }
    }

    // =========================================================================
    // MARK: - Abstract conversion methods (override in subclasses)
    // =========================================================================

    /// Converts a colour value in this colour space to sRGB.
    ///
    /// - Parameter colorvalue: Normalised component values (0.0–1.0 for most
    ///   colour spaces; XYZ components may exceed 1.0).
    /// - Returns: sRGB components [R, G, B] each in 0.0–1.0.
    open func toRGB(_ colorvalue: [Float]) -> [Float] {
      fatalError("ColorSpace.toRGB() must be overridden by subclass")
    }

    /// Converts sRGB values to this colour space.
    ///
    /// - Parameter rgbvalue: sRGB components [R, G, B] each in 0.0–1.0.
    /// - Returns: Components in this colour space.
    open func fromRGB(_ rgbvalue: [Float]) -> [Float] {
      fatalError("ColorSpace.fromRGB() must be overridden by subclass")
    }

    /// Converts a colour value in this colour space to CIE XYZ (D50).
    ///
    /// - Parameter colorvalue: Normalised component values in this colour space.
    /// - Returns: CIE XYZ components [X, Y, Z].
    open func toCIEXYZ(_ colorvalue: [Float]) -> [Float] {
      fatalError("ColorSpace.toCIEXYZ() must be overridden by subclass")
    }

    /// Converts CIE XYZ (D50) values to this colour space.
    ///
    /// - Parameter colorvalue: CIE XYZ components [X, Y, Z].
    /// - Returns: Components in this colour space.
    open func fromCIEXYZ(_ colorvalue: [Float]) -> [Float] {
      fatalError("ColorSpace.fromCIEXYZ() must be overridden by subclass")
    }

    // =========================================================================
    // MARK: - Concrete methods
    // =========================================================================

    /// Returns the colour-space type (e.g. `TYPE_RGB`, `TYPE_GRAY`).
    public func getType() -> Int { _type }

    /// Returns the number of components in this colour space.
    public func getNumComponents() -> Int { _numComponents }

    /// Returns `true` if this colour space is the built-in sRGB colour space.
    public func isCS_sRGB() -> Bool { false }

    /// Returns a human-readable name for the given component index.
    ///
    /// The default implementation returns `"Unnamed"`.  Subclasses override
    /// this to return meaningful names such as `"Red"`, `"Green"`, etc.
    open func getName(_ idx: Int) -> String { "Unnamed" }

    /// Returns the minimum normalised value for the given component.
    ///
    /// Always `0.0` for the predefined colour spaces.
    open func getMinValue(_ component: Int) -> Float { 0.0 }

    /// Returns the maximum normalised value for the given component.
    ///
    /// Always `1.0` for the predefined colour spaces.
    open func getMaxValue(_ component: Int) -> Float { 1.0 }
  }
}
