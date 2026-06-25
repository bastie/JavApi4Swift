/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Testing
@testable import JavApi

@Suite("java.awt.color")
struct JavApi_awt_color_Tests {

  // ===========================================================================
  // MARK: - ColorSpace constants
  // ===========================================================================

  @Suite("ColorSpace — constants")
  struct ConstantsTests {

    @Test("CS_* constants have correct values")
    func csConstants() {
      #expect(java.awt.color.ColorSpace.CS_sRGB       == 1000)
      #expect(java.awt.color.ColorSpace.CS_LINEAR_RGB == 1001)
      #expect(java.awt.color.ColorSpace.CS_CIEXYZ     == 1002)
      #expect(java.awt.color.ColorSpace.CS_GRAY       == 1003)
      #expect(java.awt.color.ColorSpace.CS_PYCC       == 1004)
    }

    @Test("TYPE_* constants have correct values")
    func typeConstants() {
      #expect(java.awt.color.ColorSpace.TYPE_XYZ  == 0)
      #expect(java.awt.color.ColorSpace.TYPE_RGB  == 5)
      #expect(java.awt.color.ColorSpace.TYPE_GRAY == 6)
    }
  }

  // ===========================================================================
  // MARK: - ColorSpace.getInstance
  // ===========================================================================

  @Suite("ColorSpace — getInstance")
  struct GetInstanceTests {

    @Test("getInstance(CS_sRGB) returns RGB type with 3 components")
    func sRGB_typeAndComponents() {
      let cs = try! java.awt.color.ColorSpace.getInstance(java.awt.color.ColorSpace.CS_sRGB)
      #expect(cs.getType() == java.awt.color.ColorSpace.TYPE_RGB)
      #expect(cs.getNumComponents() == 3)
      #expect(cs.isCS_sRGB() == true)
    }

    @Test("getInstance(CS_LINEAR_RGB) returns RGB type with 3 components")
    func linearRGB_typeAndComponents() {
      let cs = try! java.awt.color.ColorSpace.getInstance(java.awt.color.ColorSpace.CS_LINEAR_RGB)
      #expect(cs.getType() == java.awt.color.ColorSpace.TYPE_RGB)
      #expect(cs.getNumComponents() == 3)
      #expect(cs.isCS_sRGB() == false)
    }

    @Test("getInstance(CS_CIEXYZ) returns XYZ type with 3 components")
    func ciexyz_typeAndComponents() {
      let cs = try! java.awt.color.ColorSpace.getInstance(java.awt.color.ColorSpace.CS_CIEXYZ)
      #expect(cs.getType() == java.awt.color.ColorSpace.TYPE_XYZ)
      #expect(cs.getNumComponents() == 3)
    }

    @Test("getInstance(CS_GRAY) returns GRAY type with 1 component")
    func gray_typeAndComponents() {
      let cs = try! java.awt.color.ColorSpace.getInstance(java.awt.color.ColorSpace.CS_GRAY)
      #expect(cs.getType() == java.awt.color.ColorSpace.TYPE_GRAY)
      #expect(cs.getNumComponents() == 1)
    }

    @Test("getInstance returns cached singletons")
    func singletonIdentity() {
      let a = try! java.awt.color.ColorSpace.getInstance(java.awt.color.ColorSpace.CS_sRGB)
      let b = try! java.awt.color.ColorSpace.getInstance(java.awt.color.ColorSpace.CS_sRGB)
      #expect(a === b)
    }

    @Test("getName returns non-empty strings for all components")
    func getName_sRGB() {
      let cs = try! java.awt.color.ColorSpace.getInstance(java.awt.color.ColorSpace.CS_sRGB)
      #expect(cs.getName(0) == "Red")
      #expect(cs.getName(1) == "Green")
      #expect(cs.getName(2) == "Blue")
    }

    @Test("getName for GRAY returns Gray")
    func getName_gray() {
      let cs = try! java.awt.color.ColorSpace.getInstance(java.awt.color.ColorSpace.CS_GRAY)
      #expect(cs.getName(0) == "Gray")
    }

    @Test("getMinValue / getMaxValue for sRGB are 0 and 1")
    func minMaxValue_sRGB() {
      let cs = try! java.awt.color.ColorSpace.getInstance(java.awt.color.ColorSpace.CS_sRGB)
      #expect(cs.getMinValue(0) == 0.0)
      #expect(cs.getMaxValue(0) == 1.0)
    }

    @Test("getMaxValue for CIEXYZ exceeds 1.0")
    func maxValue_ciexyz() {
      let cs = try! java.awt.color.ColorSpace.getInstance(java.awt.color.ColorSpace.CS_CIEXYZ)
      #expect(cs.getMaxValue(0) > 1.0)
    }

    @Test("getInstance(CS_PYCC) throws IllegalArgumentException")
    func pycc_throws() {
      #expect(throws: (any Error).self) {
        try java.awt.color.ColorSpace.getInstance(java.awt.color.ColorSpace.CS_PYCC)
      }
    }
  }

  // ===========================================================================
  // MARK: - sRGB conversions
  // ===========================================================================

  @Suite("sRGB — conversions")
  struct SRGBConversionTests {

    let cs = try! java.awt.color.ColorSpace.getInstance(java.awt.color.ColorSpace.CS_sRGB)
    let eps: Float = 0.002   // 0.2% tolerance for gamma round-trips

    @Test("toRGB is identity for sRGB")
    func toRGB_identity() {
      let result = cs.toRGB([0.5, 0.25, 0.75])
      #expect(abs(result[0] - 0.5) < eps)
      #expect(abs(result[1] - 0.25) < eps)
      #expect(abs(result[2] - 0.75) < eps)
    }

    @Test("toRGB clamps values outside 0–1")
    func toRGB_clamps() {
      let result = cs.toRGB([-0.1, 0.5, 1.2])
      #expect(result[0] == 0.0)
      #expect(result[2] == 1.0)
    }

    @Test("black toRGB → toCIEXYZ round-trip")
    func black_roundTrip() {
      let rgb: [Float] = [0, 0, 0]
      let xyz = cs.toCIEXYZ(rgb)
      #expect(abs(xyz[0]) < eps)
      #expect(abs(xyz[1]) < eps)
      #expect(abs(xyz[2]) < eps)
    }

    @Test("white toRGB → toCIEXYZ produces D50 white point")
    func white_toXYZ() {
      let xyz = cs.toCIEXYZ([1, 1, 1])
      // D50 white point: X≈0.9642, Y≈1.0, Z≈0.8249
      #expect(abs(xyz[0] - 0.9642) < 0.01)
      #expect(abs(xyz[1] - 1.0000) < 0.01)
      #expect(abs(xyz[2] - 0.8249) < 0.01)
    }

    @Test("sRGB → XYZ → sRGB round-trip for mid-grey")
    func midGrey_roundTrip() {
      let input: [Float] = [0.5, 0.5, 0.5]
      let xyz    = cs.toCIEXYZ(input)
      let result = cs.fromCIEXYZ(xyz)
      #expect(abs(result[0] - 0.5) < eps)
      #expect(abs(result[1] - 0.5) < eps)
      #expect(abs(result[2] - 0.5) < eps)
    }

    @Test("sRGB → XYZ → sRGB round-trip for red primary")
    func red_roundTrip() {
      let input: [Float] = [1, 0, 0]
      let xyz    = cs.toCIEXYZ(input)
      let result = cs.fromCIEXYZ(xyz)
      #expect(abs(result[0] - 1.0) < eps)
      #expect(abs(result[1] - 0.0) < eps)
      #expect(abs(result[2] - 0.0) < eps)
    }

    @Test("sRGB → XYZ → sRGB round-trip for green primary")
    func green_roundTrip() {
      let input: [Float] = [0, 1, 0]
      let xyz    = cs.toCIEXYZ(input)
      let result = cs.fromCIEXYZ(xyz)
      #expect(abs(result[0] - 0.0) < eps)
      #expect(abs(result[1] - 1.0) < eps)
      #expect(abs(result[2] - 0.0) < eps)
    }

    @Test("sRGB → XYZ → sRGB round-trip for blue primary")
    func blue_roundTrip() {
      let input: [Float] = [0, 0, 1]
      let xyz    = cs.toCIEXYZ(input)
      let result = cs.fromCIEXYZ(xyz)
      #expect(abs(result[0] - 0.0) < eps)
      #expect(abs(result[1] - 0.0) < eps)
      #expect(abs(result[2] - 1.0) < eps)
    }

    @Test("fromRGB → toRGB round-trip")
    func fromRGB_toRGB_roundTrip() {
      let input: [Float] = [0.3, 0.6, 0.9]
      let result = cs.toRGB(cs.fromRGB(input))
      #expect(abs(result[0] - 0.3) < eps)
      #expect(abs(result[1] - 0.6) < eps)
      #expect(abs(result[2] - 0.9) < eps)
    }

    @Test("red primary XYZ Y-value matches Rec.709 luminance coefficient")
    func red_xyy_luminance() {
      // sRGB red primary Y in XYZ D50 ≈ 0.2225 (from ICC sRGB matrix row 1)
      let xyz = cs.toCIEXYZ([1, 0, 0])
      #expect(abs(xyz[1] - 0.2225) < 0.005)
    }

    @Test("green primary XYZ Y-value matches Rec.709 luminance coefficient")
    func green_xyy_luminance() {
      // sRGB green primary Y in XYZ D50 ≈ 0.7169
      let xyz = cs.toCIEXYZ([0, 1, 0])
      #expect(abs(xyz[1] - 0.7169) < 0.005)
    }
  }

  // ===========================================================================
  // MARK: - Linear RGB conversions
  // ===========================================================================

  @Suite("LinearRGB — conversions")
  struct LinearRGBConversionTests {

    let cs  = try! java.awt.color.ColorSpace.getInstance(java.awt.color.ColorSpace.CS_LINEAR_RGB)
    let eps: Float = 0.002

    @Test("linear white → XYZ → linear round-trip")
    func white_roundTrip() {
      let input: [Float] = [1, 1, 1]
      let xyz    = cs.toCIEXYZ(input)
      let result = cs.fromCIEXYZ(xyz)
      #expect(abs(result[0] - 1.0) < eps)
      #expect(abs(result[1] - 1.0) < eps)
      #expect(abs(result[2] - 1.0) < eps)
    }

    @Test("linear black → XYZ is zero")
    func black_toXYZ() {
      let xyz = cs.toCIEXYZ([0, 0, 0])
      #expect(abs(xyz[0]) < eps)
      #expect(abs(xyz[1]) < eps)
      #expect(abs(xyz[2]) < eps)
    }

    @Test("toRGB applies sRGB gamma to linear value")
    func toRGB_appliesGamma() {
      // linear 1.0 → sRGB 1.0, linear 0.0 → sRGB 0.0
      let white = cs.toRGB([1, 1, 1])
      #expect(abs(white[0] - 1.0) < eps)
      let black = cs.toRGB([0, 0, 0])
      #expect(abs(black[0] - 0.0) < eps)
      // linear ~0.2140 → sRGB ~0.5 (midpoint after gamma)
      let mid = cs.toRGB([0.2140, 0.2140, 0.2140])
      #expect(abs(mid[0] - 0.5) < 0.01)
    }
  }

  // ===========================================================================
  // MARK: - CIE XYZ conversions
  // ===========================================================================

  @Suite("CIEXYZ — conversions")
  struct CIEXYZConversionTests {

    let cs  = try! java.awt.color.ColorSpace.getInstance(java.awt.color.ColorSpace.CS_CIEXYZ)
    let eps: Float = 0.002

    @Test("toCIEXYZ is identity")
    func toCIEXYZ_identity() {
      let xyz: [Float] = [0.5, 0.4, 0.3]
      let result = cs.toCIEXYZ(xyz)
      #expect(abs(result[0] - 0.5) < eps)
      #expect(abs(result[1] - 0.4) < eps)
      #expect(abs(result[2] - 0.3) < eps)
    }

    @Test("fromCIEXYZ is identity")
    func fromCIEXYZ_identity() {
      let xyz: [Float] = [0.2, 0.3, 0.4]
      let result = cs.fromCIEXYZ(xyz)
      #expect(abs(result[0] - 0.2) < eps)
      #expect(abs(result[1] - 0.3) < eps)
      #expect(abs(result[2] - 0.4) < eps)
    }

    @Test("XYZ getName returns X Y Z")
    func getName_xyz() {
      #expect(cs.getName(0) == "X")
      #expect(cs.getName(1) == "Y")
      #expect(cs.getName(2) == "Z")
    }
  }

  // ===========================================================================
  // MARK: - Gray conversions
  // ===========================================================================

  @Suite("Gray — conversions")
  struct GrayConversionTests {

    let cs  = try! java.awt.color.ColorSpace.getInstance(java.awt.color.ColorSpace.CS_GRAY)
    let eps: Float = 0.002

    @Test("white gray → sRGB is [1,1,1]")
    func white_toRGB() {
      let rgb = cs.toRGB([1.0])
      #expect(abs(rgb[0] - 1.0) < eps)
      #expect(abs(rgb[1] - 1.0) < eps)
      #expect(abs(rgb[2] - 1.0) < eps)
    }

    @Test("black gray → sRGB is [0,0,0]")
    func black_toRGB() {
      let rgb = cs.toRGB([0.0])
      #expect(rgb[0] == 0.0)
      #expect(rgb[1] == 0.0)
      #expect(rgb[2] == 0.0)
    }

    @Test("sRGB mid-grey → gray luminance (Rec.709)")
    func midGrey_fromRGB() {
      // pure red: luminance = 0.2126
      let g = cs.fromRGB([1.0, 0.0, 0.0])
      #expect(abs(g[0] - 0.2126) < 0.001)
    }

    @Test("gray → XYZ D50 produces D50 white for value 1")
    func white_toXYZ() {
      let xyz = cs.toCIEXYZ([1.0])
      #expect(abs(xyz[0] - 0.9505) < 0.001)
      #expect(abs(xyz[1] - 1.0000) < 0.001)
      #expect(abs(xyz[2] - 1.0890) < 0.001)
    }

    @Test("XYZ → gray uses Y channel")
    func fromXYZ_usesY() {
      let g = cs.fromCIEXYZ([0.9505, 0.5, 1.0890])
      #expect(abs(g[0] - 0.5) < eps)
    }
  }

  // ===========================================================================
  // MARK: - ICC_Profile
  // ===========================================================================

  @Suite("ICC_Profile")
  struct ICCProfileTests {

    @Test("getInstance(CS_sRGB) returns ICC_ProfileRGB")
    func getInstance_sRGB() {
      let p = java.awt.color.ICC_Profile.getInstance(java.awt.color.ColorSpace.CS_sRGB)
      #expect(p is java.awt.color.ICC_ProfileRGB)
      #expect(p.getColorSpaceType() == java.awt.color.ColorSpace.TYPE_RGB)
      #expect(p.getNumComponents() == 3)
    }

    @Test("getInstance(CS_GRAY) returns ICC_ProfileGray")
    func getInstance_gray() {
      let p = java.awt.color.ICC_Profile.getInstance(java.awt.color.ColorSpace.CS_GRAY)
      #expect(p is java.awt.color.ICC_ProfileGray)
      #expect(p.getColorSpaceType() == java.awt.color.ColorSpace.TYPE_GRAY)
      #expect(p.getNumComponents() == 1)
    }

    @Test("ICC_ProfileRGB.getMatrix returns 3x3 with correct Y-row sum ≈ 1")
    func rgbMatrix_shape_and_values() {
      let p = java.awt.color.ICC_Profile.getInstance(java.awt.color.ColorSpace.CS_sRGB) as! java.awt.color.ICC_ProfileRGB
      let m = p.getMatrix()
      #expect(m.count == 3)
      #expect(m[0].count == 3)
      // Y-row (luminance) must sum to ≈ 1.0 (white maps to Y=1)
      let ySum = m[1][0] + m[1][1] + m[1][2]
      #expect(abs(ySum - 1.0) < 0.005)
    }

    @Test("ICC_ProfileRGB media white point is D50")
    func rgbWhitePoint_isD50() {
      let p = java.awt.color.ICC_Profile.getInstance(java.awt.color.ColorSpace.CS_sRGB) as! java.awt.color.ICC_ProfileRGB
      let wp = p.getMediaWhitePoint()
      #expect(abs(wp[0] - 0.9642) < 0.001)
      #expect(abs(wp[1] - 1.0000) < 0.001)
      #expect(abs(wp[2] - 0.8249) < 0.001)
    }

    @Test("ICC_ProfileRGB.getGamma is 2.2 for sRGB")
    func rgbGamma_sRGB() {
      let p = java.awt.color.ICC_Profile.getInstance(java.awt.color.ColorSpace.CS_sRGB) as! java.awt.color.ICC_ProfileRGB
      #expect(abs(p.getGamma(java.awt.color.ICC_ProfileRGB.REDCOMPONENT) - 2.2) < 0.001)
    }

    @Test("ICC_ProfileRGB.getGamma is 1.0 for LINEAR_RGB")
    func rgbGamma_linear() {
      let p = java.awt.color.ICC_Profile.getInstance(java.awt.color.ColorSpace.CS_LINEAR_RGB) as! java.awt.color.ICC_ProfileRGB
      #expect(abs(p.getGamma(java.awt.color.ICC_ProfileRGB.REDCOMPONENT) - 1.0) < 0.001)
    }

    @Test("ICC_ProfileGray.getGamma is 1.0")
    func grayGamma() {
      let p = java.awt.color.ICC_Profile.getInstance(java.awt.color.ColorSpace.CS_GRAY) as! java.awt.color.ICC_ProfileGray
      #expect(abs(p.getGamma() - 1.0) < 0.001)
    }

    @Test("getInstance([UInt8]) returns a valid profile (stub)")
    func fromBytes_stub() {
      let p = java.awt.color.ICC_Profile.getInstance([UInt8]())
      #expect(p.getNumComponents() > 0)
    }
  }

  // ===========================================================================
  // MARK: - ICC_ColorSpace
  // ===========================================================================

  // ===========================================================================
  // MARK: - Robustness
  // ===========================================================================

  @Suite("Robustness — short input arrays")
  struct RobustnessTests {

    @Test("sRGB toRGB with empty array returns [0,0,0]")
    func sRGB_emptyInput_toRGB() {
      let cs = try! java.awt.color.ColorSpace.getInstance(java.awt.color.ColorSpace.CS_sRGB)
      let result = cs.toRGB([])
      #expect(result == [0, 0, 0])
    }

    @Test("Gray toRGB with empty array returns [0,0,0]")
    func gray_emptyInput_toRGB() {
      let cs = try! java.awt.color.ColorSpace.getInstance(java.awt.color.ColorSpace.CS_GRAY)
      let result = cs.toRGB([])
      #expect(result == [0, 0, 0])
    }

    @Test("Gray fromRGB with empty array returns [0]")
    func gray_emptyInput_fromRGB() {
      let cs = try! java.awt.color.ColorSpace.getInstance(java.awt.color.ColorSpace.CS_GRAY)
      let result = cs.fromRGB([])
      #expect(result == [0])
    }
  }

  @Suite("ICC_ColorSpace")
  struct ICCColorSpaceTests {

    @Test("ICC_ColorSpace wraps sRGB profile correctly")
    func wraps_sRGB() {
      let profile =  java.awt.color.ICC_Profile.getInstance(java.awt.color.ColorSpace.CS_sRGB)
      let ics = try! java.awt.color.ICC_ColorSpace(profile)
      #expect(ics.getType() == java.awt.color.ColorSpace.TYPE_RGB)
      #expect(ics.getNumComponents() == 3)
      #expect(ics.isCS_sRGB() == true)
      #expect(ics.getProfile() === profile)
    }

    @Test("ICC_ColorSpace wraps gray profile correctly")
    func wraps_gray() {
      let profile =  java.awt.color.ICC_Profile.getInstance(java.awt.color.ColorSpace.CS_GRAY)
      let ics = try! java.awt.color.ICC_ColorSpace(profile)
      #expect(ics.getType() == java.awt.color.ColorSpace.TYPE_GRAY)
      #expect(ics.getNumComponents() == 1)
    }

    @Test("ICC_ColorSpace.toRGB delegates correctly")
    func toRGB_delegates() {
      let profile = java.awt.color.ICC_Profile.getInstance(java.awt.color.ColorSpace.CS_sRGB)
      let ics = try! java.awt.color.ICC_ColorSpace(profile)
      let result = ics.toRGB([0.5, 0.5, 0.5])
      #expect(abs(result[0] - 0.5) < 0.002)
    }

    @Test("ICC_ColorSpace white XYZ round-trip")
    func white_roundTrip() {
      let profile = java.awt.color.ICC_Profile.getInstance(java.awt.color.ColorSpace.CS_sRGB)
      let ics = try! java.awt.color.ICC_ColorSpace(profile)
      let xyz = ics.toCIEXYZ([1, 1, 1])
      let back = ics.fromCIEXYZ(xyz)
      #expect(abs(back[0] - 1.0) < 0.002)
      #expect(abs(back[1] - 1.0) < 0.002)
      #expect(abs(back[2] - 1.0) < 0.002)
    }
  }
}
