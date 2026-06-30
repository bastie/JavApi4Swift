/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import JavApi

/// Demonstrates `java.awt.PrintJob` (Java 1.1 print API).
///
/// Obtains a `PrintJob` via `Toolkit.getPrintJob()`, renders a demo page
/// using the returned `Graphics`, and finalises with `end()`.
@MainActor
final class SwingPrint11Action: SwingShowcaseAction {

  private weak var owner: javax.swing.JFrame?

  init(owner: javax.swing.JFrame) {
    self.owner = owner
    super.init("Print (Java 1.1 API)…")
    putValue(SwingPrint11Action.SHORT_DESCRIPTION,
             "Print via java.awt.Toolkit.getPrintJob (Java 1.1)" as AnyObject)
  }

  override func actionPerformed(_ e: java.awt.event.ActionEvent) {
    guard let frame = owner else { return }

    guard let job = java.awt.Toolkit.getDefaultToolkit()
            .getPrintJob(frame, "SwingShowcase – Java 1.1 Print Demo", nil) else {
      javax.swing.JOptionPane.showMessageDialog(
        frame,
        "No printer available or print cancelled.",
        "Print (Java 1.1)",
        javax.swing.JOptionPane.INFORMATION_MESSAGE)
      return
    }

    guard let g = job.getGraphics() else {
      job.end()
      return
    }

    // Render demo page
    let dim = job.getPageDimension()
    let x   = 72          // 1-inch left margin
    var y   = 72 + 40     // 1-inch top margin + offset

    g.setFont(java.awt.Font("SansSerif", java.awt.Font.BOLD, 18))
    g.drawString("JavApi⁴Swift – java.awt.PrintJob Demo (Java 1.1)", x, y)
    y += 30

    g.setFont(java.awt.Font("SansSerif", java.awt.Font.PLAIN, 12))
    g.drawString("This page was rendered via the Java 1.1 print API.", x, y)
    y += 20
    g.drawString("Toolkit.getPrintJob()  →  PrintJob  →  Graphics", x, y)
    y += 20
    g.drawString("Page size: \(dim.width) × \(dim.height) px", x, y)
    y += 20
    g.drawString("Resolution: \(job.getPageResolution()) dpi", x, y)

    g.dispose()
    job.end()
  }
}
