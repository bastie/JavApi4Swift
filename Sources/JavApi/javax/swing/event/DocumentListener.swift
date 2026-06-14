/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.event {

  /// Listener interface for changes in a `Document`.
  ///
  /// Implement this protocol to be notified whenever text is inserted into,
  /// removed from, or has attributes changed in a `Document`.
  ///
  /// - Since: Java 1.2
  @MainActor
  public protocol DocumentListener: java.util.EventListener {

    /// Called after text was inserted into the document.
    func insertUpdate(_ e: any javax.swing.event.DocumentEvent)

    /// Called after text was removed from the document.
    func removeUpdate(_ e: any javax.swing.event.DocumentEvent)

    /// Called after document attributes changed (no content change).
    func changedUpdate(_ e: any javax.swing.event.DocumentEvent)
  }
}
