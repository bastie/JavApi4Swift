/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.event {
  @MainActor
  public protocol ActionListener: java.util.EventListener {
    func actionPerformed(_ e: java.awt.event.ActionEvent)
  }
}
