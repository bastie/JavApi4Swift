/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import JavApi

/// ActionListener that logs button clicks and terminates the application.
///
/// Prints each action command to the console. When the "Quit" (Exit) button
/// is clicked, terminates the application by calling Toolkit.terminate().
@MainActor
final class ShowcaseActionListener: java.awt.event.ActionListener {
  func actionPerformed(_ e: java.awt.event.ActionEvent) {
    System.out.println("Action: \(e.getActionCommand())")
    if e.getActionCommand() == "Quit" {
      java.awt.Toolkit.getDefaultToolkit().terminate()
    }
  }
}
