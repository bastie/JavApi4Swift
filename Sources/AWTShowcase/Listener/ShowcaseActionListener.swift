/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import JavApi

/// Simple ActionListener that prints to console — beendet die App bei "Beenden".
@MainActor
final class ShowcaseActionListener: java.awt.event.ActionListener {
  func actionPerformed(_ e: java.awt.event.ActionEvent) {
    System.out.println("Action: \(e.getActionCommand())")
    if e.getActionCommand() == "Beenden" {
      java.awt.Toolkit.getDefaultToolkit().terminate()
    }
  }
}
