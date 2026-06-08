/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.image {

  /// Receives pixel data from an `ImageProducer` — mirrors `java.awt.image.ImageConsumer`.
  ///
  /// The producer calls these methods in order:
  /// 1. `setDimensions` — image size
  /// 2. `setProperties` — optional metadata
  /// 3. `setColorModel` — the color model used for subsequent pixel deliveries
  /// 4. `setHints` — delivery order hints
  /// 5. `setPixels` — one or more pixel rectangles
  /// 6. `imageComplete` — signals end of data
  public protocol ImageConsumer: AnyObject {

    // -------------------------------------------------------------------------
    // MARK: Delivery-order hint constants
    // -------------------------------------------------------------------------

    /// Pixels may arrive in any order.
    static var RANDOMPIXELORDER: Int { get }
    /// Pixels arrive top-down, left-to-right.
    static var TOPDOWNLEFTRIGHT: Int { get }
    /// Each delivery covers complete scan lines.
    static var COMPLETESCANLINES: Int { get }
    /// All pixels arrive in a single pass.
    static var SINGLEPASS: Int { get }
    /// The image consists of a single frame.
    static var SINGLEFRAME: Int { get }

    // -------------------------------------------------------------------------
    // MARK: imageComplete status constants
    // -------------------------------------------------------------------------

    /// A load error occurred.
    static var IMAGEERROR: Int { get }
    /// A single animation frame is complete (more may follow).
    static var SINGLEFRAMEDONE: Int { get }
    /// The static image is fully delivered.
    static var STATICIMAGEDONE: Int { get }
    /// Image loading was aborted.
    static var IMAGEABORTED: Int { get }

    // -------------------------------------------------------------------------
    // MARK: Callback methods
    // -------------------------------------------------------------------------

    /// Called first; provides the full image dimensions.
    func setDimensions(_ width: Int, _ height: Int)

    /// Called with optional image properties (may be empty).
    func setProperties(_ props: java.util.Hashtable<AnyHashable, AnyObject>)

    /// Sets the color model used to interpret subsequent pixel data.
    func setColorModel(_ model: java.awt.image.ColorModel)

    /// Provides delivery-order hints (bitwise OR of the hint constants above).
    func setHints(_ hints: Int)

    /// Delivers a rectangle of pixels encoded as `byte` values.
    func setPixels(_ x: Int, _ y: Int, _ w: Int, _ h: Int,
                   _ model: java.awt.image.ColorModel,
                   _ pixels: [UInt8], _ off: Int, _ scansize: Int)

    /// Delivers a rectangle of pixels encoded as `int` (packed RGB) values.
    func setPixels(_ x: Int, _ y: Int, _ w: Int, _ h: Int,
                   _ model: java.awt.image.ColorModel,
                   _ pixels: [Int], _ off: Int, _ scansize: Int)

    /// Called when delivery is finished or an error occurred.
    /// `status` is one of `IMAGEERROR`, `SINGLEFRAMEDONE`, `STATICIMAGEDONE`,
    /// or `IMAGEABORTED`.
    func imageComplete(_ status: Int)
  }
}

// Default values for the constants so conforming types only need to override
// what they actually customise.
extension java.awt.image.ImageConsumer {
  public static var RANDOMPIXELORDER: Int  { 1  }
  public static var TOPDOWNLEFTRIGHT: Int  { 2  }
  public static var COMPLETESCANLINES: Int { 4  }
  public static var SINGLEPASS: Int        { 8  }
  public static var SINGLEFRAME: Int       { 16 }

  public static var IMAGEERROR: Int        { 1  }
  public static var SINGLEFRAMEDONE: Int   { 2  }
  public static var STATICIMAGEDONE: Int   { 3  }
  public static var IMAGEABORTED: Int      { 4  }
}
