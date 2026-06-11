/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

#if os(Linux) || os(FreeBSD)
import Glibc

// X11 GC function signatures (subset needed for rendering)
private typealias XDrawLineFunc          = @convention(c) (UnsafeMutableRawPointer, UInt, UnsafeMutableRawPointer, Int32, Int32, Int32, Int32) -> Int32
private typealias XDrawRectangleFunc     = @convention(c) (UnsafeMutableRawPointer, UInt, UnsafeMutableRawPointer, Int32, Int32, UInt32, UInt32) -> Int32
private typealias XFillRectangleFunc     = @convention(c) (UnsafeMutableRawPointer, UInt, UnsafeMutableRawPointer, Int32, Int32, UInt32, UInt32) -> Int32
private typealias XSetForegroundFunc     = @convention(c) (UnsafeMutableRawPointer, UnsafeMutableRawPointer, UInt) -> Int32
// XFontSet-based text — supports UTF-8 via locale (XmbDrawString)
private typealias XCreateFontSetFunc     = @convention(c) (UnsafeMutableRawPointer, UnsafePointer<CChar>,
                                                            UnsafeMutablePointer<UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?>?,
                                                            UnsafeMutablePointer<Int32>?,
                                                            UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?) -> UnsafeMutableRawPointer?
private typealias XFreeFontSetFunc       = @convention(c) (UnsafeMutableRawPointer, UnsafeMutableRawPointer) -> Void
private typealias XmbDrawStringFunc      = @convention(c) (UnsafeMutableRawPointer, UInt, UnsafeMutableRawPointer,
                                                            UnsafeMutableRawPointer, Int32, Int32,
                                                            UnsafePointer<CChar>, Int32) -> Int32

// =============================================================================
// MARK: _X11Graphics
// =============================================================================

/// `java.awt.Graphics` subclass backed by an X11 GC (graphics context).
///
/// Passed to `Component.paint(_:)` by `_X11WindowHost.repaint(_:xwin:)`.
/// Drawing calls are routed directly to X11 via the stored `HDC`-equivalent
/// (`display` + `drawable` + `gc`).
///
/// This is a minimal first implementation — override coverage matches what
/// `HeadlessToolkit` provides, extended with actual X11 drawing calls.
/// Extend by adding the remaining `open` methods from `Graphics.swift`.
extension java.awt.toolkit.x11 {

  public final class _X11Graphics: java.awt.Graphics {

    private let display:     UnsafeMutableRawPointer   // X11 Display*
    private let drawable:    UInt                      // X11 Window (XID)
    private let gc:          UnsafeMutableRawPointer   // X11 GC
    private let scaleFactor: Double                    // HiDPI scale (e.g. 2.0)

    // Lazily resolved function pointers — loaded from the already-open libX11
    private var fnDrawLine:       XDrawLineFunc?
    private var fnDrawRect:       XDrawRectangleFunc?
    private var fnFillRect:       XFillRectangleFunc?
    private var fnSetForeground:  XSetForegroundFunc?
    private var fnCreateFontSet:  XCreateFontSetFunc?
    private var fnFreeFontSet:    XFreeFontSetFunc?
    private var fnMbDrawString:   XmbDrawStringFunc?

    // FontSet cache: scaled pixel size → XFontSet* (process-lifetime)
    private var fontSetCache: [Int: UnsafeMutableRawPointer] = [:]

    // Current drawing color (mirrors setColor — base class has no getColor on non-CG)
    private var currentColor:      java.awt.Color = java.awt.Color.black
    private var backgroundColor:   java.awt.Color = java.awt.Color.white

    // Viewport translation (accumulated via translate())
    private var originX: Int = 0
    private var originY: Int = 0

    // Save/restore stack: (originX, originY, currentColor)
    private var saveStack: [(Int, Int, java.awt.Color)] = []

    public init(display: UnsafeMutableRawPointer,
                drawable: UInt,
                gc: UnsafeMutableRawPointer,
                scaleFactor: Double = 1.0) {
      self.display     = display
      self.drawable    = drawable
      self.gc          = gc
      self.scaleFactor = scaleFactor
      // _StubCGContext satisfies the base class init on non-CoreGraphics platforms.
      super.init(java.awt._StubCGContext())
      resolveSymbols()
    }

    private func resolveSymbols() {
      guard let lib = dlopen(nil, RTLD_LAZY) else { return }
      func r<F>(_ sym: String) -> F? {
        guard let raw = dlsym(lib, sym) else { return nil }
        return unsafeBitCast(raw, to: F.self)
      }
      fnDrawLine      = r("XDrawLine")
      fnDrawRect      = r("XDrawRectangle")
      fnFillRect      = r("XFillRectangle")
      fnSetForeground = r("XSetForeground")
      fnCreateFontSet = r("XCreateFontSet")
      fnFreeFontSet   = r("XFreeFontSet")
      fnMbDrawString  = r("XmbDrawString")
      dlclose(lib)
    }

    // -------------------------------------------------------------------------
    // MARK: HiDPI scaling helpers
    // -------------------------------------------------------------------------

    @inline(__always) private func scaled(_ v: Int)         -> Int32  { Int32(Double(v) * scaleFactor) }
    @inline(__always) private func scaledSize(_ v: Int)     -> UInt32 { UInt32(max(0, Double(v) * scaleFactor)) }

    // -------------------------------------------------------------------------
    // MARK: Color
    // -------------------------------------------------------------------------

    public override func setColor(_ color: java.awt.Color) {
      currentColor = color
    }

    private func applyColor() {
      guard let fn = fnSetForeground else { return }
      let c = currentColor
      // X11 pixel: pack RGB into unsigned long (24-bit)
      let pixel: UInt = (UInt(c.getRed()) << 16)
                      | (UInt(c.getGreen()) << 8)
                      |  UInt(c.getBlue())
      _ = fn(display, gc, pixel)
    }

    // -------------------------------------------------------------------------
    // MARK: Drawing
    // -------------------------------------------------------------------------

    public override func drawLine(_ x1: Int, _ y1: Int, _ x2: Int, _ y2: Int) {
      applyColor()
      _ = fnDrawLine?(display, drawable, gc,
                      scaled(x1 + originX), scaled(y1 + originY),
                      scaled(x2 + originX), scaled(y2 + originY))
    }

    public override func drawRect(_ x: Int, _ y: Int, _ width: Int, _ height: Int) {
      guard width > 0 && height > 0 else { return }
      applyColor()
      _ = fnDrawRect?(display, drawable, gc,
                      scaled(x + originX), scaled(y + originY),
                      scaledSize(width), scaledSize(height))
    }

    public override func fillRect(_ x: Int, _ y: Int, _ width: Int, _ height: Int) {
      guard width > 0 && height > 0 else { return }
      applyColor()
      _ = fnFillRect?(display, drawable, gc,
                      scaled(x + originX), scaled(y + originY),
                      scaledSize(width), scaledSize(height))
    }

    public func clearRect(_ x: Int, _ y: Int, _ width: Int, _ height: Int) {
      let saved = currentColor
      setColor(backgroundColor)
      fillRect(x, y, width, height)
      setColor(saved)
    }

    /// Returns (or creates) an XFontSet for the given physical pixel size.
    ///
    /// XFontSet supports multibyte/UTF-8 text via `XmbDrawString` — unlike
    /// XFontStruct which only handles Latin-1 via `XDrawString`.
    /// The XLFD base pattern uses `*` for the pixel field so X finds the
    /// closest available size; we pass the size via the font-list string.
    private func fontSet(pixelSize: Int) -> UnsafeMutableRawPointer? {
      if let cached = fontSetCache[pixelSize] { return cached }
      guard let fnCreate = fnCreateFontSet else { return nil }

      // Comma-separated XLFD list — XCreateFontSet picks glyphs per locale.
      // Use "*" for the encoding field so X selects the right charset automatically
      // based on the locale set via setlocale(). Prefer sans-serif (helvetica)
      // to match the Windows/macOS system UI convention for "Dialog" logical font.
      let fontList = "-adobe-helvetica-medium-r-normal--\(pixelSize)-*-*-*-p-*-*-*," +
                     "-*-helvetica-medium-r-normal--\(pixelSize)-*-*-*-*-*-*-*," +
                     "-*-*-medium-r-normal--\(pixelSize)-*-*-*-*-*-*-*," +
                     "fixed"
      var missingList: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>? = nil
      var missingCount: Int32 = 0
      var defString: UnsafeMutablePointer<CChar>? = nil

      let fs = fontList.withCString { pattern in
        fnCreate(display, pattern, &missingList, &missingCount, &defString)
      }
      if let fs {
        fontSetCache[pixelSize] = fs
      }
      return fs
    }

    public override func drawString(_ str: String, _ x: Int, _ y: Int) {
      applyColor()
      guard let fnDraw = fnMbDrawString else { return }
      let logicalSize  = font.getSize()
      let physicalSize = max(8, Int((Double(logicalSize) * scaleFactor).rounded()))
      guard let fs = fontSet(pixelSize: physicalSize) else { return }
      // XmbDrawString expects byte count of the multibyte (UTF-8) string
      let utf8 = Array(str.utf8)
      utf8.withUnsafeBufferPointer { buf in
        guard let base = buf.baseAddress else { return }
        base.withMemoryRebound(to: CChar.self, capacity: utf8.count) { cbase in
          _ = fnDraw(display, drawable, fs, gc,
                     scaled(x + originX), scaled(y + originY),
                     cbase, Int32(utf8.count))
        }
      }
    }

    public override func drawImage(_ img: java.awt.Image,
                                   _ x: Int, _ y: Int,
                                   _ observer: java.awt.ImageObserver? = nil) -> Bool {
      // TODO: Convert BufferedImage pixels to XImage and call XPutImage
      return false
    }

    // -------------------------------------------------------------------------
    // MARK: Coordinate transform
    // -------------------------------------------------------------------------

    public override func translate(_ dx: Int, _ dy: Int) {
      originX += dx
      originY += dy
    }

    // -------------------------------------------------------------------------
    // MARK: Save / restore
    // -------------------------------------------------------------------------

    public override func save() {
      saveStack.append((originX, originY, currentColor))
    }

    public override func restore() {
      guard let (ox, oy, col) = saveStack.popLast() else { return }
      originX = ox
      originY = oy
      currentColor = col
    }

    // -------------------------------------------------------------------------
    // MARK: Clip (stub — full implementation needs XSetClipRectangles)
    // -------------------------------------------------------------------------

    public override func clipRect(_ x: Int, _ y: Int, _ w: Int, _ h: Int) {
      // TODO: XSetClipRectangles(display, gc, originX, originY, &rect, 1, Unsorted)
    }
  }
}
#endif
