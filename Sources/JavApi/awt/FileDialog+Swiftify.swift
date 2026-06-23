/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt {
  
  /// Type-safe Swift enum for FileDialog mode.
  public enum FileDialogMode: Int {
    /// The FileDialog for `LOAD` mode is requested
    case LOAD = 0
    /// The FileDialog for `SAVE` mode is requested
    case SAVE = 1
  }
}

extension java.awt.FileDialog {
  
  /// type safe mode set
  /// - Parameter mode: the mode of FileDialog
  public func setMode(mode: java.awt.FileDialogMode) {
    self.mode = mode
  }
  
}
