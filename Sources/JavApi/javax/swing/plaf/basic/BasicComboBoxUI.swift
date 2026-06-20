/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.plaf.basic {

  /// The Basic look-and-feel UI delegate for `JComboBox`.
  ///
  /// Renders the combo box as a text field with a right-aligned arrow button.
  /// When clicked, a popup list appears directly below — identical in approach
  /// to `java.awt.Choice`.  The Graphics context is already translated to the
  /// component origin — draw from (0, 0).
  ///
  /// - Since: Java 1.2
  @MainActor
  open class BasicComboBoxUI: javax.swing.plaf.ComponentUI {

    // -------------------------------------------------------------------------
    // MARK: Constants
    // -------------------------------------------------------------------------

    /// Row height of popup items (font-independent minimum).
    private let itemHeight: Int = 20

    // -------------------------------------------------------------------------
    // MARK: Install / uninstall
    // -------------------------------------------------------------------------

    private class _MouseHandler: java.awt.event.MouseAdapter {
      weak var combo: (AnyObject & _AnyJComboBox)?
      override func mouseClicked(_ e: java.awt.event.MouseEvent) {
        guard let combo else { return }
        if combo._isPopupOpen() {
          // Click while popup open: select item under cursor or close
          let h      = (combo as? javax.swing.JComponent)?.bounds.height ?? 0
          let rowH   = combo._popupItemHeight()
          let localY = e.getY() - h   // y relative to popup top
          if localY >= 0 {
            let idx = localY / max(1, rowH)
            if idx >= 0 && idx < combo._itemCount() {
              combo._selectIndex(idx)
            }
          }
          combo._closePopup()
        } else {
          combo._openPopup()
        }
      }
    }
    private var _mouseHandler: _MouseHandler?

    override open func installUI(_ component: javax.swing.JComponent) {
      guard let combo = component as? (AnyObject & _AnyJComboBox) else { return }
      let h = _MouseHandler()
      h.combo = combo
      _mouseHandler = h
      component.addMouseListener(h)
      if component.getBorder() == nil {
        component.setBorder(javax.swing.BorderFactory.createLineBorder(
          java.awt.SystemColor.controlShadow))
      }
    }

    override open func uninstallUI(_ component: javax.swing.JComponent) {
      if let h = _mouseHandler { component.removeMouseListener(h) }
      _mouseHandler = nil
      if component.getBorder() is javax.swing.border.LineBorder {
        component.setBorder(nil)
      }
    }

    // -------------------------------------------------------------------------
    // MARK: Preferred size — font-driven, no hard-coded values
    // -------------------------------------------------------------------------

    override open func getPreferredSize(_ component: javax.swing.JComponent) -> java.awt.Dimension? {
      let fm = java.awt.FontMetrics.make(for: component.font)
      let h  = fm.getHeight() + 8
      // Width: widest item text + arrow button (approx 2 × font height) + padding
      let arrowW = h  // square arrow button
      var maxItemW = 0
      if let cb = component as? _AnyJComboBox {
        for i in 0 ..< cb._itemCount() {
          maxItemW = Swift.max(maxItemW, fm.stringWidth(cb._labelAt(i)))
        }
      }
      let w = maxItemW + arrowW + 12   // 6px padding each side
      return java.awt.Dimension(Swift.max(w, arrowW + 12), h)
    }

    // -------------------------------------------------------------------------
    // MARK: Paint — origin is (0, 0) relative to the component
    // -------------------------------------------------------------------------

    override open func paint(_ g: java.awt.Graphics, _ component: javax.swing.JComponent) {
      guard let combo = component as? _AnyJComboBox else { return }

      let w     = component.bounds.width
      let h     = component.bounds.height
      let fm    = java.awt.FontMetrics.make(for: component.font)
      let arrowW = h   // square arrow button

      // Background
      g.setColor(java.awt.SystemColor.window)
      g.fillRect(0, 0, w, h)

      // Outer border is painted by JComponent.paint() via getBorder().paintBorder(...)

      // Arrow button background
      let arrowX = w - arrowW
      g.setColor(java.awt.SystemColor.control)
      g.fillRect(arrowX + 1, 1, arrowW - 2, h - 2)
      g.setColor(java.awt.SystemColor.controlShadow)
      g.drawLine(arrowX, 1, arrowX, h - 2)

      // Down-arrow ▼ — identical pattern to java.awt.Choice (known-good)
      g.setColor(java.awt.SystemColor.controlText)
      let cx = arrowX + arrowW / 2
      let cy = h / 2 - 1
      for i in 0..<4 {
        let row = 3 - i
        g.drawLine(cx - row, cy + i, cx + row, cy + i)
      }

      // Selected item text (baseline-correct)
      let label = combo._selectedLabel()
      g.setColor(java.awt.SystemColor.windowText)
      g.drawString(label, 4, fm.getAscent() + (h - fm.getHeight()) / 2)

      // Popup is drawn by the Canvas overlay after the full paint pass
      // (see _SwiftUINativeCanvas.draw) so it is not clipped by parent containers.
    }
  }
}

// Internal protocol — avoids the generic parameter of JComboBox<E>.
@MainActor
protocol _AnyJComboBox: AnyObject {
  func _selectedLabel()        -> String
  func _selectedIndex()        -> Int
  func _itemCount()            -> Int
  func _labelAt(_ i: Int)      -> String
  func _popupItemHeight()      -> Int
  func _isPopupOpen()          -> Bool
  func _openPopup()
  func _closePopup()
  func _selectIndex(_ i: Int)
  func _rolloverIndex()        -> Int
  func _setRolloverIndex(_ i: Int)
}

extension javax.swing.JComboBox: _AnyJComboBox {
  func _selectedLabel()   -> String { getSelectedItem().map { "\($0)" } ?? "" }
  func _selectedIndex()   -> Int    { getSelectedIndex() }
  func _itemCount()       -> Int    { getItemCount() }
  func _labelAt(_ i: Int) -> String { "\(getItemAt(i))" }
  func _popupItemHeight() -> Int {
    java.awt.FontMetrics.make(for: font).getHeight() + 4
  }
  func _isPopupOpen()          -> Bool { isPopupVisible() }
  func _openPopup()                    { showPopup() }
  func _closePopup()                   { hidePopup(); _rolloverIdx = -1 }
  func _selectIndex(_ i: Int)          { setSelectedIndex(i) }
  func _rolloverIndex()        -> Int  { _rolloverIdx }
  func _setRolloverIndex(_ i: Int)     { _rolloverIdx = i }
}
