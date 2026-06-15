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
    let openItem = fileMenu.add(javax.swing.JMenuItem("Open…"))
    openItem.addActionListener(SwingPrintActionListener("File > Open…"))
    let saveItem = fileMenu.add(javax.swing.JMenuItem("Save…"))
    saveItem.addActionListener(SwingPrintActionListener("File > Save…"))
    fileMenu.addSeparator()
    let quitItem = fileMenu.add(javax.swing.JMenuItem("Quit"))
    quitItem.addActionListener(SwingQuitListener())
    menuBar.add(fileMenu)

    // Edit menu
    let editMenu = javax.swing.JMenu("Edit")
    let cutItem = editMenu.add(javax.swing.JMenuItem("Cut"))
    cutItem.addActionListener(SwingPrintActionListener("Edit > Cut"))
    let copyItem = editMenu.add(javax.swing.JMenuItem("Copy"))
    copyItem.addActionListener(SwingPrintActionListener("Edit > Copy"))
    let pasteItem = editMenu.add(javax.swing.JMenuItem("Paste"))
    pasteItem.addActionListener(SwingPrintActionListener("Edit > Paste"))
    menuBar.add(editMenu)

    // Demo menu
    let demoMenu = javax.swing.JMenu("Demo")
    let cardItem = demoMenu.add(javax.swing.JMenuItem("CardLayout Dialog…"))
    cardItem.addActionListener(SwingCardLayoutDemoListener(owner: frame))
    let borderItem = demoMenu.add(javax.swing.JMenuItem("BorderLayout Dialog…"))
    borderItem.addActionListener(SwingBorderLayoutDemoListener(owner: frame))
    menuBar.add(demoMenu)

    // Help menu
    let helpMenu = javax.swing.JMenu("Help")
    let aboutItem = helpMenu.add(javax.swing.JMenuItem("About…"))
    aboutItem.addActionListener(SwingPrintActionListener("Help > About…"))
    menuBar.add(helpMenu)

    frame.setJMenuBar(menuBar)

    return frame
  }
}
