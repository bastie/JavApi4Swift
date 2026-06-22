/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

// MARK: - Helper: collecting ImageConsumer

/// Collects all pixel data delivered by a producer pipeline into an int array.
private final class PixelCollector: java.awt.image.ImageConsumer {
  var width  = 0
  var height = 0
  var pixels : [Int] = []
  var completed = false

  func setDimensions(_ w: Int, _ h: Int) { width = w; height = h }
  func setProperties(_ props: java.util.Hashtable<AnyHashable, AnyObject>) {}
  func setColorModel(_ model: java.awt.image.ColorModel) {}
  func setHints(_ hints: Int) {}

  func setPixels(_ x: Int, _ y: Int, _ w: Int, _ h: Int,
                 _ model: java.awt.image.ColorModel,
                 _ pixels: [UInt8], _ off: Int, _ scansize: Int) {
    ensureBuffer()
    for row in 0..<h {
      for col in 0..<w {
        let idx = off + row * scansize + col
        self.pixels[(y + row) * width + (x + col)] = model.getRGB(Int(pixels[idx]))
      }
    }
  }

  func setPixels(_ x: Int, _ y: Int, _ w: Int, _ h: Int,
                 _ model: java.awt.image.ColorModel,
                 _ pixels: [Int], _ off: Int, _ scansize: Int) {
    ensureBuffer()
    for row in 0..<h {
      for col in 0..<w {
        let src = off + row * scansize + col
        self.pixels[(y + row) * width + (x + col)] =
          (model === java.awt.image.ColorModel.getRGBdefault())
            ? pixels[src]
            : model.getRGB(pixels[src])
      }
    }
  }

  func imageComplete(_ status: Int) { completed = true }

  private func ensureBuffer() {
    if pixels.isEmpty && width > 0 && height > 0 {
      pixels = [Int](repeating: 0, count: width * height)
    }
  }
}

// MARK: - IllegalComponentStateException

@Suite("java.awt.IllegalComponentStateException")
struct JavApi_awt_IllegalComponentStateException_Tests {

  @Test("Kann instantiiert werden (kein Argument)")
  func testDefaultInit() {
    let ex = java.awt.IllegalComponentStateException()
    #expect(ex.getMessage() == "")
  }

  @Test("Nachricht wird korrekt gespeichert")
  func testMessageInit() {
    let msg = "component not shown"
    let ex  = java.awt.IllegalComponentStateException(msg)
    #expect(ex.getMessage() == msg)
  }

  @Test("Ist Unterklasse von IllegalStateException")
  func testInheritance() {
    let ex: IllegalStateException = java.awt.IllegalComponentStateException("x")
    // Downcast must succeed — confirms runtime type is the subclass
    #expect((ex as? java.awt.IllegalComponentStateException) != nil)
  }
}

// MARK: - PaintEvent

@Suite("java.awt.event.PaintEvent")
@MainActor
struct JavApi_awt_PaintEvent_Tests {

  @Test("Konstanten haben korrekte Werte")
  func testConstants() {
    #expect(java.awt.event.PaintEvent.PAINT_FIRST == 800)
    #expect(java.awt.event.PaintEvent.PAINT_LAST  == 801)
    #expect(java.awt.event.PaintEvent.PAINT       == 800)
    #expect(java.awt.event.PaintEvent.UPDATE      == 801)
  }

  @Test("getUpdateRect gibt korrektes Rectangle zurück")
  func testGetUpdateRect() {
    let panel = java.awt.Panel()
    let rect  = java.awt.Rectangle(10, 20, 100, 80)
    let ev    = java.awt.event.PaintEvent(panel, java.awt.event.PaintEvent.PAINT, rect)
    let r     = ev.getUpdateRect()
    #expect(r.x == 10)
    #expect(r.y == 20)
    #expect(r.width == 100)
    #expect(r.height == 80)
  }

  @Test("setUpdateRect ersetzt das Rectangle")
  func testSetUpdateRect() {
    let panel = java.awt.Panel()
    let ev    = java.awt.event.PaintEvent(panel, java.awt.event.PaintEvent.UPDATE,
                                          java.awt.Rectangle(0, 0, 50, 50))
    ev.setUpdateRect(java.awt.Rectangle(5, 5, 10, 10))
    let r = ev.getUpdateRect()
    #expect(r.x == 5 && r.y == 5 && r.width == 10 && r.height == 10)
  }

  @Test("getID gibt übergebene ID zurück")
  func testGetID() {
    let panel = java.awt.Panel()
    let ev    = java.awt.event.PaintEvent(panel, java.awt.event.PaintEvent.UPDATE,
                                          java.awt.Rectangle(0, 0, 1, 1))
    #expect(ev.getID() == java.awt.event.PaintEvent.UPDATE)
  }

  @Test("paramString enthält Eventname und Rectangle")
  func testParamString() {
    let panel = java.awt.Panel()
    let ev    = java.awt.event.PaintEvent(panel, java.awt.event.PaintEvent.PAINT,
                                          java.awt.Rectangle(1, 2, 3, 4))
    let s = ev.paramString()
    #expect(s.contains("PAINT"))
    #expect(s.contains("updateRect"))
  }
}

// MARK: - ReplicateScaleFilter

@Suite("java.awt.image.ReplicateScaleFilter")
struct JavApi_awt_ReplicateScaleFilter_Tests {

  /// Builds a w×h image of solid `color` (packed ARGB), runs it through
  /// `filter`, and returns the collected pixels.
  private func applyFilter(srcW: Int, srcH: Int, color: Int,
                            filter: java.awt.image.ImageFilter) -> PixelCollector {
    let pixels   = [Int](repeating: color, count: srcW * srcH)
    let rgbModel = java.awt.image.ColorModel.getRGBdefault()
    let src      = java.awt.image.MemoryImageSource(srcW, srcH, rgbModel, pixels, 0, srcW)
    let filtered = java.awt.image.FilteredImageSource(src, filter)
    let sink     = PixelCollector()
    filtered.startProduction(sink)
    return sink
  }

  @Test("Skalierung 4×4 → 2×2: Ausgabegröße korrekt")
  func testOutputSize() {
    let sink = applyFilter(srcW: 4, srcH: 4, color: 0xFF_FF0000,
                           filter: java.awt.image.ReplicateScaleFilter(2, 2))
    #expect(sink.width  == 2)
    #expect(sink.height == 2)
    #expect(sink.pixels.count == 4)
  }

  @Test("Skalierung 2×2 → 4×4 (upscale): Ausgabegröße korrekt")
  func testUpscaleSize() {
    let sink = applyFilter(srcW: 2, srcH: 2, color: 0xFF_00FF00,
                           filter: java.awt.image.ReplicateScaleFilter(4, 4))
    #expect(sink.width  == 4)
    #expect(sink.height == 4)
  }

  @Test("Einfarbiges Bild bleibt nach Skalierung einfarbig")
  func testSolidColorPreserved() {
    let color = Int(Int32(bitPattern: 0xFF_AABB_CC))
    let sink  = applyFilter(srcW: 6, srcH: 6, color: color,
                            filter: java.awt.image.ReplicateScaleFilter(3, 3))
    #expect(sink.pixels.allSatisfy { $0 == color })
  }

  @Test("Aspektverhältnis: Breite=-1 wird aus Höhe abgeleitet")
  func testAspectRatioWidth() {
    // 4×2 Quellbild, Ziel: Höhe=1, Breite=-1 → Breite muss 2 werden
    let sink = applyFilter(srcW: 4, srcH: 2, color: 0xFF_000000,
                           filter: java.awt.image.ReplicateScaleFilter(-1, 1))
    #expect(sink.height == 1)
    #expect(sink.width  == 2)
  }
}

// MARK: - AreaAveragingScaleFilter

@Suite("java.awt.image.AreaAveragingScaleFilter")
struct JavApi_awt_AreaAveragingScaleFilter_Tests {

  private func applyFilter(srcW: Int, srcH: Int, color: Int,
                            filter: java.awt.image.ImageFilter) -> PixelCollector {
    let pixels   = [Int](repeating: color, count: srcW * srcH)
    let rgbModel = java.awt.image.ColorModel.getRGBdefault()
    let src      = java.awt.image.MemoryImageSource(srcW, srcH, rgbModel, pixels, 0, srcW)
    let filtered = java.awt.image.FilteredImageSource(src, filter)
    let sink     = PixelCollector()
    filtered.startProduction(sink)
    return sink
  }

  @Test("Downscale 4×4 → 2×2: Ausgabegröße korrekt")
  func testOutputSize() {
    let sink = applyFilter(srcW: 4, srcH: 4, color: 0xFF_FF0000,
                           filter: java.awt.image.AreaAveragingScaleFilter(2, 2))
    #expect(sink.width  == 2)
    #expect(sink.height == 2)
    #expect(sink.pixels.count == 4)
  }

  @Test("Einfarbiges Bild bleibt nach Downscale einfarbig")
  func testSolidColorPreservedDownscale() {
    // Use a positive Swift Int (no sign extension) so ARGB component arithmetic stays correct
    let color = 0x7F_112233
    let sink  = applyFilter(srcW: 8, srcH: 8, color: color,
                            filter: java.awt.image.AreaAveragingScaleFilter(2, 2))
    // Averaging identical pixels must produce the same color
    #expect(sink.pixels.allSatisfy { $0 == color })
  }

  @Test("Upscale 2×2 → 4×4: Ausgabegröße korrekt")
  func testUpscaleSize() {
    let sink = applyFilter(srcW: 2, srcH: 2, color: 0xFF_00FF00,
                           filter: java.awt.image.AreaAveragingScaleFilter(4, 4))
    #expect(sink.width  == 4)
    #expect(sink.height == 4)
  }

  @Test("Einfarbiges Bild bleibt nach Upscale einfarbig")
  func testSolidColorPreservedUpscale() {
    let color = 0x7F_FFCC00
    let sink  = applyFilter(srcW: 2, srcH: 2, color: color,
                            filter: java.awt.image.AreaAveragingScaleFilter(4, 4))
    #expect(sink.pixels.allSatisfy { $0 == color })
  }

  @Test("imageComplete wird aufgerufen")
  func testCompleted() {
    let sink = applyFilter(srcW: 4, srcH: 4, color: 0xFF_000000,
                           filter: java.awt.image.AreaAveragingScaleFilter(2, 2))
    #expect(sink.completed)
  }
}
