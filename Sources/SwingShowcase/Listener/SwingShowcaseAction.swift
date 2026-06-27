/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import JavApi

/// Base class for all SwingShowcase actions.
///
/// Provides a shared helper for loading 16×16 toolbar icons.
@MainActor
class SwingShowcaseAction: javax.swing.AbstractAction {

  /// Loads a 16×16 toolbar icon by asset name, or returns `nil`.
  static func toolbarIcon(named name: String) -> javax.swing.ImageIcon? {
    guard let img = java.awt.Toolkit.getDefaultToolkit().loadImage(name) else { return nil }
    return javax.swing.ImageIcon(img, width: 16, height: 16)
  }
}
