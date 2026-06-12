/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

#if os(Linux) || os(FreeBSD)
#if canImport(Glibc)
import Glibc
#endif

// =============================================================================
// MARK: _X11FontMetrics
// =============================================================================

/// `FontMetrics` implementation for X11 backed by Xft (FreeType/fontconfig).
///
/// Uses `XftTextExtentsUtf8` and `XftFont` ascent/descent fields for accurate
/// measurements that match what `_X11Graphics.drawString` actually renders.
///
/// Loaded lazily via `_X11FontMetrics.make(for:display:)`.
/// Falls back to the headless approximation if libXft is unavailable.
extension java.awt.toolkit.x11 {

  final class _X11FontMetrics: java.awt.FontMetrics {

    // XGlyphInfo layout (from <X11/Xft/Xft.h>):
    //   UShort width, height, x, y, xOff, yOff — all UInt16/Int16, 12 bytes total
    // We only need 'width' (first field).
    private struct XGlyphInfo {
      var width:  UInt16 = 0
      var height: UInt16 = 0
      var x:      Int16  = 0
      var y:      Int16  = 0
      var xOff:   Int16  = 0
      var yOff:   Int16  = 0
    }

    // XftFont has ascent and descent as Int32 at known offsets.
    // We read them via raw pointer because the full XftFont struct is large and
    // platform-specific; ascent/descent are at the very start (after pattern ptr).
    // Actual layout (64-bit): XftPattern*(8), ascent(4), descent(4), height(4), max_advance_width(4)
    // So: ascent at offset 8, descent at offset 12.
    private static let xftAscentOffset  = 8
    private static let xftDescentOffset = 12

    // Resolved Xft function pointers (shared with _X11Graphics — loaded once)
    private typealias XftTextExtentsUtf8Func = @convention(c) (
      UnsafeMutableRawPointer,   // Display*
      UnsafeMutableRawPointer,   // XftFont*
      UnsafePointer<UInt8>,      // FcChar8* string
      Int32,                     // int len
      UnsafeMutableRawPointer    // XGlyphInfo* extents (out)
    ) -> Void

    private let display:              UnsafeMutableRawPointer
    private let xftFont:              UnsafeMutableRawPointer   // XftFont*
    private let fnTextExtentsUtf8:    XftTextExtentsUtf8Func

    private let _ascent:  Int
    private let _descent: Int

    private init(font:               java.awt.Font,
                 display:            UnsafeMutableRawPointer,
                 xftFont:            UnsafeMutableRawPointer,
                 fnTextExtentsUtf8:  XftTextExtentsUtf8Func) {
      self.display           = display
      self.xftFont           = xftFont
      self.fnTextExtentsUtf8 = fnTextExtentsUtf8
      // Read ascent and descent directly from the XftFont struct
      self._ascent  = Int(xftFont.load(fromByteOffset: Self.xftAscentOffset,  as: Int32.self))
      self._descent = Int(xftFont.load(fromByteOffset: Self.xftDescentOffset, as: Int32.self))
      super.init(font)
    }

    // Use headless approximations for vertical metrics — the Xft struct offsets
    // for ascent/descent are not reliable across all libXft versions/platforms.
    // Only stringWidth() (horizontal advance) is taken from Xft.
    // override func getAscent()  -> Int { _ascent  }
    // override func getDescent() -> Int { _descent }

    override func stringWidth(_ str: String) -> Int {
      guard !str.isEmpty else { return 0 }
      let utf8 = Array(str.utf8)
      var extents = XGlyphInfo()
      utf8.withUnsafeBufferPointer { buf in
        withUnsafeMutableBytes(of: &extents) { ext in
          fnTextExtentsUtf8(display, xftFont, buf.baseAddress!, Int32(utf8.count), ext.baseAddress!)
        }
      }
      return Int(extents.xOff)   // xOff = total advance width (not 'width' which is bounding box)
    }

    override func charWidth(_ ch: Character) -> Int {
      stringWidth(String(ch))
    }

    // -------------------------------------------------------------------------
    // MARK: Factory
    // -------------------------------------------------------------------------

    /// Attempts to create an `_X11FontMetrics` for `font` backed by Xft.
    /// Returns `nil` if libXft or the required symbols are unavailable.
    static func make(for font: java.awt.Font,
                     display: UnsafeMutableRawPointer) -> _X11FontMetrics? {
      // Load libXft (should already be open from _X11Graphics.resolveSymbols,
      // but dlopen with RTLD_NOLOAD | RTLD_LAZY lets us get the handle cheaply
      // if it's already loaded, or returns nil if not).
      // Use numeric constants for RTLD flags — symbolic names are inaccessible
      // under MUSL (static Linux builds) even when Glibc is importable.
      let rtldLazy:   CInt = 0x00001   // RTLD_LAZY
      let rtldNoLoad: CInt = 0x00004   // RTLD_NOLOAD
      var xftLib: UnsafeMutableRawPointer? = nil
      for name in ["libXft.so.2", "libXft.so"] {
        xftLib = dlopen(name, rtldLazy | rtldNoLoad)
        if xftLib != nil { break }
      }
      // If RTLD_NOLOAD failed (library was opened with a different path), try a fresh open
      if xftLib == nil {
        for name in ["libXft.so.2", "libXft.so"] {
          xftLib = dlopen(name, rtldLazy)
          if xftLib != nil { break }
        }
      }
      guard let lib = xftLib else { return nil }

      // Resolve XftFontOpenName and XftTextExtentsUtf8
      typealias XftFontOpenNameFunc = @convention(c) (UnsafeMutableRawPointer, Int32, UnsafePointer<CChar>) -> UnsafeMutableRawPointer?
      guard let rawOpen = dlsym(lib, "XftFontOpenName"),
            let rawExt  = dlsym(lib, "XftTextExtentsUtf8") else { return nil }

      let fnOpen = unsafeBitCast(rawOpen, to: XftFontOpenNameFunc.self)
      let fnExt  = unsafeBitCast(rawExt,  to: XftTextExtentsUtf8Func.self)

      // Also need XDefaultScreen
      typealias XDefaultScreenFunc = @convention(c) (UnsafeMutableRawPointer) -> Int32
      guard let rawScreen = dlsym(lib, "XDefaultScreen") ?? dlsym(dlopen(nil, 0x00001), "XDefaultScreen"),
            let fnScreen  = Optional(unsafeBitCast(rawScreen, to: XDefaultScreenFunc.self)) else { return nil }

      let screen  = fnScreen(display)
      let pixelSize = max(8, Int((Double(font.getSize()) * _X11WindowHost.shared.scaleFactor).rounded()))
      let pattern = "sans-serif:pixelsize=\(pixelSize)"
      guard let xftFont = pattern.withCString({ fnOpen(display, screen, $0) }) else { return nil }

      return _X11FontMetrics(font: font, display: display, xftFont: xftFont, fnTextExtentsUtf8: fnExt)
    }
  }
}

#endif
