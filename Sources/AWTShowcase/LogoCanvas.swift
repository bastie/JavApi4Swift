/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import JavApi

/// Paint JavApi⁴Swift-Logo with `Toolkit.loadImage(named:)`.
///
@MainActor
final class LogoCanvas: java.awt.Canvas {
  
  override func paint(_ g: java.awt.Graphics) {
    let w = getWidth()
    let h = getHeight()
    guard w > 0, h > 0 else { return }

    // Paint in LOCAL coordinates (0,0) — Container.paint() has already
    // translated the graphics context to this component's origin.
    g.setColor(self.getBackgroundColor())
    g.fillRect(0, 0, w, h)

    let toolkit = java.awt.Toolkit.getDefaultToolkit()
    if let img = toolkit.loadImage(named: "JavApi4Swift256") {
      let side = Swift.min(w, h)
      let ox   = (w - side) / 2
      let oy   = (h - side) / 2
      g.drawImage(img, ox, oy, side, side)
    }
    else {
      g.setColor(java.awt.Color.DARK_GRAY)
      g.drawRect(2, 2, w - 4, h - 4)
      g.drawString("JavApi⁴Swift img not found", w / 2 - 12, h / 2 + 6)
    }
  }
}
