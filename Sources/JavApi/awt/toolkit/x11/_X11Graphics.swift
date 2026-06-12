/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

#if os(Linux) || os(FreeBSD)
#if canImport(Glibc)
import Glibc
#endif

// =============================================================================
// MARK: X11 core drawing function type aliases
// =============================================================================
// All X11 drawing functions take (Display*, Drawable/XID, GC, …).
// Drawable is an XID (unsigned long = UInt on 64-bit), not a pointer.
private typealias XDrawLineFunc          = @convention(c) (UnsafeMutableRawPointer, UInt, UnsafeMutableRawPointer, Int32, Int32, Int32, Int32) -> Int32
private typealias XDrawRectangleFunc     = @convention(c) (UnsafeMutableRawPointer, UInt, UnsafeMutableRawPointer, Int32, Int32, UInt32, UInt32) -> Int32
private typealias XFillRectangleFunc     = @convention(c) (UnsafeMutableRawPointer, UInt, UnsafeMutableRawPointer, Int32, Int32, UInt32, UInt32) -> Int32
private typealias XSetForegroundFunc     = @convention(c) (UnsafeMutableRawPointer, UnsafeMutableRawPointer, UInt) -> Int32

// =============================================================================
// MARK: Xft (X FreeType) type aliases — Unicode text rendering
// =============================================================================
// Xft uses FreeType + fontconfig to render UTF-8 text on X11.
// Loaded at runtime from libXft.so.2 via dlopen.
//
// CRITICAL: the libXft dlopen handle MUST NOT be closed (dlclose) after
// resolving symbols. Closing it invalidates all function pointers and causes
// a crash (bad pointer dereference) on the next XftFontOpenName call.
// Keep the handle open for the process lifetime.
//
// Type pitfalls:
// - Drawable and Colormap are X11 XIDs (unsigned long = UInt on 64-bit).
//   They are NOT pointers. Use UInt in Swift type aliases, not RawPointer.
// - XRenderColor and XftColor are C structs. Swift @convention(c) cannot
//   pass Swift struct types as arguments. Pass them as UnsafeMutableRawPointer
//   via withUnsafeMutableBytes(of:).
//
// XftDrawCreate(Display*, Drawable/XID, Visual*, Colormap/XID)
private typealias XftDrawCreateFunc      = @convention(c) (UnsafeMutableRawPointer, UInt, UnsafeMutableRawPointer, UInt) -> UnsafeMutableRawPointer?
private typealias XftDrawDestroyFunc     = @convention(c) (UnsafeMutableRawPointer) -> Void
// XftFontOpenName(Display*, int screen, const char* fontconfig-pattern)
// e.g. "sans-serif:pixelsize=24" → Unicode-capable system font via fontconfig
private typealias XftFontOpenNameFunc    = @convention(c) (UnsafeMutableRawPointer, Int32, UnsafePointer<CChar>) -> UnsafeMutableRawPointer?
private typealias XftFontCloseFunc       = @convention(c) (UnsafeMutableRawPointer, UnsafeMutableRawPointer) -> Void
// XftDrawStringUtf8(XftDraw*, XftColor* as RawPtr, XftFont* as RawPtr, x, y, FcChar8*, len)
private typealias XftDrawStringUtf8Func  = @convention(c) (UnsafeMutableRawPointer, UnsafeMutableRawPointer,
                                                            UnsafeMutableRawPointer, Int32, Int32,
                                                            UnsafePointer<UInt8>, Int32) -> Void
// XftColorAllocValue(Display*, Visual*, Colormap/XID, XRenderColor* as RawPtr, XftColor* as RawPtr)
private typealias XftColorAllocValueFunc = @convention(c) (UnsafeMutableRawPointer, UnsafeMutableRawPointer,
                                                            UInt, UnsafeMutableRawPointer,
                                                            UnsafeMutableRawPointer) -> Int32
// XftColorFree(Display*, Visual*, Colormap/XID, XftColor* as RawPtr)
private typealias XftColorFreeFunc       = @convention(c) (UnsafeMutableRawPointer, UnsafeMutableRawPointer,
                                                            UInt, UnsafeMutableRawPointer) -> Void
// XftTextExtentsUtf8(Display*, XftFont*, FcChar8*, int len, XGlyphInfo* out)
private typealias XftTextExtentsUtf8Func = @convention(c) (UnsafeMutableRawPointer, UnsafeMutableRawPointer,
                                                            UnsafePointer<UInt8>, Int32,
                                                            UnsafeMutableRawPointer) -> Void
private typealias XDefaultVisualFunc     = @convention(c) (UnsafeMutableRawPointer, Int32) -> UnsafeMutableRawPointer?
// XDefaultColormap returns an XID (unsigned long), not a pointer
private typealias XDefaultColormapFunc   = @convention(c) (UnsafeMutableRawPointer, Int32) -> UInt
private typealias XDefaultScreenFunc2    = @convention(c) (UnsafeMutableRawPointer) -> Int32
// XSetClipRectangles(Display*, GC, clip_x_origin, clip_y_origin, XRectangle[], n, ordering)
// Sets a clip region on the GC. clip_x_origin/clip_y_origin are always 0 here because
// we pass absolute physical coordinates in the rectangles themselves.
// XRectangle: { x: Int16, y: Int16, width: UInt16, height: UInt16 } — 8 bytes
private typealias XSetClipRectanglesFunc = @convention(c) (UnsafeMutableRawPointer, UnsafeMutableRawPointer,
                                                            Int32, Int32,
                                                            UnsafeRawPointer, Int32, Int32) -> Int32
// XSetClipMask(Display*, GC, None/0) — removes the clip region (clip = entire drawable)
private typealias XSetClipMaskFunc       = @convention(c) (UnsafeMutableRawPointer, UnsafeMutableRawPointer, UInt) -> Int32

// =============================================================================
// MARK: X11 oval / arc / polygon type aliases
// =============================================================================
// XDrawArc / XFillArc(Display*, Drawable, GC, x, y, w, h, angle1*64, angle2*64)
// Angles are in 1/64 degree units. Full circle: angle1=0, angle2=360*64.
private typealias XDrawArcFunc           = @convention(c) (UnsafeMutableRawPointer, UInt, UnsafeMutableRawPointer,
                                                            Int32, Int32, UInt32, UInt32, Int32, Int32) -> Int32
private typealias XFillArcFunc           = @convention(c) (UnsafeMutableRawPointer, UInt, UnsafeMutableRawPointer,
                                                            Int32, Int32, UInt32, UInt32, Int32, Int32) -> Int32
// XDrawLines / XFillPolygon use XPoint arrays: { x: Int16, y: Int16 }
// XDrawLines(Display*, Drawable, GC, XPoint[], npoints, CoordModeOrigin=0)
private typealias XDrawLinesFunc         = @convention(c) (UnsafeMutableRawPointer, UInt, UnsafeMutableRawPointer,
                                                            UnsafeRawPointer, Int32, Int32) -> Int32
// XFillPolygon(Display*, Drawable, GC, XPoint[], npoints, Complex=0, CoordModeOrigin=0)
private typealias XFillPolygonFunc       = @convention(c) (UnsafeMutableRawPointer, UInt, UnsafeMutableRawPointer,
                                                            UnsafeRawPointer, Int32, Int32, Int32) -> Int32

// XRenderColor: 4 × UInt16 = 8 bytes total.
// Map 8-bit (0–255) → 16-bit (0–65535) by multiplying by 257 (= 0x101).
// alpha: 0xFFFF = fully opaque.
struct XRenderColor {
  var red: UInt16; var green: UInt16; var blue: UInt16; var alpha: UInt16
}
// XftColor: X pixel value (UInt) + XRenderColor = 16 bytes on 64-bit.
// Passed to Xft functions as UnsafeMutableRawPointer (see type notes above).
struct XftColor {
  var pixel: UInt
  var color: XRenderColor
}

// =============================================================================
// MARK: XFontSet / Xutf8DrawString type aliases — Unicode text fallback
// =============================================================================
// Used only when libXft is unavailable.
// Xutf8DrawString handles UTF-8 correctly (unlike XDrawString which is Latin-1
// only), but requires the installed XLFD fonts to contain the needed glyphs —
// not guaranteed on modern systems that ship few or no bitmap fonts.
// For reliable Unicode rendering, prefer Xft above.
private typealias XCreateFontSetFunc     = @convention(c) (UnsafeMutableRawPointer, UnsafePointer<CChar>,
                                                            UnsafeMutablePointer<UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?>?,
                                                            UnsafeMutablePointer<Int32>?,
                                                            UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?) -> UnsafeMutableRawPointer?
private typealias XFreeFontSetFunc       = @convention(c) (UnsafeMutableRawPointer, UnsafeMutableRawPointer) -> Void
private typealias Xutf8DrawStringFunc    = @convention(c) (UnsafeMutableRawPointer, UInt, UnsafeMutableRawPointer,
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

    // Lazily resolved function pointers — loaded from the already-open libX11/libXft
    private var fnDrawLine:          XDrawLineFunc?
    private var fnDrawRect:          XDrawRectangleFunc?
    private var fnFillRect:          XFillRectangleFunc?
    private var fnSetForeground:     XSetForegroundFunc?
    // Xft (primary text renderer — full Unicode via FreeType/fontconfig)
    private var fnXftDrawCreate:     XftDrawCreateFunc?
    private var fnXftDrawDestroy:    XftDrawDestroyFunc?
    private var fnXftFontOpenName:   XftFontOpenNameFunc?
    private var fnXftFontClose:      XftFontCloseFunc?
    private var fnXftDrawStringUtf8:  XftDrawStringUtf8Func?
    private var fnXftTextExtentsUtf8: XftTextExtentsUtf8Func?
    private var fnXftColorAllocValue: XftColorAllocValueFunc?
    private var fnXftColorFree:      XftColorFreeFunc?
    private var fnDefaultVisual:     XDefaultVisualFunc?
    private var fnDefaultColormap:   XDefaultColormapFunc?
    private var fnDefaultScreen:     XDefaultScreenFunc2?
    // XFontSet fallback (kept in case Xft is unavailable)
    private var fnCreateFontSet:     XCreateFontSetFunc?
    private var fnFreeFontSet:       XFreeFontSetFunc?
    private var fnUtf8DrawString:    Xutf8DrawStringFunc?

    // Xft font cache: pixel size → XftFont* (shared, process-lifetime)
    nonisolated(unsafe) private static var sharedXftFontCache: [Int: UnsafeMutableRawPointer] = [:]
    // XFontSet fallback cache
    nonisolated(unsafe) private static var sharedFontSetCache: [Int: UnsafeMutableRawPointer] = [:]

    // Clip functions
    private var fnSetClipRectangles: XSetClipRectanglesFunc?
    private var fnSetClipMask:       XSetClipMaskFunc?
    // Oval / arc / polygon
    private var fnDrawArc:           XDrawArcFunc?
    private var fnFillArc:           XFillArcFunc?
    private var fnDrawLines:         XDrawLinesFunc?
    private var fnFillPolygon:       XFillPolygonFunc?

    // Current drawing color (mirrors setColor — base class has no getColor on non-CG)
    private var currentColor:      java.awt.Color = java.awt.Color.black
    private var backgroundColor:   java.awt.Color = java.awt.Color.white

    // Viewport translation (accumulated via translate())
    private var originX: Int = 0
    private var originY: Int = 0

    // Active clip rect in logical coordinates (nil = no clip / clip to everything)
    // Stored as logical coords; converted to physical pixels when applied to the GC.
    private var clipLogical: java.awt.Rectangle? = nil

    // Save/restore stack: (originX, originY, currentColor, clipLogical)
    private var saveStack: [(Int, Int, java.awt.Color, java.awt.Rectangle?)] = []

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
      // Works on glibc and dynamic MUSL
      // Use numeric constant — RTLD_LAZY is inaccessible under static MUSL builds.
      let rtldLazy: CInt = 0x00001
      guard let lib = dlopen(nil, rtldLazy) else {
        print("[X11Graphics] WARNING: dlopen() failed (may be static MUSL build).")
        return
      }
      func r<F>(_ sym: String) -> F? {
        guard let raw = dlsym(lib, sym) else { return nil }
        return unsafeBitCast(raw, to: F.self)
      }
      fnDrawLine       = r("XDrawLine")
      fnDrawRect       = r("XDrawRectangle")
      fnFillRect       = r("XFillRectangle")
      fnSetForeground  = r("XSetForeground")
      fnDefaultVisual  = r("XDefaultVisual")
      fnDefaultColormap = r("XDefaultColormap")
      fnDefaultScreen  = r("XDefaultScreen")
      // XFontSet fallback
      fnCreateFontSet      = r("XCreateFontSet")
      fnFreeFontSet        = r("XFreeFontSet")
      fnUtf8DrawString     = r("Xutf8DrawString")
      // Clip region
      fnSetClipRectangles  = r("XSetClipRectangles")
      fnSetClipMask        = r("XSetClipMask")
      // Oval / arc / polygon
      fnDrawArc            = r("XDrawArc")
      fnFillArc            = r("XFillArc")
      fnDrawLines          = r("XDrawLines")
      fnFillPolygon        = r("XFillPolygon")
      _ = dlclose(lib)
      // Load Xft from libXft — separate library from libX11
      let xftCandidates = ["libXft.so.2", "libXft.so"]
      for name in xftCandidates {
        if let xftLib = dlopen(name, rtldLazy) {
          func rx<F>(_ sym: String) -> F? {
            guard let raw = dlsym(xftLib, sym) else { return nil }
            return unsafeBitCast(raw, to: F.self)
          }
          fnXftDrawCreate      = rx("XftDrawCreate")
          fnXftDrawDestroy     = rx("XftDrawDestroy")
          fnXftFontOpenName    = rx("XftFontOpenName")
          fnXftFontClose       = rx("XftFontClose")
          fnXftDrawStringUtf8  = rx("XftDrawStringUtf8")
          fnXftTextExtentsUtf8 = rx("XftTextExtentsUtf8")
          fnXftColorAllocValue = rx("XftColorAllocValue")
          fnXftColorFree       = rx("XftColorFree")
          // NOTE: intentionally NOT calling dlclose(xftLib) —
          // closing the handle invalidates all resolved function pointers.
          // libXft stays open for the process lifetime.
          break
        }
      }
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

    public override func drawOval(_ x: Int, _ y: Int, _ width: Int, _ height: Int) {
      guard width > 0 && height > 0 else { return }
      applyColor()
      _ = fnDrawArc?(display, drawable, gc,
                     scaled(x + originX), scaled(y + originY),
                     scaledSize(width), scaledSize(height),
                     0, 360 * 64)
    }

    public override func fillOval(_ x: Int, _ y: Int, _ width: Int, _ height: Int) {
      guard width > 0 && height > 0 else { return }
      applyColor()
      _ = fnFillArc?(display, drawable, gc,
                     scaled(x + originX), scaled(y + originY),
                     scaledSize(width), scaledSize(height),
                     0, 360 * 64)
    }

    /// Draws a polygon outline. The last point is automatically connected back to
    /// the first by appending the first point — matching Java AWT semantics.
    public override func drawPolygon(_ xpoints: [Int], _ ypoints: [Int], _ npoints: Int) {
      guard npoints >= 2, let fn = fnDrawLines else { return }
      applyColor()
      // XPoint: Int16 x, Int16 y (4 bytes each, packed)
      // Close the polygon by repeating the first point at the end.
      var pts = (0..<npoints).map { i -> (Int16, Int16) in
        (Int16(truncatingIfNeeded: scaled(xpoints[i] + originX)),
         Int16(truncatingIfNeeded: scaled(ypoints[i] + originY)))
      }
      pts.append(pts[0])  // close
      pts.withUnsafeBytes { buf in
        _ = fn(display, drawable, gc, buf.baseAddress!, Int32(pts.count), 0 /* CoordModeOrigin */)
      }
    }

    /// Fills a polygon. Uses X11 `XFillPolygon` with `Complex` shape hint.
    public override func fillPolygon(_ xpoints: [Int], _ ypoints: [Int], _ npoints: Int) {
      guard npoints >= 3, let fn = fnFillPolygon else { return }
      applyColor()
      let pts = (0..<npoints).map { i -> (Int16, Int16) in
        (Int16(truncatingIfNeeded: scaled(xpoints[i] + originX)),
         Int16(truncatingIfNeeded: scaled(ypoints[i] + originY)))
      }
      pts.withUnsafeBytes { buf in
        _ = fn(display, drawable, gc, buf.baseAddress!, Int32(npoints),
               0 /* Complex */, 0 /* CoordModeOrigin */)
      }
    }

    public func clearRect(_ x: Int, _ y: Int, _ width: Int, _ height: Int) {
      let saved = currentColor
      setColor(backgroundColor)
      fillRect(x, y, width, height)
      setColor(saved)
    }

    /// Returns (or creates) a cached XFontSet for the given physical pixel size.
    ///
    /// This is the **fallback** text renderer, used only when Xft (libXft) is
    /// unavailable.  `Xutf8DrawString` handles UTF-8 encoding correctly, but the
    /// underlying XLFD font must contain glyphs for the needed codepoints — on
    /// modern Linux systems that ship few bitmap fonts this can silently produce
    /// invisible text for non-ASCII characters.
    ///
    /// The font set is cached in `sharedFontSetCache` (shared static, not per-instance)
    /// so that short-lived `_X11Graphics` objects reuse the same XFontSet across
    /// paint calls.  Creating a new XFontSet for each draw call is prohibitively slow.
    ///
    /// XLFD patterns are tried from most specific to least specific until
    /// `XCreateFontSet` succeeds.  The fully-wildcarded fallback always matches.
    private func fontSet(pixelSize: Int) -> UnsafeMutableRawPointer? {
      if let cached = Self.sharedFontSetCache[pixelSize] { return cached }
      guard let fnCreate = fnCreateFontSet else { return nil }

      // Prefer fonts with iso10646-1 encoding (Unicode BMP coverage).
      // Fall back to progressively broader patterns until XCreateFontSet succeeds.
      let candidates: [String] = [
        "-*-dejavu sans-book-r-normal--\(pixelSize)-*-*-*-*-*-iso10646-1",
        "-*-liberation sans-regular-r-normal--\(pixelSize)-*-*-*-*-*-iso10646-1",
        "-*-noto sans-regular-r-normal--\(pixelSize)-*-*-*-*-*-iso10646-1",
        "-*-*-medium-r-normal--\(pixelSize)-*-*-*-*-*-iso10646-1",
        "-*-*-*-*-*-*-\(pixelSize)-*-*-*-*-*-iso10646-1",
        "-*-*-*-*-*-*-*-*-*-*-*-*-iso10646-1",
        "-*-*-*-*-*-*-*-*-*-*-*-*-*-*",
      ]

      for pattern in candidates {
        var missingList: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>? = nil
        var missingCount: Int32 = 0
        var defString: UnsafeMutablePointer<CChar>? = nil
        let fs = pattern.withCString { cstr in
          fnCreate(display, cstr, &missingList, &missingCount, &defString)
        }
        if let fs {
          Self.sharedFontSetCache[pixelSize] = fs
          return fs
        }
      }
      return nil
    }

    /// Returns FontMetrics whose `stringWidth` uses `XftTextExtentsUtf8` —
    /// so horizontal measurements (e.g. Label CENTER) match the Xft renderer.
    /// Vertical metrics (ascent/descent) use the headless approximation because
    /// they don't affect centering and the XftFont struct offsets vary by platform.
    public override func getFontMetrics(_ f: java.awt.Font) -> java.awt.FontMetrics {
      let pixelSize = max(8, Int((Double(f.getSize()) * scaleFactor).rounded()))
      if let xftFnt = xftFont(pixelSize: pixelSize),
         let fnExt  = fnXftTextExtentsUtf8 {
        let rawFn = unsafeBitCast(fnExt, to: UnsafeMutableRawPointer.self)
        return _X11InlineMetrics(font: f, display: display,
                                 xftFont: xftFnt, fnTextExtentsRaw: rawFn,
                                 scaleFactor: scaleFactor)
      }
      return java.awt.FontMetrics.make(for: f)
    }

    public override func getFontMetrics() -> java.awt.FontMetrics {
      getFontMetrics(font)
    }

    /// Lightweight FontMetrics that reuses the already-loaded XftFont from
    /// this `_X11Graphics` instance — no extra dlopen/dlsym needed.
    /// `fnTextExtentsRaw` is stored as `UnsafeMutableRawPointer` to avoid
    /// Swift access-level conflicts with the private `@convention(c)` typealias.
    private final class _X11InlineMetrics: java.awt.FontMetrics {
      private struct XGlyphInfo {
        var width: UInt16 = 0; var height: UInt16 = 0
        var x: Int16 = 0;     var y: Int16 = 0
        var xOff: Int16 = 0;  var yOff: Int16 = 0
      }
      private let display:          UnsafeMutableRawPointer
      private let xftFont:          UnsafeMutableRawPointer
      private let fnTextExtentsRaw: UnsafeMutableRawPointer  // XftTextExtentsUtf8Func
      private let scaleFactor:      Double
      init(font: java.awt.Font,
           display: UnsafeMutableRawPointer,
           xftFont: UnsafeMutableRawPointer,
           fnTextExtentsRaw: UnsafeMutableRawPointer,
           scaleFactor: Double) {
        self.display          = display
        self.xftFont          = xftFont
        self.fnTextExtentsRaw = fnTextExtentsRaw
        self.scaleFactor      = scaleFactor
        super.init(font)
      }
      override func stringWidth(_ str: String) -> Int {
        guard !str.isEmpty else { return 0 }
        typealias Fn = @convention(c) (UnsafeMutableRawPointer, UnsafeMutableRawPointer,
                                       UnsafePointer<UInt8>, Int32,
                                       UnsafeMutableRawPointer) -> Void
        let fn = unsafeBitCast(fnTextExtentsRaw, to: Fn.self)
        let utf8 = Array(str.utf8)
        // Use a raw 12-byte buffer to avoid Swift struct padding surprises.
        // XGlyphInfo layout: width(u16), height(u16), x(s16), y(s16), xOff(s16), yOff(s16)
        // xOff is at byte offset 8 as a little-endian Int16.
        var buf12 = [UInt8](repeating: 0, count: 12)
        utf8.withUnsafeBufferPointer { ubuf in
          buf12.withUnsafeMutableBytes { rbuf in
            fn(display, xftFont, ubuf.baseAddress!, Int32(utf8.count), rbuf.baseAddress!)
          }
        }
        // Read xOff (offset 8, Int16 LE) — advance width in physical pixels.
        // Divide by scaleFactor to get logical pixels (matching AWT bounds).
        let xOff = Int(Int16(bitPattern: UInt16(buf12[8]) | (UInt16(buf12[9]) << 8)))
        // Read width (offset 0, UInt16 LE) — bounding box width, fallback
        let width = Int(UInt16(buf12[0]) | (UInt16(buf12[1]) << 8))
        let physical = xOff > 0 ? xOff : width
        return Int((Double(physical) / scaleFactor).rounded())
      }
      override func charWidth(_ ch: Character) -> Int { stringWidth(String(ch)) }
    }

    public override func drawString(_ str: String, _ x: Int, _ y: Int) {
      applyColor()
      let physX = scaled(x + originX)
      let physY = scaled(y + originY)
      let physicalSize = max(8, Int((Double(font.getSize()) * scaleFactor).rounded()))

      // Primary: Xft (FreeType/fontconfig) — full Unicode, anti-aliased
      if drawStringXft(str, x: physX, y: physY, pixelSize: physicalSize) { return }

      // Fallback: XFontSet + Xutf8DrawString
      guard let fnDraw = fnUtf8DrawString,
            let fs = fontSet(pixelSize: physicalSize) else { return }
      let utf8 = Array(str.utf8)
      utf8.withUnsafeBufferPointer { buf in
        guard let base = buf.baseAddress else { return }
        base.withMemoryRebound(to: CChar.self, capacity: utf8.count) { cbase in
          _ = fnDraw(display, drawable, fs, gc, physX, physY, cbase, Int32(utf8.count))
        }
      }
    }

    /// Draw `str` using Xft (FreeType). Returns `true` on success.
    private func drawStringXft(_ str: String, x: Int32, y: Int32, pixelSize: Int) -> Bool {
      guard let fnCreate     = fnXftDrawCreate,
            let fnDestroy    = fnXftDrawDestroy,
            let fnDrawStr    = fnXftDrawStringUtf8,
            let fnAllocColor = fnXftColorAllocValue,
            let fnFreeColor  = fnXftColorFree,
            let fnScreen     = fnDefaultScreen,
            let fnVisual     = fnDefaultVisual,
            let fnColormap   = fnDefaultColormap
      else { return false }

      guard let xftFont = xftFont(pixelSize: pixelSize) else { return false }

      let screen = fnScreen(display)
      guard let visual = fnVisual(display, screen) else { return false }
      let colormap = fnColormap(display, screen)

      guard let xftDraw = fnCreate(display, drawable, visual, colormap) else { return false }
      defer { fnDestroy(xftDraw) }

      let c = currentColor
      let scale: Double = 257.0   // maps 0-255 → 0-65535
      // XRenderColor: 4 × UInt16 = 8 bytes
      var renderColor = XRenderColor(
        red:   UInt16(Double(c.getRed())   * scale),
        green: UInt16(Double(c.getGreen()) * scale),
        blue:  UInt16(Double(c.getBlue())  * scale),
        alpha: 0xFFFF)
      // XftColor: UInt (pixel) + XRenderColor = 16 bytes on 64-bit
      var xftColor = XftColor(pixel: 0, color: renderColor)
      withUnsafeMutableBytes(of: &renderColor) { rBuf in
        withUnsafeMutableBytes(of: &xftColor) { cBuf in
          _ = fnAllocColor(display, visual, colormap,
                           rBuf.baseAddress!, cBuf.baseAddress!)
        }
      }
      defer {
        withUnsafeMutableBytes(of: &xftColor) { cBuf in
          fnFreeColor(display, visual, colormap, cBuf.baseAddress!)
        }
      }

      let utf8 = Array(str.utf8)
      utf8.withUnsafeBufferPointer { buf in
        guard let base = buf.baseAddress else { return }
        withUnsafeMutableBytes(of: &xftColor) { cBuf in
          fnDrawStr(xftDraw, cBuf.baseAddress!, xftFont, x, y, base, Int32(utf8.count))
        }
      }
      return true
    }

    /// Returns (or creates) a cached XftFont* for the given physical pixel size.
    ///
    /// Uses a fontconfig pattern `"sans-serif:pixelsize=N"` which resolves to a
    /// Unicode-capable font (DejaVu Sans, Liberation Sans, Noto Sans, …) on all
    /// modern Linux desktops.  The result is stored in `sharedXftFontCache` — a
    /// shared static dictionary keyed by pixel size — because font loading is
    /// expensive and `_X11Graphics` instances are short-lived (one per paint call).
    ///
    /// Returns `nil` if `fnXftFontOpenName` could not be resolved (libXft missing).
    private func xftFont(pixelSize: Int) -> UnsafeMutableRawPointer? {
      if let cached = Self.sharedXftFontCache[pixelSize] { return cached }
      guard let fnOpen   = fnXftFontOpenName,
            let fnScreen = fnDefaultScreen else { return nil }
      let screen = fnScreen(display)
      let pattern = "sans-serif:pixelsize=\(pixelSize)"
      let fnt = pattern.withCString { fnOpen(display, screen, $0) }
      if let fnt { Self.sharedXftFontCache[pixelSize] = fnt }
      return fnt
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
      saveStack.append((originX, originY, currentColor, clipLogical))
    }

    public override func restore() {
      guard let (ox, oy, col, clip) = saveStack.popLast() else { return }
      originX = ox
      originY = oy
      currentColor = col
      clipLogical = clip
      applyClip()
    }

    // -------------------------------------------------------------------------
    // MARK: Clip
    // -------------------------------------------------------------------------

    /// Sets a clip rectangle in **logical** coordinates (same space as all draw calls).
    ///
    /// Intersects with the current clip — matching GDI `IntersectClipRect` semantics
    /// so that nested `clipRect` calls inside `ScrollPane.paint` restrict rather than
    /// replace the parent clip.
    ///
    /// The clip is stored as logical coords and re-applied (scaled to physical pixels)
    /// whenever `applyClip()` is called.  `restore()` reinstates the saved clip.
    public override func clipRect(_ x: Int, _ y: Int, _ w: Int, _ h: Int) {
      let newClip = java.awt.Rectangle(x, y, w, h)
      if let existing = clipLogical {
        // Intersect with existing clip
        let ix = max(existing.x, newClip.x)
        let iy = max(existing.y, newClip.y)
        let ix2 = min(existing.x + existing.width,  newClip.x + newClip.width)
        let iy2 = min(existing.y + existing.height, newClip.y + newClip.height)
        clipLogical = java.awt.Rectangle(ix, iy, max(0, ix2 - ix), max(0, iy2 - iy))
      } else {
        clipLogical = newClip
      }
      applyClip()
    }

    /// Pushes the current `clipLogical` to the GC via `XSetClipRectangles`,
    /// or removes the clip with `XSetClipMask(None)` when `clipLogical` is nil.
    ///
    /// XRectangle is a packed C struct: Int16 x, Int16 y, UInt16 width, UInt16 height (8 bytes).
    /// Coordinates must be in physical (device) pixels, so logical coords are scaled.
    /// clip_x_origin and clip_y_origin are 0 — absolute coords are in the XRectangle itself.
    private func applyClip() {
      if let clip = clipLogical, let fn = fnSetClipRectangles {
        // Physical pixels — apply origin offset (from translate) then scale,
        // clamped to XRectangle's Int16/UInt16 range.
        // Must match the same (x + originX) / (y + originY) pattern used in all draw calls.
        let px = Int16(max(Int32(Int16.min), min(Int32(Int16.max), scaled(clip.x + originX))))
        let py = Int16(max(Int32(Int16.min), min(Int32(Int16.max), scaled(clip.y + originY))))
        let pw = UInt16(min(Int32(UInt16.max), Int32(scaledSize(clip.width))))
        let ph = UInt16(min(Int32(UInt16.max), Int32(scaledSize(clip.height))))
        // XRectangle layout: Int16, Int16, UInt16, UInt16 = 8 bytes
        var rect: (Int16, Int16, UInt16, UInt16) = (px, py, pw, ph)
        withUnsafeBytes(of: &rect) { buf in
          _ = fn(display, gc, 0, 0, buf.baseAddress!, 1, 0 /* Unsorted */)
        }
      } else if let fn = fnSetClipMask {
        // None = 0: remove clip region (draw everywhere)
        _ = fn(display, gc, 0)
      }
    }
  }
}
#endif
