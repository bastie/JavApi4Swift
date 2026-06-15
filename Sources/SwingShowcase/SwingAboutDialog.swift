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

/// Zeichnet das JavApi4Swift-Logo als Swing-JComponent.
@MainActor
final class SwingLogoPanel: javax.swing.JPanel {

  init() {
    super.init()
    setOpaque(true)
    setBackground(java.awt.Color(0x1A, 0x1A, 0x2E))
  }

  override func paintComponent(_ g: java.awt.Graphics) {
    super.paintComponent(g)
    let rect = getBounds()
    let w = rect.width
    let h = rect.height

    // Hintergrund
    g.setColor(java.awt.Color(0x1A, 0x1A, 0x2E))
    g.fillRect(0, 0, w, h)

    // Äußerer Kreis (Java-Orange) — Swift.min statt globalem min
    let cx = w / 2
    let cy = h / 2
    let r  = Swift.min(w, h) / 2 - 10
    g.setColor(java.awt.Color(0xF8, 0x92, 0x17))
    g.fillOval(cx - r, cy - r, r * 2, r * 2)

    // Innerer Kreis (Swift-Hellrot)
    let r2 = r * 2 / 3
    g.setColor(java.awt.Color(0xFF, 0x3B, 0x30))
    g.fillOval(cx - r2, cy - r2, r2 * 2, r2 * 2)

    // "4" in der Mitte — zeichne direkt ohne FontMetrics
    g.setColor(java.awt.Color.white)
    // Einfache Positionierung: leicht links vom Mittelpunkt
    g.drawString("4", cx - 8, cy + 10)
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
