/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import JavApi

/// Builds the "Rich Text (JTextPane)" tab for the SwingShowcase.
///
/// Demonstrates `JTextPane` together with `DefaultStyledDocument`,
/// `SimpleAttributeSet`, and `StyleConstants`.  The tab shows:
///
/// - A `JTextPane` with pre-formatted rich text (bold, italic, colors).
/// - Buttons to apply bold / italic / color to the current selection.
/// - A read-only `JTextArea` that mirrors the raw plain text of the document.
@MainActor
class SwingRichTextTab {

  static func build() -> javax.swing.JPanel {
    let panel = javax.swing.JPanel(java.awt.BorderLayout())

    // ── Document & JTextPane ─────────────────────────────────────────────────
    let doc   = javax.swing.text.DefaultStyledDocument()
    let pane  = javax.swing.JTextPane(doc: doc)
    pane.setEditable(true)

    // Pre-populate with styled text
    _fillDemoContent(pane, doc)

    let scrollPane = javax.swing.JScrollPane(pane)
    panel.add(scrollPane, java.awt.BorderLayout.CENTER)

    // ── Toolbar buttons ───────────────────────────────────────────────────────
    let toolbar = javax.swing.JPanel(java.awt.FlowLayout(java.awt.FlowLayout.LEFT, 4, 4))

    // Bold button
    let boldBtn = javax.swing.JButton("Bold")
    boldBtn.addActionListener { _ in
      let attrs = javax.swing.text.SimpleAttributeSet()
      let current = pane.getCharacterAttributes(at: pane.getCaretPosition())
      let isBold = current.map { javax.swing.text.StyleConstants.isBold($0) } ?? false
      javax.swing.text.StyleConstants.setBold(attrs, !isBold)
      pane.setCharacterAttributes(attrs, replace: false)
    }
    toolbar.add(boldBtn)

    // Italic button
    let italicBtn = javax.swing.JButton("Italic")
    italicBtn.addActionListener { _ in
      let attrs = javax.swing.text.SimpleAttributeSet()
      let current = pane.getCharacterAttributes(at: pane.getCaretPosition())
      let isItalic = current.map { javax.swing.text.StyleConstants.isItalic($0) } ?? false
      javax.swing.text.StyleConstants.setItalic(attrs, !isItalic)
      pane.setCharacterAttributes(attrs, replace: false)
    }
    toolbar.add(italicBtn)

    // Underline button
    let underlineBtn = javax.swing.JButton("Underline")
    underlineBtn.addActionListener { _ in
      let attrs = javax.swing.text.SimpleAttributeSet()
      let current = pane.getCharacterAttributes(at: pane.getCaretPosition())
      let isUnderline = current.map { javax.swing.text.StyleConstants.isUnderline($0) } ?? false
      javax.swing.text.StyleConstants.setUnderline(attrs, !isUnderline)
      pane.setCharacterAttributes(attrs, replace: false)
    }
    toolbar.add(underlineBtn)

    toolbar.add(javax.swing.JSeparator(javax.swing.JSeparator.VERTICAL))

    // Color buttons
    let redBtn = javax.swing.JButton("Red")
    redBtn.addActionListener { _ in
      let attrs = javax.swing.text.SimpleAttributeSet()
      javax.swing.text.StyleConstants.setForeground(attrs, java.awt.Color.red)
      pane.setCharacterAttributes(attrs, replace: false)
    }
    toolbar.add(redBtn)

    let blueBtn = javax.swing.JButton("Blue")
    blueBtn.addActionListener { _ in
      let attrs = javax.swing.text.SimpleAttributeSet()
      javax.swing.text.StyleConstants.setForeground(attrs, java.awt.Color.blue)
      pane.setCharacterAttributes(attrs, replace: false)
    }
    toolbar.add(blueBtn)

    let blackBtn = javax.swing.JButton("Black")
    blackBtn.addActionListener { _ in
      let attrs = javax.swing.text.SimpleAttributeSet()
      javax.swing.text.StyleConstants.setForeground(attrs, java.awt.Color.black)
      pane.setCharacterAttributes(attrs, replace: false)
    }
    toolbar.add(blackBtn)

    toolbar.add(javax.swing.JSeparator(javax.swing.JSeparator.VERTICAL))

    // Font size buttons
    let smallBtn = javax.swing.JButton("Small (10)")
    smallBtn.addActionListener { _ in
      let attrs = javax.swing.text.SimpleAttributeSet()
      javax.swing.text.StyleConstants.setFontSize(attrs, 10)
      pane.setCharacterAttributes(attrs, replace: false)
    }
    toolbar.add(smallBtn)

    let largeBtn = javax.swing.JButton("Large (18)")
    largeBtn.addActionListener { _ in
      let attrs = javax.swing.text.SimpleAttributeSet()
      javax.swing.text.StyleConstants.setFontSize(attrs, 18)
      pane.setCharacterAttributes(attrs, replace: false)
    }
    toolbar.add(largeBtn)

    panel.add(toolbar, java.awt.BorderLayout.NORTH)

    // ── Info label ────────────────────────────────────────────────────────────
    let info = javax.swing.JLabel(
      "Select text, then click a button to apply attributes.")
    info.setBorder(javax.swing.BorderFactory.createEmptyBorder(4, 8, 4, 8))
    panel.add(info, java.awt.BorderLayout.SOUTH)

    return panel
  }

  // ── Demo content ─────────────────────────────────────────────────────────────

  private static func _fillDemoContent(
    _ pane: javax.swing.JTextPane,
    _ doc: javax.swing.text.DefaultStyledDocument
  ) {
    // Plain intro line
    try? doc.insertString(0, "JTextPane – Rich Text Demo\n")

    // Bold heading
    let boldAttrs = javax.swing.text.SimpleAttributeSet()
    javax.swing.text.StyleConstants.setBold(boldAttrs, true)
    javax.swing.text.StyleConstants.setFontSize(boldAttrs, 16)
    let headingStart = doc.getLength()
    try? doc.insertString(headingStart, "Styled Text with JTextPane\n")
    doc.setCharacterAttributes(headingStart,
                               doc.getLength() - headingStart,
                               boldAttrs,
                               false)

    // Normal paragraph
    let normalStart = doc.getLength()
    try? doc.insertString(normalStart,
      "This paragraph uses the default attributes — plain, 12pt, black.\n")

    // Italic red sentence
    let italicAttrs = javax.swing.text.SimpleAttributeSet()
    javax.swing.text.StyleConstants.setItalic(italicAttrs, true)
    javax.swing.text.StyleConstants.setForeground(italicAttrs, java.awt.Color.red)
    let italicStart = doc.getLength()
    try? doc.insertString(italicStart, "This sentence is italic and red.\n")
    doc.setCharacterAttributes(italicStart,
                               doc.getLength() - italicStart,
                               italicAttrs,
                               false)

    // Blue large text
    let bigBlueAttrs = javax.swing.text.SimpleAttributeSet()
    javax.swing.text.StyleConstants.setFontSize(bigBlueAttrs, 18)
    javax.swing.text.StyleConstants.setForeground(bigBlueAttrs, java.awt.Color.blue)
    let bigStart = doc.getLength()
    try? doc.insertString(bigStart, "Large blue text (18pt).\n")
    doc.setCharacterAttributes(bigStart,
                               doc.getLength() - bigStart,
                               bigBlueAttrs,
                               false)

    // Mixed: bold + underline
    let mixedAttrs = javax.swing.text.SimpleAttributeSet()
    javax.swing.text.StyleConstants.setBold(mixedAttrs, true)
    javax.swing.text.StyleConstants.setUnderline(mixedAttrs, true)
    let mixedStart = doc.getLength()
    try? doc.insertString(mixedStart, "Bold and underlined.\n")
    doc.setCharacterAttributes(mixedStart,
                               doc.getLength() - mixedStart,
                               mixedAttrs,
                               false)

    pane.setCaretPosition(0)
  }
}
