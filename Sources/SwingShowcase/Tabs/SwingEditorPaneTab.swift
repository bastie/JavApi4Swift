/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import JavApi

/// Builds the "JEditorPane" tab for the SwingShowcase.
///
/// Demonstrates `JEditorPane` as the direct superclass of `JTextPane`.
/// Shows content-type switching and the EditorKit API.
@MainActor
class SwingEditorPaneTab {

  static func build() -> javax.swing.JPanel {
    let panel = javax.swing.JPanel(java.awt.BorderLayout())

    // ── JEditorPane ───────────────────────────────────────────────────────────
    let editorPane = javax.swing.JEditorPane()
    editorPane.setEditable(true)
    editorPane.setText(
      "JEditorPane – plain text mode\n\n" +
      "This component is the superclass of JTextPane.\n" +
      "It uses a pluggable EditorKit to handle different content types.\n\n" +
      "Current content type: " + editorPane.getContentType()
    )

    let scrollPane = javax.swing.JScrollPane(editorPane)
    panel.add(scrollPane, java.awt.BorderLayout.CENTER)

    // ── Toolbar ───────────────────────────────────────────────────────────────
    let toolbar = javax.swing.JPanel(java.awt.FlowLayout(java.awt.FlowLayout.LEFT, 4, 4))

    // Content-type label
    let typeLabel = javax.swing.JLabel("Content type: text/plain")
    toolbar.add(typeLabel)

    toolbar.add(javax.swing.JSeparator(javax.swing.JSeparator.VERTICAL))

    // Switch to plain text
    let plainBtn = javax.swing.JButton("text/plain")
    plainBtn.setToolTipText("Switch EditorPane to plain-text mode")
    plainBtn.addActionListener { _ in
      editorPane.setContentType("text/plain")
      editorPane.setText(
        "Content type switched to: " + editorPane.getContentType() + "\n\n" +
        "EditorKit: " + String(describing: type(of: editorPane.getEditorKit()))
      )
      typeLabel.setText("Content type: " + editorPane.getContentType())
    }
    toolbar.add(plainBtn)

    // Switch to HTML (type only — rendering stays plain in this backend)
    let htmlBtn = javax.swing.JButton("text/html")
    htmlBtn.setToolTipText("Switch EditorPane to HTML content type")
    htmlBtn.addActionListener { _ in
      editorPane.setContentType("text/html")
      editorPane.setText(
        "Content type switched to: " + editorPane.getContentType() + "\n\n" +
        "Note: HTML rendering is not yet implemented in JavApi\u{2074}Swift.\n" +
        "The content type is stored and queryable via getContentType()."
      )
      typeLabel.setText("Content type: " + editorPane.getContentType())
    }
    toolbar.add(htmlBtn)

    toolbar.add(javax.swing.JSeparator(javax.swing.JSeparator.VERTICAL))

    // Show EditorKit info
    let kitBtn = javax.swing.JButton("Show EditorKit")
    kitBtn.setToolTipText("Print the active EditorKit class to the text area")
    kitBtn.addActionListener { _ in
      let kit = editorPane.getEditorKit()
      editorPane.setText(
        "Active EditorKit: " + String(describing: type(of: kit)) + "\n" +
        "Content type:     " + kit.getContentType() + "\n" +
        "Document type:    " + String(describing: type(of: editorPane.getDocument()))
      )
    }
    toolbar.add(kitBtn)

    panel.add(toolbar, java.awt.BorderLayout.NORTH)

    // ── Info label ────────────────────────────────────────────────────────────
    let info = javax.swing.JLabel(
      "JEditorPane is the superclass of JTextPane — use EditorKit to extend it.")
    info.setBorder(javax.swing.BorderFactory.createEmptyBorder(4, 8, 4, 8))
    panel.add(info, java.awt.BorderLayout.SOUTH)

    return panel
  }
}
