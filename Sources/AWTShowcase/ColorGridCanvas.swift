/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import JavApi

/// Draws a 5×2 color grid — demonstrates Canvas.paint().
@MainActor
final class ColorGridCanvas: java.awt.Canvas {

  private let colors: [java.awt.Color] = [
    .red, .green, .blue, .yellow, .cyan,
    .magenta, .orange, .pink, .white, .lightGray
  ]

  override func paint(_ g: java.awt.Graphics) {
    let cols  = 5
    let cellW = getWidth()  / cols
    let cellH = getHeight() / 2
    for (i, color) in colors.enumerated() {
      g.setColor(color)
      g.fillRect((i % cols) * cellW,
                 (i / cols) * cellH,
                 cellW, cellH)
    }
    g.setColor(.black)
    g.drawRect(0, 0, getWidth() - 1, getHeight() - 1)
  }
}

