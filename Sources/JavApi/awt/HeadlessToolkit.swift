/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt {

  /// Headless toolkit stub for platforms without a native window system
  /// (Linux, Windows, WASI, …).
  ///
  /// All operations are no-ops. Extend this class to add a real backend
  /// for a new platform.
  @MainActor
  public final class HeadlessToolkit: Toolkit {

    public override init() {}

    public override func show(_ frame: java.awt.Frame) {
      // no-op — headless environment
    }

    public override func hide(_ frame: java.awt.Frame) {
      // no-op — headless environment
    }
  }
}
