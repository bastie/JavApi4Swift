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

    // Background
    g.setColor(self.getBackgroundColor())
    g.fillRect(getX(), getY(), w, h)

    // load Logo with Toolkit implementation of platform
    let toolkit = java.awt.Toolkit.getDefaultToolkit()
    if let img = toolkit.loadImage(named: "JavApi4Swift256") {
      let side = Swift.min(w, h)
      let ox   = getX() + (w - side) / 2
      let oy   = getY() + (h - side) / 2
      g.drawImage(img, ox, oy, side, side)
    }
    else {
      // Fallback: Placeholder if no image can load
      g.setColor(java.awt.Color.DARK_GRAY)
      g.drawRect(getX() + 2, getY() + 2, w - 4, h - 4)
      g.drawString("JavApi⁴Swift img not found", getX() + w / 2 - 12, getY() + h / 2 + 6)
    }
  }
}
