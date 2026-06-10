/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import JavApi

/// Draws sample polygons — demonstrates drawPolygon/fillPolygon.
@MainActor
final class PolygonCanvas: java.awt.Canvas {
  override func paint(_ g: java.awt.Graphics) {
    let w = bounds.width, h = bounds.height
    guard w > 4, h > 4 else { return }
    
    // Hintergrund
    g.setColor(.darkGray)
    g.fillRect(bounds.x, bounds.y, w, h)
    
    let ox = bounds.x, oy = bounds.y
    
    // Gefülltes Dreieck (blau)
    g.setColor(.blue)
    let tri = java.awt.Polygon(
      xpoints: [ox + w/2,  ox + w - 4, ox + 4],
      ypoints: [oy + 4,    oy + h/2,   oy + h/2],
      npoints: 3)
    g.fillPolygon(tri)
    
    // Umriss-Stern (gelb) — 6-Punkt-Stern über zwei Dreiecke
    g.setColor(.yellow)
    let cx = ox + w/2, cy = oy + h*3/4
    let r1 = Swift.min(w, h) / 5
    let r2 = r1 / 2
    var sx = [Int](), sy = [Int]()
    for i in 0..<6 {
      let angle1 = Double(i) * Double.pi / 3.0 - Double.pi / 2
      let angle2 = angle1 + Double.pi / 6.0
      sx.append(cx + Int(Double(r1) * Math.cos(angle1)))
      sy.append(cy + Int(Double(r1) * Math.sin(angle1)))
      sx.append(cx + Int(Double(r2) * Math.cos(angle2)))
      sy.append(cy + Int(Double(r2) * Math.sin(angle2)))
    }
    g.drawPolygon(sx, sy, 12)
    
    // Label
    g.setColor(.white)
    g.drawString("Polygon", ox + 2, oy + h - 4)
  }
}
