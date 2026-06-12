/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

///
/// Extension for FileDialog on headless platforms. **Must implement `_setToolkitVisible`!**
///

#if !canImport(AppKit) && !os(Windows) && !os(Linux) && !os(FreeBSD)
extension java.awt.FileDialog {
  public func _setToolkitVisible() {
    // Headless — no native implementation
    file      = nil
    directory = nil
  }
}
#endif
