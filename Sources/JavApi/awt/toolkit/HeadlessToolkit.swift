/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.toolkit {

  /// Headless toolkit stub for platforms without a native window system
  /// (Linux, Windows, WASI, …).
  ///
  /// All operations are no-ops. Extend this class to add a real backend
  /// for a new platform.
  @MainActor
  public final class HeadlessToolkit: java.awt.Toolkit {

    public override init() {}

    public override func show(_ window: java.awt.Window) {
      // no-op — headless environment
    }

    public override func hide(_ window: java.awt.Window) {
      // no-op — headless environment
    }

    public override func attachMenuBar(_ menuBar: java.awt.MenuBar?, to frame: java.awt.Frame) {
      // no-op — headless environment
    }
  }
}
