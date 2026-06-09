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
  /// ### Example
  /// ```swift
  /// var pix = [Int](repeating: 0, count: w * h)
  /// // ... fill pix with packed ARGB values ...
  /// let src = java.awt.image.MemoryImageSource(w, h, pix, 0, w)
  /// ```
  public class MemoryImageSource: ImageProducer {

    // -------------------------------------------------------------------------
    // MARK: Private state
    // -------------------------------------------------------------------------

    private let width:    Int
    private let height:   Int
    private let model:    ColorModel
    private let bytePixels: [UInt8]?
    private let intPixels:  [Int]?
    private let offset:   Int
    private let scansize: Int
    private let props:    java.util.Hashtable<AnyHashable, AnyObject>

    /// Current consumer being served (at most one at a time per Java spec).
    private weak var currentConsumer: (any ImageConsumer)?

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

    /// Registers `ic` and immediately delivers the full image.
    public func addConsumer(_ consumer: any ImageConsumer) {
      currentConsumer = consumer
      deliver(to: consumer)
    }

    /// Returns `true` if `ic` is the consumer currently being served.
    public func isConsumer(_ consumer: any ImageConsumer) -> Bool {
      guard let cur = currentConsumer else { return false }
      return cur === consumer
    }

    /// Unregisters `ic`.
    public func removeConsumer(_ consumer: any ImageConsumer) {
      if currentConsumer === consumer {
        currentConsumer = nil
      }
    }

    /// Registers `ic` and immediately (re-)delivers the full image.
    public func startProduction(_ consumer: any ImageConsumer) {
      currentConsumer = consumer
      deliver(to: consumer)
    }

    /// No-op: MemoryImageSource always delivers data in top-down left-to-right order.
    public func requestTopDownLeftRightResend(_ consumer: any ImageConsumer) {
      // ignored per Java spec
    }

    // -------------------------------------------------------------------------
    // MARK: Private delivery helper
    // -------------------------------------------------------------------------

    private func deliver(to consumer: any ImageConsumer) {
      consumer.setDimensions(width, height)
      consumer.setProperties(props)
      consumer.setColorModel(model)
      // Hint constants: TOPDOWNLEFTRIGHT=2 | COMPLETESCANLINES=4 | SINGLEPASS=8 | SINGLEFRAME=16
      consumer.setHints(2 | 4 | 8 | 16)
      if let bp = bytePixels {
        consumer.setPixels(0, 0, width, height, model, bp, offset, scansize)
      } else if let ip = intPixels {
        consumer.setPixels(0, 0, width, height, model, ip, offset, scansize)
      }
      consumer.imageComplete(3) // STATICIMAGEDONE = 3
      currentConsumer = nil
    }
  }
}
