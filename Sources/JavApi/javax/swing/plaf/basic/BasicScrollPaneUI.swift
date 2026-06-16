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
    // MARK: Paint
    // -------------------------------------------------------------------------

    override open func paint(_ g: java.awt.Graphics, on component: javax.swing.JComponent) {
      guard let sp = component as? javax.swing.JScrollPane else { return }
      sp.doLayout()

      let w  = sp.bounds.width
      let h  = sp.bounds.height
      let t  = sp.scrollbarThickness
      let vb = sp.showVBarPublic
      let hb = sp.showHBarPublic
      let vpW = w - (vb ? t : 0)
      let vpH = h - (hb ? t : 0)
      let vp  = sp.getViewport()

      // Viewport
      g.save()
      g.clipRect(0, 0, vpW, vpH)
      vp.paint(g)
      g.restore()

      // Vertical scrollbar
      if vb {
        g.save()
        g.translate(vpW, 0)
        sp.getVerticalScrollBar().paint(g)
        g.restore()
      }

      // Horizontal scrollbar
      if hb {
        g.save()
        g.translate(0, vpH)
        sp.getHorizontalScrollBar().paint(g)
        g.restore()
      }

      // Corner fill when both bars visible
      if vb && hb {
        g.setColor(java.awt.SystemColor.control)
        g.fillRect(vpW, vpH, t, t)
      }

      // Border — blue focus ring if a descendant is focused
      let viewIsFocused: Bool = {
        guard let focused = _SwiftUIFocusManager.shared.focusOwner else { return false }
        var node: java.awt.Component? = focused
        while let n = node {
          if n === sp { return true }
          node = n.parent
        }
        return false
      }()
      g.setColor(viewIsFocused ? java.awt.Color(59, 130, 246) : java.awt.SystemColor.windowBorder)
      g.drawLine(0,   0,   w-1, 0)
      g.drawLine(0,   0,   0,   h-1)
      g.drawLine(w-1, 0,   w-1, h-1)
      g.drawLine(0,   h-1, w-1, h-1)
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
