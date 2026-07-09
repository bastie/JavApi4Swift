/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

// MARK: - Scroll pane focus border

/// Focus-sensitive border for `JScrollPane`.
///
/// Uses `FocusManager.getCurrentManager().getFocusOwner()` to determine
/// whether the scroll pane or any of its direct interactive children
/// (viewport, vertical scrollbar, horizontal scrollbar) currently hold
/// keyboard focus, and draws a blue focus ring vs. the normal window-border
/// colour accordingly.
///
/// Installed by `BasicScrollPaneUI.installUI(_:)` — do not construct directly.
@MainActor
private final class _ScrollPaneBorder: javax.swing.border.AbstractBorder, @unchecked Sendable {

  override func paintBorder(
    _ component: java.awt.Component,
    _ g: java.awt.Graphics,
    _ x: Int, _ y: Int, _ width: Int, _ height: Int
  ) {
    guard let sp = component as? javax.swing.JScrollPane else { return }
    let focusOwner = javax.swing.FocusManager.getCurrentManager().getFocusOwner()
    let isFocused  = focusOwner === sp
      || focusOwner === sp.getViewport()
      || focusOwner === sp.getVerticalScrollBar()
      || focusOwner === sp.getHorizontalScrollBar()
    g.setColor(isFocused ? java.awt.Color(59, 130, 246) : java.awt.SystemColor.windowBorder)
    g.drawLine(x,             y,              x + width - 1, y)
    g.drawLine(x,             y,              x,             y + height - 1)
    g.drawLine(x + width - 1, y,              x + width - 1, y + height - 1)
    g.drawLine(x,             y + height - 1, x + width - 1, y + height - 1)
  }

  override func getBorderInsets(_ component: java.awt.Component) -> java.awt.Insets {
    java.awt.Insets(1, 1, 1, 1)
  }

  override var isBorderOpaque: Bool { false }
}

extension javax.swing.plaf.basic {

  /// The Basic Look-and-Feel UI delegate for `JScrollPane`.
  ///
  /// Layout and painting are handled directly by `JScrollPane`; this class
  /// exists as the correct Java-API hook so that `UIManager` can install it
  /// and custom L&Fs can override it.
  ///
  /// The scroll-pane border (a 1-pixel focus ring) is installed via
  /// `installUI(_:)` as a proper `Border` object, following the
  /// `ComponentUI` contract.  Focus detection uses
  /// `FocusManager.getCurrentManager().getFocusOwner()` so the ring updates
  /// correctly when focus moves between the viewport and scrollbars.
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
    // MARK: Install / uninstall
    // -------------------------------------------------------------------------

    override open func installUI(_ c: javax.swing.JComponent) {
      if c.getBorder() == nil {
        c.setBorder(_ScrollPaneBorder())
      }
    }

    override open func uninstallUI(_ c: javax.swing.JComponent) {
      if c.getBorder() is _ScrollPaneBorder {
        c.setBorder(nil)
      }
    }

    // -------------------------------------------------------------------------
    // MARK: Paint
    // -------------------------------------------------------------------------

    override open func paint(_ g: java.awt.Graphics, _ component: javax.swing.JComponent) {
      guard let sp = component as? javax.swing.JScrollPane else { return }
      sp.doLayout()

      let t  = sp.scrollbarThickness
      let vb = sp.showVBarPublic
      let hb = sp.showHBarPublic
      let vp = sp.getViewport()

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
