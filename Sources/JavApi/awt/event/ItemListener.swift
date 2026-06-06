/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.event {
  @MainActor
  public protocol ItemListener: java.util.EventListener {
    func itemStateChanged(_ e: ItemEvent)
  }
}
