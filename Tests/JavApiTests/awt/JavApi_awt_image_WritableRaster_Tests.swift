/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Testing
@testable import JavApi

@Suite("java.awt.image — DataBuffer / Raster / WritableRaster")
struct JavApi_awt_image_WritableRaster_Tests {

  // MARK: - DataBufferInt

  @Test("DataBufferInt initialises to zero")
  func dataBufferInt_zeroInit() {
    let db = java.awt.image.DataBufferInt(size: 4)
    #expect(db.getElem(0) == 0)
    #expect(db.getElem(3) == 0)
    #expect(db.size == 4)
    #expect(db.dataType == java.awt.image.DataBuffer.TYPE_INT)
  }

  @Test("DataBufferInt get/set round-trip")
  func dataBufferInt_getSet() {
    let db = java.awt.image.DataBufferInt(size: 4)
    // DataBufferInt uses Int32 internally (Java's int is 32-bit signed).
    // Values with the high bit set must be stored as sign-extended Int.
    let argb = Int(Int32(bitPattern: 0xFF_AA_BB_CC))  // → -5588020 in two's complement
    db.setElem(2, argb)
    #expect(db.getElem(2) == argb)
  }

  @Test("DataBufferInt wraps existing array")
  func dataBufferInt_wrapsArray() {
    let arr: [Int32] = [1, 2, 3, 4]
    let db = java.awt.image.DataBufferInt(dataArray: arr, size: 4)
    #expect(db.getElem(0) == 1)
    #expect(db.getElem(3) == 4)
  }

  // MARK: - DataBufferByte

  @Test("DataBufferByte get/set round-trip")
  func dataBufferByte_getSet() {
    let db = java.awt.image.DataBufferByte(size: 8)
    db.setElem(0, 255)
    db.setElem(1, 128)
    #expect(db.getElem(0) == 255)
    #expect(db.getElem(1) == 128)
  }

  // MARK: - SinglePixelPackedSampleModel

  @Test("SinglePixelPackedSampleModel extracts ARGB bands")
  func spsm_extractsARGBBands() {
    let bandMasks: [Int] = [
      Int(bitPattern: 0xFF000000), // alpha
      0x00FF0000,                  // red
      0x0000FF00,                  // green
      0x000000FF,                  // blue
    ]
    let sm = java.awt.image.SinglePixelPackedSampleModel(
      dataType: java.awt.image.DataBuffer.TYPE_INT,
      width: 2, height: 2, bitMasks: bandMasks)
    let db = java.awt.image.DataBufferInt(size: 4)
    // pixel (0,0) = 0xFF_11_22_33
    db.setElem(0, 0xFF_11_22_33)

    #expect(sm.getSample(0, 0, 0, db) == 0xFF)  // alpha
    #expect(sm.getSample(0, 0, 1, db) == 0x11)  // red
    #expect(sm.getSample(0, 0, 2, db) == 0x22)  // green
    #expect(sm.getSample(0, 0, 3, db) == 0x33)  // blue
  }

  @Test("SinglePixelPackedSampleModel setSample modifies only target band")
  func spsm_setSample_isolatesBand() {
    let bandMasks: [Int] = [0xFF0000, 0x00FF00, 0x0000FF]
    let sm = java.awt.image.SinglePixelPackedSampleModel(
      dataType: java.awt.image.DataBuffer.TYPE_INT,
      width: 1, height: 1, bitMasks: bandMasks)
    let db = java.awt.image.DataBufferInt(size: 1)
    db.setElem(0, 0x00_AA_BB_CC)

    sm.setSample(0, 0, 0, 0xFF, db)   // set red band to 0xFF
    #expect(sm.getSample(0, 0, 0, db) == 0xFF)
    #expect(sm.getSample(0, 0, 1, db) == 0xBB)  // green unchanged
    #expect(sm.getSample(0, 0, 2, db) == 0xCC)  // blue unchanged
  }

  // MARK: - WritableRaster

  @Test("WritableRaster setSample / getSample round-trip")
  func writableRaster_setSample() {
    let raster = java.awt.image.Raster.createPackedRaster(
      dataType: java.awt.image.DataBuffer.TYPE_INT,
      width: 4, height: 4,
      bandMasks: [0xFF0000, 0x00FF00, 0x0000FF])

    raster.setSample(1, 2, 0, 0xAB)  // red at (1,2)
    #expect(raster.getSample(1, 2, 0) == 0xAB)
    #expect(raster.getSample(1, 2, 1) == 0)     // green untouched
  }

  @Test("WritableRaster setPixel / getPixel round-trip")
  func writableRaster_setPixel() {
    let raster = java.awt.image.Raster.createPackedRaster(
      dataType: java.awt.image.DataBuffer.TYPE_INT,
      width: 2, height: 2,
      bandMasks: [0xFF0000, 0x00FF00, 0x0000FF])

    raster.setPixel(0, 0, [0x11, 0x22, 0x33])
    let result = raster.getPixel(0, 0, nil)
    #expect(result[0] == 0x11)
    #expect(result[1] == 0x22)
    #expect(result[2] == 0x33)
  }

  @Test("WritableRaster setRect copies from source raster")
  func writableRaster_setRect() {
    let src = java.awt.image.Raster.createPackedRaster(
      dataType: java.awt.image.DataBuffer.TYPE_INT,
      width: 2, height: 2,
      bandMasks: [0xFF0000, 0x00FF00, 0x0000FF])
    src.setPixel(0, 0, [0xAA, 0xBB, 0xCC])

    let dst = java.awt.image.Raster.createPackedRaster(
      dataType: java.awt.image.DataBuffer.TYPE_INT,
      width: 2, height: 2,
      bandMasks: [0xFF0000, 0x00FF00, 0x0000FF])
    dst.setRect(src)

    let result = dst.getPixel(0, 0, nil)
    #expect(result[0] == 0xAA)
    #expect(result[1] == 0xBB)
    #expect(result[2] == 0xCC)
  }

  // MARK: - BufferedImage.getRaster()

  @Test("BufferedImage.getRaster reflects pixel data")
  func bufferedImage_getRaster() {
    let img = java.awt.image.BufferedImage(4, 4, java.awt.image.BufferedImage.TYPE_INT_ARGB)
    img.setRGB(1, 1, Int(bitPattern: 0xFF_AA_BB_CC))

    let raster = img.getRaster()
    // alpha band (mask 0xFF000000 → offset 24)
    let alpha = raster.getSample(1, 1, 0)
    #expect(alpha == 0xFF)
    // red band (mask 0x00FF0000 → offset 16)
    let red = raster.getSample(1, 1, 1)
    #expect(red == 0xAA)
  }

  @Test("BufferedImage.getColorModel returns DirectColorModel")
  func bufferedImage_getColorModel() {
    let img = java.awt.image.BufferedImage(2, 2, java.awt.image.BufferedImage.TYPE_INT_ARGB)
    let cm = img.getColorModel()
    #expect(cm is java.awt.image.DirectColorModel)
  }
}
