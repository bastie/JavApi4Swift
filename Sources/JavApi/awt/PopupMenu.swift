/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt {

  /// Contextmenu
  @MainActor
  open class PopupMenu: Menu {

    public override init(_ label: String = "", tearOff: Bool = false) {
      super.init(label, tearOff: tearOff)
    }

    /// Show the PopupMenu on position `(x, y)` relativ to `origin`.
    ///
    /// Delegates to `Toolkit.getDefaultToolkit().showPopupMenu(_:origin:x:y:)`
    /// so that the platform-specific rendering stays in the toolkit layer.
    ///
    /// - Parameters:
    ///   - origin: component to compute relative position
    ///   - x: move x
    ///   - y: move y
    ///
    open func show(_ origin: Component, _ x: Int, _ y: Int) {
      java.awt.Toolkit.getDefaultToolkit().showPopupMenu(self, origin: origin, x: x, y: y)
    }
  }
}
