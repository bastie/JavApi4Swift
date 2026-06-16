/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.event {

  /// Listener notified when the caret position or selection changes in a text component.
  ///
  /// Register with `JTextComponent.addCaretListener(_:)`.
  ///
  /// ## Example
  ///
  /// ```swift
  /// class SelectionTracker: javax.swing.event.CaretListener {
  ///   func caretUpdate(_ e: any javax.swing.event.CaretEvent) {
  ///     let selected = e.dot != e.mark
  ///     print(selected ? "Selection: \(e.mark)..<\(e.dot)" : "Caret at \(e.dot)")
  ///   }
  /// }
  ///
  /// textField.addCaretListener(SelectionTracker())
  /// ```
  ///
  /// - Since: Java 1.2
  @MainActor
  public protocol CaretListener: java.util.EventListener {

    /// Called whenever the caret position or selection changes.
    ///
    /// - Parameter e: The caret event describing the new dot and mark positions.
    func caretUpdate(_ e: any javax.swing.event.CaretEvent)
  }
}
