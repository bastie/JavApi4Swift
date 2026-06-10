/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import JavApi

/// Zeichnet das JavApi⁴Swift-Logo via `Toolkit.loadImage(named:)`.
///
/// Plattformspezifisches Bildladen ist vollständig im Toolkit gekapselt —
/// kein `import AppKit` oder `import WinSDK` nötig.
@MainActor
final class LogoCanvas: java.awt.Canvas {
  
  override func paint(_ g: java.awt.Graphics) {
    let w = bounds.width
    let h = bounds.height
    guard w > 0, h > 0 else { return }
    
    // Background
    g.setColor(background)
    g.fillRect(bounds.x, bounds.y, w, h)
    
    // Logo laden über Toolkit — kein plattformspezifischer Code nötig
    let toolkit = java.awt.Toolkit.getDefaultToolkit()
    if let img = toolkit.loadImage(named: "JavApi4Swift256") {
      let side = Swift.min(w, h)
      let ox   = bounds.x + (w - side) / 2
      let oy   = bounds.y + (h - side) / 2
      g.drawImage(img, ox, oy, side, side)
    }
    else {
      // Fallback: Placeholder wenn kein Bild gefunden
      g.setColor(.darkGray)
      g.drawRect(bounds.x + 2, bounds.y + 2, w - 4, h - 4)
      g.drawString("JavApi⁴Swift img not found", bounds.x + w / 2 - 12, bounds.y + h / 2 + 6)
    }
  }
}
