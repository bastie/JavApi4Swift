/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

#if canImport(SwiftUI)
import SwiftUI

#if os(macOS)

// ---------------------------------------------------------------------------
// MARK: _SwiftUIMenuItemTarget — Objective-C-Ziel für NSMenuItem-Aktionen
// ---------------------------------------------------------------------------

/// Hält einen starken Verweis auf ein `java.awt.MenuItem` und leitet
/// NSMenuItem-Aktionen an dessen `doAction()` weiter.
@MainActor
@objc internal final class _SwiftUIMenuItemTarget: NSObject {
  private let menuItem: java.awt.MenuItem
  init(menuItem: java.awt.MenuItem) { self.menuItem = menuItem }

  @objc func trigger(_ sender: Any?) {
    menuItem.doAction()
    // Sync NSMenuItem checkmark after doAction() — CheckboxMenuItem.doAction()
    // toggles the state, but AppKit cannot see that change automatically.
    if let nsItem = sender as? NSMenuItem,
       let cbItem = menuItem as? java.awt.CheckboxMenuItem {
      nsItem.state = cbItem.getState() ? .on : .off
    }
  }
}

#endif   // os(macOS)

#endif   // canImport(SwiftUI)

