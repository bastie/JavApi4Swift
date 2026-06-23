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

/// Internal wrapper that adapts a Swift closure to `javax.swing.event.ChangeListener`.
///
/// Used by `JSlider.addChangeListener(_:)` and similar components
/// to accept closure-style registration alongside Java-style listener objects.
@MainActor
internal final class _SwingClosureChangeListener: javax.swing.event.ChangeListener {
  private let handler: (javax.swing.event.ChangeEvent) -> Void
  internal init(_ handler: @escaping (javax.swing.event.ChangeEvent) -> Void) {
    self.handler = handler
  }
  public func stateChanged(_ e: javax.swing.event.ChangeEvent) { handler(e) }
}

/// Internal wrapper that adapts a Swift closure to `javax.swing.event.ListSelectionListener`.
///
/// Used by `JList.addListSelectionListener(_:)` to accept closure-style registration.
@MainActor
internal final class _SwingClosureListSelectionListener: javax.swing.event.ListSelectionListener {
  private let handler: (javax.swing.event.ListSelectionEvent) -> Void
  internal init(_ handler: @escaping (javax.swing.event.ListSelectionEvent) -> Void) {
    self.handler = handler
  }
  public func valueChanged(_ e: javax.swing.event.ListSelectionEvent) { handler(e) }
}

/// Internal wrapper that adapts a `mouseClicked` closure to `java.awt.event.MouseAdapter`.
///
/// Used where a single-method mouse listener is needed without subclassing.
@MainActor
internal final class _SwingClosureMouseAdapter: java.awt.event.MouseAdapter {
  private let handler: (java.awt.event.MouseEvent) -> Void
  internal init(_ handler: @escaping (java.awt.event.MouseEvent) -> Void) {
    self.handler = handler
  }
  override public func mouseClicked(_ e: java.awt.event.MouseEvent) { handler(e) }
}
