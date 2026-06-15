/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import JavApi

/// ActionListener that closes (hides) a JDialog when triggered.
@MainActor
final class SwingDialogCloseListener: java.awt.event.ActionListener {
  private weak var dialog: javax.swing.JDialog?
  init(dialog: javax.swing.JDialog) { self.dialog = dialog }

  func actionPerformed(_ e: java.awt.event.ActionEvent) {
    dialog?.setVisible(false)
  }
}
