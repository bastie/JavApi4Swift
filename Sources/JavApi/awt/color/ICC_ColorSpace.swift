/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.color {

  /// A `ColorSpace` backed by an `ICC_Profile` —
  /// mirrors `java.awt.color.ICC_ColorSpace`.
  ///
  /// Colour conversions are delegated to the underlying `ICC_Profile` type.
  /// For the predefined profiles (sRGB, linear-RGB, CIEXYZ, gray) the same
  /// pure-Swift math as in `ColorSpace.getInstance()` is reused; there is no
  /// platform dependency.
  ///
  /// - Since: Java 1.2
  open class ICC_ColorSpace: ColorSpace, @unchecked Sendable {

    // =========================================================================
    // MARK: - Stored properties
    // =========================================================================

    private let profile: ICC_Profile
    /// Delegate colour space used for all conversions.
    private let delegate: ColorSpace

    // =========================================================================
    // MARK: - Initialisers
    // =========================================================================

    /// Creates an `ICC_ColorSpace` from the given `ICC_Profile`.
    ///
    /// - Parameter profile: The ICC profile backing this colour space.
    public init(_ profile: ICC_Profile) throws {
      self.profile  = profile
      self.delegate = try ColorSpace.getInstance(profile.colorSpaceID)
      super.init(delegate.getType(), delegate.getNumComponents())
    }

    // =========================================================================
    // MARK: - Accessors
    // =========================================================================

    /// Returns the `ICC_Profile` that backs this colour space.
    public func getProfile() -> ICC_Profile { profile }

    // =========================================================================
    // MARK: - Conversion (delegated)
    // =========================================================================

    override public func toRGB(_ colorvalue: [Float]) -> [Float] {
      delegate.toRGB(colorvalue)
    }

    override public func fromRGB(_ rgbvalue: [Float]) -> [Float] {
      delegate.fromRGB(rgbvalue)
    }

    override public func toCIEXYZ(_ colorvalue: [Float]) -> [Float] {
      delegate.toCIEXYZ(colorvalue)
    }

    override public func fromCIEXYZ(_ colorvalue: [Float]) -> [Float] {
      delegate.fromCIEXYZ(colorvalue)
    }

    override public func isCS_sRGB() -> Bool { delegate.isCS_sRGB() }

    override public func getName(_ idx: Int) -> String { delegate.getName(idx) }

    override public func getMinValue(_ component: Int) -> Float { delegate.getMinValue(component) }

    override public func getMaxValue(_ component: Int) -> Float { delegate.getMaxValue(component) }
  }
}
