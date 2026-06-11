/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import JavApi

/// ActionListener that closes a dialog when its button is clicked.
///
/// Generic utility listener for dialog close buttons. Calls dispose() on the
/// dialog to properly clean up resources and dismiss the dialog window.
@MainActor
final class DialogCloseListener: java.awt.event.ActionListener {
  private weak var dialog: java.awt.Dialog?
  init(dialog: java.awt.Dialog) { self.dialog = dialog }
  func actionPerformed(_ e: java.awt.event.ActionEvent) {
    dialog?.dispose()
  }
}
