/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt {

  /// Kontextmenü das an einer beliebigen Position eingeblendet wird —
  /// mirrors `java.awt.PopupMenu`.
  @MainActor
  open class PopupMenu: Menu {

    public override init(_ label: String = "", tearOff: Bool = false) {
      super.init(label, tearOff: tearOff)
    }

    /// Zeigt das PopupMenu an Position `(x, y)` relativ zu `origin`.
    ///
    /// Delegates to `Toolkit.getDefaultToolkit().showPopupMenu(_:origin:x:y:)`
    /// so that the platform-specific rendering stays in the toolkit layer.
    open func show(_ origin: Component, _ x: Int, _ y: Int) {
      java.awt.Toolkit.getDefaultToolkit().showPopupMenu(self, origin: origin, x: x, y: y)
    }
  }
}
