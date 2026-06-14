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
    fileMenu.add(javax.swing.JMenuItem("Open…")).addActionListener { _ in
      print("File > Open…")
    }
    fileMenu.add(javax.swing.JMenuItem("Save…")).addActionListener { _ in
      print("File > Save…")
    }
    fileMenu.addSeparator()
    let quitItem = javax.swing.JMenuItem("Quit")
    quitItem.addActionListener { _ in java.lang.System.exit(0) }
    fileMenu.add(quitItem)
    menuBar.add(fileMenu)

    // Edit menu
    let editMenu = javax.swing.JMenu("Edit")
    editMenu.add(javax.swing.JMenuItem("Cut")).addActionListener { _ in
      print("Edit > Cut")
    }
    editMenu.add(javax.swing.JMenuItem("Copy")).addActionListener { _ in
      print("Edit > Copy")
    }
    editMenu.add(javax.swing.JMenuItem("Paste")).addActionListener { _ in
      print("Edit > Paste")
    }
    menuBar.add(editMenu)

    // Help menu
    let helpMenu = javax.swing.JMenu("Help")
    helpMenu.add(javax.swing.JMenuItem("About…")).addActionListener { _ in
      print("Help > About…")
    }
    menuBar.add(helpMenu)

    frame.setJMenuBar(menuBar)

    return frame
  }
}
