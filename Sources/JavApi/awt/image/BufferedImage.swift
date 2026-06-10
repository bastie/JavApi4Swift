/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

#if canImport(CoreGraphics) && canImport(ImageIO)
import CoreGraphics
import ImageIO
import Foundation
#endif

extension java.awt.image {

  /// In-Memory-Rasterbild — mirrors `java.awt.image.BufferedImage`.
  ///
  /// Unterstützt:
  /// - Erstellen leerer Bilder mit Füllfarbe
  /// - Laden aus Datei (PNG, JPEG, …) via ImageIO
  /// - Pixel lesen (`getRGB`) und schreiben (`setRGB`)
  /// - Rendern über `Graphics.drawImage`
  public final class BufferedImage: java.awt.Image {

    // -------------------------------------------------------------------------
    // MARK: Typ-Konstanten
    // -------------------------------------------------------------------------

    public static let TYPE_INT_ARGB      = 2
    public static let TYPE_INT_RGB       = 1
    public static let TYPE_BYTE_GRAY     = 10
    public static let TYPE_INT_ARGB_PRE  = 3

    // -------------------------------------------------------------------------
    // MARK: Eigenschaften
    // -------------------------------------------------------------------------

    public let width:  Int
    public let height: Int
    public let type:   Int

    /// ARGB-Pixel in Zeilenreihenfolge (Zeile 0 = oben), Format 0xAARRGGBB.
    private var pixels: [UInt32]

    // -------------------------------------------------------------------------
    // MARK: Konstruktoren
    // -------------------------------------------------------------------------

    public init(_ width: Int, _ height: Int, _ type: Int = TYPE_INT_ARGB) {
      self.width  = max(1, width)
      self.height = max(1, height)
      self.type   = type
      // Standardfüllung: undurchsichtiges Weiß
      self.pixels = [UInt32](repeating: 0xFF_FF_FF_FF, count: self.width * self.height)
    }

    /// Erstellt ein `BufferedImage` aus einem bestehenden `CGImage`.
    ///
    /// Die Pixel werden einmalig in den internen ARGB-Puffer kopiert.
    ///
    /// - Since: JavaApi > 0.19.1
#if canImport(CoreGraphics)
    public convenience init?(cgImage: CGImage) {
      let w = cgImage.width
      let h = cgImage.height
      guard w > 0, h > 0 else { return nil }
      self.init(w, h, BufferedImage.TYPE_INT_ARGB)
      guard let ctx = CGContext(
        data:             &self.pixels,
        width:            w,
        height:           h,
        bitsPerComponent: 8,
        bytesPerRow:      w * 4,
        space:            CGColorSpaceCreateDeviceRGB(),
        bitmapInfo:       CGBitmapInfo(rawValue:
                            CGImageAlphaInfo.premultipliedFirst.rawValue |
                            CGBitmapInfo.byteOrder32Big.rawValue).rawValue)
      else { return nil }
      ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: CGFloat(w), height: CGFloat(h)))
    }
#endif

    /// Lädt ein Bild aus einer Datei (PNG / JPEG / BMP / TIFF …).
    /// Gibt `nil` zurück wenn die Datei nicht gelesen werden kann.
    public convenience init?(fromFile path: String) {
#if canImport(CoreGraphics) && canImport(ImageIO)
      guard let result = BufferedImage.loadPixels(from: path) else { return nil }
      self.init(result.width, result.height, BufferedImage.TYPE_INT_ARGB)
      self.pixels = result.pixels
#else
      return nil
#endif
    }

    // -------------------------------------------------------------------------
    // MARK: java.awt.Image
    // -------------------------------------------------------------------------

    public override func getWidth(_ observer: java.awt.ImageObserver? = nil) -> Int  { width }
    public override func getHeight(_ observer: java.awt.ImageObserver? = nil) -> Int { height }

    /// Returns a `Graphics` that draws directly into this image's pixel buffer.
    ///
    /// On platforms with CoreGraphics a real `CGContext` is created over the
    /// pixel buffer; every drawing call writes directly into the image data.
    /// On platforms without CoreGraphics `Graphics.stub` (no-op) is returned.
    public override func getGraphics() -> java.awt.Graphics? {
#if canImport(CoreGraphics)
      guard let ctx = CGContext(
        data:             &pixels,
        width:            width,
        height:           height,
        bitsPerComponent: 8,
        bytesPerRow:      width * 4,
        space:            CGColorSpaceCreateDeviceRGB(),
        bitmapInfo:       CGBitmapInfo(rawValue:
                            CGImageAlphaInfo.premultipliedFirst.rawValue |
                            CGBitmapInfo.byteOrder32Big.rawValue).rawValue)
      else { return java.awt.Graphics.stub }
      return java.awt.Graphics(ctx)
#else
      return java.awt.Graphics.stub
#endif
    }

    /// Returns a `MemoryImageSource` backed by this image's pixel buffer.
    public override func getSource() -> (any java.awt.image.ImageProducer)? {
      let intPixels = pixels.map { Int(bitPattern: UInt($0)) }
      return java.awt.image.MemoryImageSource(width, height, intPixels, 0, width)
    }

    // -------------------------------------------------------------------------
    // MARK: Pixel-Zugriff (ARGB 0xAARRGGBB)
    // -------------------------------------------------------------------------

    public func getRGB(_ x: Int, _ y: Int) -> Int {
      guard x >= 0, x < width, y >= 0, y < height else { return 0 }
      return Int(bitPattern: UInt(pixels[y * width + x]))
    }

    public func setRGB(_ x: Int, _ y: Int, _ argb: Int) {
      guard x >= 0, x < width, y >= 0, y < height else { return }
      pixels[y * width + x] = UInt32(bitPattern: Int32(truncatingIfNeeded: argb))
    }

    /// Füllt den gesamten Puffer mit einer Farbe.
    public func fill(_ color: java.awt.Color) {
      let a = UInt32(255)
      let r = UInt32(min(255, Int(color.red   * 255)))
      let g = UInt32(min(255, Int(color.green * 255)))
      let b = UInt32(min(255, Int(color.blue  * 255)))
      let argb = (a << 24) | (r << 16) | (g << 8) | b
      pixels = [UInt32](repeating: argb, count: width * height)
    }
  }
}

// =============================================================================
// MARK: - CGImage-Brücke
// =============================================================================

#if canImport(CoreGraphics) && canImport(ImageIO)
import CoreGraphics
import ImageIO
import Foundation

extension java.awt.image.BufferedImage {

  /// Erzeugt ein `CGImage` aus dem Pixelpuffer — wird von `Graphics.drawImage` genutzt.
  public func toCGImage() -> CGImage? {
    var copy = pixels   // braucht mutablen Puffer für CGDataProvider
    let bytesPerRow = width * 4
    return copy.withUnsafeMutableBytes { ptr in
      guard let baseAddress = ptr.baseAddress,
            let cfData = CFDataCreate(nil,
                                     baseAddress.assumingMemoryBound(to: UInt8.self),
                                     ptr.count),
            let provider = CGDataProvider(data: cfData)
      else { return nil }
      return CGImage(
        width:             width,
        height:            height,
        bitsPerComponent:  8,
        bitsPerPixel:      32,
        bytesPerRow:       bytesPerRow,
        space:             CGColorSpaceCreateDeviceRGB(),
        bitmapInfo:        CGBitmapInfo(rawValue:
                             CGImageAlphaInfo.premultipliedFirst.rawValue |
                             CGBitmapInfo.byteOrder32Big.rawValue),
        provider:          provider,
        decode:            nil,
        shouldInterpolate: true,
        intent:            .defaultIntent)
    }
  }

  /// Lädt eine Bilddatei und gibt Breite, Höhe und Pixelpuffer zurück.
  static func loadPixels(from path: String) -> (width: Int, height: Int, pixels: [UInt32])? {
    let url  = URL(fileURLWithPath: path) as CFURL
    guard let src = CGImageSourceCreateWithURL(url, nil),
          let img = CGImageSourceCreateImageAtIndex(src, 0, nil) else { return nil }

    let w = img.width
    let h = img.height
    var buf = [UInt32](repeating: 0, count: w * h)

    guard let ctx = CGContext(
      data:             &buf,
      width:            w,
      height:           h,
      bitsPerComponent: 8,
      bytesPerRow:      w * 4,
      space:            CGColorSpaceCreateDeviceRGB(),
      bitmapInfo:       CGBitmapInfo(rawValue:
                          CGImageAlphaInfo.premultipliedFirst.rawValue |
                          CGBitmapInfo.byteOrder32Big.rawValue).rawValue)
    else { return nil }

    ctx.draw(img, in: CGRect(x: 0, y: 0, width: w, height: h))
    return (w, h, buf)
  }
}
#endif
