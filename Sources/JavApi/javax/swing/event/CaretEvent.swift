/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.event {

  /// Describes a change in the caret position or selection of a text component.
  ///
  /// `CaretEvent` is fired by `JTextComponent` whenever the insertion point
  /// (dot) or the selection anchor (mark) changes.  The two positions together
  /// define the current selection:
  ///
  /// - If `dot == mark` there is no selection; the caret is at `dot`.
  /// - If `dot != mark` the selected region runs between the two positions
  ///   (the smaller value is the start, the larger is the end).
  ///
  /// Listeners receive this event through `CaretListener.caretUpdate(_:)`.
  ///
  /// ## Example
  ///
  /// ```swift
  /// field.addCaretListener(MyCaretListener())
  ///
  /// class MyCaretListener: javax.swing.event.CaretListener {
  ///   func caretUpdate(_ e: any javax.swing.event.CaretEvent) {
  ///     print("caret at \(e.dot), selection mark at \(e.mark)")
  ///   }
  /// }
  /// ```
  ///
  /// - Since: Java 1.2
  @MainActor
  public protocol CaretEvent: AnyObject {

    /// The caret position (insertion point).
    ///
    /// Equivalent to `JTextComponent.getCaretPosition()`.
    var dot: Int { get }

    /// The selection anchor.
    ///
    /// If equal to `dot` there is no selection.
    /// The selected text spans `min(dot, mark) ..< max(dot, mark)`.
    var mark: Int { get }
  }
}
