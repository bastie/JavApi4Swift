/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import JavApi

/// ActionListener that opens a FileDialog and prints the result.
///
/// Handles both file open and file save dialogs. Prints the selected file path
/// to the console if a file was chosen, or "canceled" if the user dismissed
/// the dialog without selecting a file.
@MainActor
final class FileDialogListener: java.awt.event.ActionListener {
  private weak var frame: java.awt.Frame?
  private let mode: Int
  
  init(frame: java.awt.Frame, mode: Int) {
    self.frame = frame
    self.mode  = (mode != java.awt.FileDialog.LOAD && mode != java.awt.FileDialog.SAVE) ? java.awt.FileDialog.LOAD : mode
  }
  
  func actionPerformed(_ e: java.awt.event.ActionEvent) {
    let title = self.mode == java.awt.FileDialog.LOAD ? "File open" : "File save"
    let fd    = try! java.awt.FileDialog (frame, title, mode)
    fd.setVisible (true)
    if let file = fd.getFile(), let dir = fd.getDirectory() {
      System.out.println ("FileDialog: \(dir)\(file)")
    }
    else {
      System.out.println ("FileDialog: canceled")
    }
  }
}

