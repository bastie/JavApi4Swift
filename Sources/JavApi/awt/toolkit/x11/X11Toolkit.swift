/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

#if os(Linux) || os(FreeBSD)
import Glibc

extension java.awt.toolkit.x11 {

  /// X11 toolkit for Linux and FreeBSD.
  ///
  /// Mirrors `java.awt.toolkit.gdi.GDIToolkit` for X11 platforms.
  /// Window lifecycle is delegated to `_X11WindowHost`.
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
      // Dialogs: for now treat like a regular window (modal loop not yet implemented)
      _X11WindowHost.shared.openWindow(for: window)
    }

    public override func hide(_ window: java.awt.Window) {
      _X11WindowHost.shared.hide(window)
    }

    public override func attachMenuBar(_ menuBar: java.awt.MenuBar?,
                                       to frame: java.awt.Frame) {
      // TODO: Implement native menu bar via X11/Motif hints or a custom rendered menu
    }

    public override func showPopupMenu(_ menu: java.awt.PopupMenu,
                                       origin: java.awt.Component,
                                       x: Int, y: Int) {
      // TODO: Implement popup menu rendering
    }

    public override func isFocusOwner(_ component: java.awt.Component) -> Bool {
      return _X11FocusManager.shared.focusOwner === component
    }

    public override func closeDialog(_ dialog: java.awt.Dialog) {
      hide(dialog)
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

    /// Returns 96 dpi — Linux/X11 conventional baseline.
    ///
    /// TODO: Query via `XGetDefault(display, "Xft", "dpi")` for HiDPI support.
    public override func getScreenResolution() -> Int {
      return 96
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
      let len = Glibc.readlink("/proc/self/exe", &buf, buf.count - 1)
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
