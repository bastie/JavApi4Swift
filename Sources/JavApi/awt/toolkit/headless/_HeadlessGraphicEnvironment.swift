/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

// ===========================================================================
// MARK: - HeadlessGraphicsEnvironment (internal default)
// ===========================================================================

extension java.awt.toolkit.headless {
  /// A minimal headless `GraphicsEnvironment` used when no display is available.
  final class _HeadlessGraphicsEnvironment: java.awt.GraphicsEnvironment {
    
    override func isHeadlessInstance() -> Bool { return true }
    
    override func getScreenDevices() -> [java.awt.GraphicsDevice] { return [] }
    
    override func getDefaultScreenDevice() -> java.awt.GraphicsDevice {
      fatalError("HeadlessException: No screen devices available in headless mode")
    }
    
    override func getAvailableFontFamilyNames() -> [String] { return [] }
  }
}
