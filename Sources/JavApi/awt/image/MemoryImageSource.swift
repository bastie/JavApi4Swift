/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.image {

  /// An `ImageProducer` backed by an in-memory pixel array —
  /// mirrors `java.awt.image.MemoryImageSource`.
  ///
  /// Because all pixel data is available immediately, `addConsumer` and
  /// `startProduction` both deliver the full image synchronously and complete.
  /// `requestTopDownLeftRightResend` is a no-op (data is always delivered
  /// top-down left-to-right).
  ///
  /// ### Animation (Java 1.1)
  /// Call `setAnimated(true)` to keep consumers registered across frames,
  /// then call `newPixels()` (or one of its overloads) to push updated
  /// pixel data to all registered consumers.
  ///
  /// ### Example
  /// ```swift
  /// var pix = [Int](repeating: 0, count: w * h)
  /// // ... fill pix with packed ARGB values ...
  /// let src = java.awt.image.MemoryImageSource(w, h, pix, 0, w)
  /// ```
  public class MemoryImageSource: ImageProducer, @unchecked Sendable {

    // -------------------------------------------------------------------------
    // MARK: Private state
    // -------------------------------------------------------------------------

    private let width:    Int
    private let height:   Int
    private var model:    ColorModel
    private var bytePixels: [UInt8]?
    private var intPixels:  [Int]?
    private var offset:   Int
    private var scansize: Int
    private let props:    java.util.Hashtable<AnyHashable, AnyObject>

    /// Animation mode: when `true`, consumers are kept after frame delivery.
    private var animated: Bool = false

    /// When `true`, `newPixels(_:_:_:_:)` sends the full buffer regardless of region.
    private var fullBuffers: Bool = false

    /// Registered consumers — strong refs so the producer keeps them alive
    /// during animation. (Since `ImageConsumer: AnyObject`, we key by identity.)
    private var consumers: [ObjectIdentifier: any ImageConsumer] = [:]

    // -------------------------------------------------------------------------
    // MARK: Constructors
    // -------------------------------------------------------------------------

    // §2.7.1  byte pixels, explicit color model, no properties
    public init(_ w: Int, _ h: Int, _ cm: ColorModel,
                _ pix: [UInt8], _ off: Int, _ scan: Int) {
      self.width       = w
      self.height      = h
      self.model       = cm
      self.bytePixels  = pix
      self.intPixels   = nil
      self.offset      = off
      self.scansize    = scan
      self.props       = java.util.Hashtable()
    }

    // §2.7.2  byte pixels, explicit color model, with properties
    public init(_ w: Int, _ h: Int, _ cm: ColorModel,
                _ pix: [UInt8], _ off: Int, _ scan: Int,
                _ props: java.util.Hashtable<AnyHashable, AnyObject>) {
      self.width       = w
      self.height      = h
      self.model       = cm
      self.bytePixels  = pix
      self.intPixels   = nil
      self.offset      = off
      self.scansize    = scan
      self.props       = props
    }

    // §2.7.3  int pixels, explicit color model, no properties
    public init(_ w: Int, _ h: Int, _ cm: ColorModel,
                _ pix: [Int], _ off: Int, _ scan: Int) {
      self.width       = w
      self.height      = h
      self.model       = cm
      self.bytePixels  = nil
      self.intPixels   = pix
      self.offset      = off
      self.scansize    = scan
      self.props       = java.util.Hashtable()
    }

    // §2.7.4  int pixels, explicit color model, with properties
    public init(_ w: Int, _ h: Int, _ cm: ColorModel,
                _ pix: [Int], _ off: Int, _ scan: Int,
                _ props: java.util.Hashtable<AnyHashable, AnyObject>) {
      self.width       = w
      self.height      = h
      self.model       = cm
      self.bytePixels  = nil
      self.intPixels   = pix
      self.offset      = off
      self.scansize    = scan
      self.props       = props
    }

    // §2.7.5  int pixels, default RGB color model, no properties
    public init(_ w: Int, _ h: Int,
                _ pix: [Int], _ off: Int, _ scan: Int) {
      self.width       = w
      self.height      = h
      self.model       = ColorModel.getRGBdefault()
      self.bytePixels  = nil
      self.intPixels   = pix
      self.offset      = off
      self.scansize    = scan
      self.props       = java.util.Hashtable()
    }

    // §2.7.6  int pixels, default RGB color model, with properties
    public init(_ w: Int, _ h: Int,
                _ pix: [Int], _ off: Int, _ scan: Int,
                _ props: java.util.Hashtable<AnyHashable, AnyObject>) {
      self.width       = w
      self.height      = h
      self.model       = ColorModel.getRGBdefault()
      self.bytePixels  = nil
      self.intPixels   = pix
      self.offset      = off
      self.scansize    = scan
      self.props       = props
    }

    // -------------------------------------------------------------------------
    // MARK: ImageProducer §2.7.7 – §2.7.11
    // -------------------------------------------------------------------------

    /// Registers `consumer` and immediately delivers the full image.
    public func addConsumer(_ consumer: any ImageConsumer) {
      consumers[ObjectIdentifier(consumer)] = consumer
      deliver(to: consumer)
    }

    /// Returns `true` if `consumer` is currently registered.
    public func isConsumer(_ consumer: any ImageConsumer) -> Bool {
      return consumers[ObjectIdentifier(consumer)] != nil
    }

    /// Unregisters `consumer`.
    public func removeConsumer(_ consumer: any ImageConsumer) {
      consumers.removeValue(forKey: ObjectIdentifier(consumer))
    }

    /// Registers `consumer` and immediately (re-)delivers the full image.
    public func startProduction(_ consumer: any ImageConsumer) {
      consumers[ObjectIdentifier(consumer)] = consumer
      deliver(to: consumer)
    }

    /// No-op: MemoryImageSource always delivers data in top-down left-to-right order.
    public func requestTopDownLeftRightResend(_ consumer: any ImageConsumer) {
      // ignored per Java spec
    }

    // -------------------------------------------------------------------------
    // MARK: Animation API (Java 1.1)
    // -------------------------------------------------------------------------

    /// Enables or disables animation mode.
    ///
    /// In animation mode, consumers remain registered after each frame so that
    /// subsequent `newPixels()` calls push updated frames to them.
    /// Setting to `false` removes all currently registered consumers.
    ///
    /// - Since: JavaApi > 0.20.0 (Java 1.1)
    public func setAnimated(_ animated: Bool) {
      self.animated = animated
      if !animated {
        consumers.removeAll()
      }
    }

    /// Controls whether partial `newPixels` calls send the entire buffer.
    ///
    /// When `true`, even `newPixels(_:_:_:_:)` calls send the full pixel
    /// buffer instead of just the changed region.
    ///
    /// - Since: JavaApi > 0.20.0 (Java 1.1)
    public func setFullBufferUpdates(_ fullbuffers: Bool) {
      self.fullBuffers = fullbuffers
    }

    /// Pushes a full-frame update to all registered consumers.
    ///
    /// Only effective in animation mode (after `setAnimated(true)`).
    ///
    /// - Since: JavaApi > 0.20.0 (Java 1.1)
    public func newPixels() {
      guard animated else { return }
      for consumer in consumers.values {
        sendPixels(to: consumer)
        consumer.imageComplete(2 /* ImageConsumer.SINGLEFRAMEDONE */)
      }
    }

    /// Pushes a partial-region update to all registered consumers.
    ///
    /// If `setFullBufferUpdates(true)` was called, the full buffer is sent.
    /// A `SINGLEFRAMEDONE` notification is sent after the pixels.
    ///
    /// Only effective in animation mode.
    ///
    /// - Since: JavaApi > 0.20.0 (Java 1.1)
    public func newPixels(_ x: Int, _ y: Int, _ w: Int, _ h: Int) {
      newPixels(x, y, w, h, true)
    }

    /// Pushes a partial-region update with optional frame-complete notification.
    ///
    /// - Parameter framenotify: If `true`, sends `SINGLEFRAMEDONE` after pixels.
    /// - Since: JavaApi > 0.20.0 (Java 1.1)
    public func newPixels(_ x: Int, _ y: Int, _ w: Int, _ h: Int,
                          _ framenotify: Bool) {
      guard animated else { return }
      for consumer in consumers.values {
        if fullBuffers {
          sendPixels(to: consumer)
        } else {
          sendRegion(x, y, w, h, to: consumer)
        }
        if framenotify {
          consumer.imageComplete(2 /* ImageConsumer.SINGLEFRAMEDONE */)
        }
      }
    }

    /// Replaces the byte pixel source and pushes a full-frame update.
    ///
    /// Only effective in animation mode.
    ///
    /// - Since: JavaApi > 0.20.0 (Java 1.1)
    public func newPixels(_ newpix: [UInt8], _ newmodel: ColorModel,
                          _ offset: Int, _ scansize: Int) {
      self.bytePixels = newpix
      self.intPixels  = nil
      self.model      = newmodel
      self.offset     = offset
      self.scansize   = scansize
      newPixels()
    }

    /// Replaces the int pixel source and pushes a full-frame update.
    ///
    /// Only effective in animation mode.
    ///
    /// - Since: JavaApi > 0.20.0 (Java 1.1)
    public func newPixels(_ newpix: [Int], _ newmodel: ColorModel,
                          _ offset: Int, _ scansize: Int) {
      self.intPixels  = newpix
      self.bytePixels = nil
      self.model      = newmodel
      self.offset     = offset
      self.scansize   = scansize
      newPixels()
    }

    // -------------------------------------------------------------------------
    // MARK: Private delivery helpers
    // -------------------------------------------------------------------------

    /// Full initial delivery: sends dimensions, properties, color model, hints,
    /// pixels, then `imageComplete`.
    /// In animated mode uses `SINGLEFRAMEDONE` and keeps the consumer;
    /// in static mode uses `STATICIMAGEDONE` and removes the consumer.
    private func deliver(to consumer: any ImageConsumer) {
      consumer.setDimensions(width, height)
      consumer.setProperties(props)
      consumer.setColorModel(model)
      // Hint constants: TOPDOWNLEFTRIGHT=2 | COMPLETESCANLINES=4 | SINGLEPASS=8 | SINGLEFRAME=16
      let hints = animated ? (2 | 4 | 8) : (2 | 4 | 8 | 16)
      consumer.setHints(hints)
      sendPixels(to: consumer)
      if animated {
        consumer.imageComplete(2 /* ImageConsumer.SINGLEFRAMEDONE */)
        // consumer stays registered for future newPixels() calls
      } else {
        consumer.imageComplete(3 /* ImageConsumer.STATICIMAGEDONE */)
        consumers.removeValue(forKey: ObjectIdentifier(consumer))
      }
    }

    /// Sends the complete pixel buffer (no setup calls).
    private func sendPixels(to consumer: any ImageConsumer) {
      if let bp = bytePixels {
        consumer.setPixels(0, 0, width, height, model, bp, offset, scansize)
      } else if let ip = intPixels {
        consumer.setPixels(0, 0, width, height, model, ip, offset, scansize)
      }
    }

    /// Sends only the specified rectangular region (clipped to image bounds).
    private func sendRegion(_ rx: Int, _ ry: Int, _ rw: Int, _ rh: Int,
                            to consumer: any ImageConsumer) {
      let cx  = max(0, rx);            let cy  = max(0, ry)
      let cx2 = min(width,  rx + rw);  let cy2 = min(height, ry + rh)
      let cw  = cx2 - cx;              let ch  = cy2 - cy
      guard cw > 0 && ch > 0 else { return }

      if let bp = bytePixels {
        var region = [UInt8](repeating: 0, count: cw * ch)
        for row in 0 ..< ch {
          let srcStart = offset + (cy + row) * scansize + cx
          let dstStart = row * cw
          for col in 0 ..< cw {
            region[dstStart + col] = bp[srcStart + col]
          }
        }
        consumer.setPixels(cx, cy, cw, ch, model, region, 0, cw)
      } else if let ip = intPixels {
        var region = [Int](repeating: 0, count: cw * ch)
        for row in 0 ..< ch {
          let srcStart = offset + (cy + row) * scansize + cx
          let dstStart = row * cw
          for col in 0 ..< cw {
            region[dstStart + col] = ip[srcStart + col]
          }
        }
        consumer.setPixels(cx, cy, cw, ch, model, region, 0, cw)
      }
    }
  }
}
