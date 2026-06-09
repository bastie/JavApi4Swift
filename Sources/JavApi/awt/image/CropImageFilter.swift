/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.image {

  /// An image filter that extracts a rectangular region from an image.
  ///
  /// Typically used together with `FilteredImageSource`:
  /// ```swift
  /// let crop = java.awt.image.CropImageFilter(10, 10, 100, 80)
  /// let src  = java.awt.image.FilteredImageSource(producer, crop)
  /// ```
  public class CropImageFilter: ImageFilter {

    // -------------------------------------------------------------------------
    // MARK: Private crop geometry
    // -------------------------------------------------------------------------

    private let cropX: Int
    private let cropY: Int
    private let cropW: Int
    private let cropH: Int

    // -------------------------------------------------------------------------
    // MARK: Constructor  §2.2.1
    // -------------------------------------------------------------------------

    /// Creates a crop filter that extracts the rectangle defined by
    /// (`x`, `y`, `w`, `h`) from the source image.
    ///
    /// - Parameters:
    ///   - x: Left edge of the crop rectangle (in source coordinates).
    ///   - y: Top  edge of the crop rectangle (in source coordinates).
    ///   - w: Width  of the crop rectangle.
    ///   - h: Height of the crop rectangle.
    public init(_ x: Int, _ y: Int, _ w: Int, _ h: Int) {
      self.cropX = x
      self.cropY = y
      self.cropW = w
      self.cropH = h
      super.init()
    }

    // -------------------------------------------------------------------------
    // MARK: setDimensions  §2.2.2
    // -------------------------------------------------------------------------

    /// Ignores the source dimensions and reports the crop size to the consumer.
    override public func setDimensions(_ width: Int, _ height: Int) {
      consumer?.setDimensions(cropW, cropH)
    }

    // -------------------------------------------------------------------------
    // MARK: setProperties  §2.2.5
    // -------------------------------------------------------------------------

    /// Adds a `"croprect"` property (as a `java.awt.Rectangle`) and forwards
    /// the property table to the consumer.
    override public func setProperties(
        _ props: java.util.Hashtable<AnyHashable, AnyObject>) {
      let key: AnyHashable = "croprect"
      let rect = java.awt.Rectangle(cropX, cropY, cropW, cropH)
      props.put(key, rect as AnyObject)
      consumer?.setProperties(props)
    }

    // -------------------------------------------------------------------------
    // MARK: setPixels — byte variant  §2.2.3
    // -------------------------------------------------------------------------

    /// Clips the incoming pixel rectangle to the crop area and forwards only
    /// the intersecting region to the consumer.
    override public func setPixels(_ x: Int, _ y: Int, _ w: Int, _ h: Int,
                                   _ model: ColorModel,
                                   _ pixels: [UInt8],
                                   _ off: Int, _ scansize: Int) {
      // Compute intersection of [x,x+w) × [y,y+h) with [cropX,cropX+cropW) × [cropY,cropY+cropH)
      let ix = max(x, cropX)
      let iy = max(y, cropY)
      let ix2 = min(x + w, cropX + cropW)
      let iy2 = min(y + h, cropY + cropH)
      let iw = ix2 - ix
      let ih = iy2 - iy
      guard iw > 0 && ih > 0 else { return }

      // Offset into the source pixels array for the first intersecting row/col
      let newOff = off + (iy - y) * scansize + (ix - x)

      // Translate to consumer coordinate space (relative to crop origin)
      consumer?.setPixels(ix - cropX, iy - cropY, iw, ih,
                          model, pixels, newOff, scansize)
    }

    // -------------------------------------------------------------------------
    // MARK: setPixels — int variant  §2.2.4
    // -------------------------------------------------------------------------

    /// Clips the incoming pixel rectangle to the crop area and forwards only
    /// the intersecting region to the consumer.
    override public func setPixels(_ x: Int, _ y: Int, _ w: Int, _ h: Int,
                                   _ model: ColorModel,
                                   _ pixels: [Int],
                                   _ off: Int, _ scansize: Int) {
      let ix = max(x, cropX)
      let iy = max(y, cropY)
      let ix2 = min(x + w, cropX + cropW)
      let iy2 = min(y + h, cropY + cropH)
      let iw = ix2 - ix
      let ih = iy2 - iy
      guard iw > 0 && ih > 0 else { return }

      let newOff = off + (iy - y) * scansize + (ix - x)

      consumer?.setPixels(ix - cropX, iy - cropY, iw, ih,
                          model, pixels, newOff, scansize)
    }

    // -------------------------------------------------------------------------
    // MARK: makeInstance (for getFilterInstance)
    // -------------------------------------------------------------------------

    override open func makeInstance() -> ImageFilter {
      CropImageFilter(cropX, cropY, cropW, cropH)
    }
  }
}
