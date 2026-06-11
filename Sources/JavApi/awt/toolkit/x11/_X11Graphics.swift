/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

#if os(Linux) || os(FreeBSD)
import Glibc

// X11 GC function signatures (subset needed for rendering)
private typealias XDrawLineFunc      = @convention(c) (UnsafeMutableRawPointer, UInt, UnsafeMutableRawPointer, Int32, Int32, Int32, Int32) -> Int32
private typealias XDrawRectangleFunc = @convention(c) (UnsafeMutableRawPointer, UInt, UnsafeMutableRawPointer, Int32, Int32, UInt32, UInt32) -> Int32
private typealias XFillRectangleFunc = @convention(c) (UnsafeMutableRawPointer, UInt, UnsafeMutableRawPointer, Int32, Int32, UInt32, UInt32) -> Int32
private typealias XDrawStringFunc    = @convention(c) (UnsafeMutableRawPointer, UInt, UnsafeMutableRawPointer, Int32, Int32, UnsafePointer<CChar>, Int32) -> Int32
private typealias XSetForegroundFunc = @convention(c) (UnsafeMutableRawPointer, UnsafeMutableRawPointer, UInt) -> Int32

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

    private let display:  UnsafeMutableRawPointer   // X11 Display*
    private let drawable: UInt                      // X11 Window (XID)
    private let gc:       UnsafeMutableRawPointer   // X11 GC

    // Lazily resolved function pointers — loaded from the already-open libX11
    private var fnDrawLine:      XDrawLineFunc?
    private var fnDrawRect:      XDrawRectangleFunc?
    private var fnFillRect:      XFillRectangleFunc?
    private var fnDrawString:    XDrawStringFunc?
    private var fnSetForeground: XSetForegroundFunc?

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
                gc: UnsafeMutableRawPointer) {
      self.display  = display
      self.drawable = drawable
      self.gc       = gc
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
      fnDrawString    = r("XDrawString")
      fnSetForeground = r("XSetForeground")
      dlclose(lib)
    }

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
                      Int32(x1 + originX), Int32(y1 + originY),
                      Int32(x2 + originX), Int32(y2 + originY))
    }

    public override func drawRect(_ x: Int, _ y: Int, _ width: Int, _ height: Int) {
      guard width > 0 && height > 0 else { return }
      applyColor()
      _ = fnDrawRect?(display, drawable, gc,
                      Int32(x + originX), Int32(y + originY),
                      UInt32(width), UInt32(height))
    }

    public override func fillRect(_ x: Int, _ y: Int, _ width: Int, _ height: Int) {
      guard width > 0 && height > 0 else { return }
      applyColor()
      _ = fnFillRect?(display, drawable, gc,
                      Int32(x + originX), Int32(y + originY),
                      UInt32(width), UInt32(height))
    }

    public func clearRect(_ x: Int, _ y: Int, _ width: Int, _ height: Int) {
      let saved = currentColor
      setColor(backgroundColor)
      fillRect(x, y, width, height)
      setColor(saved)
    }

    public override func drawString(_ str: String, _ x: Int, _ y: Int) {
      applyColor()
      _ = str.withCString { cstr in
        fnDrawString?(display, drawable, gc,
                      Int32(x + originX), Int32(y + originY),
                      cstr, Int32(str.utf8.count))
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
