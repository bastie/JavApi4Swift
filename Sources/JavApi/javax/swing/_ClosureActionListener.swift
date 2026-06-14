/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

/// Internal wrapper that adapts a Swift closure to `java.awt.event.ActionListener`.
///
/// Used by `JButton.addActionListener(_:)` and `JMenuItem.addActionListener(_:)`
/// to accept closure-style registration alongside Java-style listener objects.
@MainActor
internal final class _SwingClosureActionListener: java.awt.event.ActionListener {
  private let handler: (java.awt.event.ActionEvent) -> Void
  internal init(_ handler: @escaping (java.awt.event.ActionEvent) -> Void) {
    self.handler = handler
  }
  public func actionPerformed(_ e: java.awt.event.ActionEvent) { handler(e) }
}
