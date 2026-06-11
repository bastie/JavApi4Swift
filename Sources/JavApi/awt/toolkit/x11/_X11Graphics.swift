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
private typealias XDefaultVisualFunc     = @convention(c) (UnsafeMutableRawPointer, Int32) -> UnsafeMutableRawPointer?
// XDefaultColormap returns an XID (unsigned long), not a pointer
private typealias XDefaultColormapFunc   = @convention(c) (UnsafeMutableRawPointer, Int32) -> UInt
private typealias XDefaultScreenFunc2    = @convention(c) (UnsafeMutableRawPointer) -> Int32

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
    private var fnXftDrawStringUtf8: XftDrawStringUtf8Func?
    private var fnXftColorAllocValue:XftColorAllocValueFunc?
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
      // Works on glibc and dynamic MUSL
      #if canImport(Glibc)
      guard let lib = dlopen(nil, RTLD_LAZY) else { return }
      #else
      guard let lib = dlopen(nil, 0x00001) else {
        print("[X11Graphics] WARNING: dlopen() failed (may be static MUSL build).")
        return
      }
      #endif
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
      fnCreateFontSet  = r("XCreateFontSet")
      fnFreeFontSet    = r("XFreeFontSet")
      fnUtf8DrawString = r("Xutf8DrawString")
      _ = dlclose(lib)
      // Load Xft from libXft — separate library from libX11
      let xftCandidates = ["libXft.so.2", "libXft.so"]
      let xftFlags: CInt
      #if canImport(Glibc)
      xftFlags = RTLD_LAZY
      #else
      xftFlags = 0x00001
      #endif
      for name in xftCandidates {
        if let xftLib = dlopen(name, xftFlags) {
          func rx<F>(_ sym: String) -> F? {
            guard let raw = dlsym(xftLib, sym) else { return nil }
            return unsafeBitCast(raw, to: F.self)
          }
          fnXftDrawCreate      = rx("XftDrawCreate")
          fnXftDrawDestroy     = rx("XftDrawDestroy")
          fnXftFontOpenName    = rx("XftFontOpenName")
          fnXftFontClose       = rx("XftFontClose")
          fnXftDrawStringUtf8  = rx("XftDrawStringUtf8")
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
