/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.toolkit {
  /// A native FileDialog must be implement this protocol.
  public protocol FileDialogProvider {
    /// show the native FileDialog
    func _setToolkitVisible()
  }
}
