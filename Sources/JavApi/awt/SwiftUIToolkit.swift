/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

#if canImport(SwiftUI)

extension java.awt {

  /// SwiftUI-backed toolkit for Apple platforms (macOS, iOS, tvOS, visionOS).
  ///
  /// Delegates window lifecycle to `AWTWindowHost`.
  @MainActor
  public final class SwiftUIToolkit: Toolkit {

    public static let shared = SwiftUIToolkit()

    private override init() {}

    public override func show(_ window: java.awt.Window) {
#if os(macOS)
      // FileDialog verwaltet seinen eigenen nativen Panel in setVisible —
      // kein AWTWindowHost-Fenster nötig.
      if window is java.awt.FileDialog { return }
      if let dialog = window as? java.awt.Dialog {
        AWTWindowHost.shared.openDialog(dialog)
        return
      }
      AWTWindowHost.shared.openNewWindow(for: window)
#else
      AWTWindowHost.shared.show(window)
#endif
    }

    public override func hide(_ window: java.awt.Window) {
      AWTWindowHost.shared.hide(window)
    }

    public override func attachMenuBar(_ menuBar: java.awt.MenuBar?, to frame: java.awt.Frame) {
#if os(macOS)
      AWTWindowHost.shared.attachMenuBar(menuBar, to: frame)
#endif
    }
  }
}

#endif
