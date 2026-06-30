/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import JavApi

/// Demonstrates `java.awt.print.PrinterJob` (Java 1.2 print API).
///
/// Builds a one-page `Printable` that draws a short text block and
/// the current date, then sends it to the system printer via
/// `PrinterJob.getPrinterJob()`.
@MainActor
final class SwingPrint12Action: SwingShowcaseAction {

  private weak var owner: javax.swing.JFrame?

  init(owner: javax.swing.JFrame) {
    self.owner = owner
    super.init("Print (Java 1.2 API)…")
    putValue(SwingPrint12Action.SHORT_DESCRIPTION,
             "Print via java.awt.print.PrinterJob" as AnyObject)
  }

  override func actionPerformed(_ e: java.awt.event.ActionEvent) {
    let job = java.awt.print.PrinterJob.getPrinterJob()
    job.jobName = "SwingShowcase – Java 1.2 Print Demo"

    let pf = job.defaultPage()
    job.setPrintable(ShowcasePrintable(), pf)

    // Show print dialog; proceed only if user confirmed
    guard job.printDialog() else { return }

    do {
      try job.print()
    } catch {
      let msg = "Printing failed: \(error)"
      javax.swing.JOptionPane.showMessageDialog(
        owner,
        msg,
        "Print Error",
        javax.swing.JOptionPane.ERROR_MESSAGE)
    }
  }
}

// ---------------------------------------------------------------------------
// MARK: - Printable content
// ---------------------------------------------------------------------------

/// Renders a simple demo page using the Java 1.2 `Printable` protocol.
private final class ShowcasePrintable: java.awt.print.Printable {
  

  func print(_ graphics: java.awt.Graphics,
             _ pageFormat: java.awt.print.PageFormat,
             _ pageIndex: Int) -> Int {
    guard pageIndex == 0 else {
      return ShowcasePrintable.NO_SUCH_PAGE
    }

    let x = Int(pageFormat.getImageableX()) + 20
    var y = Int(pageFormat.getImageableY()) + 40

    graphics.setFont(java.awt.Font("SansSerif", java.awt.Font.BOLD, 18))
    graphics.drawString("JavApi⁴Swift – java.awt.print Demo", x, y)
    y += 30

    graphics.setFont(java.awt.Font("SansSerif", java.awt.Font.PLAIN, 12))
    graphics.drawString("This page was rendered via the Java 1.2 print API.", x, y)
    y += 20
    graphics.drawString("PrinterJob  →  Printable  →  PageFormat  →  Paper", x, y)
    y += 20
    graphics.drawString("Page size: \(Int(pageFormat.getWidth())) × \(Int(pageFormat.getHeight())) pt", x, y)
    y += 20
    graphics.drawString("Imageable: \(Int(pageFormat.getImageableWidth())) × \(Int(pageFormat.getImageableHeight())) pt", x, y)

    return ShowcasePrintable.PAGE_EXISTS
  }
}
