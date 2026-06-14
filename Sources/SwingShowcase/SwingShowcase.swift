/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import JavApi

// ---------------------------------------------------------------------------
// MARK: - Application entry point
// ---------------------------------------------------------------------------

@main
struct SwingShowcaseApp {

  @MainActor
  static func main() {
    java.awt.EventQueue.invokeLater {
      SwingShowcaseApp().buildShowcase().setVisible(true)
    }
    java.awt.Toolkit.getDefaultToolkit().runEventLoop()
  }

  @MainActor
  private func buildShowcase() -> javax.swing.JFrame {
    let frame = javax.swing.JFrame("JavApi⁴Swift – Swing Showcase")
    frame.setSize(520, 400)
    frame.setDefaultCloseOperation(javax.swing.JFrame.EXIT_ON_CLOSE)

    // ── JMenuBar ─────────────────────────────────────────────────────────────
    let menuBar = javax.swing.JMenuBar()

    // File menu
    let fileMenu = javax.swing.JMenu("File")
    fileMenu.add(javax.swing.JMenuItem("Open…"))
      .addActionListener(SwingPrintActionListener("File > Open…"))
    fileMenu.add(javax.swing.JMenuItem("Save…"))
      .addActionListener(SwingPrintActionListener("File > Save…"))
    fileMenu.addSeparator()
    fileMenu.add(javax.swing.JMenuItem("Quit"))
      .addActionListener(SwingQuitListener())
    menuBar.add(fileMenu)

    // Edit menu
    let editMenu = javax.swing.JMenu("Edit")
    editMenu.add(javax.swing.JMenuItem("Cut"))
      .addActionListener(SwingPrintActionListener("Edit > Cut"))
    editMenu.add(javax.swing.JMenuItem("Copy"))
      .addActionListener(SwingPrintActionListener("Edit > Copy"))
    editMenu.add(javax.swing.JMenuItem("Paste"))
      .addActionListener(SwingPrintActionListener("Edit > Paste"))
    menuBar.add(editMenu)

    // Demo menu
    let demoMenu = javax.swing.JMenu("Demo")
    demoMenu.add(javax.swing.JMenuItem("CardLayout Dialog…"))
      .addActionListener(SwingCardLayoutDemoListener(owner: frame))
    demoMenu.add(javax.swing.JMenuItem("BorderLayout Dialog…"))
      .addActionListener(SwingBorderLayoutDemoListener(owner: frame))
    menuBar.add(demoMenu)

    // Help menu
    let helpMenu = javax.swing.JMenu("Help")
    helpMenu.add(javax.swing.JMenuItem("About…"))
      .addActionListener(SwingPrintActionListener("Help > About…"))
    menuBar.add(helpMenu)

    frame.setJMenuBar(menuBar)

    return frame
  }
}
