/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

#if os(Windows)
import WinSDK

extension java.awt.toolkit.gdi {

  /// Windows GDI toolkit.
  ///
  /// Mirrors `java.awt.toolkit.swiftui.SwiftUIToolkit` for the Windows platform.
  /// Window lifecycle is delegated to `_Win32WindowHost`.
  @MainActor
  public final class GDIToolkit: java.awt.Toolkit {

    public static let shared = GDIToolkit()
    private override init() {}

    // -------------------------------------------------------------------------
    // MARK: Window lifecycle
    // -------------------------------------------------------------------------

    public override func show(_ window: java.awt.Window) {
      // FileDialog manages its own native panel — skip here
      if window is java.awt.FileDialog { return }
      if let dialog = window as? java.awt.Dialog {
        _Win32WindowHost.shared.openDialog(dialog)
        return
      }
      _Win32WindowHost.shared.openWindow(for: window)
    }

    public override func hide(_ window: java.awt.Window) {
      _Win32WindowHost.shared.hide(window)
    }

    public override func attachMenuBar(_ menuBar: java.awt.MenuBar?,
                                       to frame: java.awt.Frame) {
      _Win32WindowHost.shared.attachMenuBar(menuBar, to: frame)
    }

    public override func showPopupMenu(_ menu: java.awt.PopupMenu,
                                       origin: java.awt.Component,
                                       x: Int, y: Int) {
      _Win32WindowHost.shared.showPopupMenu(menu, origin: origin, x: x, y: y)
    }

    public override func isFocusOwner(_ component: java.awt.Component) -> Bool {
      return _Win32FocusManager.shared.focusOwner === component
    }

    public override func closeDialog(_ dialog: java.awt.Dialog) {
      _Win32WindowHost.shared.closeDialog(dialog)
    }

    // -------------------------------------------------------------------------
    // MARK: Application lifecycle
    // -------------------------------------------------------------------------

    /// Opens `frame` and spins the Win32 message loop until the application exits.
    ///
    /// This method does not return until `PostQuitMessage` is called (e.g. from
    /// `terminate()` or when the last window is destroyed).
    ///
    /// - Since: JavaApi > 0.19.1
    public override func run(frame: java.awt.Frame) {
      frame.setVisible(true)
      runEventLoop()
    }

    /// Drains pending `EventQueue` runnables and spins the Win32 message loop.
    /// - Since: JavaApi > 0.19.1
    public override func runEventLoop() {
      java.awt.EventQueue.drainAndMarkRunning()
      var msg = MSG()
      while GetMessageW(&msg, nil, 0, 0) {
        TranslateMessage(&msg)
        DispatchMessageW(&msg)
      }
    }

    /// Terminates the application by posting `WM_QUIT` to the Win32 message
    /// loop started in `run(frame:)`.
    ///
    /// - Since: JavaApi > 0.19.1
    public override func terminate() {
      PostQuitMessage(0)
    }

    // -------------------------------------------------------------------------
    // MARK: Screen properties
    // -------------------------------------------------------------------------

    /// Returns the primary monitor's size in pixels via Win32 `GetSystemMetrics`.
    ///
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    public override func getScreenSize() -> java.awt.Dimension {
      let w = Int(GetSystemMetrics(SM_CXSCREEN))
      let h = Int(GetSystemMetrics(SM_CYSCREEN))
      return java.awt.Dimension(w, h)
    }

    /// Returns the screen resolution in dots-per-inch via `GetDpiForSystem()`.
    ///
    /// Windows baseline is 96 dpi (unlike macOS which uses 72).
    ///
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    public override func getScreenResolution() -> Int {
      return Int(GetDpiForSystem())
    }

    // -------------------------------------------------------------------------
    // MARK: Font list
    // -------------------------------------------------------------------------

    /// Returns system font family names via `EnumFontFamiliesExW`.
    ///
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    public override func getFontList() -> [String] {
      var families: [String] = []
      var lf = LOGFONTW()
      lf.lfCharSet = BYTE(DEFAULT_CHARSET)
      let dc = GetDC(nil)
      defer { ReleaseDC(nil, dc) }
      withUnsafeMutablePointer(to: &lf) { lfPtr in
        withUnsafeMutablePointer(to: &families) { familiesPtr in
          let callback: FONTENUMPROCW = { logFont, _, _, lParam in
            guard let lf = logFont else { return 1 }
            guard let raw = UnsafeRawPointer(bitPattern: Int(lParam)) else { return 1 }
            let families = raw.assumingMemoryBound(to: [String].self)
            let name = withUnsafeBytes(of: lf.pointee.lfFaceName) { rawBytes -> String in
              let buf = rawBytes.bindMemory(to: WCHAR.self)
              return String(decodingCString: buf.baseAddress!, as: UTF16.self)
            }
            // Skip @ fonts (vertical layout variants)
            if !name.hasPrefix("@") {
              UnsafeMutablePointer(mutating: families).pointee.append(name)
            }
            return 1  // continue enumeration
          }
          let lparamValue = LPARAM(Int(bitPattern: familiesPtr))
          EnumFontFamiliesExW(dc, lfPtr, callback, lparamValue, 0)
        }
      }
      return families.sorted()
    }

    // -------------------------------------------------------------------------
    // MARK: Image loading
    // -------------------------------------------------------------------------

    /// Loads a PNG by name.
    ///
    /// The search order is:
    ///   1. `RT_RCDATA` resource embedded in this executable (resource ID 256
    ///      for `"JavApi4Swift256"`); present only in builds produced by
    ///      `build-exe.ps1`.
    ///   2. `<exe-dir>\<name>.png`                         (installed layout)
    ///   3. `<exe-dir>\..\..\..\..\Sources\AWTShowcase\Assets.xcassets\AppIcon.appiconset\<name>.png`
    ///      (works when running via `swift run` from the package root)
    ///   4. `Sources\AWTShowcase\Assets.xcassets\AppIcon.appiconset\<name>.png`
    ///      (relative to the current working directory)
    ///
    /// - Returns: A `BufferedImage` ready for `Graphics.drawImage`, or `nil`.
    /// - Since: JavaApi > 0.19.1
    public override func loadImage(_ name: String) -> java.awt.Image? {
      // Determine the directory that contains the running executable.
      var exePath = [WCHAR](repeating: 0, count: Int(MAX_PATH))
      GetModuleFileNameW(nil, &exePath, DWORD(MAX_PATH))
      let nullIdx  = exePath.firstIndex(of: 0) ?? exePath.endIndex
      let fullPath = String(decoding: exePath[..<nullIdx], as: UTF16.self)
      let exeDir: String
      if let lastSlash = fullPath.lastIndex(of: "\\") {
        exeDir = String(fullPath[fullPath.startIndex ..< lastSlash])
      } else {
        exeDir = "."
      }

      // 1. PNG embedded as RT_RCDATA in this executable (resource ID 256).
      //    Embedded by build-exe.ps1 — only present in packaged builds.
      if name == "JavApi4Swift256",
         let img = _PNGLoader.loadFromResource(id: 256) {
        return img
      }

      // 2. File-system fallback (swift run / manual deployment).
      let xcassets = "Assets.xcassets\\AppIcon.appiconset\\\(name).png"
      let candidates: [String] = [
        "\(exeDir)\\\(name).png",
        "\(exeDir)\\..\\..\\..\\..\\Sources\\AWTShowcase\\\(xcassets)",
        "Sources\\AWTShowcase\\\(xcassets)",
      ]

      for path in candidates {
        if let img = _PNGLoader.load(path: path) { return img }
      }
      return nil
    }

    // -------------------------------------------------------------------------
    // MARK: Color model
    // -------------------------------------------------------------------------

    /// Returns the screen color model (32-bit ARGB default).
    ///
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    public override func getColorModel() -> java.awt.image.ColorModel {
      return java.awt.image.ColorModel.getRGBdefault()
    }

    // -------------------------------------------------------------------------
    // MARK: Clipboard
    // -------------------------------------------------------------------------

    /// Returns the Win32 clipboard provider.
    ///
    /// The shared ``_Win32ClipboardProvider`` is also used by
    /// ``_Win32FocusManager`` for Ctrl+C/V/X key handling, so both paths
    /// read and write the same OS clipboard.
    public override func _makeClipboardProvider() -> any java.awt.toolkit.ClipboardProvider {
      return java.awt.toolkit._Win32ClipboardProvider.shared
    }
  }
}
#endif
