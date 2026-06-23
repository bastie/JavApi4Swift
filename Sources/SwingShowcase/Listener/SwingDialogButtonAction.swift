/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import JavApi

// ---------------------------------------------------------------------------
// MARK: showMessageDialog listeners
// ---------------------------------------------------------------------------

/// Shows a JOptionPane information message dialog.
@MainActor
class SwingDialogInfoAction: java.awt.event.ActionListener {
  private let resultLabel: javax.swing.JLabel
  init(resultLabel: javax.swing.JLabel) { self.resultLabel = resultLabel }
  func actionPerformed(_ e: java.awt.event.ActionEvent) {
    javax.swing.JOptionPane.showMessageDialog(
      nil, "Operation completed successfully.",
      "Information", javax.swing.JOptionPane.INFORMATION_MESSAGE)
    resultLabel.setText("Result: showMessageDialog — INFORMATION closed")
  }
}

/// Shows a JOptionPane warning message dialog.
@MainActor
class SwingDialogWarningAction: java.awt.event.ActionListener {
  private let resultLabel: javax.swing.JLabel
  init(resultLabel: javax.swing.JLabel) { self.resultLabel = resultLabel }
  func actionPerformed(_ e: java.awt.event.ActionEvent) {
    javax.swing.JOptionPane.showMessageDialog(
      nil, "Disk space is running low.",
      "Warning", javax.swing.JOptionPane.WARNING_MESSAGE)
    resultLabel.setText("Result: showMessageDialog — WARNING closed")
  }
}

/// Shows a JOptionPane error message dialog.
@MainActor
class SwingDialogErrorAction: java.awt.event.ActionListener {
  private let resultLabel: javax.swing.JLabel
  init(resultLabel: javax.swing.JLabel) { self.resultLabel = resultLabel }
  func actionPerformed(_ e: java.awt.event.ActionEvent) {
    javax.swing.JOptionPane.showMessageDialog(
      nil, "An unexpected error occurred.",
      "Error", javax.swing.JOptionPane.ERROR_MESSAGE)
    resultLabel.setText("Result: showMessageDialog — ERROR closed")
  }
}

/// Shows a JOptionPane plain message dialog.
@MainActor
class SwingDialogPlainAction: java.awt.event.ActionListener {
  private let resultLabel: javax.swing.JLabel
  init(resultLabel: javax.swing.JLabel) { self.resultLabel = resultLabel }
  func actionPerformed(_ e: java.awt.event.ActionEvent) {
    javax.swing.JOptionPane.showMessageDialog(
      nil, "This is a plain message.",
      "Plain", javax.swing.JOptionPane.PLAIN_MESSAGE)
    resultLabel.setText("Result: showMessageDialog — PLAIN closed")
  }
}

// ---------------------------------------------------------------------------
// MARK: showConfirmDialog listeners
// ---------------------------------------------------------------------------

/// Shows a YES/NO confirm dialog.
@MainActor
class SwingDialogConfirmYesNoAction: java.awt.event.ActionListener {
  private let resultLabel: javax.swing.JLabel
  init(resultLabel: javax.swing.JLabel) { self.resultLabel = resultLabel }
  func actionPerformed(_ e: java.awt.event.ActionEvent) {
    let r = javax.swing.JOptionPane.showConfirmDialog(
      nil, "Do you want to proceed?",
      "Confirm", javax.swing.JOptionPane.YES_NO_OPTION)
    let txt = r == javax.swing.JOptionPane.YES_OPTION ? "YES"
            : r == javax.swing.JOptionPane.NO_OPTION  ? "NO" : "CLOSED"
    resultLabel.setText("Result: showConfirmDialog YES_NO → \(txt)")
  }
}

/// Shows a YES/NO/CANCEL confirm dialog.
@MainActor
class SwingDialogConfirmYesNoCancelAction: java.awt.event.ActionListener {
  private let resultLabel: javax.swing.JLabel
  init(resultLabel: javax.swing.JLabel) { self.resultLabel = resultLabel }
  func actionPerformed(_ e: java.awt.event.ActionEvent) {
    let r = javax.swing.JOptionPane.showConfirmDialog(
      nil, "Save changes before closing?",
      "Confirm", javax.swing.JOptionPane.YES_NO_CANCEL_OPTION)
    let txt = r == javax.swing.JOptionPane.YES_OPTION    ? "YES"
            : r == javax.swing.JOptionPane.NO_OPTION     ? "NO"
            : r == javax.swing.JOptionPane.CANCEL_OPTION ? "CANCEL" : "CLOSED"
    resultLabel.setText("Result: showConfirmDialog YES_NO_CANCEL → \(txt)")
  }
}

// ---------------------------------------------------------------------------
// MARK: showInputDialog listeners
// ---------------------------------------------------------------------------

/// Shows a plain input dialog.
@MainActor
class SwingDialogInputAction: java.awt.event.ActionListener {
  private let resultLabel: javax.swing.JLabel
  init(resultLabel: javax.swing.JLabel) { self.resultLabel = resultLabel }
  func actionPerformed(_ e: java.awt.event.ActionEvent) {
    if let name = javax.swing.JOptionPane.showInputDialog(nil, "Enter your name:") {
      resultLabel.setText("Result: showInputDialog → \"\(name)\"")
    } else {
      resultLabel.setText("Result: showInputDialog → cancelled")
    }
  }
}

/// Shows a titled input dialog.
@MainActor
class SwingDialogInputTitledAction: java.awt.event.ActionListener {
  private let resultLabel: javax.swing.JLabel
  init(resultLabel: javax.swing.JLabel) { self.resultLabel = resultLabel }
  func actionPerformed(_ e: java.awt.event.ActionEvent) {
    if let val = javax.swing.JOptionPane.showInputDialog(
        nil, "Enter a value:", "Input Required",
        javax.swing.JOptionPane.QUESTION_MESSAGE) {
      resultLabel.setText("Result: showInputDialog (titled) → \"\(val)\"")
    } else {
      resultLabel.setText("Result: showInputDialog (titled) → cancelled")
    }
  }
}

// ---------------------------------------------------------------------------
// MARK: JFileChooser listeners
// ---------------------------------------------------------------------------

/// Shows a JFileChooser open dialog.
@MainActor
class SwingDialogFileOpenAction: java.awt.event.ActionListener {
  private let resultLabel: javax.swing.JLabel
  init(resultLabel: javax.swing.JLabel) { self.resultLabel = resultLabel }
  func actionPerformed(_ e: java.awt.event.ActionEvent) {
    let fc = javax.swing.JFileChooser()
    fc.setDialogTitle("Open File")
    let r = fc.showOpenDialog(nil)
    if r == javax.swing.JFileChooser.APPROVE_OPTION {
      resultLabel.setText("Result: JFileChooser Open → \(fc.getSelectedFile()?.getPath() ?? "?")")
    } else {
      resultLabel.setText("Result: JFileChooser Open → cancelled")
    }
  }
}

/// Shows a JFileChooser save dialog.
@MainActor
class SwingDialogFileSaveAction: java.awt.event.ActionListener {
  private let resultLabel: javax.swing.JLabel
  init(resultLabel: javax.swing.JLabel) { self.resultLabel = resultLabel }
  func actionPerformed(_ e: java.awt.event.ActionEvent) {
    let fc = javax.swing.JFileChooser()
    fc.setDialogTitle("Save File")
    let r = fc.showSaveDialog(nil)
    if r == javax.swing.JFileChooser.APPROVE_OPTION {
      resultLabel.setText("Result: JFileChooser Save → \(fc.getSelectedFile()?.getPath() ?? "?")")
    } else {
      resultLabel.setText("Result: JFileChooser Save → cancelled")
    }
  }
}

// ---------------------------------------------------------------------------
// MARK: JColorChooser listener
// ---------------------------------------------------------------------------

/// Shows a JColorChooser dialog and applies the chosen color to a preview label.
@MainActor
class SwingDialogColorAction: java.awt.event.ActionListener {
  private let resultLabel:   javax.swing.JLabel
  private let colorPreview:  javax.swing.JLabel
  init(resultLabel: javax.swing.JLabel, colorPreview: javax.swing.JLabel) {
    self.resultLabel  = resultLabel
    self.colorPreview = colorPreview
  }
  func actionPerformed(_ e: java.awt.event.ActionEvent) {
    if let c = javax.swing.JColorChooser.showDialog(
        nil, "Choose a Color", colorPreview.getBackground()) {
      colorPreview.setBackground(c)
      resultLabel.setText(
        "Result: JColorChooser → R=\(c.getRed()) G=\(c.getGreen()) B=\(c.getBlue())")
    } else {
      resultLabel.setText("Result: JColorChooser → cancelled")
    }
  }
}
