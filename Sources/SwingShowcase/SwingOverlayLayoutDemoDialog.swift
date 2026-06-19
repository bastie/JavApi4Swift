/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import JavApi

/// Demonstriert `OverlayLayout` — Komponenten werden übereinandergelegt.
///
/// Drei farbige Panels mit unterschiedlicher Größe und Ausrichtung werden
/// im selben Container gestapelt. Die Alignment-Werte steuern, wie die
/// Komponenten relativ zum gemeinsamen Ankerpunkt positioniert werden.
///
/// ```
/// ┌──────────────────────────────────────────┐
/// │  OverlayLayout — Komponenten stapeln     │
/// ├──────────────────────────────────────────┤
/// │                                          │
/// │   ┌──────────────────────────────┐       │
/// │   │  Blau (200×140, center/center│       │
/// │   │   ┌─────────────────┐        │       │
/// │   │   │ Grün (160×100)  │        │       │
/// │   │   │  ┌──────────┐   │        │       │
/// │   │   │  │Rot(80×60)│   │        │       │
/// │   │   │  └──────────┘   │        │       │
/// │   │   └─────────────────┘        │       │
/// │   └──────────────────────────────┘       │
/// │                           [Schließen]    │
/// └──────────────────────────────────────────┘
/// ```
@MainActor
final class SwingOverlayLayoutDemoDialog: javax.swing.JDialog {

  init(_ owner: javax.swing.JFrame) {
    super.init(owner, "LayoutManager – OverlayLayout", false)
    setSize(440, 320)

    // ── Titel ────────────────────────────────────────────────────────────────
    let title = javax.swing.JLabel("OverlayLayout — Komponenten übereinanderlegen")
    title.setHorizontalAlignment(javax.swing.JLabel.CENTER)
    add(title, java.awt.BorderLayout.NORTH)

    // ── Overlay-Container ────────────────────────────────────────────────────
    // Alle drei Panels werden im selben Container gestapelt.
    // alignmentX = alignmentY = 0.5 → alle zentriert übereinander.
    let overlay = javax.swing.JPanel()
    overlay.setLayout(javax.swing.OverlayLayout(overlay))
    overlay.setPreferredSize(java.awt.Dimension(400, 200))

    // Hintergrund: groß, blau
    let back = javax.swing.JPanel(java.awt.BorderLayout())
    back.setBackground(java.awt.Color(0x4472C4))   // Blau
    back.setPreferredSize(java.awt.Dimension(200, 140))
    back.setAlignmentX(0.5)
    back.setAlignmentY(0.5)
    let backLabel = javax.swing.JLabel("Blau 200×140 (center)")
    backLabel.setHorizontalAlignment(javax.swing.JLabel.CENTER)
    backLabel.setForeground(java.awt.Color.white)
    back.add(backLabel, java.awt.BorderLayout.SOUTH)

    // Mittelschicht: mittelgroß, grün
    let mid = javax.swing.JPanel(java.awt.BorderLayout())
    mid.setBackground(java.awt.Color(0x70AD47))    // Grün
    mid.setPreferredSize(java.awt.Dimension(140, 100))
    mid.setAlignmentX(0.5)
    mid.setAlignmentY(0.5)
    let midLabel = javax.swing.JLabel("Grün 140×100")
    midLabel.setHorizontalAlignment(javax.swing.JLabel.CENTER)
    midLabel.setForeground(java.awt.Color.white)
    mid.add(midLabel, java.awt.BorderLayout.CENTER)

    // Vordergrund: klein, rot
    let front = javax.swing.JPanel(java.awt.BorderLayout())
    front.setBackground(java.awt.Color(0xFF0000))  // Rot
    front.setPreferredSize(java.awt.Dimension(80, 60))
    front.setAlignmentX(0.5)
    front.setAlignmentY(0.5)
    let frontLabel = javax.swing.JLabel("Rot 80×60")
    frontLabel.setHorizontalAlignment(javax.swing.JLabel.CENTER)
    frontLabel.setForeground(java.awt.Color.white)
    front.add(frontLabel, java.awt.BorderLayout.CENTER)

    // Reihenfolge: zuerst hinzugefügt = unten gemalt
    overlay.add(back)
    overlay.add(mid)
    overlay.add(front)

    // Erklärungstext
    let info = javax.swing.JLabel(
      "alignmentX/Y = 0.5 → alle Ebenen zentriert übereinander"
    )
    info.setHorizontalAlignment(javax.swing.JLabel.CENTER)

    let content = javax.swing.JPanel(java.awt.BorderLayout())
    content.add(overlay, java.awt.BorderLayout.CENTER)
    content.add(info, java.awt.BorderLayout.SOUTH)
    add(content, java.awt.BorderLayout.CENTER)

    // ── Schließen ────────────────────────────────────────────────────────────
    let south = javax.swing.JPanel(java.awt.FlowLayout(java.awt.FlowLayout.RIGHT, 8, 6))
    let closeBtn = javax.swing.JButton("Schließen")
    closeBtn.addActionListener(SwingDialogCloseListener(dialog: self))
    south.add(closeBtn)
    add(south, java.awt.BorderLayout.SOUTH)
  }
}
