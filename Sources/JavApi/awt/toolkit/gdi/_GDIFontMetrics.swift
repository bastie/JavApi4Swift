/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

#if os(Windows)
import WinSDK

extension java.awt.toolkit.gdi {

  /// `java.awt.FontMetrics` backed by GDI `GetTextExtentPoint32W` and
  /// `GetTextMetricsW`.  Measurements are exact for the logical font that GDI
  /// selects for a given `java.awt.Font`.
  final class _GDIFontMetrics: java.awt.FontMetrics {

    // Cached metrics retrieved once from a temporary memory DC.
    private let ascent:   Int
    private let descent:  Int
    private let leading:  Int

    override init(_ font: java.awt.Font) {
      // Bootstrap with zero so the superclass designated init can run first.
      var a = 0, d = 0, l = 0

      // Create a temporary off-screen DC to query GDI metrics without a window.
      if let memDC = CreateCompatibleDC(nil) {
        if let hFont = _GDIFontMetrics.createHFont(font) {
          let old = SelectObject(memDC, hFont)
          var tm = TEXTMETRICW()
          if GetTextMetricsW(memDC, &tm) {
            a = Int(tm.tmAscent)
            d = Int(tm.tmDescent)
            l = Int(tm.tmExternalLeading)
          }
          SelectObject(memDC, old)
          DeleteObject(hFont)
        }
        DeleteDC(memDC)
      }

      ascent  = a
      descent = d
      leading = l
      super.init(font)
    }

    // ── Metrics ──────────────────────────────────────────────────────────────

    override func getAscent()   -> Int { ascent  }
    override func getDescent()  -> Int { descent }
    override func getLeading()  -> Int { leading }

    override func stringWidth(_ str: String) -> Int {
      guard !str.isEmpty else { return 0 }
      guard let memDC = CreateCompatibleDC(nil) else {
        return super.stringWidth(str)
      }
      defer { DeleteDC(memDC) }
      guard let hFont = _GDIFontMetrics.createHFont(font) else {
        return super.stringWidth(str)
      }
      let old = SelectObject(memDC, hFont)
      defer { SelectObject(memDC, old); DeleteObject(hFont) }

      let wide = Array(str.utf16)
      var size = SIZE()
      guard GetTextExtentPoint32W(memDC, wide, INT(wide.count), &size) else {
        return super.stringWidth(str)
      }
      return Int(size.cx)
    }

    override func charWidth(_ ch: Character) -> Int {
      stringWidth(String(ch))
    }

    // ── Helper ───────────────────────────────────────────────────────────────

    static func createHFont(_ f: java.awt.Font) -> HFONT? {
      f.platformName.withCString(encodedAs: UTF16.self) { namePtr in
        CreateFontW(
          -LONG(f.size),
          0, 0, 0,
          (f.style & java.awt.Font.BOLD)   != 0 ? FW_BOLD   : FW_NORMAL,
          (f.style & java.awt.Font.ITALIC) != 0 ? DWORD(1)  : DWORD(0),
          0, 0,
          DWORD(DEFAULT_CHARSET),
          DWORD(OUT_DEFAULT_PRECIS),
          DWORD(CLIP_DEFAULT_PRECIS),
          DWORD(DEFAULT_QUALITY),
          DWORD(DEFAULT_PITCH | FF_DONTCARE),
          namePtr)
      }
    }
  }
}
#endif  // os(Windows)
