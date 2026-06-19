/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.plaf.basic {

  /// The Basic look-and-feel UI delegate for `JList`.
  ///
  /// Renders each list row with selection highlight using system colors.
  /// The Graphics context is already clipped and translated to the component
  /// origin — draw from (0, 0).
  ///
  /// - Since: Java 1.2
  @MainActor
  open class BasicListUI: javax.swing.plaf.ComponentUI {

    // -------------------------------------------------------------------------
    // MARK: Install / uninstall
    // -------------------------------------------------------------------------

    private class _MouseHandler: java.awt.event.MouseAdapter {
      weak var list: (AnyObject & _AnyJList)?

      private func rowAt(_ e: java.awt.event.MouseEvent) -> Int? {
        guard let list else { return nil }
        let rowH = list._cellHeight()
        guard rowH > 0 else { return nil }
        let row = e.getY() / rowH
        guard row >= 0 && row < list._modelSize() else { return nil }
        return row
      }

      override func mouseClicked(_ e: java.awt.event.MouseEvent) {
        guard let row = rowAt(e), let list else { return }
        list._selModel().setSelectionInterval(row, row)
        (list as? javax.swing.JComponent)?.repaint()
      }

      override func mouseMoved(_ e: java.awt.event.MouseEvent) {
        guard let list else { return }
        let newHover = rowAt(e) ?? -1
        if newHover != list._hoverIndex() {
          list._setHoverIndex(newHover)
          (list as? javax.swing.JComponent)?.repaint()
        }
      }

      override func mouseExited(_ e: java.awt.event.MouseEvent) {
        guard let list else { return }
        if list._hoverIndex() >= 0 {
          list._setHoverIndex(-1)
          (list as? javax.swing.JComponent)?.repaint()
        }
      }
    }
    private var _mouseHandler: _MouseHandler?

    override open func installUI(_ component: javax.swing.JComponent) {
      guard let list = component as? (AnyObject & _AnyJList) else { return }
      let h = _MouseHandler()
      h.list = list
      _mouseHandler = h
      component.addMouseListener(h)
      component.addMouseMotionListener(h)
      if component.getBorder() == nil {
        component.setBorder(javax.swing.BorderFactory.createLineBorder(
          java.awt.SystemColor.controlShadow))
      }
    }

    override open func uninstallUI(_ component: javax.swing.JComponent) {
      if let h = _mouseHandler {
        component.removeMouseListener(h)
        component.removeMouseMotionListener(h)
      }
      _mouseHandler = nil
      if component.getBorder() is javax.swing.border.LineBorder {
        component.setBorder(nil)
      }
    }

    // -------------------------------------------------------------------------
    // MARK: Preferred size — row height from font, count from model
    // -------------------------------------------------------------------------

    override open func getPreferredSize(_ component: javax.swing.JComponent) -> java.awt.Dimension? {
      guard let list = component as? _AnyJList else { return nil }
      let fm   = java.awt.FontMetrics.make(for: component.font)
      let rowH = fm.getHeight() + 4
      let rows = list._modelSize()
      return java.awt.Dimension(150, max(1, rows) * rowH)
    }

    // -------------------------------------------------------------------------
    // MARK: Paint — origin is (0, 0) relative to the component
    // -------------------------------------------------------------------------

    override open func paint(_ g: java.awt.Graphics, _ component: javax.swing.JComponent) {
      guard let list = component as? _AnyJList else { return }

      let w     = component.bounds.width
      let h     = component.bounds.height
      let rowH  = list._cellHeight()
      let count = list._modelSize()
      let sel   = list._selModel()
      let hover = list._hoverIndex()
      let fm    = java.awt.FontMetrics.make(for: component.font)

      // Background
      g.setColor(java.awt.SystemColor.window)
      g.fillRect(0, 0, w, h)

      // Rows
      for i in 0 ..< count {
        let rowY = i * rowH
        guard rowY < h else { break }

        if sel.isSelectedIndex(i) {
          g.setColor(java.awt.SystemColor.textHighlight)
          g.fillRect(0, rowY, w, rowH)
          g.setColor(java.awt.SystemColor.textHighlightText)
        } else if i == hover {
          // Rollover highlight (lighter than selection)
          g.setColor(java.awt.SystemColor.controlHighlight)
          g.fillRect(0, rowY, w, rowH)
          g.setColor(java.awt.SystemColor.windowText)
        } else {
          g.setColor(java.awt.SystemColor.windowText)
        }

        let label = list._elementLabel(at: i)
        g.drawString(label, 4, rowY + fm.getAscent() + 2)
      }

      // Border is painted by JComponent.paint() via getBorder().paintBorder(...)
    }
  }
}

// Internal protocol — avoids the generic parameter of JList<E>.
@MainActor
private protocol _AnyJList: AnyObject {
  func _modelSize()             -> Int
  func _elementLabel(at: Int)   -> String
  func _selModel()              -> javax.swing.ListSelectionModel
  func _cellHeight()            -> Int
  func _hoverIndex()            -> Int
  func _setHoverIndex(_ i: Int)
}

extension javax.swing.JList: _AnyJList {
  func _modelSize()            -> Int    { getModel().getSize() }
  func _elementLabel(at i: Int) -> String { "\(getModel().getElementAt(i))" }
  func _selModel()             -> javax.swing.ListSelectionModel { getSelectionModel() }
  func _cellHeight()           -> Int    { getFixedCellHeight() }
  func _hoverIndex()           -> Int    { _hoverIdx }
  func _setHoverIndex(_ i: Int)          { _hoverIdx = i }
}
