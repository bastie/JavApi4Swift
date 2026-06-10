/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import JavApi

/// Draws a 5×2 colour grid — demonstrates Canvas.paint().
@MainActor
final class ColourGridCanvas: java.awt.Canvas {
  
  private let colours: [java.awt.Color] = [
    .red, .green, .blue, .yellow, .cyan,
    .magenta, .orange, .pink, .white, .lightGray
  ]
  
  override func paint(_ g: java.awt.Graphics) {
    let cols  = 5
    let cellW = bounds.width  / cols
    let cellH = bounds.height / 2
    for (i, colour) in colours.enumerated() {
      g.setColor(colour)
      g.fillRect((i % cols) * cellW,
                 (i / cols) * cellH,
                 cellW, cellH)
    }
    g.setColor(.black)
    g.drawRect(0, 0, bounds.width - 1, bounds.height - 1)
  }
}

