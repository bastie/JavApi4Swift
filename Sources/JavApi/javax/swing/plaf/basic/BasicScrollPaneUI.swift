/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.plaf.basic {

  /// The Basic Look-and-Feel UI delegate for `JScrollPane`.
  ///
  /// Layout and painting are handled directly by `JScrollPane`; this class
  /// exists as the correct Java-API hook so that `UIManager` can install it
  /// and custom L&Fs can override it.
  ///
  /// - Since: Java 1.2
  @MainActor
  open class BasicScrollPaneUI: javax.swing.plaf.ComponentUI {

    // -------------------------------------------------------------------------
    // MARK: ComponentUI factory
    // -------------------------------------------------------------------------

    open class func createUI(_ c: javax.swing.JComponent) -> javax.swing.plaf.ComponentUI {
      return BasicScrollPaneUI()
    }

    // -------------------------------------------------------------------------
    // MARK: Paint — delegates to JScrollPane.paint
    // -------------------------------------------------------------------------

    open func paint(_ g: java.awt.Graphics, _ c: javax.swing.JComponent) {
      // JScrollPane.paint() already handles viewport + scrollbars + border.
      // Nothing extra to do here; subclasses may override for custom decoration.
    }

    // -------------------------------------------------------------------------
    // MARK: Preferred size
    // -------------------------------------------------------------------------

    override open func getPreferredSize(_ c: javax.swing.JComponent) -> java.awt.Dimension {
      guard let sp = c as? javax.swing.JScrollPane else {
        return java.awt.Dimension(100, 100)
      }
      return sp.getPreferredSize()
    }
  }
}
