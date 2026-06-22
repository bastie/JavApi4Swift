/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

// MARK: - Helper: frame-collecting ImageConsumer

/// Records every `imageComplete` call and the pixels received per frame.
private final class FrameCollector: java.awt.image.ImageConsumer {
  var frames: [[Int]] = []
  var currentFrame: [Int] = []
  var completions: [Int] = []   // status codes received
  var width  = 0
  var height = 0

  func setDimensions(_ w: Int, _ h: Int) { width = w; height = h }
  func setProperties(_ props: java.util.Hashtable<AnyHashable, AnyObject>) {}
  func setColorModel(_ model: java.awt.image.ColorModel) {}
  func setHints(_ hints: Int) {}

  func setPixels(_ x: Int, _ y: Int, _ w: Int, _ h: Int,
                 _ model: java.awt.image.ColorModel,
                 _ pixels: [UInt8], _ off: Int, _ scansize: Int) {
    if currentFrame.isEmpty { currentFrame = [Int](repeating: 0, count: width * height) }
    for row in 0..<h {
      for col in 0..<w {
        currentFrame[(y + row) * width + (x + col)] = model.getRGB(Int(pixels[off + row * scansize + col]))
      }
    }
  }

  func setPixels(_ x: Int, _ y: Int, _ w: Int, _ h: Int,
                 _ model: java.awt.image.ColorModel,
                 _ pixels: [Int], _ off: Int, _ scansize: Int) {
    if currentFrame.isEmpty { currentFrame = [Int](repeating: 0, count: width * height) }
    for row in 0..<h {
      for col in 0..<w {
        let src = off + row * scansize + col
        currentFrame[(y + row) * width + (x + col)] = model.getRGB(pixels[src])
      }
    }
  }

  func imageComplete(_ status: Int) {
    completions.append(status)
    frames.append(currentFrame)
    currentFrame = []
  }
}

// MARK: - Tests

@Suite("java.awt.image.MemoryImageSource — Java 1.1 Animation API")
struct JavApi_awt_image_MemoryImageSource_1_1_Tests {

  private let W = 4
  private let H = 4

  private func makePixels(_ value: Int) -> [Int] {
    [Int](repeating: value, count: W * H)
  }

  // MARK: - setAnimated / static mode (no regression)

  @Test("Static mode (animated=false): consumer receives STATICIMAGEDONE and is removed")
  func staticMode_consumerRemovedAfterDelivery() {
    let pix = makePixels(0xFF_FF0000)   // red
    let src = java.awt.image.MemoryImageSource(W, H, pix, 0, W)
    let col = FrameCollector()

    src.addConsumer(col)

    // In static mode, imageComplete(STATICIMAGEDONE=3) must have been sent
    #expect(col.completions == [3])
    // Consumer must be removed after delivery
    #expect(src.isConsumer(col) == false)
  }

  // MARK: - setAnimated(true)

  @Test("setAnimated(true): addConsumer keeps consumer registered")
  func animated_addConsumerKeepsConsumer() {
    let pix = makePixels(0xFF_00FF00)   // green
    let src = java.awt.image.MemoryImageSource(W, H, pix, 0, W)
    src.setAnimated(true)
    let col = FrameCollector()

    src.addConsumer(col)

    // Initial frame uses SINGLEFRAMEDONE=2
    #expect(col.completions == [2])
    // Consumer stays registered
    #expect(src.isConsumer(col) == true)
  }

  @Test("setAnimated(true): newPixels() pushes a second frame")
  func animated_newPixels_pushesSecondFrame() {
    var pix = makePixels(0xFF_0000FF)   // blue frame 1
    let src = java.awt.image.MemoryImageSource(W, H, pix, 0, W)
    src.setAnimated(true)
    let col = FrameCollector()

    src.addConsumer(col)
    #expect(col.frames.count == 1)

    pix = makePixels(0xFF_FF0000)       // red frame 2 (replace via newPixels)
    src.newPixels(pix, java.awt.image.ColorModel.getRGBdefault(), 0, W)
    #expect(col.frames.count == 2)
    #expect(col.completions == [2, 2])
  }

  @Test("newPixels() without setAnimated is a no-op")
  func newPixels_withoutAnimated_isNoOp() {
    let pix = makePixels(0xFF_FF00FF)
    let src = java.awt.image.MemoryImageSource(W, H, pix, 0, W)
    let col = FrameCollector()

    src.addConsumer(col)
    let framesAfterAdd = col.frames.count

    // Not animated — newPixels() should do nothing
    src.newPixels()
    #expect(col.frames.count == framesAfterAdd)
  }

  // MARK: - setAnimated(false) removes consumers

  @Test("setAnimated(false) removes all registered consumers")
  func setAnimated_false_removesConsumers() {
    let pix = makePixels(0xFF_AABBCC)
    let src = java.awt.image.MemoryImageSource(W, H, pix, 0, W)
    src.setAnimated(true)
    let col = FrameCollector()

    src.addConsumer(col)
    #expect(src.isConsumer(col) == true)

    src.setAnimated(false)
    #expect(src.isConsumer(col) == false)
  }

  // MARK: - newPixels partial region

  @Test("newPixels(x,y,w,h) delivers only the specified region")
  func newPixels_partialRegion_deliveredCorrectly() {
    // 4×4 image, all zeros initially
    let pix = [Int](repeating: 0, count: W * H)
    let src = java.awt.image.MemoryImageSource(W, H, pix, 0, W)
    src.setAnimated(true)

    var receivedRect: (x: Int, y: Int, w: Int, h: Int)? = nil

    final class RectConsumer: java.awt.image.ImageConsumer {
      var lastX = -1, lastY = -1, lastW = -1, lastH = -1
      func setDimensions(_ w: Int, _ h: Int) {}
      func setProperties(_ props: java.util.Hashtable<AnyHashable, AnyObject>) {}
      func setColorModel(_ model: java.awt.image.ColorModel) {}
      func setHints(_ hints: Int) {}
      func setPixels(_ x: Int, _ y: Int, _ w: Int, _ h: Int,
                     _ model: java.awt.image.ColorModel,
                     _ pixels: [UInt8], _ off: Int, _ scansize: Int) {
        lastX = x; lastY = y; lastW = w; lastH = h
      }
      func setPixels(_ x: Int, _ y: Int, _ w: Int, _ h: Int,
                     _ model: java.awt.image.ColorModel,
                     _ pixels: [Int], _ off: Int, _ scansize: Int) {
        lastX = x; lastY = y; lastW = w; lastH = h
      }
      func imageComplete(_ status: Int) {}
    }

    let rc = RectConsumer()
    src.addConsumer(rc)

    // Push only top-left 2×2
    src.newPixels(0, 0, 2, 2, false)
    #expect(rc.lastX == 0)
    #expect(rc.lastY == 0)
    #expect(rc.lastW == 2)
    #expect(rc.lastH == 2)
    _ = receivedRect  // suppress warning
  }

  // MARK: - setFullBufferUpdates

  @Test("setFullBufferUpdates(true): partial newPixels sends full buffer")
  func setFullBufferUpdates_forcesFullBuffer() {
    let pix = [Int](repeating: 0xFF_112233, count: W * H)
    let src = java.awt.image.MemoryImageSource(W, H, pix, 0, W)
    src.setAnimated(true)
    src.setFullBufferUpdates(true)

    final class SizeCapture: java.awt.image.ImageConsumer {
      var lastW = -1, lastH = -1
      func setDimensions(_ w: Int, _ h: Int) {}
      func setProperties(_ props: java.util.Hashtable<AnyHashable, AnyObject>) {}
      func setColorModel(_ m: java.awt.image.ColorModel) {}
      func setHints(_ h: Int) {}
      func setPixels(_ x: Int, _ y: Int, _ w: Int, _ h: Int,
                     _ m: java.awt.image.ColorModel,
                     _ p: [UInt8], _ o: Int, _ s: Int) { lastW = w; lastH = h }
      func setPixels(_ x: Int, _ y: Int, _ w: Int, _ h: Int,
                     _ m: java.awt.image.ColorModel,
                     _ p: [Int], _ o: Int, _ s: Int) { lastW = w; lastH = h }
      func imageComplete(_ status: Int) {}
    }

    let sc = SizeCapture()
    src.addConsumer(sc)

    // Even though we request only 1×1, fullBuffers=true should send 4×4
    src.newPixels(0, 0, 1, 1, false)
    #expect(sc.lastW == W)
    #expect(sc.lastH == H)
  }

  // MARK: - newPixels with byte array replacement

  @Test("newPixels(byte[], ColorModel, offset, scansize) replaces pixel source")
  func newPixels_byteArray_replacesSource() {
    let intPix = makePixels(0)
    let src    = java.awt.image.MemoryImageSource(W, H, intPix, 0, W)
    src.setAnimated(true)
    let col    = FrameCollector()
    src.addConsumer(col)
    let framesBefore = col.frames.count

    // Replace with byte pixels (all index 0 = transparent in IndexColorModel)
    let newBytes = [UInt8](repeating: 0, count: W * H)
    src.newPixels(newBytes, java.awt.image.ColorModel.getRGBdefault(), 0, W)

    // A new frame must have arrived
    #expect(col.frames.count == framesBefore + 1)
  }

  // MARK: - framenotify=false

  @Test("newPixels(x,y,w,h, framenotify:false) does not send imageComplete")
  func newPixels_framenotifyFalse_noImageComplete() {
    let pix = makePixels(0xFF_CCDDEE)
    let src = java.awt.image.MemoryImageSource(W, H, pix, 0, W)
    src.setAnimated(true)
    let col = FrameCollector()
    src.addConsumer(col)
    let completionsBefore = col.completions.count

    src.newPixels(0, 0, W, H, false)   // framenotify = false
    #expect(col.completions.count == completionsBefore)   // no new completion
  }
}
