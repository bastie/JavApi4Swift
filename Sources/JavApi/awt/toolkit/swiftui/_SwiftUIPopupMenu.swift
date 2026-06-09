/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

#if canImport(SwiftUI)
import SwiftUI

#if os(macOS)
import AppKit

// =============================================================================
// MARK: - macOS PopupMenu rendering
// =============================================================================

/// macOS-specific extension on `java.awt.PopupMenu` providing native NSMenu display.
///
/// Called exclusively via `SwiftUIToolkit.showPopupMenu(_:origin:x:y:)` —
/// never directly from AWT code.
extension java.awt.PopupMenu {

  /// Shows the popup at `(x, y)` relative to `origin` using a coordinate
  /// fallback (no NSEvent available). Called from `SwiftUIToolkit`.
  @MainActor
  func _showNative(origin: java.awt.Component, x: Int, y: Int) {
    guard let view = NSApp.keyWindow?.contentView else { return }
    // AWT: Y from top; NSView (non-flipped): Y from bottom
    let viewH = view.bounds.height
    let nsX   = CGFloat(origin.bounds.x + x)
    let nsY   = viewH - CGFloat(origin.bounds.y + y)
    _buildNSMenu().popUp(positioning: nil, at: NSPoint(x: nsX, y: nsY), in: view)
  }

  /// Shows the popup exactly at the mouse cursor using the originating NSEvent.
  /// Called from `_SwiftUINativeCanvas.rightMouseDown`.
  @MainActor
  func _showAtEvent(_ event: NSEvent, in view: NSView) {
    _buildNSMenu().popUp(positioning: nil,
                         at: view.convert(event.locationInWindow, from: nil),
                         in: view)
  }

  /// Builds an `NSMenu` from this `PopupMenu`'s items, reusing
  /// `_SwiftUIWindowHost.makeNSMenuItem` for consistent action wiring.
  @MainActor
  func _buildNSMenu() -> NSMenu {
    let nsMenu = NSMenu(title: getLabel())
    for item in getItems() {
      nsMenu.addItem(_SwiftUIWindowHost.shared.makeNSMenuItem(from: item))
    }
    return nsMenu
  }
}

#endif   // os(macOS)
#endif   // canImport(SwiftUI)
