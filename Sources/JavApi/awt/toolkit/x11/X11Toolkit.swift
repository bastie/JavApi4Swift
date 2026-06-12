/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

#if os(Linux) || os(FreeBSD)
#if canImport(Glibc)
import Glibc
#endif
import Dispatch

// TODO: Test X11 toolkit on MUSL systems (Alpine Linux, etc.)
//
// Current status:
// - glibc systems (Debian, Ubuntu, Fedora, etc.): Fully tested ✓
// - Dynamic MUSL systems (Alpine): Code path exists, untested in practice
// - Static MUSL builds: Will compile but fail at runtime (dlopen unavailable)
//
// Required testing:
// 1. Build on Alpine Linux (dynamic MUSL):
//    `swift build --target AWTShowcase`
//    Expected: X11 toolkit loads, dlopen succeeds, X11 display works
//
// 2. Build static MUSL binary:
//    `swift build --target AWTShowcase --swift-sdk swift-6.3.2-RELEASE_static-linux-*`
//    Expected: Binary compiles, but X11Toolkit.runEventLoop() fails at runtime
//    Error message: "[X11Toolkit] ERROR: dlopen() unavailable (static MUSL build)"
//
// 3. Verify locale handling (setlocale) works on MUSL
//    Should work via @_silgen_name declarations
//
// See: _X11WindowHost.swift loadLibrary() and _X11Graphics.swift resolveSymbols()

extension java.awt.toolkit.x11 {

  /// X11 toolkit for Linux and FreeBSD.
  ///
  /// Mirrors `java.awt.toolkit.gdi.GDIToolkit` for X11 platforms.
  /// Window lifecycle is delegated to `_X11WindowHost`.
  ///
  /// Platform support:
  /// - **glibc** (Linux, FreeBSD): Fully supported ✓
  /// - **MUSL dynamic** (Alpine): Code implemented, needs real-system testing
  /// - **MUSL static**: Partial support (POSIX functions work, X11 dlopen may fail)
  ///
  /// Activate by setting the system property before any AWT code:
  /// ```swift
  /// try? System.setProperty("awt.toolkit", "X11")
  /// ```
  @MainActor
  public final class X11Toolkit: java.awt.Toolkit {

    public static let shared = X11Toolkit()
    private override init() {}

    // -------------------------------------------------------------------------
    // MARK: Window lifecycle
    // -------------------------------------------------------------------------

    public override func show(_ window: java.awt.Window) {
      // FileDialog manages its own native panel — skip here
      if window is java.awt.FileDialog { return }
      // openWindow blocks for modal dialogs until closeDialog() is called
      _X11WindowHost.shared.openWindow(for: window)
    }

    public override func hide(_ window: java.awt.Window) {
      _X11WindowHost.shared.hide(window)
    }

    public override func attachMenuBar(_ menuBar: java.awt.MenuBar?,
                                       to frame: java.awt.Frame) {
      _X11WindowHost.shared.attachMenuBar(menuBar, to: frame)
    }

    public override func showPopupMenu(_ menu: java.awt.PopupMenu,
                                       origin: java.awt.Component,
                                       x: Int, y: Int) {
      let screenX = origin.getX() + x
      let screenY = origin.getY() + y
      _X11PopupWindow.show(menu: menu, at: screenX, y: screenY,
                           host: _X11WindowHost.shared, ownerXwin: 0,
                           ownerWindow: nil)
    }

    public override func repaint(_ window: java.awt.Window) {
      _X11WindowHost.shared.repaintWindow(window)
    }

    public override func isFocusOwner(_ component: java.awt.Component) -> Bool {
      return _X11FocusManager.shared.focusOwner === component
    }

    public override func closeDialog(_ dialog: java.awt.Dialog) {
      _X11WindowHost.shared.closeDialog(dialog)
    }

    // -------------------------------------------------------------------------
    // MARK: Application lifecycle
    // -------------------------------------------------------------------------

    /// Opens `frame` and spins the X11 event loop until the application exits.
    public override func run(frame: java.awt.Frame) {
      frame.setVisible(true)
      runEventLoop()
    }

    /// Drains pending `EventQueue` runnables and spins the X11 event loop.
    public override func runEventLoop() {
      _X11WindowHost.shared.runEventLoop()
    }

    /// Terminates the application by signalling the X11 event loop to exit.
    public override func terminate() {
      _X11WindowHost.shared.terminate()
    }

    // -------------------------------------------------------------------------
    // MARK: Screen properties
    // -------------------------------------------------------------------------

    /// Returns the primary screen size.
    ///
    /// TODO: Query via `XDisplayWidth` / `XDisplayHeight` for accurate values.
    public override func getScreenSize() -> java.awt.Dimension {
      return java.awt.Dimension(0, 0)
    }

    /// Returns the screen resolution in dpi, derived from Xft.dpi.
    ///
    /// On HiDPI displays (e.g. 192 dpi) this returns the actual value so that
    /// font metrics and size calculations reflect the physical display density.
    public override func getScreenResolution() -> Int {
      return Int(96.0 * _X11WindowHost.shared.scaleFactor)
    }

    // -------------------------------------------------------------------------
    // MARK: Font list
    // -------------------------------------------------------------------------

    /// Returns system font family names.
    ///
    /// TODO: Implement via `fc-list` (fontconfig) or `XListFonts`.
    public override func getFontList() -> [String] {
      return super.getFontList()
    }

    /// Returns Xft-backed font metrics when a display is open, falling back to
    /// headless approximation otherwise.  Used by `FontMetrics.make(for:)` so
    /// that hit-testing and caret positioning agree with actual X11 rendering.
    public override func getFontMetrics(_ font: java.awt.Font) -> java.awt.FontMetrics {
      if let dpy = _X11WindowHost.shared.currentDisplay,
         let xft = _X11FontMetrics.make(for: font, display: dpy) {
        return xft
      }
      return super.getFontMetrics(font)
    }

    // -------------------------------------------------------------------------
    // MARK: Image loading
    // -------------------------------------------------------------------------

    /// Loads a PNG by name relative to the running executable.
    ///
    /// Search order:
    ///   1. `<exe-dir>/<name>.png`
    ///   2. `<exe-dir>/../../../../Sources/AWTShowcase/Assets.xcassets/AppIcon.appiconset/<name>.png`
    ///      (works when running via `swift run` from the package root)
    public override func loadImage(named name: String) -> java.awt.Image? {
      // Resolve executable directory via /proc/self/exe (Linux) or sysctl (FreeBSD)
      var exeDir = "."
      #if os(Linux)
      var buf = [CChar](repeating: 0, count: 4096)
      let len = readlink("/proc/self/exe", &buf, buf.count - 1)
      if len > 0 {
        let fullPath = buf.withUnsafeBufferPointer {
          String(bytes: $0.prefix(while: { $0 != 0 }).map { UInt8(bitPattern: $0) }, encoding: .utf8) ?? ""
        }
        if let lastSlash = fullPath.lastIndex(of: "/") {
          exeDir = String(fullPath[fullPath.startIndex ..< lastSlash])
        }
      }
      #endif

      let xcassets = "Assets.xcassets/AppIcon.appiconset/\(name).png"
      let candidates: [String] = [
        "\(exeDir)/\(name).png",
        "\(exeDir)/../../../../Sources/AWTShowcase/\(xcassets)",
        "Sources/AWTShowcase/\(xcassets)",
      ]

      for path in candidates {
        if let img = _X11PNGLoader.load(path: path) { return img }
      }
      return nil
    }

    // -------------------------------------------------------------------------
    // MARK: Color model
    // -------------------------------------------------------------------------

    public override func getColorModel() -> java.awt.image.ColorModel {
      return java.awt.image.ColorModel.getRGBdefault()
    }
  }
}
#endif
