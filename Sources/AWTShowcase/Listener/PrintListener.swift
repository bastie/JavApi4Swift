/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import JavApi

/// ActionListener that prints a sample page via `java.awt.PrintJob`.
///
/// Shows the native print panel; if the user confirms, renders a simple
/// demo page with title, lines of text, and a coloured rectangle, then
/// opens the result in Preview.app.
@MainActor
final class PrintListener: java.awt.event.ActionListener {

  private weak var frame: java.awt.Frame?

  init(frame: java.awt.Frame) {
    self.frame = frame
  }

  func actionPerformed(_ e: java.awt.event.ActionEvent) {
    guard let frame else { return }

    let toolkit = java.awt.Toolkit.getDefaultToolkit()
    guard let job = toolkit.getPrintJob(frame, "JavApi⁴Swift – Sample Page", nil) else {
      System.out.println("PrintJob: cancelled")
      return
    }

    guard let g = job.getGraphics() else {
      job.end()
      return
    }

    drawSamplePage(g, pageSize: job.getPageDimension())

    job.end()
    System.out.println("PrintJob: done")
  }

  // ---------------------------------------------------------------------------
  // MARK: Sample page content
  // ---------------------------------------------------------------------------

  private func drawSamplePage(_ g: java.awt.Graphics, pageSize: java.awt.Dimension) {
    let w = pageSize.width
    let margin = 50

    // Background
    g.setColor(java.awt.Color.white)
    g.fillRect(0, 0, w, pageSize.height)

    // Title bar
    g.setColor(java.awt.Color(0x003366))
    g.fillRect(margin, margin, w - margin * 2, 48)

    g.setColor(java.awt.Color.white)
    g.setFont(java.awt.Font("SansSerif", java.awt.Font.BOLD, 24))
    g.drawString("JavApi⁴Swift – AWT Showcase", margin + 12, margin + 32)

    // Subtitle
    g.setColor(java.awt.Color(0x003366))
    g.setFont(java.awt.Font("SansSerif", java.awt.Font.PLAIN, 13))
    g.drawString("java.awt.PrintJob  ·  JFC 1.0 compatible  ·  Swift 6", margin, margin + 80)

    // Separator line
    g.setColor(java.awt.Color(0x003366))
    g.drawLine(margin, margin + 90, w - margin, margin + 90)

    // Info lines
    g.setColor(java.awt.Color.black)
    g.setFont(java.awt.Font("Monospaced", java.awt.Font.PLAIN, 12))
    let lines = [
      "Page size : \(pageSize.width) × \(pageSize.height) pt",
      "Resolution: \(72) dpi",
      "Renderer  : CoreGraphics PDF context",
      "Platform  : \((try? System.getProperty("os.name")) ?? "macOS")",
    ]
    var y = margin + 120
    for line in lines {
      g.drawString(line, margin, y)
      y += 20
    }

    // Colour swatches
    let colours: [(java.awt.Color, String)] = [
      (.red,     "Red"),
      (.green,   "Green"),
      (.blue,    "Blue"),
      (java.awt.Color(255, 165, 0), "Orange"),
      (.cyan,    "Cyan"),
      (.magenta, "Magenta"),
    ]
    var swatchX = margin
    let swatchY = y + 20
    for (colour, name) in colours {
      g.setColor(colour)
      g.fillRect(swatchX, swatchY, 60, 40)
      g.setColor(java.awt.Color.black)
      g.drawRect(swatchX, swatchY, 60, 40)
      g.setFont(java.awt.Font("SansSerif", java.awt.Font.PLAIN, 10))
      g.drawString(name, swatchX + 4, swatchY + 54)
      swatchX += 72
    }

    // Border around the whole page
    g.setColor(java.awt.Color(0x003366))
    g.drawRect(margin - 4, margin - 4,
               w - (margin - 4) * 2,
               pageSize.height - (margin - 4) * 2)
  }
}
