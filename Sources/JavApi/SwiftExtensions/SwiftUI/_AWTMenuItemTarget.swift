/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Foundation

#if canImport(SwiftUI)
import SwiftUI

#if os(macOS)

// ---------------------------------------------------------------------------
// MARK: AWTMenuItemTarget — Objective-C-Ziel für NSMenuItem-Aktionen
// ---------------------------------------------------------------------------

/// Hält einen starken Verweis auf ein `java.awt.MenuItem` und leitet
/// NSMenuItem-Aktionen an dessen `doAction()` weiter.
@MainActor
@objc internal final class AWTMenuItemTarget: NSObject {
  private let menuItem: java.awt.MenuItem
  init(menuItem: java.awt.MenuItem) { self.menuItem = menuItem }
  
  @objc func trigger(_ sender: Any?) {
    menuItem.doAction()
  }
}

#endif   // os(macOS)

#endif   // canImport(SwiftUI)

