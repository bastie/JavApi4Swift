/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt {
  
  /// Type-safe Swift enum for FileDialog mode.
  internal enum FileDialogMode: Int {
    case LOAD = 0
    case SAVE = 1
  }
}
