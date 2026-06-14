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

    // Demo menu — opens the CardLayout dialog
    let demoMenu = javax.swing.JMenu("Demo")
    let cardDialogItem = javax.swing.JMenuItem("CardLayout Dialog…")
    cardDialogItem.addActionListener { [frame] _ in
      SwingShowcaseApp().showCardDialog(owner: frame)
    }
    demoMenu.add(cardDialogItem)
    menuBar.add(demoMenu)

    // Help menu
    let helpMenu = javax.swing.JMenu("Help")
    helpMenu.add(javax.swing.JMenuItem("About…")).addActionListener { _ in
      print("Help > About…")
    }
    menuBar.add(helpMenu)

    frame.setJMenuBar(menuBar)

    return frame
  }

  // -------------------------------------------------------------------------
  // MARK: - CardLayout dialog
  // -------------------------------------------------------------------------

  /// A non-modal JDialog that demonstrates CardLayout navigation.
  ///
  /// Three coloured cards are stacked in a CardLayout panel (analogous to
  /// AWTShowcase's CardLayoutDemoDialog).  ◀ / ▶ buttons cycle through them;
  /// "Schließen" dismisses the dialog.
  @MainActor
  private func showCardDialog(owner: javax.swing.JFrame) {
    let dialog = javax.swing.JDialog(owner: owner, title: "LayoutManager – CardLayout", modal: false)
    dialog.setSize(380, 240)

    // Title label
    let title = javax.swing.JLabel("CardLayout — 3 Karten, umschaltbar per ◀ ▶")
    title.setHorizontalAlignment(javax.swing.JLabel.CENTER)
    dialog.add(title, java.awt.BorderLayout.NORTH)

    // Card demo panel (coloured cards + ◀ ▶ navigation)
    let cardDemo = SwingCardDemoPanel()
    dialog.add(cardDemo, java.awt.BorderLayout.CENTER)

    // Close button
    let closeBtn = javax.swing.JButton("Schließen")
    closeBtn.addActionListener { [dialog] _ in
      dialog.setVisible(false)
    }
    let south = javax.swing.JPanel()
    south.setLayout(java.awt.FlowLayout())
    south.add(closeBtn)
    dialog.add(south, java.awt.BorderLayout.SOUTH)

    dialog.setVisible(true)
  }
}
