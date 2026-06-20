/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.event {

  /// Listener for `HyperlinkEvent`s fired by `JEditorPane`.
  ///
  /// - Since: Java 1.2
  @MainActor
  public protocol HyperlinkListener: AnyObject {

    /// Called when a hyperlink is entered, exited, or activated.
    func hyperlinkUpdate(_ e: javax.swing.event.HyperlinkEvent)
  }
}
