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

    // LayoutManager menu
    let layoutMenu = javax.swing.JMenu("LayoutManager")
    let blItem = layoutMenu.add(javax.swing.JMenuItem("BorderLayout…"))
    blItem.addActionListener(SwingBorderLayoutDemoListener(owner: frame))
    let flItem = layoutMenu.add(javax.swing.JMenuItem("FlowLayout…"))
    flItem.addActionListener(SwingFlowLayoutDemoListener(owner: frame))
    let glItem = layoutMenu.add(javax.swing.JMenuItem("GridLayout…"))
    glItem.addActionListener(SwingGridLayoutDemoListener(owner: frame))
    let clItem = layoutMenu.add(javax.swing.JMenuItem("CardLayout…"))
    clItem.addActionListener(SwingCardLayoutDemoListener(owner: frame))
    layoutMenu.addSeparator()
    let gbItem = layoutMenu.add(javax.swing.JMenuItem("GridBagLayout…"))
    gbItem.addActionListener(SwingGridBagLayoutDemoListener(owner: frame))
    menuBar.add(layoutMenu)

    // Help menu
    let helpMenu = javax.swing.JMenu("Help")
    let aboutItem = helpMenu.add(javax.swing.JMenuItem("About JavApi⁴Swift…"))
    aboutItem.addActionListener(SwingAboutListener(owner: frame))
    menuBar.add(helpMenu)

    frame.setJMenuBar(menuBar)

    // ── JToolBar ─────────────────────────────────────────────────────────────
    let toolbar = javax.swing.JToolBar()

    // File group: Open, Save  |  Quit
    let toolkit = java.awt.Toolkit.getDefaultToolkit()

    func makeBtn(_ label: String, _ imageName: String,
                 _ listener: java.awt.event.ActionListener) -> javax.swing.JButton {
      let btn: javax.swing.JButton
      if let img = toolkit.loadImage(named: imageName) {
        let icon = javax.swing.ImageIcon(img, width: 16, height: 16)
        btn = javax.swing.JButton(icon: icon)
      } else {
        btn = javax.swing.JButton(label)
      }
      btn.setPreferredSize(java.awt.Dimension(28, 28))
      btn.addActionListener(listener)
      return btn
    }

    toolbar.add(makeBtn("Open",  "toolbar-open",  SwingPrintActionListener("File > Open…")))
    toolbar.add(makeBtn("Save",  "toolbar-save",  SwingPrintActionListener("File > Save…")))
    toolbar.addSeparator()

    // Edit group: Cut, Copy, Paste
    toolbar.add(makeBtn("Cut",   "toolbar-cut",   SwingPrintActionListener("Edit > Cut")))
    toolbar.add(makeBtn("Copy",  "toolbar-copy",  SwingPrintActionListener("Edit > Copy")))
    toolbar.add(makeBtn("Paste", "toolbar-paste", SwingPrintActionListener("Edit > Paste")))
    toolbar.addSeparator()

    // LayoutManager group
    toolbar.add(makeBtn("BL",  "toolbar-border",   SwingBorderLayoutDemoListener(owner: frame)))
    toolbar.add(makeBtn("FL",  "toolbar-flow",     SwingFlowLayoutDemoListener(owner: frame)))
    toolbar.add(makeBtn("GL",  "toolbar-grid",     SwingGridLayoutDemoListener(owner: frame)))
    toolbar.add(makeBtn("CL",  "toolbar-card",     SwingCardLayoutDemoListener(owner: frame)))
    toolbar.add(makeBtn("GBL", "toolbar-gridbag",  SwingGridBagLayoutDemoListener(owner: frame)))
    toolbar.addSeparator()

    // Help group
    toolbar.add(makeBtn("About", "JavApi4Swift256", SwingAboutListener(owner: frame)))

    frame.add(toolbar, java.awt.BorderLayout.NORTH)

    return frame
  }
}
