/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.image {

  /// Base class for image filters that sit between an `ImageProducer` and an
  /// `ImageConsumer` — mirrors `java.awt.image.ImageFilter`.
  ///
  /// This is the "null filter": every callback is forwarded unchanged to the
  /// downstream `consumer`.  Subclasses override the methods they need to
  /// modify.
  ///
  /// In Java, `ImageFilter` is cloned by `getFilterInstance` so that each
  /// producer–consumer pair gets its own filter state.  Swift has no built-in
  /// `clone()`, so `getFilterInstance` returns a new instance created by
  /// `makeInstance()`.  Subclasses that carry mutable state should override
  /// `makeInstance()` to return a fresh copy.
  ///
  open class ImageFilter: ImageConsumer {

    // -------------------------------------------------------------------------
    // MARK: Fields
    // -------------------------------------------------------------------------

    /// The downstream consumer that receives the (possibly modified) data.
    /// Set by `getFilterInstance` before pixel delivery begins.
    public var consumer: (any java.awt.image.ImageConsumer)?

    // -------------------------------------------------------------------------
    // MARK: Constructor
    // -------------------------------------------------------------------------

    public init() {}

    // -------------------------------------------------------------------------
    // MARK: Java clone / getFilterInstance
    // -------------------------------------------------------------------------

    /// Returns a new instance of this filter wired to `ic`.
    ///
    /// The default implementation calls `makeInstance()` to obtain a fresh
    /// object, sets its `consumer` to `ic`, and returns it.  Subclasses that
    /// need additional initialisation should override `makeInstance()`.
    public func getFilterInstance(_ ic: any java.awt.image.ImageConsumer) -> ImageFilter {
      let copy = makeInstance()
      copy.consumer = ic
      return copy
    }

    /// Factory method used by `getFilterInstance`.
    ///
    /// The default returns a plain `ImageFilter`.  Subclasses **must** override
    /// this to return `Self()` (or an equivalent fresh instance) so that
    /// `getFilterInstance` produces the correct dynamic type.
    open func makeInstance() -> ImageFilter { ImageFilter() }

    // -------------------------------------------------------------------------
    // MARK: ImageConsumer callbacks — all forward to consumer unchanged
    // -------------------------------------------------------------------------

    open func setDimensions(_ width: Int, _ height: Int) {
      consumer?.setDimensions(width, height)
    }

    open func setProperties(_ props: java.util.Hashtable<AnyHashable, AnyObject>) {
      // Append a description of this filter to the "filters" property, then
      // forward — mirrors the Java spec.
      let key: AnyHashable = "filters"
      var description = "\(type(of: self))"
      if let existing = props.get(key) as? String {
        description = existing + "," + description
      }
      props.put(key, description as AnyObject)
      consumer?.setProperties(props)
    }

    open func setColorModel(_ model: java.awt.image.ColorModel) {
      consumer?.setColorModel(model)
    }

    open func setHints(_ hints: Int) {
      consumer?.setHints(hints)
    }

    open func setPixels(_ x: Int, _ y: Int, _ w: Int, _ h: Int,
                        _ model: java.awt.image.ColorModel,
                        _ pixels: [UInt8], _ off: Int, _ scansize: Int) {
      consumer?.setPixels(x, y, w, h, model, pixels, off, scansize)
    }

    open func setPixels(_ x: Int, _ y: Int, _ w: Int, _ h: Int,
                        _ model: java.awt.image.ColorModel,
                        _ pixels: [Int], _ off: Int, _ scansize: Int) {
      consumer?.setPixels(x, y, w, h, model, pixels, off, scansize)
    }

    open func imageComplete(_ status: Int) {
      consumer?.imageComplete(status)
    }

    /// Forwards a "resend top-down-left-right" request to the upstream
    /// producer, using this filter itself as the requesting consumer.
    public func resendTopDownLeftRight(_ ip: any java.awt.image.ImageProducer) {
      ip.requestTopDownLeftRightResend(self)
    }
  }
}
