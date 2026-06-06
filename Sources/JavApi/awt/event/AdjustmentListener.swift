/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.event {

  /// Listener for `AdjustmentEvent`s — mirrors `java.awt.event.AdjustmentListener`.
  @MainActor
  public protocol AdjustmentListener: java.util.EventListener {
    func adjustmentValueChanged(_ e: AdjustmentEvent)
  }
}
