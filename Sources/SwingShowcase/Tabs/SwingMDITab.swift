/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import JavApi

/// Builds the "MDI" tab for the SwingShowcase.
///
/// Demonstrates `JDesktopPane`, `JInternalFrame`, `DefaultDesktopManager`,
/// and `InternalFrameListener` / `InternalFrameAdapter`.
@MainActor
class SwingMDITab {

  static func build() -> javax.swing.JPanel {
    let outer = javax.swing.JPanel(java.awt.BorderLayout())

    // ── Control toolbar ───────────────────────────────────────────────────────
    let controlPanel = javax.swing.JPanel(java.awt.FlowLayout(java.awt.FlowLayout.LEFT))

    let desktop = javax.swing.JDesktopPane()
    var frameCounter = 0

    // "New Frame" button
    let newBtn = javax.swing.JButton("New Frame")
    // statusLabel wird weiter unten erzeugt — Referenz via Array-Wrapper um capture zu ermöglichen
    var statusLabelRef: [javax.swing.JLabel] = []
    newBtn.addActionListener(MDINewFrameAction(desktop: desktop,
                                               counter: { frameCounter += 1; return frameCounter },
                                               statusLabelRef: statusLabelRef))
    controlPanel.add(newBtn)

    // "Close All" button
    let closeAllBtn = javax.swing.JButton("Close All")
    closeAllBtn.addActionListener(MDICloseAllAction(desktop: desktop))
    controlPanel.add(closeAllBtn)

    // Drag mode selector
    controlPanel.add(javax.swing.JLabel("Drag mode:"))
    let dragCombo = javax.swing.JComboBox<String>(["Live", "Outline"])
    dragCombo.addItemListener(MDIDragModeListener(desktop: desktop))
    controlPanel.add(dragCombo)

    // Status label
    let statusLabel = javax.swing.JLabel("No frame selected")
    statusLabelRef.append(statusLabel)
    controlPanel.add(statusLabel)

    // ── JDesktopPane ──────────────────────────────────────────────────────────
    desktop.setPreferredSize(java.awt.Dimension(700, 450))

    // Pre-populate with three demo frames
    for i in 1...3 {
      let f = makeDemoFrame(title: "Document \(i)", x: 20 + (i - 1) * 60, y: 20 + (i - 1) * 40,
                            statusLabel: statusLabel)
      desktop.add(f)
      f.setVisible(true)
    }
    frameCounter = 3

    // Wire "New Frame" counter into action after initial frames are set up
    // (already captured via closure above)

    outer.add(controlPanel, java.awt.BorderLayout.NORTH)
    outer.add(desktop,      java.awt.BorderLayout.CENTER)
    return outer
  }

  // MARK: - Factory

  static func makeDemoFrame(
    title: String,
    x: Int,
    y: Int,
    statusLabel: javax.swing.JLabel
  ) -> javax.swing.JInternalFrame {

    let frame = javax.swing.JInternalFrame(
      title,
      resizable:   true,
      closable:    true,
      maximizable: true,
      iconifiable: true
    )
    frame.setSize(260, 160)
    frame.setLocation(x, y)

    // ── Content ────────────────────────────────────────────────────────────
    let content = javax.swing.JPanel(java.awt.BorderLayout())

    let textArea = javax.swing.JTextArea("Content of \(title)\n\nEdit me freely.")
    textArea.setLineWrap(true)
    textArea.setWrapStyleWord(true)
    content.add(javax.swing.JScrollPane(textArea), java.awt.BorderLayout.CENTER)

    let btnPanel = javax.swing.JPanel(java.awt.FlowLayout(java.awt.FlowLayout.RIGHT))
    let closeBtn = javax.swing.JButton("Close")
    closeBtn.addActionListener(MDICloseSingleFrameAction(frame: frame))
    btnPanel.add(closeBtn)
    content.add(btnPanel, java.awt.BorderLayout.SOUTH)

    frame.setContentPane(content)

    // ── Listener ────────────────────────────────────────────────────────────
    frame.addInternalFrameListener(MDIStatusListener(label: statusLabel, frameTitle: title))

    return frame
  }
}

// MARK: - Actions & Listeners

/// Opens a new `JInternalFrame` on the desktop.
@MainActor
private class MDINewFrameAction: javax.swing.AbstractAction {
  private let desktop: javax.swing.JDesktopPane
  private let counter: () -> Int
  private let statusLabelRef: [javax.swing.JLabel]

  init(desktop: javax.swing.JDesktopPane,
       counter: @escaping () -> Int,
       statusLabelRef: [javax.swing.JLabel]) {
    self.desktop = desktop
    self.counter = counter
    self.statusLabelRef = statusLabelRef
    super.init("New Frame")
  }

  override func actionPerformed(_ e: java.awt.event.ActionEvent) {
    let n = counter()
    let title = "Document \(n)"
    let label = statusLabelRef.first ?? javax.swing.JLabel()
    let f = SwingMDITab.makeDemoFrame(title: title,
                                       x: 30 + (n % 8) * 30,
                                       y: 30 + (n % 6) * 30,
                                       statusLabel: label)
    desktop.add(f)
    f.setVisible(true)
  }
}

/// Closes all internal frames on the desktop.
@MainActor
private class MDICloseAllAction: javax.swing.AbstractAction {
  private let desktop: javax.swing.JDesktopPane

  init(desktop: javax.swing.JDesktopPane) {
    self.desktop = desktop
    super.init("Close All")
  }

  override func actionPerformed(_ e: java.awt.event.ActionEvent) {
    for f in desktop.getAllFrames() {
      f.dispose()
    }
  }
}

/// Closes a single frame.
@MainActor
private class MDICloseSingleFrameAction: javax.swing.AbstractAction {
  private weak var frame: javax.swing.JInternalFrame?

  init(frame: javax.swing.JInternalFrame) {
    self.frame = frame
    super.init("Close")
  }

  override func actionPerformed(_ e: java.awt.event.ActionEvent) {
    frame?.dispose()
  }
}

/// Switches drag mode based on combo selection.
@MainActor
private class MDIDragModeListener: java.awt.event.ItemListener {
  private let desktop: javax.swing.JDesktopPane

  init(desktop: javax.swing.JDesktopPane) {
    self.desktop = desktop
  }

  func itemStateChanged(_ e: java.awt.event.ItemEvent) {
    guard e.getStateChange() == java.awt.event.ItemEvent.SELECTED else { return }
    if let selected = e.getItem() as? String, selected == "Outline" {
      desktop.setDragMode(javax.swing.JDesktopPane.OUTLINE_DRAG_MODE)
    } else {
      desktop.setDragMode(javax.swing.JDesktopPane.LIVE_DRAG_MODE)
    }
  }
}

/// Updates the status label when an internal frame is activated or closed.
@MainActor
private class MDIStatusListener: javax.swing.event.InternalFrameAdapter, @unchecked Sendable {
  private weak var label: javax.swing.JLabel?
  private let frameTitle: String

  init(label: javax.swing.JLabel, frameTitle: String) {
    self.label = label
    self.frameTitle = frameTitle
  }

  override func internalFrameActivated(_ e: javax.swing.event.InternalFrameEvent) {
    label?.setText("Active: \(frameTitle)")
  }

  override func internalFrameClosed(_ e: javax.swing.event.InternalFrameEvent) {
    label?.setText("Closed: \(frameTitle)")
  }

  override func internalFrameIconified(_ e: javax.swing.event.InternalFrameEvent) {
    label?.setText("Iconified: \(frameTitle)")
  }

  override func internalFrameDeiconified(_ e: javax.swing.event.InternalFrameEvent) {
    label?.setText("Restored: \(frameTitle)")
  }
}
