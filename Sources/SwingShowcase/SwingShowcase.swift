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

    // ── Actions (shared between menu items and toolbar buttons) ──────────────
    let openAction       = SwingOpenAction()
    let saveAction       = SwingSaveAction()
    let quitAction       = SwingQuitAction()

    let cutAction        = SwingCutAction()
    let copyAction       = SwingCopyAction()
    let pasteAction      = SwingPasteAction()

    let borderAction     = SwingBorderLayoutAction(owner: frame)
    let flowAction       = SwingFlowLayoutAction(owner: frame)
    let gridAction       = SwingGridLayoutAction(owner: frame)
    let cardAction       = SwingCardLayoutAction(owner: frame)
    let gridBagAction    = SwingGridBagLayoutAction(owner: frame)

    let aboutAction      = SwingAboutAction(owner: frame)

    // ── JMenuBar ─────────────────────────────────────────────────────────────
    let menuBar = javax.swing.JMenuBar()

    // File menu
    let fileMenu = javax.swing.JMenu("File")
    fileMenu.add(openAction)
    fileMenu.add(saveAction)
    fileMenu.addSeparator()
    fileMenu.add(quitAction)
    menuBar.add(fileMenu)

    // Edit menu
    let editMenu = javax.swing.JMenu("Edit")
    editMenu.add(cutAction)
    editMenu.add(copyAction)
    editMenu.add(pasteAction)
    menuBar.add(editMenu)

    // LayoutManager menu
    let layoutMenu = javax.swing.JMenu("LayoutManager")
    layoutMenu.add(borderAction)
    layoutMenu.add(flowAction)
    layoutMenu.add(gridAction)
    layoutMenu.add(cardAction)
    layoutMenu.addSeparator()
    layoutMenu.add(gridBagAction)
    menuBar.add(layoutMenu)

    // Help menu
    let helpMenu = javax.swing.JMenu("Help")
    helpMenu.add(aboutAction)
    menuBar.add(helpMenu)

    frame.setJMenuBar(menuBar)

    // ── JToolBar ─────────────────────────────────────────────────────────────
    let toolbar = javax.swing.JToolBar()

    // File group
    toolbar.add(openAction)
    toolbar.add(saveAction)
    toolbar.addSeparator()

    // Edit group
    toolbar.add(cutAction)
    toolbar.add(copyAction)
    toolbar.add(pasteAction)
    toolbar.addSeparator()

    // LayoutManager group
    toolbar.add(borderAction)
    toolbar.add(flowAction)
    toolbar.add(gridAction)
    toolbar.add(cardAction)
    toolbar.add(gridBagAction)
    toolbar.addSeparator()

    // Help group
    toolbar.add(aboutAction)

    frame.add(toolbar, java.awt.BorderLayout.NORTH)

    return frame
  }
}
