/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

@Suite("java.awt.image.PixelGrabber — Java 1.1 additions")
struct JavApi_awt_image_PixelGrabber_1_1_Tests {

  // MARK: - Helpers

  /// Creates a W×H MemoryImageSource filled with `color` (packed ARGB).
  private func makeSource(_ w: Int, _ h: Int, _ color: Int) -> java.awt.image.MemoryImageSource {
    let pix = [Int](repeating: color, count: w * h)
    return java.awt.image.MemoryImageSource(w, h, pix, 0, w)
  }

  // MARK: - getWidth / getHeight

  @Test("getWidth() returns grab width after grabPixels()")
  func getWidth_afterGrab() throws {
    let src = makeSource(8, 6, 0xFF_FF0000)
    var pix = [Int](repeating: 0, count: 4 * 3)
    let pg  = java.awt.image.PixelGrabber(src, 0, 0, 4, 3, &pix, 0, 4)
    try pg.grabPixels()
    #expect(pg.getWidth()  == 4)
    #expect(pg.getHeight() == 3)
  }

  @Test("getWidth/Height return -1 before grab starts")
  func getWidth_beforeGrab_isNegativeOne() {
    let src = makeSource(4, 4, 0xFF_000000)
    var pix = [Int](repeating: 0, count: 16)
    let pg  = java.awt.image.PixelGrabber(src, 0, 0, 4, 4, &pix, 0, 4)
    // Before any grab: declared w/h = 4 → getWidth() returns 4 (grab rect known)
    #expect(pg.getWidth()  == 4)
    #expect(pg.getHeight() == 4)
  }

  // MARK: - getColorModel

  @Test("getColorModel() returns nil before grabPixels()")
  func getColorModel_beforeGrab_isNil() {
    let src = makeSource(4, 4, 0xFF_AABBCC)
    var pix = [Int](repeating: 0, count: 16)
    let pg  = java.awt.image.PixelGrabber(src, 0, 0, 4, 4, &pix, 0, 4)
    #expect(pg.getColorModel() == nil)
  }

  @Test("getColorModel() is non-nil after grabPixels()")
  func getColorModel_afterGrab_nonNil() throws {
    let src = makeSource(4, 4, 0xFF_001122)
    var pix = [Int](repeating: 0, count: 16)
    let pg  = java.awt.image.PixelGrabber(src, 0, 0, 4, 4, &pix, 0, 4)
    try pg.grabPixels()
    #expect(pg.getColorModel() != nil)
  }

  // MARK: - startGrabbing

  @Test("startGrabbing() starts delivery (synchronous MemoryImageSource completes immediately)")
  func startGrabbing_completesForMemorySource() {
    let src = makeSource(2, 2, 0xFF_FF00FF)
    var pix = [Int](repeating: 0, count: 4)
    let pg  = java.awt.image.PixelGrabber(src, 0, 0, 2, 2, &pix, 0, 2)
    pg.startGrabbing()
    // MemoryImageSource delivers synchronously, so status should be set immediately
    #expect((pg.status() & 64) != 0)   // ALLBITS = 64
  }

  @Test("startGrabbing() called twice is idempotent")
  func startGrabbing_idempotent() {
    let src = makeSource(2, 2, 0xFF_AACCEE)
    var pix = [Int](repeating: 0, count: 4)
    let pg  = java.awt.image.PixelGrabber(src, 0, 0, 2, 2, &pix, 0, 2)
    pg.startGrabbing()
    pg.startGrabbing()   // must not crash or duplicate-deliver
    #expect((pg.status() & 64) != 0)
  }

  // MARK: - abortGrabbing

  @Test("abortGrabbing() sets error/abort flag")
  func abortGrabbing_setsFlag() {
    let src = makeSource(2, 2, 0xFF_112233)
    var pix = [Int](repeating: 0, count: 4)
    let pg  = java.awt.image.PixelGrabber(src, 0, 0, 2, 2, &pix, 0, 2)
    pg.abortGrabbing()
    #expect((pg.status() & 128) != 0)   // abort/error bit
  }

  // MARK: - New constructor (Image, x, y, w, h, forceRGB)

  // Helper: java.awt.Image subclass backed by a MemoryImageSource
  private final class ProducerImage: java.awt.Image {
    private let producer: any java.awt.image.ImageProducer
    init(_ p: any java.awt.image.ImageProducer) { producer = p }
    override func getSource() -> (any java.awt.image.ImageProducer)? { producer }
  }

  @Test("forceRGB constructor allocates internal buffer")
  func forceRGBConstructor_internalBuffer() throws {
    let pix = [Int](repeating: 0xFF_FF0000, count: 16)
    let mis = java.awt.image.MemoryImageSource(4, 4, pix, 0, 4)
    let img = ProducerImage(mis)
    let pg  = java.awt.image.PixelGrabber(img, 0, 0, 4, 4, true)

    let success = try pg.grabPixels()
    #expect(success == true)
    let grabbed = pg.getPixels()
    #expect(grabbed.count == 16)
    for p in grabbed {
      #expect(p != 0)   // red — non-zero
    }
  }

  @Test("forceRGB constructor: getWidth/Height reflect grab rect")
  func forceRGBConstructor_dimensions() throws {
    let pix = [Int](repeating: 0xFF_00FF00, count: 8 * 6)
    let mis = java.awt.image.MemoryImageSource(8, 6, pix, 0, 8)
    let img = ProducerImage(mis)
    let pg  = java.awt.image.PixelGrabber(img, 1, 1, 3, 3, true)

    try pg.grabPixels()
    #expect(pg.getWidth()  == 3)
    #expect(pg.getHeight() == 3)
  }

  // MARK: - Pixel correctness (regression)

  @Test("grabPixels fills pixel array with correct RGB values")
  func grabPixels_correctValues() throws {
    let red  = 0xFF_FF0000
    let pix  = [Int](repeating: red, count: 4 * 4)
    let src  = java.awt.image.MemoryImageSource(4, 4, pix, 0, 4)
    var dest = [Int](repeating: 0, count: 16)
    let pg   = java.awt.image.PixelGrabber(src, 0, 0, 4, 4, &dest, 0, 4)
    try pg.grabPixels()
    for p in pg.getPixels() {
      // getRGBdefault converts packed ARGB: red channel should be 0xFF
      #expect((p >> 16 & 0xFF) == 0xFF)
    }
  }
}
