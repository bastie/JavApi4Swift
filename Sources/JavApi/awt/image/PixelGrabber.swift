/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

#if canImport(Dispatch)
import Dispatch
#endif

extension java.awt.image {

  /// Grabs a rectangular region of pixels from an image or `ImageProducer`
  /// into a caller-supplied `[Int]` array in the default RGB color model —
  /// mirrors `java.awt.image.PixelGrabber`.
  ///
  /// ### Usage
  /// ```swift
  /// var pixels = [Int](repeating: 0, count: w * h)
  /// let pg = java.awt.image.PixelGrabber(producer, x, y, w, h,
  ///                                      &pixels, 0, w)
  /// _ = try pg.grabPixels()
  /// ```
  public class PixelGrabber: ImageConsumer {

    // -------------------------------------------------------------------------
    // MARK: Private state
    // -------------------------------------------------------------------------

    private let producer:  any ImageProducer
    private let grabX:     Int
    private let grabY:     Int
    private let grabW:     Int
    private let grabH:     Int
    private var pixels:    [Int]
    private let offset:    Int
    private let scansize:  Int

    /// Bitwise status flags (mirrors ImageObserver flags).
    /// 8 = FRAMEBITS (complete frame available)
    /// 64 = ALLBITS   (full image delivered)
    /// 128 = ERROR
    /// 64 = ABORT
    private var statusFlags: Int = 0

    /// Set to `true` once `imageComplete` is called.
    private var done: Bool = false

    #if canImport(Dispatch)
    private let semaphore = DispatchSemaphore(value: 0)
    #endif

    // -------------------------------------------------------------------------
    // MARK: Constructors
    // -------------------------------------------------------------------------

    // §2.8.1  from Image — in Swift we use its producer
    /// Creates a pixel grabber that reads from `img`'s producer.
    public convenience init(_ img: java.awt.Image,
                            _ x: Int, _ y: Int, _ w: Int, _ h: Int,
                            _ pix: inout [Int], _ off: Int, _ scansize: Int) {
      // Unwrap the optional producer; use an empty MemoryImageSource as fallback.
      let ip: any ImageProducer = img.getSource()
                                  ?? MemoryImageSource(0, 0, [], 0, 0)
      self.init(ip, x, y, w, h, &pix, off, scansize)
    }

    // §2.8.2  from ImageProducer
    /// Creates a pixel grabber that reads directly from `ip`.
    public init(_ ip: any ImageProducer,
                _ x: Int, _ y: Int, _ w: Int, _ h: Int,
                _ pix: inout [Int], _ off: Int, _ scansize: Int) {
      self.producer  = ip
      self.grabX     = x
      self.grabY     = y
      self.grabW     = w
      self.grabH     = h
      self.pixels    = pix
      self.offset    = off
      self.scansize  = scansize
    }

    // -------------------------------------------------------------------------
    // MARK: grabPixels  §2.8.3 / §2.8.4
    // -------------------------------------------------------------------------

    /// Starts pixel delivery and waits until all pixels have arrived.
    ///
    /// - Returns: `true` on success; `false` on abort or error.
    /// - Throws: `java.lang.InterruptedException` (mapped to Swift `throw`) if
    ///           the wait is interrupted.
    @discardableResult
    public func grabPixels() throws -> Bool {
      return try grabPixels(0)
    }

    /// Starts pixel delivery and waits up to `ms` milliseconds.
    ///
    /// - Parameter ms: Maximum wait in milliseconds; 0 means wait indefinitely.
    /// - Returns: `true` if all pixels were grabbed within the timeout.
    @discardableResult
    public func grabPixels(_ ms: Int64) throws -> Bool {
      producer.startProduction(self)
      #if canImport(Dispatch)
      if ms <= 0 {
        semaphore.wait()
      } else {
        let deadline = DispatchTime.now() + .milliseconds(Int(ms))
        let result   = semaphore.wait(timeout: deadline)
        if result == .timedOut { return false }
      }
      #endif
      return (statusFlags & 192) != 0   // ALLBITS | FRAMEBITS
    }

    // -------------------------------------------------------------------------
    // MARK: status  §2.8.12
    // -------------------------------------------------------------------------

    /// Returns the bitwise OR of applicable `ImageObserver` flags.
    public func status() -> Int { statusFlags }

    // -------------------------------------------------------------------------
    // MARK: Swift convenience — access the filled pixel array
    // -------------------------------------------------------------------------

    /// Returns the pixel array filled by `grabPixels`.
    ///
    /// In Java, `int[]` is a reference type so the caller's array is modified
    /// in place.  In Swift, `[Int]` is a value type (copy-on-write), so use
    /// this method to retrieve the result after calling `grabPixels()`.
    public func getPixels() -> [Int] { pixels }

    // -------------------------------------------------------------------------
    // MARK: ImageConsumer callbacks — §2.8.5 – §2.8.11
    // -------------------------------------------------------------------------

    /// Ignored — PixelGrabber uses the dimensions passed to the constructor.
    public func setDimensions(_ width: Int, _ height: Int) {}

    /// Ignored.
    public func setProperties(_ props: java.util.Hashtable<AnyHashable, AnyObject>) {}

    /// Ignored — pixels are always converted to default RGB.
    public func setColorModel(_ model: ColorModel) {}

    /// Ignored.
    public func setHints(_ hints: Int) {}

    /// Receives byte pixels, converts to default RGB, clips to grab rectangle.
    public func setPixels(_ x: Int, _ y: Int, _ w: Int, _ h: Int,
                          _ model: ColorModel,
                          _ srcPixels: [UInt8],
                          _ srcOff: Int, _ srcScan: Int) {
      // Clip to grab rectangle
      let ix = max(x, grabX);  let iy = max(y, grabY)
      let ix2 = min(x + w, grabX + grabW)
      let iy2 = min(y + h, grabY + grabH)
      let iw = ix2 - ix;       let ih = iy2 - iy
      guard iw > 0 && ih > 0 else { return }

      for row in 0 ..< ih {
        for col in 0 ..< iw {
          let si = srcOff + (iy - y + row) * srcScan + (ix - x + col)
          let di = offset + (iy - grabY + row) * scansize + (ix - grabX + col)
          guard si < srcPixels.count, di < pixels.count else { continue }
          pixels[di] = model.getRGB(Int(srcPixels[si]))
        }
      }
    }

    /// Receives int pixels, converts to default RGB, clips to grab rectangle.
    public func setPixels(_ x: Int, _ y: Int, _ w: Int, _ h: Int,
                          _ model: ColorModel,
                          _ srcPixels: [Int],
                          _ srcOff: Int, _ srcScan: Int) {
      let ix = max(x, grabX);  let iy = max(y, grabY)
      let ix2 = min(x + w, grabX + grabW)
      let iy2 = min(y + h, grabY + grabH)
      let iw = ix2 - ix;       let ih = iy2 - iy
      guard iw > 0 && ih > 0 else { return }

      for row in 0 ..< ih {
        for col in 0 ..< iw {
          let si = srcOff + (iy - y + row) * srcScan + (ix - x + col)
          let di = offset + (iy - grabY + row) * scansize + (ix - grabX + col)
          guard si < srcPixels.count, di < pixels.count else { continue }
          pixels[di] = model.getRGB(srcPixels[si])
        }
      }
    }

    /// Called when delivery is finished or has errored/aborted.
    public func imageComplete(_ status: Int) {
      switch status {
      case PixelGrabber.STATICIMAGEDONE, PixelGrabber.SINGLEFRAMEDONE:
        statusFlags |= 64   // ALLBITS
      case PixelGrabber.IMAGEERROR:
        statusFlags |= 128  // ERROR
      case PixelGrabber.IMAGEABORTED:
        statusFlags |= 64   // treat abort as done for grabPixels return value
      default:
        break
      }
      done = true
      producer.removeConsumer(self)
      #if canImport(Dispatch)
      semaphore.signal()
      #endif
    }
  }
}
