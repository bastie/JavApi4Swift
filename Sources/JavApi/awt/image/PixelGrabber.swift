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
  /// ### Usage with external pixel array
  /// ```swift
  /// var pixels = [Int](repeating: 0, count: w * h)
  /// let pg = java.awt.image.PixelGrabber(producer, x, y, w, h,
  ///                                      &pixels, 0, w)
  /// _ = try pg.grabPixels()
  /// ```
  ///
  /// ### Usage with internal pixel array (Java 1.1)
  /// ```swift
  /// let pg = java.awt.image.PixelGrabber(image, x, y, w, h, true)
  /// _ = try pg.grabPixels()
  /// let pixels = pg.getPixels()
  /// ```
  public class PixelGrabber: ImageConsumer {

    // -------------------------------------------------------------------------
    // MARK: Private state
    // -------------------------------------------------------------------------

    private let producer:  any ImageProducer
    private let grabX:     Int
    private let grabY:     Int
    private var grabW:     Int   // may be -1 until setDimensions is called
    private var grabH:     Int   // may be -1 until setDimensions is called
    private var pixels:    [Int]
    private let offset:    Int
    private var scansize:  Int

    /// Bitwise status flags (mirrors ImageObserver flags).
    /// 64  = ALLBITS   (full image delivered)
    /// 128 = ERROR / ABORT
    private var statusFlags: Int = 0

    /// Set to `true` once `imageComplete` is called.
    private var done: Bool = false

    /// Guards against calling `startProduction` more than once.
    private var grabbing: Bool = false

    /// Whether we allocated the pixel array internally (Java 1.1 constructor).
    private var internalPixels: Bool = false

    /// The color model reported by the image producer.
    private var grabbedModel: ColorModel? = nil

    /// Image dimensions reported by `setDimensions` (needed when grabW/grabH < 0).
    private var imageWidth:  Int = -1
    private var imageHeight: Int = -1

    #if canImport(Dispatch)
    private let semaphore = DispatchSemaphore(value: 0)
    #endif

    // -------------------------------------------------------------------------
    // MARK: Constructors
    // -------------------------------------------------------------------------

    // §2.8.1  from Image, external pixel array
    /// Creates a pixel grabber that reads from `img`'s producer into `pix`.
    public convenience init(_ img: java.awt.Image,
                            _ x: Int, _ y: Int, _ w: Int, _ h: Int,
                            _ pix: inout [Int], _ off: Int, _ scansize: Int) {
      let ip: any ImageProducer = img.getSource()
                                  ?? MemoryImageSource(0, 0, [], 0, 0)
      self.init(ip, x, y, w, h, &pix, off, scansize)
    }

    // §2.8.2  from ImageProducer, external pixel array
    /// Creates a pixel grabber that reads directly from `ip` into `pix`.
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

    // §2.8.3 (Java 1.1)  from Image, internal pixel array, optional RGB coercion
    /// Creates a pixel grabber that allocates its own pixel buffer.
    ///
    /// If `w` or `h` is `-1`, the grabber waits for `setDimensions` to learn
    /// the full image size and allocates the buffer then.
    ///
    /// - Parameter forceRGB: When `true`, pixels are converted to the default
    ///   RGB color model. When `false`, the native model is preserved (in this
    ///   Swift port all `setPixels` paths convert via `model.getRGB()`, so the
    ///   flag records intent rather than changing behaviour).
    /// - Since: JavaApi > 0.20.0 (Java 1.1)
    public convenience init(_ img: java.awt.Image,
                            _ x: Int, _ y: Int, _ w: Int, _ h: Int,
                            _ forceRGB: Bool) {
      let ip: any ImageProducer = img.getSource()
                                  ?? MemoryImageSource(0, 0, [], 0, 0)
      // Allocate buffer if size is known; otherwise defer to setDimensions.
      var buf: [Int]
      let scan: Int
      if w >= 0 && h >= 0 {
        buf  = [Int](repeating: 0, count: w * h)
        scan = w
      } else {
        buf  = []
        scan = 0
      }
      self.init(ip, x, y, w, h, &buf, 0, scan)
      self.internalPixels = true
      self.pixels = buf
    }

    // -------------------------------------------------------------------------
    // MARK: grabPixels  §2.8.4 / §2.8.5
    // -------------------------------------------------------------------------

    /// Starts pixel delivery and waits until all pixels have arrived.
    ///
    /// - Returns: `true` on success; `false` on abort or error.
    /// - Throws: `java.lang.InterruptedException` if the wait is interrupted.
    @discardableResult
    public func grabPixels() throws -> Bool {
      return try grabPixels(0)
    }

    /// Starts pixel delivery and waits up to `ms` milliseconds.
    ///
    /// - Parameter ms: Maximum wait in milliseconds; `0` means wait indefinitely.
    /// - Returns: `true` if all pixels were grabbed within the timeout.
    @discardableResult
    public func grabPixels(_ ms: Int64) throws -> Bool {
      guard !grabbing else { return done && (statusFlags & 192) != 0 }
      grabbing = true
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
    // MARK: startGrabbing / abortGrabbing (Java 1.1)
    // -------------------------------------------------------------------------

    /// Starts pixel delivery asynchronously without blocking.
    ///
    /// Returns immediately. Poll ``status()`` to check for completion, or
    /// call ``grabPixels()`` if you want to block for the result.
    ///
    /// - Since: JavaApi > 0.20.0 (Java 1.1)
    public func startGrabbing() {
      guard !grabbing else { return }
      grabbing = true
      producer.startProduction(self)
    }

    /// Aborts an in-progress grab.
    ///
    /// Sets an error/abort flag, unregisters this grabber from the producer,
    /// and unblocks any pending ``grabPixels()`` call (which will return `false`).
    ///
    /// - Since: JavaApi > 0.20.0 (Java 1.1)
    public func abortGrabbing() {
      statusFlags |= 128   // ABORT
      producer.removeConsumer(self)
      done = true
      #if canImport(Dispatch)
      semaphore.signal()
      #endif
    }

    // -------------------------------------------------------------------------
    // MARK: status  §2.8.12
    // -------------------------------------------------------------------------

    /// Returns the bitwise OR of applicable `ImageObserver` flags.
    public func status() -> Int { statusFlags }

    // -------------------------------------------------------------------------
    // MARK: Accessors (Java 1.1)
    // -------------------------------------------------------------------------

    /// Returns the width of the grabbed image, or `-1` if not yet known.
    ///
    /// - Since: JavaApi > 0.20.0 (Java 1.1)
    public func getWidth() -> Int {
      if grabW >= 0 { return grabW }
      return imageWidth
    }

    /// Returns the height of the grabbed image, or `-1` if not yet known.
    ///
    /// - Since: JavaApi > 0.20.0 (Java 1.1)
    public func getHeight() -> Int {
      if grabH >= 0 { return grabH }
      return imageHeight
    }

    /// Returns the color model of the grabbed image, or `nil` if not yet known.
    ///
    /// - Since: JavaApi > 0.20.0 (Java 1.1)
    public func getColorModel() -> ColorModel? { return grabbedModel }

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
    // MARK: ImageConsumer callbacks — §2.8.6 – §2.8.11
    // -------------------------------------------------------------------------

    /// Records the image dimensions; allocates the internal buffer if needed
    /// (only when constructed with the Java 1.1 `forceRGB` constructor and
    /// `w` or `h` was `-1`).
    public func setDimensions(_ width: Int, _ height: Int) {
      imageWidth  = width
      imageHeight = height
      if internalPixels && pixels.isEmpty {
        let w = (grabW < 0) ? width  : grabW
        let h = (grabH < 0) ? height : grabH
        if grabW < 0 { grabW = w }
        if grabH < 0 { grabH = h }
        scansize = w
        pixels   = [Int](repeating: 0, count: w * h)
      }
    }

    /// Ignored.
    public func setProperties(_ props: java.util.Hashtable<AnyHashable, AnyObject>) {}

    /// Records the producer's color model (returned by `getColorModel()`).
    public func setColorModel(_ model: ColorModel) {
      grabbedModel = model
    }

    /// Ignored.
    public func setHints(_ hints: Int) {}

    /// Receives byte pixels, converts to default RGB, clips to grab rectangle.
    public func setPixels(_ x: Int, _ y: Int, _ w: Int, _ h: Int,
                          _ model: ColorModel,
                          _ srcPixels: [UInt8],
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
