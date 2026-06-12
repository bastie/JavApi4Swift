/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt {
  
  /// Type-safe Swift enum for FileDialog mode.
  internal enum FileDialogMode: Int {
    /// The FileDialog for `LOAD` mode is requested
    case LOAD = 0
    /// The FileDialog for `SAVE` mode is requested
    case SAVE = 1
  }
}
