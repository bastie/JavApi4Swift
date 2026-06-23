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

    override open func paint(_ g: java.awt.Graphics, _ component: javax.swing.JComponent) {
      guard let sp = component as? javax.swing.JScrollPane else { return }
      sp.doLayout()

      let w  = sp.bounds.width
      let h  = sp.bounds.height
      let t  = sp.scrollbarThickness
      let vb = sp.showVBarPublic
      let hb = sp.showHBarPublic
      let vp  = sp.getViewport()

      // Use the bounds already set by doLayout() — they correctly account for
      // the column-header height, scrollbar visibility, etc.
      let vpBounds = vp.bounds

      // Column-header viewport (e.g. JTableHeader) — painted first so it appears
      // above the data viewport.
      if let ch = sp.getColumnHeader(), ch.getView() != nil {
        let chb = ch.bounds
        g.save()
        g.clipRect(chb.x, chb.y, chb.width, chb.height)
        g.translate(chb.x, chb.y)
        ch.paint(g)
        g.restore()
      }

      // Viewport
      g.save()
      g.clipRect(vpBounds.x, vpBounds.y, vpBounds.width, vpBounds.height)
      g.translate(vpBounds.x, vpBounds.y)
      vp.paint(g)
      g.restore()

      // Vertical scrollbar
      if vb {
        let vsbBounds = sp.getVerticalScrollBar().bounds
        g.save()
        g.clipRect(vsbBounds.x, vsbBounds.y, vsbBounds.width, vsbBounds.height)
        g.translate(vsbBounds.x, vsbBounds.y)
        sp.getVerticalScrollBar().paint(g)
        g.restore()
      }

      // Horizontal scrollbar
      if hb {
        let hsbBounds = sp.getHorizontalScrollBar().bounds
        g.save()
        g.clipRect(hsbBounds.x, hsbBounds.y, hsbBounds.width, hsbBounds.height)
        g.translate(hsbBounds.x, hsbBounds.y)
        sp.getHorizontalScrollBar().paint(g)
        g.restore()
      }

      // Corner fill when both bars visible
      if vb && hb {
        g.setColor(java.awt.SystemColor.control)
        g.fillRect(vpBounds.x + vpBounds.width, vpBounds.y + vpBounds.height, t, t)
      }

      // Border — blue focus ring if the viewport or scrollbars are focused
      // FIXME: implement KeyboardFocusManager 
      let viewIsFocused = sp.isFocusOwner || vp.isFocusOwner || sp.getVerticalScrollBar().isFocusOwner || sp.getHorizontalScrollBar().isFocusOwner
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
        return java.awt.Dimension(0, 0)
      }
      return sp.getPreferredSize()
    }
  }
}
