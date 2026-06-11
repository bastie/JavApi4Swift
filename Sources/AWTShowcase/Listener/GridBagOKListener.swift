/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import JavApi

/// ActionListener that handles the OK button in the GridBagLayout demo.
///
/// Collects form data (name, city, note) from input fields, prints it to
/// the console for verification, and closes the demo dialog. Demonstrates
/// accessing component state and proper dialog cleanup.
@MainActor
final class GridBagDemoOKListener : java.awt.event.ActionListener {
  
  private weak var dialog: java.awt.Dialog?
  private weak var nameInput:  java.awt.TextField?
  private weak var cityInput: java.awt.TextField?
  private weak var noteInput:   java.awt.TextArea?
  
  init(dialog: java.awt.Dialog, nameField: java.awt.TextField, stadtField: java.awt.TextField, textArea: java.awt.TextArea) {
    self.dialog     = dialog
    self.nameInput  = nameField
    self.cityInput  = stadtField
    self.noteInput  = textArea
  }
  
  func actionPerformed(_ e: java.awt.event.ActionEvent) {
    System.out.println ("GridBagLayout-Demo OK button pressed:")
    System.out.println ("  Name : \(nameInput?.getText()  ?? "-")")
    System.out.println ("  City: \(cityInput?.getText() ?? "-")")
    System.out.println ("  Note: \(noteInput?.getText()   ?? "-")")
    dialog?.dispose()
  }
}
