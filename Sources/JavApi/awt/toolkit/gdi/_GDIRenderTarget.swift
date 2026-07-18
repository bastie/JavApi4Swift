/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

#if os(Windows)
import WinSDK

// =============================================================================
// MARK: Win32 macro replacements
// =============================================================================

@inline(__always) private func _LOWORD(_ v: DWORD_PTR) -> WORD { WORD(v & 0xFFFF) }
@inline(__always) private func _HIWORD(_ v: DWORD_PTR) -> WORD { WORD((v >> 16) & 0xFFFF) }

// =============================================================================
// MARK: _GDIRenderTarget — java.awt.Graphics backed by a Win32 HDC
// =============================================================================

extension java.awt.toolkit.gdi {

  /// `java.awt.Graphics` subclass that routes all drawing calls to GDI.
  ///
  /// On Windows `CGContext` is the stub protocol from `Graphics.swift`;
  /// `_StubCGContext()` satisfies `super.init()` while real drawing uses `hdc`.
  ///
  /// Note: `open` (not `final`) so `java.awt.Graphics2D` (Graphics2D+GDI.swift)
  /// can subclass it and reuse the HDC, color/font handling, and primitive
  /// draw calls instead of duplicating them.
  open class _GDIRenderTarget: java.awt.Graphics {

    // `internal` (not `private`): java.awt.Graphics2D lives in a different
    // file and needs these to manage its own stroke-width pen and clip
    // region without duplicating the base HDC/pen bookkeeping.
    internal let hdc: HDC

    // Current GDI pen/brush (replaced on setColor)
    internal var hPen:    HPEN?
    private var hBrush:  HBRUSH?
    internal var oldPen:  HGDIOBJ?
    private var oldBrush: HGDIOBJ?

    public init(hdc: HDC) {
      self.hdc = hdc
      super.init(java.awt._StubCGContext())
      applyColor(java.awt.Color.black)
      applyFont(font)
    }

    deinit {
      if let op = oldPen   { SelectObject(hdc, op) }
      if let ob = oldBrush { SelectObject(hdc, ob) }
      if let p = hPen   { DeleteObject(p) }
      if let b = hBrush { DeleteObject(b) }
    }

    // ── Color ────────────────────────────────────────────────────────────────

    public override func setColor(_ color: java.awt.Color) {
      applyColor(color)
    }

    private func applyColor(_ color: java.awt.Color) {
      let r = BYTE(color.getRed())
      let g = BYTE(color.getGreen())
      let b = BYTE(color.getBlue())
      let colorRef = COLORREF(DWORD(r) | (DWORD(g) << 8) | (DWORD(b) << 16))

      // Replace pen
      if let op = oldPen   { SelectObject(hdc, op) }
      if let p  = hPen     { DeleteObject(p) }
      if let newPen = CreatePen(PS_SOLID, 1, colorRef) {
        oldPen = SelectObject(hdc, newPen)
        hPen   = newPen
      }

      // Replace solid brush
      if let ob = oldBrush { SelectObject(hdc, ob) }
      if let br = hBrush   { DeleteObject(br) }
      if let newBrush = CreateSolidBrush(colorRef) {
        oldBrush = SelectObject(hdc, newBrush)
        hBrush   = newBrush
      }

      // Text foreground color
      SetTextColor(hdc, colorRef)
    }

    // ── Font ─────────────────────────────────────────────────────────────────

    public override func setFont(_ f: java.awt.Font) {
      super.setFont(f)
      applyFont(f)
    }

    private func applyFont(_ f: java.awt.Font) {
      // GDI logical units are in device pixels; negative = character height
      let hFont = f.platformName.withCString(encodedAs: UTF16.self) { namePtr in
        CreateFontW(
          -LONG(f.size),          // height (negative = em size)
          0,                       // width  (0 = auto)
          0,                       // escapement
          0,                       // orientation
          (f.style & java.awt.Font.BOLD)   != 0 ? FW_BOLD   : FW_NORMAL,
          (f.style & java.awt.Font.ITALIC) != 0 ? DWORD(1)  : DWORD(0),
          0,                       // underline
          0,                       // strikeout
          DWORD(DEFAULT_CHARSET),
          DWORD(OUT_DEFAULT_PRECIS),
          DWORD(CLIP_DEFAULT_PRECIS),
          DWORD(DEFAULT_QUALITY),
          DWORD(DEFAULT_PITCH | FF_DONTCARE),
          namePtr)
      }
      if let hf = hFont { SelectObject(hdc, hf) }
    }

    // ── Shapes ───────────────────────────────────────────────────────────────

    public override func fillRect(_ x: Int, _ y: Int, _ w: Int, _ h: Int) {
      // FillRect ignores SetViewportOrgEx — use Rectangle with a null pen instead,
      // which does respect the viewport origin like all other GDI drawing functions.
      guard w > 0, h > 0 else { return }
      let nullPen = GetStockObject(NULL_PEN)
      let old = SelectObject(hdc, nullPen)
      // Rectangle draws outline+fill; to get exact w×h fill without a 1px border,
      // draw to (x+w+1, y+h+1) with null pen so the outline falls outside.
      Rectangle(hdc, LONG(x), LONG(y), LONG(x + w + 1), LONG(y + h + 1))
      SelectObject(hdc, old)
    }

    public override func drawRect(_ x: Int, _ y: Int, _ w: Int, _ h: Int) {
      // GDI Rectangle draws outline with current pen, fills with current brush
      // We want outline only → use a null brush
      let nullBrush = GetStockObject(NULL_BRUSH)
      let old = SelectObject(hdc, nullBrush)
      Rectangle(hdc, LONG(x), LONG(y), LONG(x + w), LONG(y + h))
      SelectObject(hdc, old)
    }

    public override func drawLine(_ x1: Int, _ y1: Int, _ x2: Int, _ y2: Int) {
      MoveToEx(hdc, LONG(x1), LONG(y1), nil)
      LineTo(hdc, LONG(x2), LONG(y2))
    }

    public override func fillOval(_ x: Int, _ y: Int, _ w: Int, _ h: Int) {
      let nullPen = GetStockObject(NULL_PEN)
      let old = SelectObject(hdc, nullPen)
      Ellipse(hdc, LONG(x), LONG(y), LONG(x + w), LONG(y + h))
      SelectObject(hdc, old)
    }

    public override func drawOval(_ x: Int, _ y: Int, _ w: Int, _ h: Int) {
      let nullBrush = GetStockObject(NULL_BRUSH)
      let old = SelectObject(hdc, nullBrush)
      Ellipse(hdc, LONG(x), LONG(y), LONG(x + w), LONG(y + h))
      SelectObject(hdc, old)
    }

    // ── Text ─────────────────────────────────────────────────────────────────

    public override func drawString(_ str: String, _ x: Int, _ y: Int) {
      // GDI TextOut origin is top-left of the character cell; AWT passes baseline.
      // Shift up by ascent so baseline aligns.
      let ascent = getFontMetrics().getAscent()
      SetBkMode(hdc, Int32(1))  // TRANSPARENT = 1
      let wide = Array(str.utf16)
      _ = wide.withUnsafeBufferPointer { buf in
        TextOutW(hdc, LONG(x), LONG(y - ascent), buf.baseAddress!, INT(wide.count))
      }
    }

    // ── Polygon ──────────────────────────────────────────────────────────────

    public override func drawPolygon(_ xpoints: [Int], _ ypoints: [Int],
                                      _ npoints: Int) {
      let pts = (0..<npoints).map { POINT(x: LONG(xpoints[$0]), y: LONG(ypoints[$0])) }
      pts.withUnsafeBufferPointer { buf in
        Polyline(hdc, buf.baseAddress!, INT(npoints))
        // Close the polygon manually
        if npoints >= 2 {
          MoveToEx(hdc, LONG(xpoints[npoints-1]), LONG(ypoints[npoints-1]), nil)
          LineTo(hdc, LONG(xpoints[0]), LONG(ypoints[0]))
        }
      }
    }

    public override func fillPolygon(_ xpoints: [Int], _ ypoints: [Int],
                                      _ npoints: Int) {
      let pts = (0..<npoints).map { POINT(x: LONG(xpoints[$0]), y: LONG(ypoints[$0])) }
      pts.withUnsafeBufferPointer { buf in
        let nullPen = GetStockObject(NULL_PEN)
        let old = SelectObject(hdc, nullPen)
        SetPolyFillMode(hdc, Int32(WINDING))
        Polygon(hdc, buf.baseAddress!, INT(npoints))
        SelectObject(hdc, old)
      }
    }

    // ── Image ────────────────────────────────────────────────────────────────

    @discardableResult
    public override func drawImage(_ img: java.awt.Image, _ x: Int, _ y: Int,
                                    _ observer: java.awt.ImageObserver? = nil) -> Bool {
      guard let bi = img as? java.awt.image.BufferedImage else { return false }
      return blitBitmap(bi, dx: x, dy: y, dw: bi.getWidth(nil), dh: bi.getHeight(nil))
    }

    @discardableResult
    public override func drawImage(_ img: java.awt.Image,
                                    _ x: Int, _ y: Int, _ w: Int, _ h: Int,
                                    _ observer: java.awt.ImageObserver? = nil) -> Bool {
      guard let bi = img as? java.awt.image.BufferedImage else { return false }
      return blitBitmap(bi, dx: x, dy: y, dw: w, dh: h)
    }

    private func blitBitmap(_ bi: java.awt.image.BufferedImage,
                              dx: Int, dy: Int, dw: Int, dh: Int) -> Bool {
      let sw = bi.getWidth(nil), sh = bi.getHeight(nil)
      guard sw > 0, sh > 0 else { return false }

      // Build BITMAPINFO for a top-down 32bpp DIB
      var bmi = BITMAPINFO()
      bmi.bmiHeader.biSize        = DWORD(MemoryLayout<BITMAPINFOHEADER>.size)
      bmi.bmiHeader.biWidth       = LONG(sw)
      bmi.bmiHeader.biHeight      = -LONG(sh)  // negative = top-down
      bmi.bmiHeader.biPlanes      = 1
      bmi.bmiHeader.biBitCount    = 32
      bmi.bmiHeader.biCompression = DWORD(BI_RGB)

      // Pack ARGB → premultiplied BGRA (required by AlphaBlend)
      var pixels = [UInt8](repeating: 0, count: sw * sh * 4)
      for row in 0..<sh {
        for col in 0..<sw {
          let argb = bi.getRGB(col, row)
          let i    = (row * sw + col) * 4
          let a    = UInt32((argb >> 24) & 0xFF)
          // Premultiply each channel by alpha/255
          pixels[i+0] = UInt8((UInt32((argb >>  0) & 0xFF) * a + 127) / 255)  // B
          pixels[i+1] = UInt8((UInt32((argb >>  8) & 0xFF) * a + 127) / 255)  // G
          pixels[i+2] = UInt8((UInt32((argb >> 16) & 0xFF) * a + 127) / 255)  // R
          pixels[i+3] = UInt8(a)                                                // A
        }
      }

      let memDC = CreateCompatibleDC(hdc)
      defer { DeleteDC(memDC) }

      var bits: UnsafeMutableRawPointer? = nil
      let hBmp = CreateDIBSection(memDC, &bmi, UINT(DIB_RGB_COLORS), &bits, nil, 0)
      guard let hBmp, let bits else { return false }
      defer { DeleteObject(hBmp) }

      pixels.withUnsafeBytes { raw in
        bits.copyMemory(from: raw.baseAddress!, byteCount: sw * sh * 4)
      }

      let old = SelectObject(memDC, hBmp)
      defer { SelectObject(memDC, old) }

      // AlphaBlend respects per-pixel alpha; AC_SRC_ALPHA = premultiplied source.
      // Loaded dynamically to avoid a hard link against Msimg32.lib.
      var bf = BLENDFUNCTION()
      bf.BlendOp             = BYTE(AC_SRC_OVER)
      bf.BlendFlags          = 0
      bf.SourceConstantAlpha = 255
      bf.AlphaFormat         = BYTE(AC_SRC_ALPHA)

      typealias AlphaBlendFn = @convention(c) (
        HDC, INT, INT, INT, INT,
        HDC, INT, INT, INT, INT,
        BLENDFUNCTION) -> WindowsBool

      if let hMsimg = LoadLibraryA("Msimg32.dll"),
         let raw = GetProcAddress(hMsimg, "AlphaBlend"),
         let memDCUnwrapped = memDC {
        let fn = unsafeBitCast(raw, to: AlphaBlendFn.self)
        _ = fn(hdc, INT(dx), INT(dy), INT(dw), INT(dh),
               memDCUnwrapped, 0, 0, INT(sw), INT(sh), bf)
        FreeLibrary(hMsimg)
      } else {
        // Fallback: opaque blit (no transparency)
        StretchBlt(hdc, LONG(dx), LONG(dy), LONG(dw), LONG(dh),
                   memDC, 0, 0, LONG(sw), LONG(sh), SRCCOPY)
      }
      return true
    }

    // ── Graphics state (save/restore/clip/translate) ─────────────────────────

    public override func save() {
      SaveDC(hdc)
    }

    public override func restore() {
      RestoreDC(hdc, -1)
    }

    public override func clipRect(_ x: Int, _ y: Int, _ w: Int, _ h: Int) {
      // IntersectClipRect works in logical coordinates and automatically
      // respects the current viewport origin set by SetViewportOrgEx.
      // This is the idiomatic GDI clipping call — no manual device-coordinate
      // conversion needed.
      IntersectClipRect(hdc, LONG(x), LONG(y), LONG(x + w), LONG(y + h))
    }

    public override func translate(_ dx: Int, _ dy: Int) {
      // Move the viewport origin so subsequent drawing calls are offset.
      // Clip regions are in device (absolute) coords and must NOT be shifted —
      // they were set before the translate and should remain fixed in screen space.
      var pt = POINT(x: 0, y: 0)
      GetViewportOrgEx(hdc, &pt)
      SetViewportOrgEx(hdc, pt.x + LONG(dx), pt.y + LONG(dy), nil)
    }
  }
}

#endif  // os(Windows)
