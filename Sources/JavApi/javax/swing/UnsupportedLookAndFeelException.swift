/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing {

  /// Thrown by `UIManager.setLookAndFeel(_:)` when the requested L&F is not
  /// supported on the current platform.
  ///
  /// - Since: Java 1.2
  public final class UnsupportedLookAndFeelException: java.lang.Exception, @unchecked Sendable {
    public override init(_ message: String) {
      super.init(message)
    }
  }
}
