/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.plaf.basic {

  /// The Basic look-and-feel UI delegate for `JSlider`.
  ///
  /// Renders a track with a draggable thumb.  Major and minor tick marks and
  /// value labels are drawn when enabled on the component.
  ///
  /// The preferred size is font-driven; no hard-coded pixel values are used.
  ///
  /// - Since: Java 1.2
  @MainActor
  open class BasicSliderUI: javax.swing.plaf.ComponentUI {

    // -------------------------------------------------------------------------
    // MARK: Mouse drag handler
    // -------------------------------------------------------------------------

    private class _DragHandler: java.awt.event.MouseAdapter {
      weak var slider: javax.swing.JSlider?

      override func mousePressed(_ e: java.awt.event.MouseEvent) {
        guard let slider else { return }
        slider.setValueIsAdjusting(true)
        updateValue(slider, e)
      }

      override func mouseDragged(_ e: java.awt.event.MouseEvent) {
        guard let slider else { return }
        updateValue(slider, e)
      }

      override func mouseReleased(_ e: java.awt.event.MouseEvent) {
        guard let slider else { return }
        updateValue(slider, e)
        slider.setValueIsAdjusting(false)
      }

      private func updateValue(_ slider: javax.swing.JSlider, _ e: java.awt.event.MouseEvent) {
        let w    = slider.bounds.width
        let h    = slider.bounds.height
        let min  = slider.getMinimum()
        let max  = slider.getMaximum()
        let range = max - min
        guard range > 0 else { return }

        let fraction: Double
        if slider.getOrientation() == javax.swing.JSlider.HORIZONTAL {
          fraction = Double(Math.max(0, Math.min(e.getX(), w))) / Double(w)
        } else {
          fraction = 1.0 - Double(Math.max(0, Math.min(e.getY(), h))) / Double(h)
        }
        slider.setValue(min + Int(fraction * Double(range)))
      }
    }

    private var _drag: _DragHandler?

    // -------------------------------------------------------------------------
    // MARK: Install / uninstall
    // -------------------------------------------------------------------------

    override open func installUI(_ component: javax.swing.JComponent) {
      guard let slider = component as? javax.swing.JSlider else { return }
      let d = _DragHandler()
      d.slider = slider
      _drag = d
      component.addMouseListener(d)
      component.addMouseMotionListener(d)
    }

    override open func uninstallUI(_ component: javax.swing.JComponent) {
      if let d = _drag {
        component.removeMouseListener(d)
        component.removeMouseMotionListener(d)
      }
      _drag = nil
    }

    // -------------------------------------------------------------------------
    // MARK: Preferred size
    // -------------------------------------------------------------------------

    override open func getPreferredSize(_ component: javax.swing.JComponent) -> java.awt.Dimension? {
      guard let slider = component as? javax.swing.JSlider else { return nil }
      let fm = java.awt.FontMetrics.make(for: component.font)
      let thick = fm.getHeight() + 16
      if slider.getOrientation() == javax.swing.JSlider.HORIZONTAL {
        return java.awt.Dimension(200, thick)
      } else {
        return java.awt.Dimension(thick, 200)
      }
    }

    // -------------------------------------------------------------------------
    // MARK: Paint
    // -------------------------------------------------------------------------

    override open func paint(_ g: java.awt.Graphics, _ component: javax.swing.JComponent) {
      guard let slider = component as? javax.swing.JSlider else { return }

      let w    = component.bounds.width
      let h    = component.bounds.height
      let min  = slider.getMinimum()
      let max  = slider.getMaximum()
      let val  = slider.getValue()
      let range = max - min

      let horizontal = slider.getOrientation() == javax.swing.JSlider.HORIZONTAL

      // Fraction of the way from min to max
      let fraction: Double = range > 0
        ? Double(val - min) / Double(range)
        : 0

      // ── Track ───────────────────────────────────────────────────────────────
      let trackThick = 4
      g.setColor(java.awt.SystemColor.controlShadow)
      if horizontal {
        let ty = (h - trackThick) / 2
        g.fillRect(0, ty, w, trackThick)
      } else {
        let tx = (w - trackThick) / 2
        g.fillRect(tx, 0, trackThick, h)
      }

      // ── Thumb ───────────────────────────────────────────────────────────────
      let thumbSize = 12
      let thumbHalf = thumbSize / 2
      let thumbX: Int
      let thumbY: Int
      if horizontal {
        thumbX = Int(Double(w - thumbSize) * fraction)
        thumbY = (h - thumbSize) / 2
      } else {
        thumbX = (w - thumbSize) / 2
        thumbY = h - thumbSize - Int(Double(h - thumbSize) * fraction)
      }
      g.setColor(java.awt.SystemColor.control)
      g.fillOval(thumbX, thumbY, thumbSize, thumbSize)
      g.setColor(java.awt.SystemColor.controlShadow)
      g.drawOval(thumbX, thumbY, thumbSize - 1, thumbSize - 1)

      // ── Major tick marks ────────────────────────────────────────────────────
      let major = slider.getMajorTickSpacing()
      if slider.getPaintTicks() && major > 0 && range > 0 {
        g.setColor(java.awt.SystemColor.controlDkShadow)
        var v = min
        while v <= max {
          let frac = Double(v - min) / Double(range)
          if horizontal {
            let tx = Int(Double(w) * frac)
            let cy = h / 2 + thumbHalf + 2
            g.drawLine(tx, cy, tx, cy + 5)
          } else {
            let ty = h - 1 - Int(Double(h) * frac)
            let cx = w / 2 + thumbHalf + 2
            g.drawLine(cx, ty, cx + 5, ty)
          }
          v += major
        }
      }

      // ── Minor tick marks ────────────────────────────────────────────────────
      let minor = slider.getMinorTickSpacing()
      if slider.getPaintTicks() && minor > 0 && range > 0 {
        g.setColor(java.awt.SystemColor.controlShadow)
        var v = min
        while v <= max {
          let frac = Double(v - min) / Double(range)
          if horizontal {
            let tx = Int(Double(w) * frac)
            let cy = h / 2 + thumbHalf + 2
            g.drawLine(tx, cy, tx, cy + 3)
          } else {
            let ty = h - 1 - Int(Double(h) * frac)
            let cx = w / 2 + thumbHalf + 2
            g.drawLine(cx, ty, cx + 3, ty)
          }
          v += minor
        }
      }

      // ── Labels ──────────────────────────────────────────────────────────────
      if slider.getPaintLabels() && major > 0 && range > 0 {
        let fm = java.awt.FontMetrics.make(for: component.font)
        g.setColor(java.awt.Color.black)
        var v = min
        while v <= max {
          let frac = Double(v - min) / Double(range)
          let label = "\(v)"
          let lw    = fm.stringWidth(label)
          if horizontal {
            let tx = Int(Double(w) * frac) - lw / 2
            let ty = h - 1
            g.drawString(label, tx, ty)
          } else {
            let ty = h - 1 - Int(Double(h) * frac) + fm.getAscent() / 2
            let tx = w / 2 + thumbHalf + 10
            g.drawString(label, tx, ty)
          }
          v += major
        }
      }
    }
  }
}
