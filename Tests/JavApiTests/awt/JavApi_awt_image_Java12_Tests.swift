/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Testing
@testable import JavApi

// =============================================================================
// MARK: - DataBuffer subclasses
// =============================================================================

@Suite("java.awt.image — DataBufferShort / DataBufferUShort")
struct JavApi_awt_image_DataBuffer_Tests {

  @Test("DataBufferShort initialises to zero")
  func dataBufferShort_zeroInit() {
    let db = java.awt.image.DataBufferShort(size: 4)
    #expect(db.getElem(0) == 0)
    #expect(db.size == 4)
    #expect(db.dataType == java.awt.image.DataBuffer.TYPE_SHORT)
  }

  @Test("DataBufferShort get/set round-trip")
  func dataBufferShort_getSet() {
    let db = java.awt.image.DataBufferShort(size: 4)
    db.setElem(2, 1234)
    #expect(db.getElem(2) == 1234)
  }

  @Test("DataBufferShort multi-bank")
  func dataBufferShort_multiBank() {
    let db = java.awt.image.DataBufferShort(dataArrays: [[0, 1], [2, 3]], size: 2)
    #expect(db.numBanks == 2)
    #expect(db.getElem(0, 1) == 1)
    #expect(db.getElem(1, 0) == 2)
  }

  @Test("DataBufferUShort initialises to zero")
  func dataBufferUShort_zeroInit() {
    let db = java.awt.image.DataBufferUShort(size: 4)
    #expect(db.getElem(0) == 0)
    #expect(db.dataType == java.awt.image.DataBuffer.TYPE_USHORT)
  }

  @Test("DataBufferUShort get/set round-trip")
  func dataBufferUShort_getSet() {
    let db = java.awt.image.DataBufferUShort(size: 4)
    db.setElem(1, 65535)
    #expect(db.getElem(1) == 65535)
  }

  @Test("DataBufferByte multi-bank constructor")
  func dataBufferByte_multiBank() {
    let db = java.awt.image.DataBufferByte(
      dataArrays: [[10, 20], [30, 40]], size: 2)
    #expect(db.numBanks == 2)
    #expect(db.getElem(0, 0) == 10)
    #expect(db.getElem(1, 1) == 40)
  }
}

// =============================================================================
// MARK: - SampleModel subclasses
// =============================================================================

@Suite("java.awt.image — ComponentSampleModel / BandedSampleModel")
struct JavApi_awt_image_SampleModel_Tests {

  @Test("PixelInterleavedSampleModel get/set RGB")
  func pixelInterleaved_getSet() {
    // 3-band interleaved (R,G,B), 1×1
    let sm = java.awt.image.PixelInterleavedSampleModel(
      dataType: java.awt.image.DataBuffer.TYPE_BYTE,
      width: 1, height: 1,
      pixelStride: 3, scanlineStride: 3,
      bandOffsets: [0, 1, 2])
    let db = java.awt.image.DataBufferByte(size: 3)
    sm.setSample(0, 0, 0, 0xAA, db)  // R
    sm.setSample(0, 0, 1, 0xBB, db)  // G
    sm.setSample(0, 0, 2, 0xCC, db)  // B
    #expect(sm.getSample(0, 0, 0, db) == 0xAA)
    #expect(sm.getSample(0, 0, 1, db) == 0xBB)
    #expect(sm.getSample(0, 0, 2, db) == 0xCC)
  }

  @Test("BandedSampleModel separates bands into different banks")
  func banded_separateBanks() {
    let sm = java.awt.image.BandedSampleModel(
      dataType: java.awt.image.DataBuffer.TYPE_BYTE,
      width: 2, height: 1, numBands: 3)
    #expect(sm.numBands == 3)
    let db = sm.createDataBuffer()
    #expect(db.numBanks == 3)
    sm.setSample(0, 0, 0, 10, db)
    sm.setSample(0, 0, 1, 20, db)
    sm.setSample(0, 0, 2, 30, db)
    #expect(sm.getSample(0, 0, 0, db) == 10)
    #expect(sm.getSample(0, 0, 1, db) == 20)
    #expect(sm.getSample(0, 0, 2, db) == 30)
  }

  @Test("MultiPixelPackedSampleModel packs 4-bit pixels")
  func multiPixelPacked_4bit() {
    let sm = java.awt.image.MultiPixelPackedSampleModel(
      dataType: java.awt.image.DataBuffer.TYPE_BYTE,
      width: 4, height: 1,
      numberOfBits: 4)
    let db = sm.createDataBuffer()
    sm.setSample(0, 0, 0, 0xF, db)
    sm.setSample(1, 0, 0, 0xA, db)
    #expect(sm.getSample(0, 0, 0, db) == 0xF)
    #expect(sm.getSample(1, 0, 0, db) == 0xA)
  }
}

// =============================================================================
// MARK: - LookupTable
// =============================================================================

@Suite("java.awt.image — LookupTable")
struct JavApi_awt_image_LookupTable_Tests {

  @Test("ByteLookupTable single-component identity")
  func byteLookup_identity() {
    let table = [UInt8](0 ... 255)
    let lut = java.awt.image.ByteLookupTable(offset: 0, data: table)
    let dst = lut.lookupPixel([42, 100, 200], nil)
    #expect(dst[0] == 42)
    #expect(dst[1] == 100)
    #expect(dst[2] == 200)
  }

  @Test("ByteLookupTable offset shifts lookup")
  func byteLookup_offset() {
    var table = [UInt8](repeating: 0, count: 200)
    table[0] = 99   // index 0 in table → value 99
    let lut = java.awt.image.ByteLookupTable(offset: 50, data: table)
    let dst = lut.lookupPixel([50], nil)  // input 50, offset 50 → index 0 → 99
    #expect(dst[0] == 99)
  }

  @Test("ShortLookupTable single-component")
  func shortLookup_single() {
    let table = [UInt16](0 ..< 256)
    let lut = java.awt.image.ShortLookupTable(offset: 0, data: table)
    let dst = lut.lookupPixel([128], nil)
    #expect(dst[0] == 128)
  }
}

// =============================================================================
// MARK: - RescaleOp
// =============================================================================

@Suite("java.awt.image — RescaleOp")
struct JavApi_awt_image_RescaleOp_Tests {

  @Test("RescaleOp single factor brightens image")
  func rescale_singleFactor() throws {
    let op = java.awt.image.RescaleOp(2.0 as Float, 0 as Float, nil)
    let src = java.awt.image.BufferedImage(1, 1, java.awt.image.BufferedImage.TYPE_INT_ARGB)
    src.setRGB(0, 0, Int(bitPattern: 0xFF_40_40_40))
    let dst = try op.filter(src, nil as java.awt.image.BufferedImage?)
    let result = dst.getRGB(0, 0)
    let r = (result >> 16) & 0xFF
    #expect(r == 0x80)  // 0x40 * 2 = 0x80
  }

  @Test("RescaleOp clamps to 255")
  func rescale_clamp() throws {
    let op = java.awt.image.RescaleOp(4.0 as Float, 0 as Float, nil)
    let src = java.awt.image.BufferedImage(1, 1, java.awt.image.BufferedImage.TYPE_INT_ARGB)
    src.setRGB(0, 0, Int(bitPattern: 0xFF_FF_FF_FF))
    let dst = try op.filter(src, nil as java.awt.image.BufferedImage?)
    let r = (dst.getRGB(0, 0) >> 16) & 0xFF
    #expect(r == 255)
  }
}

// =============================================================================
// MARK: - LookupOp
// =============================================================================

@Suite("java.awt.image — LookupOp")
struct JavApi_awt_image_LookupOp_Tests {

  @Test("LookupOp inverts image")
  func lookupOp_invert() throws {
    let table = [UInt8](0 ... 255).map { 255 &- $0 }
    let lut = java.awt.image.ByteLookupTable(offset: 0, data: table)
    let op = java.awt.image.LookupOp(lut, nil)

    let src = java.awt.image.BufferedImage(1, 1, java.awt.image.BufferedImage.TYPE_INT_ARGB)
    src.setRGB(0, 0, Int(bitPattern: 0xFF_40_80_C0))
    let dst = try op.filter(src, nil as java.awt.image.BufferedImage?)
    let result = dst.getRGB(0, 0)
    #expect((result >> 16) & 0xFF == 0xBF)  // 255 - 0x40
    #expect((result >>  8) & 0xFF == 0x7F)  // 255 - 0x80
    #expect( result        & 0xFF == 0x3F)  // 255 - 0xC0
  }
}

// =============================================================================
// MARK: - ConvolveOp / Kernel
// =============================================================================

@Suite("java.awt.image — Kernel / ConvolveOp")
struct JavApi_awt_image_ConvolveOp_Tests {

  @Test("Kernel stores dimensions and origin")
  func kernel_properties() {
    let k = java.awt.image.Kernel(3, 3, [Float](repeating: 1.0/9.0, count: 9))
    #expect(k.getWidth()   == 3)
    #expect(k.getHeight()  == 3)
    #expect(k.getXOrigin() == 1)
    #expect(k.getYOrigin() == 1)
  }

  @Test("ConvolveOp identity kernel leaves pixel unchanged")
  func convolve_identityKernel() throws {
    // 3×3 identity kernel
    var data = [Float](repeating: 0, count: 9)
    data[4] = 1.0   // centre = 1
    let k  = java.awt.image.Kernel(3, 3, data)
    let op = java.awt.image.ConvolveOp(k, java.awt.image.ConvolveOp.EDGE_ZERO_FILL, nil)

    let src = java.awt.image.BufferedImage(3, 3, java.awt.image.BufferedImage.TYPE_INT_ARGB)
    src.setRGB(1, 1, Int(bitPattern: 0xFF_11_22_33))
    let dst = try op.filter(src, nil)
    let r = (dst.getRGB(1, 1) >> 16) & 0xFF
    #expect(r == 0x11)
  }
}

// =============================================================================
// MARK: - AffineTransformOp
// =============================================================================

@Suite("java.awt.image — AffineTransformOp")
struct JavApi_awt_image_AffineTransformOp_Tests {

  @Test("AffineTransformOp identity leaves image unchanged")
  func affine_identity() throws {
    let identity = java.awt.geom.AffineTransform()
    let op = java.awt.image.AffineTransformOp(
      identity, java.awt.image.AffineTransformOp.TYPE_NEAREST_NEIGHBOR)
    let src = java.awt.image.BufferedImage(2, 2, java.awt.image.BufferedImage.TYPE_INT_ARGB)
    src.setRGB(0, 0, Int(bitPattern: 0xFF_AA_BB_CC))
    let dst = try op.filter(src, nil)
    let r = (dst.getRGB(0, 0) >> 16) & 0xFF
    #expect(r == 0xAA)
  }
}

// =============================================================================
// MARK: - ColorConvertOp
// =============================================================================

@Suite("java.awt.image — ColorConvertOp")
struct JavApi_awt_image_ColorConvertOp_Tests {

  @Test("ColorConvertOp converts RGB to gray")
  func colorConvert_toGray() throws {
    let op = java.awt.image.ColorConvertOp(
      dstType: java.awt.image.BufferedImage.TYPE_BYTE_GRAY)
    let src = java.awt.image.BufferedImage(1, 1, java.awt.image.BufferedImage.TYPE_INT_RGB)
    // pure red: R=255, G=0, B=0 → gray ≈ 76 (BT.601)
    src.setRGB(0, 0, Int(bitPattern: 0xFF_FF_00_00))
    let dst = try op.filter(src, nil)
    let gray = (dst.getRGB(0, 0) >> 16) & 0xFF
    // BT.601: 0.299*255 ≈ 76
    #expect(gray >= 74 && gray <= 78)
  }
}

// =============================================================================
// MARK: - RenderedImage / WritableRenderedImage conformance on BufferedImage
// =============================================================================

@Suite("java.awt.image — RenderedImage / WritableRenderedImage")
struct JavApi_awt_image_RenderedImage_Tests {

  @Test("BufferedImage conforms to WritableRenderedImage")
  func bufferedImage_conformsToWritableRenderedImage() {
    let img: any java.awt.image.WritableRenderedImage =
      java.awt.image.BufferedImage(4, 4, java.awt.image.BufferedImage.TYPE_INT_ARGB)
    #expect(img.getWidth()  == 4)
    #expect(img.getHeight() == 4)
    #expect(img.getMinX()   == 0)
    #expect(img.getMinY()   == 0)
    #expect(img.getNumXTiles() == 1)
    #expect(img.getNumYTiles() == 1)
  }

  @Test("BufferedImage tile checkout fires observer")
  func bufferedImage_tileObserver() {
    final class MockObserver: java.awt.image.TileObserver {
      var callCount = 0
      var lastWillBeWritable = false
      func tileUpdate(_ source: any java.awt.image.WritableRenderedImage,
                      _ tileX: Int, _ tileY: Int, _ willBeWritable: Bool) {
        callCount += 1
        lastWillBeWritable = willBeWritable
      }
    }
    let img = java.awt.image.BufferedImage(2, 2, java.awt.image.BufferedImage.TYPE_INT_ARGB)
    let obs = MockObserver()
    img.addTileObserver(obs)

    _ = img.getWritableTile(0, 0)
    #expect(obs.callCount == 1)
    #expect(obs.lastWillBeWritable == true)

    img.releaseWritableTile(0, 0)
    #expect(obs.callCount == 2)
    #expect(obs.lastWillBeWritable == false)
  }

  @Test("BufferedImage hasTileWriters tracks checkout count")
  func bufferedImage_hasTileWriters() {
    let img = java.awt.image.BufferedImage(2, 2, java.awt.image.BufferedImage.TYPE_INT_ARGB)
    #expect(img.hasTileWriters() == false)
    _ = img.getWritableTile(0, 0)
    #expect(img.hasTileWriters() == true)
    _ = img.getWritableTile(0, 0)
    img.releaseWritableTile(0, 0)
    #expect(img.hasTileWriters() == true)  // still one checkout left
    img.releaseWritableTile(0, 0)
    #expect(img.hasTileWriters() == false)
  }

  @Test("WritableRenderedImage copyData round-trips pixels")
  func writableRenderedImage_copyData() {
    let img = java.awt.image.BufferedImage(2, 2, java.awt.image.BufferedImage.TYPE_INT_ARGB)
    img.setRGB(0, 0, Int(bitPattern: 0xFF_AA_BB_CC))
    let raster = img.copyData(nil)
    // pixel (0,0): alpha band = 0xFF
    #expect(raster.getSample(0, 0, 0) == 0xFF)
  }
}

// =============================================================================
// MARK: - BufferedImageFilter
// =============================================================================

@Suite("java.awt.image — BufferedImageFilter")
struct JavApi_awt_image_BufferedImageFilter_Tests {

  @Test("BufferedImageFilter wraps a BufferedImageOp")
  func bufferedImageFilter_wrapsOp() {
    let op = java.awt.image.RescaleOp(1.0 as Float, 0 as Float, nil)
    let filter = java.awt.image.BufferedImageFilter(op)
    // getBufferedImageOp should return the same op (type-erased, so just check non-nil)
    let retrieved = filter.getBufferedImageOp()
    // It's a protocol existential — verify it's functional by running a filter round-trip
    let src = java.awt.image.BufferedImage(2, 2, java.awt.image.BufferedImage.TYPE_INT_ARGB)
    src.setRGB(0, 0, Int(bitPattern: 0xFF_10_20_30))
    let dst = try? retrieved.filter(src, nil as java.awt.image.BufferedImage?)
    #expect(dst != nil)
    let r = ((dst?.getRGB(0, 0) ?? 0) >> 16) & 0xFF
    #expect(r == 0x10)
  }
}
