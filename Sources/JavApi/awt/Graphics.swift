/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

#if canImport(CoreGraphics)
import CoreGraphics
#if canImport(CoreText)
import CoreText
#endif

extension java.awt {

  /// java.awt.Graphics — mapped auf CGContext
  open class Graphics {
    internal var cgContext: CGContext

    public var font: java.awt.Font = java.awt.Font("Dialog", java.awt.Font.PLAIN, 12)

    internal init(_ context: CGContext) {
      self.cgContext = context
    }

    /// Creates a no-op `Graphics` backed by a 1×1 offscreen bitmap context.
    ///
    /// Mirrors Java's `protected Graphics()` constructor.
    /// Use when a `Graphics` object is required outside an active paint cycle
    /// (e.g. headless environments, unit tests, peer API calls).
    public convenience init() {
      let ctx = CGContext(data: nil, width: 1, height: 1,
                         bitsPerComponent: 8, bytesPerRow: 4,
                         space: CGColorSpaceCreateDeviceRGB(),
                         bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
      self.init(ctx)
    }

    /// A no-op stub context — used when a `Graphics` is required but no real
    /// paint cycle is active (e.g. peer API calls).
    @available(*, deprecated, renamed: "init()")
    public static var stub: Graphics { Graphics() }

    // -------------------------------------------------------------------------
    // MARK: Lifecycle
    // -------------------------------------------------------------------------

    /// Releases the native resources held by this `Graphics` context.
    ///
    /// Must be called when the `Graphics` object is no longer needed.
    /// For `PrintJob`-derived contexts, calling `dispose()` also signals
    /// that the current page is complete and advances to the next page.
    ///
    /// Mirrors `java.awt.Graphics.dispose()`.
    open func dispose() {
      // CoreGraphics contexts are reference-counted and released automatically.
      // Subclasses (e.g. PrintJob graphics) override this to flush the page.
    }

    // -------------------------------------------------------------------------
    // MARK: Font & FontMetrics
    // -------------------------------------------------------------------------

    public func setFont(_ f: java.awt.Font) { font = f }
    public func getFont() -> java.awt.Font  { font     }

    open func getFontMetrics() -> java.awt.FontMetrics {
      java.awt.FontMetrics.make(for: font)
    }
    open func getFontMetrics(_ f: java.awt.Font) -> java.awt.FontMetrics {
      java.awt.FontMetrics.make(for: f)
    }

    // -------------------------------------------------------------------------
    // MARK: Color
    // -------------------------------------------------------------------------

    private var _color: java.awt.Color = java.awt.Color.black

    public func setColor(_ color: java.awt.Color) {
      // getRed/getGreen/getBlue werden von SystemColor überschrieben und liefern
      // den aktuellen Systemwert (Dark-Mode-sicher). Daher Getter statt stored properties.
      _color = color
      let r = CGFloat(color.getRed())   / 255.0
      let g = CGFloat(color.getGreen()) / 255.0
      let b = CGFloat(color.getBlue())  / 255.0
      let a = CGFloat(color.getAlpha()) / 255.0
      let cg = CGColor(red: r, green: g, blue: b, alpha: a)
      cgContext.setFillColor(cg)
      cgContext.setStrokeColor(cg)
    }

    public func getColor() -> java.awt.Color { _color }

    // -------------------------------------------------------------------------
    // MARK: Shapes
    // -------------------------------------------------------------------------

    open func fillRect(_ x: Int, _ y: Int, _ width: Int, _ height: Int) {
      cgContext.fill(CGRect(x: x, y: y, width: width, height: height))
    }

    open func drawRect(_ x: Int, _ y: Int, _ width: Int, _ height: Int) {
      cgContext.stroke(CGRect(x: x, y: y, width: width, height: height))
    }

    open func drawLine(_ x1: Int, _ y1: Int, _ x2: Int, _ y2: Int) {
      cgContext.move(to: CGPoint(x: x1, y: y1))
      cgContext.addLine(to: CGPoint(x: x2, y: y2))
      cgContext.strokePath()
    }

    open func fillOval(_ x: Int, _ y: Int, _ width: Int, _ height: Int) {
      cgContext.fillEllipse(in: CGRect(x: x, y: y, width: width, height: height))
    }

    open func drawOval(_ x: Int, _ y: Int, _ width: Int, _ height: Int) {
      cgContext.strokeEllipse(in: CGRect(x: x, y: y, width: width, height: height))
    }

    open func drawRoundRect(_ x: Int, _ y: Int, _ width: Int, _ height: Int,
                            _ arcWidth: Int, _ arcHeight: Int) {
      let path = CGPath(
        roundedRect: CGRect(x: x, y: y, width: width, height: height),
        cornerWidth:  CGFloat(arcWidth)  / 2,
        cornerHeight: CGFloat(arcHeight) / 2,
        transform: nil
      )
      cgContext.addPath(path)
      cgContext.strokePath()
    }

    open func fillRoundRect(_ x: Int, _ y: Int, _ width: Int, _ height: Int,
                            _ arcWidth: Int, _ arcHeight: Int) {
      let path = CGPath(
        roundedRect: CGRect(x: x, y: y, width: width, height: height),
        cornerWidth:  CGFloat(arcWidth)  / 2,
        cornerHeight: CGFloat(arcHeight) / 2,
        transform: nil
      )
      cgContext.addPath(path)
      cgContext.fillPath()
    }

    // -------------------------------------------------------------------------
    // MARK: Graphics state (save / restore / clip / translate)
    // -------------------------------------------------------------------------

    /// Save the current graphics state (transform, clip, color).
    open func save() { cgContext.saveGState() }

    /// Restore the previously saved graphics state.
    open func restore() { cgContext.restoreGState() }

    /// Intersect the current clip with the given rectangle (AWT coordinates).
    open func clipRect(_ x: Int, _ y: Int, _ w: Int, _ h: Int) {
      cgContext.clip(to: CGRect(x: x, y: y, width: w, height: h))
    }

    /// Translate the origin by (`dx`, `dy`) in AWT coordinates.
    ///
    /// In the Y-flipped CGContext used by the AWT bridge, positive `dy` moves
    /// content downward (same direction as positive AWT-y), so passing
    /// `(-scrollX, -scrollY)` shifts visible content left/up — exactly what
    /// `ScrollPane` needs when rendering its clipped child.
    open func translate(_ dx: Int, _ dy: Int) {
      cgContext.translateBy(x: CGFloat(dx), y: CGFloat(dy))
    }

    // -------------------------------------------------------------------------
    // MARK: Text
    // -------------------------------------------------------------------------

    open func drawString(_ str: String, _ x: Int, _ y: Int) {
#if canImport(CoreText)
      let cfName = font.platformName as CFString
      let ctFont  = CTFontCreateWithName(cfName, CGFloat(font.size), nil)
      let attrs   = [kCTFontAttributeName: ctFont,
                     kCTForegroundColorFromContextAttributeName: true] as CFDictionary
      guard let attrStr = CFAttributedStringCreate(kCFAllocatorDefault, str as CFString, attrs) else { return }
      let line = CTLineCreateWithAttributedString(attrStr)

      cgContext.saveGState()
      cgContext.translateBy(x: CGFloat(x), y: CGFloat(y))
      cgContext.scaleBy(x: 1, y: -1)
      cgContext.textPosition = .zero
      CTLineDraw(line, cgContext)
      cgContext.restoreGState()
#endif
    }

    // -------------------------------------------------------------------------
    // MARK: Polygon
    // -------------------------------------------------------------------------

    /// Zeichnet den Umriss eines Polygons.
    open func drawPolygon(_ xpoints: [Int], _ ypoints: [Int], _ npoints: Int) {
      guard npoints >= 2 else { return }
      cgContext.move(to: CGPoint(x: xpoints[0], y: ypoints[0]))
      for i in 1..<npoints {
        cgContext.addLine(to: CGPoint(x: xpoints[i], y: ypoints[i]))
      }
      cgContext.closePath()
      cgContext.strokePath()
    }

    /// Zeichnet den Umriss eines `Polygon`-Objekts.
    open func drawPolygon(_ p: java.awt.Polygon) {
      drawPolygon(p.xpoints, p.ypoints, p.npoints)
    }

    /// Füllt ein Polygon (Even-Odd-Füllregel).
    open func fillPolygon(_ xpoints: [Int], _ ypoints: [Int], _ npoints: Int) {
      guard npoints >= 2 else { return }
      cgContext.move(to: CGPoint(x: xpoints[0], y: ypoints[0]))
      for i in 1..<npoints {
        cgContext.addLine(to: CGPoint(x: xpoints[i], y: ypoints[i]))
      }
      cgContext.closePath()
      cgContext.fillPath(using: .evenOdd)
    }

    /// Füllt ein `Polygon`-Objekt.
    open func fillPolygon(_ p: java.awt.Polygon) {
      fillPolygon(p.xpoints, p.ypoints, p.npoints)
    }

    // -------------------------------------------------------------------------
    // MARK: Image
    // -------------------------------------------------------------------------

    /// Zeichnet ein `java.awt.Image` an Position `(x, y)` in Originalgröße.
    @discardableResult
    open func drawImage(_ img: java.awt.Image, _ x: Int, _ y: Int,
                        _ observer: java.awt.ImageObserver? = nil) -> Bool {
      guard let bi = img as? java.awt.image.BufferedImage,
            let cg = bi.toCGImage() else { return false }
      let rect = CGRect(x: CGFloat(x), y: CGFloat(y),
                        width: CGFloat(bi.width), height: CGFloat(bi.height))
      // Der Kontext ist bereits Y-gespiegelt (AWT-Koordinaten), daher nochmal
      // lokal spiegeln damit das Bild nicht auf dem Kopf steht.
      cgContext.saveGState()
      cgContext.translateBy(x: rect.minX, y: rect.maxY)
      cgContext.scaleBy(x: 1, y: -1)
      cgContext.draw(cg, in: CGRect(origin: .zero, size: rect.size))
      cgContext.restoreGState()
      return true
    }

    /// Zeichnet ein Bild skaliert auf `(width × height)`.
    @discardableResult
    open func drawImage(_ img: java.awt.Image,
                        _ x: Int, _ y: Int, _ width: Int, _ height: Int,
                        _ observer: java.awt.ImageObserver? = nil) -> Bool {
      guard let bi = img as? java.awt.image.BufferedImage,
            let cg = bi.toCGImage() else { return false }
      let rect = CGRect(x: CGFloat(x), y: CGFloat(y),
                        width: CGFloat(width), height: CGFloat(height))
      cgContext.saveGState()
      cgContext.translateBy(x: rect.minX, y: rect.maxY)
      cgContext.scaleBy(x: 1, y: -1)
      cgContext.draw(cg, in: CGRect(origin: .zero, size: rect.size))
      cgContext.restoreGState()
      return true
    }
  }
}

#else // Platforms without CoreGraphics (e.g. Windows, bare Linux without swift-corelibs)

extension java.awt {
  public protocol CGContext {}

  /// Concrete no-op implementation used as a stub on non-Apple platforms.
  public struct _StubCGContext: CGContext {
    public init() {}
  }

  open class Graphics {
    internal var cgContext: CGContext
    public var font: java.awt.Font = java.awt.Font("Dialog", java.awt.Font.PLAIN, 12)

    internal init(_ context: CGContext) {
      self.cgContext = context
    }

    /// Creates a no-op `Graphics` instance.
    ///
    /// Mirrors the `protected Graphics()` constructor in Java.
    /// All drawing calls on this instance are no-ops; use this when a
    /// `Graphics` object is required outside an active paint cycle
    /// (e.g. headless environments, unit tests).
    public convenience init() {
      self.init(_StubCGContext())
    }

    /// Releases the native resources held by this `Graphics` context.
    ///
    /// Mirrors `java.awt.Graphics.dispose()`.
    open func dispose() {
      // No native resources to release on non-Apple platforms.
    }

    public func setFont(_ f: java.awt.Font) { font = f }
    public func getFont() -> java.awt.Font  { font     }

    open func getFontMetrics() -> java.awt.FontMetrics {
      java.awt.FontMetrics.make(for: font)
    }
    open func getFontMetrics(_ f: java.awt.Font) -> java.awt.FontMetrics {
      java.awt.FontMetrics.make(for: f)
    }

    private var _color: java.awt.Color = java.awt.Color.black
    public func setColor(_ color: java.awt.Color) { _color = color }
    public func getColor() -> java.awt.Color { _color }
    open func fillRect(_ x: Int, _ y: Int, _ width: Int, _ height: Int) {}
    open func drawRect(_ x: Int, _ y: Int, _ width: Int, _ height: Int) {}
    open func drawLine(_ x1: Int, _ y1: Int, _ x2: Int, _ y2: Int) {}
    open func fillOval(_ x: Int, _ y: Int, _ width: Int, _ height: Int) {}
    open func drawOval(_ x: Int, _ y: Int, _ width: Int, _ height: Int) {}
    open func drawRoundRect(_ x: Int, _ y: Int, _ width: Int, _ height: Int,
                            _ arcWidth: Int, _ arcHeight: Int) {}
    open func fillRoundRect(_ x: Int, _ y: Int, _ width: Int, _ height: Int,
                            _ arcWidth: Int, _ arcHeight: Int) {}
    open func drawString(_ str: String, _ x: Int, _ y: Int) {}
    open func save()    {}
    open func restore() {}
    open func clipRect(_ x: Int, _ y: Int, _ w: Int, _ h: Int) {}
    open func translate(_ dx: Int, _ dy: Int) {}

    @discardableResult
    open func drawImage(_ img: java.awt.Image, _ x: Int, _ y: Int,
                        _ observer: java.awt.ImageObserver? = nil) -> Bool { false }
    @discardableResult
    open func drawImage(_ img: java.awt.Image,
                        _ x: Int, _ y: Int, _ width: Int, _ height: Int,
                        _ observer: java.awt.ImageObserver? = nil) -> Bool { false }

    open func drawPolygon(_ xpoints: [Int], _ ypoints: [Int], _ npoints: Int) {}
    open func drawPolygon(_ p: java.awt.Polygon) {
      drawPolygon(p.xpoints, p.ypoints, p.npoints)
    }
    open func fillPolygon(_ xpoints: [Int], _ ypoints: [Int], _ npoints: Int) {}
    open func fillPolygon(_ p: java.awt.Polygon) {
      fillPolygon(p.xpoints, p.ypoints, p.npoints)
    }
  }
}
#endif
