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
      // Remove any previously built children so installUI is idempotent —
      // setInitialValue() re-runs updateUI()/installUI() to rebuild contents.
      pane.removeAll()
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
      guard let pane = c as? javax.swing.JOptionPane else {
        return nil
      }

      // ── Measure the message text ──────────────────────────────────────────
      let msgText: String
      if let msg = pane.getMessage() as? String {
        msgText = msg
      } else if let msg = pane.getMessage() {
        msgText = "\(msg)"
      } else {
        msgText = ""
      }

      let font = java.awt.Font("Dialog", java.awt.Font.PLAIN, 13)
      let fm   = java.awt.FontMetrics.make(for: font)

      // Support multi-line messages (split on \n)
      let lines      = msgText.components(separatedBy: "\n")
      let maxLineW   = lines.map { fm.stringWidth($0) }.max() ?? 0
      let lineHeight = fm.getHeight()
      let msgHeight  = lineHeight * max(lines.count, 1)

      // ── Button row width ──────────────────────────────────────────────────
      let btnLabels  = buttonLabels(for: pane)
      let btnFont    = java.awt.Font("Dialog", java.awt.Font.PLAIN, 12)
      let btnFm      = java.awt.FontMetrics.make(for: btnFont)
      // Each button: text width + horizontal padding (24 px each side) + gap (8 px between)
      let btnRowW    = btnLabels.reduce(0) { $0 + btnFm.stringWidth($1) + 48 }
                       + 8 * max(btnLabels.count - 1, 0)

      // ── Icon width (font-relative: icon uses 24pt font) ──────────────────
      let hasIcon    = !iconString(for: pane.getMessageType()).isEmpty
      let iconFont   = java.awt.Font("Dialog", java.awt.Font.PLAIN, 24)
      let iconFm     = java.awt.FontMetrics.make(for: iconFont)
      let iconW      = hasIcon ? iconFm.stringWidth("✖") + lineHeight : 0

      // ── Input field extra height (showInputDialog) ────────────────────────
      // Use the same font metrics as BasicTextFieldUI: getHeight() + 2*pad + 2px border
      let inputH: Int
      if pane.getInitialValue() is String {
        let tfFont = java.awt.Font("Dialog", java.awt.Font.PLAIN, 12)
        let tfFm   = java.awt.FontMetrics.make(for: tfFont)
        inputH = tfFm.getHeight() + 6 + 2   // padY=3 each side + 2px border
      } else {
        inputH = 0
      }

      // ── Button row height (measured, not hardcoded) ───────────────────────
      let btnH       = btnFm.getHeight() + 16   // button text + top/bottom padding
      let topBottomPad = lineHeight             // one line-height of top+bottom margin

      // ── Compose final size ────────────────────────────────────────────────
      let hPad       = lineHeight * 2           // left + right dialog padding (font-relative)
      let vPad       = btnH + topBottomPad      // button row + surrounding padding
      let contentW   = max(maxLineW + iconW, btnRowW)
      let width      = max(contentW + hPad, btnRowW + hPad)
      let height     = max(msgHeight + inputH + vPad + topBottomPad, btnH * 3)

      return java.awt.Dimension(width, height)
    }

    // -------------------------------------------------------------------------
    // MARK: Content construction
    // -------------------------------------------------------------------------

    private func buildContents(_ pane: javax.swing.JOptionPane) {
      // ── Top panel: icon + message + optional input field ────────────────────
      // Layout:
      //   WEST  = icon (if any)
      //   CENTER = vertical stack: message label / input field
      let topPanel = javax.swing.JPanel(java.awt.BorderLayout())
      topPanel.setBackground(java.awt.SystemColor.control)

      // Icon — no setPreferredSize; JLabel with font 24pt lets BasicLabelUI
      // compute the correct size via FontMetrics.
      let iconText = iconString(for: pane.getMessageType())
      if !iconText.isEmpty {
        let iconLabel = javax.swing.JLabel(iconText)
        iconLabel.setFont(java.awt.Font("Dialog", java.awt.Font.PLAIN, 24))
        let iconPad = javax.swing.JPanel(java.awt.BorderLayout())
        iconPad.setBackground(java.awt.SystemColor.control)
        iconPad.add(iconLabel, java.awt.BorderLayout.CENTER)
        topPanel.add(iconPad, java.awt.BorderLayout.WEST)
      }

      // Center area: message label, and below it the input field when present
      let centerPanel = javax.swing.JPanel(java.awt.BorderLayout())
      centerPanel.setBackground(java.awt.SystemColor.control)

      let msgWidget = messageWidget(for: pane)
      centerPanel.add(msgWidget, java.awt.BorderLayout.CENTER)

      // Input field — shown when initialValue is a String (showInputDialog)
      let inputField: javax.swing.JTextField?
      if pane.getInitialValue() is String {
        let field = javax.swing.JTextField(pane.getInitialValue() as? String ?? "")
        // No setPreferredSize — BasicTextFieldUI.getPreferredSize computes the
        // correct height from the font metrics; width comes from getPreferredSize
        // of the panel which stretches to the dialog width via BorderLayout.
        centerPanel.add(field, java.awt.BorderLayout.SOUTH)
        inputField = field
      } else {
        inputField = nil
      }

      topPanel.add(centerPanel, java.awt.BorderLayout.CENTER)
      pane.add(topPanel, java.awt.BorderLayout.CENTER)

      // ── Button panel ────────────────────────────────────────────────────────
      let btnPanel = javax.swing.JPanel(java.awt.FlowLayout())
      btnPanel.setBackground(java.awt.SystemColor.control)

      let labels = buttonLabels(for: pane)
      for (idx, label) in labels.enumerated() {
        let btn = javax.swing.JButton(label)
        let capturedIdx = idx
        let isOK = (label == "OK" || label == "Yes")
        btn.addActionListener(_SwingClosureActionListener { _ in
          if isOK, let field = inputField {
            // For input dialogs: OK stores the typed text
            pane.setValue(field.getText())
          } else if inputField == nil {
            // For message/confirm dialogs: store the button index
            pane.setValue(capturedIdx)
          }
          // Close the enclosing dialog
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
