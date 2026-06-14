/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import JavApi

/// ActionListener that prints a message — placeholder for File/Edit menu items.
@MainActor
final class SwingPrintActionListener: java.awt.event.ActionListener {
  private let message: String
  init(_ message: String) { self.message = message }

  func actionPerformed(_ e: java.awt.event.ActionEvent) {
    print(message)
  }
}

/// ActionListener that terminates the application.
@MainActor
final class SwingQuitListener: java.awt.event.ActionListener {
  func actionPerformed(_ e: java.awt.event.ActionEvent) {
    java.lang.System.exit(0)
  }
}
