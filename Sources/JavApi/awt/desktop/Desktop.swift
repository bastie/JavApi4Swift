/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.desktop {
  open class Desktop : @unchecked Sendable {
    
    static let desktop = Desktop()
  
    internal var isValid = true
    
    
    internal init() {
    }
    
    public static func getDesktop() throws -> java.awt.desktop.Desktop {
      guard java.awt.GraphicsEnvironment.isHeadless() else {
        throw java.awt.HeadlessException()
      }
      guard isDesktopSupported() else {
        throw UnsupportedOperationException()
      }
      return Desktop.desktop
    }
    
    public static func isDesktopSupported() -> Bool {
      return false // FIXME: make platform specific result
    }
  }
}
