/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import JavApi

/// Öffnet einen FileDialog und gibt das Ergebnis auf der Konsole aus.
@MainActor
final class FileDialogListener: java.awt.event.ActionListener {
  private weak var frame: java.awt.Frame?
  private let mode: Int
  
  init(frame: java.awt.Frame, mode: Int) {
    self.frame = frame
    self.mode  = mode
  }
  
  func actionPerformed(_ e: java.awt.event.ActionEvent) {
    let title = mode == java.awt.FileDialog.LOAD ? "File open" : "File save"
    let fd    = java.awt.FileDialog (frame, title, mode)
    fd.setVisible (true)
    if let file = fd.getFile(), let dir = fd.getDirectory() {
      System.out.println ("FileDialog: \(dir)\(file)")
    }
    else {
      System.out.println ("FileDialog: canceled")
    }
  }
}

