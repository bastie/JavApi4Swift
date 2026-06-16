/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.plaf.basic {

  /// The Basic look-and-feel UI delegate for `JSpinner`.
  ///
  /// Renders the spinner as a text area with stacked up/down arrow buttons
  /// on the right side.  The Graphics context is already clipped and
  /// translated to the component origin — draw from (0, 0).
  ///
  /// - Since: Java 1.4
  @MainActor
  open class BasicSpinnerUI: javax.swing.plaf.ComponentUI {

    // -------------------------------------------------------------------------
    // MARK: Install / uninstall
    // -------------------------------------------------------------------------

    private class _MouseHandler: java.awt.event.MouseAdapter {
      weak var spinner: javax.swing.JSpinner?
      override func mouseClicked(_ e: java.awt.event.MouseEvent) {
        guard let spinner else { return }
        let w    = spinner.bounds.width
        let h    = spinner.bounds.height
        let btnW = h   // square button column on the right
        guard e.getX() >= w - btnW else { return }   // ignore clicks in text area
        if e.getY() < h / 2 {
          if let v = spinner.getNextValue()     { spinner.setValue(v) }
        } else {
          if let v = spinner.getPreviousValue() { spinner.setValue(v) }
        }
      }
    }
    private var _mouseHandler: _MouseHandler?

    override open func installUI(_ component: javax.swing.JComponent) {
      guard let spinner = component as? javax.swing.JSpinner else { return }
      let h = _MouseHandler()
      h.spinner = spinner
      _mouseHandler = h
      component.addMouseListener(h)
    }

    override open func uninstallUI(_ component: javax.swing.JComponent) {
      if let h = _mouseHandler { component.removeMouseListener(h) }
      _mouseHandler = nil
    }

    // -------------------------------------------------------------------------
    // MARK: Preferred size — font-driven, no hard-coded values
    // -------------------------------------------------------------------------

    override open func getPreferredSize(_ component: javax.swing.JComponent) -> java.awt.Dimension? {
      let fm = java.awt.FontMetrics.make(for: component.font)
      let h  = fm.getHeight() + 8
      return java.awt.Dimension(80, h)    // 80 is a minimum width hint only
    }

    // -------------------------------------------------------------------------
    // MARK: Paint — origin is (0, 0) relative to the component
    // -------------------------------------------------------------------------

    override open func paint(_ g: java.awt.Graphics, on component: javax.swing.JComponent) {
      guard let spinner = component as? javax.swing.JSpinner else { return }

      let w    = component.bounds.width
      let h    = component.bounds.height
      let fm   = java.awt.FontMetrics.make(for: component.font)
      let btnW = h   // square button column

      // Text field background
      g.setColor(java.awt.SystemColor.window)
      g.fillRect(0, 0, w - btnW, h)

      // Text field border
      g.setColor(java.awt.SystemColor.controlShadow)
      g.drawLine(0,          0,   w-btnW-1, 0)
      g.drawLine(0,          0,   0,         h-1)
      g.drawLine(w-btnW-1,   0,   w-btnW-1, h-1)
      g.drawLine(0,          h-1, w-btnW-1, h-1)

      // Current value (baseline-correct). Format whole-number Doubles without
      // the ".0" suffix so that integer spinners look like integers.
      let label: String
      if let d = spinner.getValue() as? Double, d.truncatingRemainder(dividingBy: 1) == 0 {
        label = String(Int(d))
      } else {
        label = spinner.getValue().map { "\($0)" } ?? ""
      }
      g.setColor(java.awt.SystemColor.windowText)
      g.drawString(label, 4, fm.getAscent() + (h - fm.getHeight()) / 2)

      // Up / down arrow buttons
      let halfH = h / 2
      _drawArrowButton(g, x: w-btnW, y: 0,     w: btnW, h: halfH,   up: true)
      _drawArrowButton(g, x: w-btnW, y: halfH, w: btnW, h: h-halfH, up: false)
    }

    private func _drawArrowButton(_ g: java.awt.Graphics, x: Int, y: Int, w: Int, h: Int, up: Bool) {
      g.setColor(java.awt.SystemColor.control)
      g.fillRect(x, y, w, h)
      g.setColor(java.awt.SystemColor.controlShadow)
      g.drawLine(x,     y,     x+w-1, y)
      g.drawLine(x,     y,     x,     y+h-1)
      g.drawLine(x+w-1, y,     x+w-1, y+h-1)
      g.drawLine(x,     y+h-1, x+w-1, y+h-1)

      // Arrow glyphs — same pattern as java.awt.Choice (known-good ▼),
      // mirrored on Y for ▲.
      g.setColor(java.awt.SystemColor.controlText)
      let cx = x + w / 2
      let cy = y + h / 2 - 1
      for i in 0..<4 {
        let row = 3 - i
        if up {
          // ▲: tip at top → y decreases with i
          g.drawLine(cx - row, cy - i, cx + row, cy - i)
        } else {
          // ▼: tip at bottom → y increases with i
          g.drawLine(cx - row, cy + i, cx + row, cy + i)
        }
      }
    }
  }
}
