/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.plaf.basic {

  /// The Basic look-and-feel UI delegate for `JFileChooser`.
  ///
  /// Renders a minimal file-browser layout:
  ///
  /// ```
  /// ┌────────────────────────────────────────┐
  /// │ Current directory: [path label]        │  ← NORTH
  /// ├────────────────────────────────────────┤
  /// │                                        │
  /// │  file1.txt                             │  ← CENTER (JList of filenames)
  /// │  file2.png                             │
  /// │  subdir/                               │
  /// │  …                                     │
  /// │                                        │
  /// ├────────────────────────────────────────┤
  /// │ File name: [______________]            │  ← file name field (SOUTH-top)
  /// │             [Approve]  [Cancel]        │  ← buttons (SOUTH-bottom)
  /// └────────────────────────────────────────┘
  /// ```
  ///
  /// Double-clicking a directory navigates into it.
  /// Double-clicking a file (or clicking Approve) selects it and closes the dialog.
  ///
  /// - Since: Java 1.2
  @MainActor
  open class BasicFileChooserUI: javax.swing.plaf.ComponentUI {

    // -------------------------------------------------------------------------
    // MARK: Factory
    // -------------------------------------------------------------------------

    open class func createUI(_ c: javax.swing.JComponent) -> javax.swing.plaf.ComponentUI {
      BasicFileChooserUI()
    }

    // -------------------------------------------------------------------------
    // MARK: Install
    // -------------------------------------------------------------------------

    override open func installUI(_ c: javax.swing.JComponent) {
      guard let chooser = c as? javax.swing.JFileChooser else { return }
      chooser.setLayout(java.awt.BorderLayout())
      chooser.setBackground(java.awt.SystemColor.control)
      buildContents(chooser)
    }

    // -------------------------------------------------------------------------
    // MARK: Paint — layout does the work
    // -------------------------------------------------------------------------

    override open func paint(_ g: java.awt.Graphics, _ c: javax.swing.JComponent) {
      g.setColor(c.getBackground())
      g.fillRect(0, 0, c.bounds.width, c.bounds.height)
    }

    // -------------------------------------------------------------------------
    // MARK: Preferred size
    // -------------------------------------------------------------------------

    override open func getPreferredSize(_ c: javax.swing.JComponent) -> java.awt.Dimension? {
      // Delegate to the content hierarchy built by buildContents / installUI.
      // Falls back to a font-relative default before children are wired up.
      let fm = java.awt.FontMetrics.make(for: c.font)
      let lineH = fm.getHeight()
      return java.awt.Dimension(lineH * 30, lineH * 20)
    }

    // -------------------------------------------------------------------------
    // MARK: Content construction
    // -------------------------------------------------------------------------

    private func buildContents(_ chooser: javax.swing.JFileChooser) {

      // ── Header: current directory ──────────────────────────────────────────
      let dirLabel = javax.swing.JLabel(
        "  " + (chooser.getCurrentDirectory()?.getAbsolutePath() ?? ""))
      dirLabel.setBackground(java.awt.SystemColor.controlHighlight)
      dirLabel.setOpaque(true)
      chooser.add(dirLabel, java.awt.BorderLayout.NORTH)

      // ── File list (CENTER) ─────────────────────────────────────────────────
      let listModel = javax.swing.DefaultListModel<String>()
      let fileList  = javax.swing.JList(listModel)

      func populate(directory: java.io.File?) {
        listModel.removeAllElements()
        guard let dir = directory else { return }
        dirLabel.setText("  " + dir.getAbsolutePath())
        let mode = chooser.getFileSelectionMode()
        let entries = (dir.listFiles() ?? []).sorted {
          // directories first, then alphabetically
          let aDir = $0.isDirectory()
          let bDir = $1.isDirectory()
          if aDir != bDir { return aDir }
          return $0.getName() < $1.getName()
        }
        for f in entries {
          if mode == javax.swing.JFileChooser.DIRECTORIES_ONLY && !f.isDirectory() { continue }
          listModel.addElement(f.isDirectory() ? f.getName() + "/" : f.getName())
        }
      }
      populate(directory: chooser.getCurrentDirectory())

      let scroll = javax.swing.JScrollPane(fileList)
      chooser.add(scroll, java.awt.BorderLayout.CENTER)

      // ── South panel: file name field + buttons ─────────────────────────────
      let southPanel = javax.swing.JPanel(java.awt.BorderLayout())
      southPanel.setBackground(java.awt.SystemColor.control)

      // File name field
      let nameField = javax.swing.JTextField()
      let nameRow = javax.swing.JPanel(java.awt.BorderLayout())
      nameRow.setBackground(java.awt.SystemColor.control)
      nameRow.add(javax.swing.JLabel("  File name: "), java.awt.BorderLayout.WEST)
      nameRow.add(nameField, java.awt.BorderLayout.CENTER)
      southPanel.add(nameRow, java.awt.BorderLayout.NORTH)

      // Buttons
      let approveText = chooser.getApproveButtonText()
        ?? (chooser.getDialogType() == javax.swing.JFileChooser.SAVE_DIALOG ? "Save" : "Open")
      let approveBtn = javax.swing.JButton(approveText)
      let cancelBtn  = javax.swing.JButton("Cancel")

      let btnRow = javax.swing.JPanel(java.awt.FlowLayout())
      btnRow.setBackground(java.awt.SystemColor.control)
      btnRow.add(approveBtn)
      btnRow.add(cancelBtn)
      southPanel.add(btnRow, java.awt.BorderLayout.SOUTH)
      chooser.add(southPanel, java.awt.BorderLayout.SOUTH)

      // ── List selection → name field ────────────────────────────────────────
      fileList.addListSelectionListener(_SwingClosureListSelectionListener { event in
        guard !event.valueIsAdjusting else { return }
        if let name = fileList.getSelectedValue() {
          nameField.setText(name.hasSuffix("/") ? String(name.dropLast()) : name)
        }
      })

      // ── Double-click on directory → navigate ───────────────────────────────
      fileList.addMouseListener(_SwingClosureMouseAdapter { event in
        guard event.getClickCount() == 2 else { return }
        guard let name = fileList.getSelectedValue() else { return }
        guard name.hasSuffix("/") else { return }
        let dir  = java.io.File(chooser.getCurrentDirectory()!, String(name.dropLast()))
        chooser.setCurrentDirectory(dir)
        populate(directory: dir)
        nameField.setText("")
      })

      // ── Approve button ─────────────────────────────────────────────────────
      approveBtn.addActionListener(_SwingClosureActionListener { _ in
        let name = nameField.getText()
        guard !name.isEmpty else { return }
        let file = java.io.File(chooser.getCurrentDirectory()!, name)
        // Navigate into directory
        if file.isDirectory() {
          chooser.setCurrentDirectory(file)
          populate(directory: file)
          nameField.setText("")
          return
        }
        chooser.setSelectedFile(file)
        chooser.approveSelection()
      })

      // ── Cancel button ──────────────────────────────────────────────────────
      cancelBtn.addActionListener(_SwingClosureActionListener { _ in
        chooser.cancelSelection()
      })
    }
  }
}
