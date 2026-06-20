/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.plaf.basic {

  /// The Basic look-and-feel UI delegate for `JOptionPane`.
  ///
  /// Lays out the pane as:
  ///
  /// ```
  /// ┌─────────────────────────────────┐
  /// │  [icon]  message text / widget  │  ← message area (CENTER)
  /// ├─────────────────────────────────┤
  /// │  [Option buttons …]             │  ← button row (SOUTH)
  /// └─────────────────────────────────┘
  /// ```
  ///
  /// The message icon is derived from `messageType`:
  /// - `ERROR_MESSAGE`       → "✖"
  /// - `INFORMATION_MESSAGE` → "ℹ"
  /// - `WARNING_MESSAGE`     → "⚠"
  /// - `QUESTION_MESSAGE`    → "?"
  /// - `PLAIN_MESSAGE`       → (none)
  ///
  /// Button labels follow `optionType`:
  /// - `DEFAULT_OPTION`        → ["OK"]
  /// - `YES_NO_OPTION`         → ["Yes", "No"]
  /// - `YES_NO_CANCEL_OPTION`  → ["Yes", "No", "Cancel"]
  /// - `OK_CANCEL_OPTION`      → ["OK", "Cancel"]
  ///
  /// Custom `options` arrays override the default labels.
  ///
  /// - Since: Java 1.2
  @MainActor
  open class BasicOptionPaneUI: javax.swing.plaf.ComponentUI {

    // -------------------------------------------------------------------------
    // MARK: Factory
    // -------------------------------------------------------------------------

    open class func createUI(_ c: javax.swing.JComponent) -> javax.swing.plaf.ComponentUI {
      BasicOptionPaneUI()
    }

    // -------------------------------------------------------------------------
    // MARK: Install / uninstall
    // -------------------------------------------------------------------------

    override open func installUI(_ c: javax.swing.JComponent) {
      guard let pane = c as? javax.swing.JOptionPane else { return }
      pane.setLayout(java.awt.BorderLayout())
      buildContents(pane)
    }

    // -------------------------------------------------------------------------
    // MARK: Paint — layout does the work; paint just fills the background
    // -------------------------------------------------------------------------

    override open func paint(_ g: java.awt.Graphics, _ c: javax.swing.JComponent) {
      g.setColor(c.getBackground())
      g.fillRect(0, 0, c.bounds.width, c.bounds.height)
    }

    // -------------------------------------------------------------------------
    // MARK: Preferred size
    // -------------------------------------------------------------------------

    override open func getPreferredSize(_ c: javax.swing.JComponent) -> java.awt.Dimension? {
      return java.awt.Dimension(320, 140)
    }

    // -------------------------------------------------------------------------
    // MARK: Content construction
    // -------------------------------------------------------------------------

    private func buildContents(_ pane: javax.swing.JOptionPane) {
      // ── Message panel ───────────────────────────────────────────────────────
      let msgPanel = javax.swing.JPanel(java.awt.BorderLayout())
      msgPanel.setBackground(java.awt.SystemColor.control)

      // Icon label
      let iconText = iconString(for: pane.getMessageType())
      if !iconText.isEmpty {
        let iconLabel = javax.swing.JLabel(iconText)
        iconLabel.setFont(java.awt.Font("Dialog", java.awt.Font.PLAIN, 24))
        let iconPad = javax.swing.JPanel(java.awt.BorderLayout())
        iconPad.setBackground(java.awt.SystemColor.control)
        iconPad.add(iconLabel, java.awt.BorderLayout.CENTER)
        iconPad.setPreferredSize(java.awt.Dimension(48, 48))
        msgPanel.add(iconPad, java.awt.BorderLayout.WEST)
      }

      // Message widget
      let msgWidget = messageWidget(for: pane)
      msgPanel.add(msgWidget, java.awt.BorderLayout.CENTER)
      pane.add(msgPanel, java.awt.BorderLayout.CENTER)

      // ── Button panel ────────────────────────────────────────────────────────
      let btnPanel = javax.swing.JPanel(java.awt.FlowLayout())
      btnPanel.setBackground(java.awt.SystemColor.control)

      let labels = buttonLabels(for: pane)
      for (idx, label) in labels.enumerated() {
        let btn = javax.swing.JButton(label)
        let capturedIdx = idx
        btn.addActionListener(_SwingClosureActionListener { _ in
          pane.setValue(capturedIdx)
          // Walk up to enclosing JDialog and hide it
          var comp: java.awt.Component? = pane
          while let c = comp {
            if let dlg = c as? javax.swing.JDialog {
              dlg.setVisible(false)
              break
            }
            comp = c.getParent()
          }
        })
        btnPanel.add(btn)
      }

      // Input field (for showInputDialog)
      if pane.getInitialValue() is String {
        let field = javax.swing.JTextField()
        field.setPreferredSize(java.awt.Dimension(200, 24))
        let inputPanel = javax.swing.JPanel(java.awt.BorderLayout())
        inputPanel.setBackground(java.awt.SystemColor.control)
        inputPanel.add(field, java.awt.BorderLayout.CENTER)
        pane.add(inputPanel, java.awt.BorderLayout.EAST)

        // OK button sets the typed text as the pane value
        if let okBtn = btnPanel.getComponents().first as? javax.swing.JButton {
          okBtn.addActionListener(_SwingClosureActionListener { _ in
            pane.setValue(field.getText())
          })
        }
      }

      pane.add(btnPanel, java.awt.BorderLayout.SOUTH)
    }

    // -------------------------------------------------------------------------
    // MARK: Helpers
    // -------------------------------------------------------------------------

    private func iconString(for messageType: Int) -> String {
      switch messageType {
      case javax.swing.JOptionPane.ERROR_MESSAGE:       return "✖"
      case javax.swing.JOptionPane.INFORMATION_MESSAGE: return "ℹ"
      case javax.swing.JOptionPane.WARNING_MESSAGE:     return "⚠"
      case javax.swing.JOptionPane.QUESTION_MESSAGE:    return "?"
      default: return ""
      }
    }

    private func messageWidget(for pane: javax.swing.JOptionPane) -> java.awt.Component {
      let text: String
      if let msg = pane.getMessage() as? String {
        text = msg
      } else if let msg = pane.getMessage() {
        text = "\(msg)"
      } else {
        text = ""
      }
      let label = javax.swing.JLabel(text)
      label.setBackground(java.awt.SystemColor.control)
      return label
    }

    private func buttonLabels(for pane: javax.swing.JOptionPane) -> [String] {
      // Custom options override everything
      if let opts = pane.getOptions() {
        return opts.map { "\($0)" }
      }
      switch pane.getOptionType() {
      case javax.swing.JOptionPane.YES_NO_OPTION:         return ["Yes", "No"]
      case javax.swing.JOptionPane.YES_NO_CANCEL_OPTION:  return ["Yes", "No", "Cancel"]
      case javax.swing.JOptionPane.OK_CANCEL_OPTION:      return ["OK",  "Cancel"]
      default:                                             return ["OK"]
      }
    }
  }
}
