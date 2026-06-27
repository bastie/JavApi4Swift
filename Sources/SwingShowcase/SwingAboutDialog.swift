/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import JavApi

/// Swing-Pendant zu `AboutListener` im AWTShowcase.
///
/// Zeigt einen modalen About-Dialog mit Logo (als JPanel paintComponent),
/// Projektname und einem Schließen-Button.
@MainActor
final class SwingAboutDialog: javax.swing.JDialog {

  init(_ owner: javax.swing.JFrame) {
    super.init(owner, "About JavApi⁴Swift", true)
    setSize(320, 260)

    // Logo-Panel (zeichnet das JavApi4Swift-Logo via paintComponent)
    let logo = SwingLogoPanel()
    logo.setPreferredSize(java.awt.Dimension(320, 140))
    add(logo, java.awt.BorderLayout.NORTH)

    // Info-Label
    let info = javax.swing.JLabel("JavApi⁴Swift  •  Java Swing 4 Swift")
    info.setHorizontalAlignment(javax.swing.JLabel.CENTER)
    info.setPreferredSize(java.awt.Dimension(320, 40))
    add(info, java.awt.BorderLayout.CENTER)

    // Schließen-Button
    let south = javax.swing.JPanel(java.awt.FlowLayout(java.awt.FlowLayout.CENTER))
    south.setPreferredSize(java.awt.Dimension(320, 50))
    let closeBtn = javax.swing.JButton("Close")
    closeBtn.setPreferredSize(java.awt.Dimension(100, 30))
    closeBtn.addActionListener(SwingDialogCloseListener(dialog: self))
    south.add(closeBtn)
    add(south, java.awt.BorderLayout.SOUTH)
  }
}

// ---------------------------------------------------------------------------
// MARK: - Logo panel (Swing-Äquivalent zu LogoCanvas)
// ---------------------------------------------------------------------------

/// Zeigt das JavApi4Swift-Logo — analog zu `LogoCanvas` im AWTShowcase,
/// aber als Swing-JPanel mit `paintComponent`.
@MainActor
final class SwingLogoPanel: javax.swing.JPanel {

  init() {
    super.init()
    setOpaque(true)
    setBackground(java.awt.SystemColor.window)
  }

  override func paintComponent(_ g: java.awt.Graphics) {
    super.paintComponent(g)
    let w = getWidth()
    let h = getHeight()
    guard w > 0, h > 0 else { return }

    // Hintergrund
    g.setColor(getBackground())
    g.fillRect(0, 0, w, h)

    // Logo laden — gleiche Asset-Quelle wie im AWTShowcase
    let toolkit = java.awt.Toolkit.getDefaultToolkit()
    if let img = toolkit.loadImage("JavApi4Swift256") {
      let side = Swift.min(w, h)
      let ox = (w - side) / 2
      let oy = (h - side) / 2
      g.drawImage(img, ox, oy, side, side)
    } else {
      // Fallback: Platzhalter-Text
      g.setColor(java.awt.SystemColor.controlText)
      g.drawString("JavApi⁴Swift", w / 2 - 30, h / 2)
    }
  }
}

// ---------------------------------------------------------------------------
// MARK: - Listener
// ---------------------------------------------------------------------------

@MainActor
final class SwingAboutListener: java.awt.event.ActionListener {
  private weak var owner: javax.swing.JFrame?
  init(owner: javax.swing.JFrame) { self.owner = owner }

  func actionPerformed(_ e: java.awt.event.ActionEvent) {
    guard let owner else { return }
    SwingAboutDialog(owner).setVisible(true)
  }
}
