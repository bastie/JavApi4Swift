/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.event {

  /// Event fired when an undoable edit occurs.
  ///
  /// Carries the `UndoableEdit` that was performed.  Sources (such as
  /// `javax.swing.text.Document`) fire this event to registered
  /// `UndoableEditListener`s so that they can accumulate edits in an
  /// undo stack.
  ///
  /// - Since: Java 1.2
  @MainActor
  public class UndoableEditEvent: java.util.EventObject, @unchecked Sendable {

    private let edit: any UndoableEdit

    /// Creates an `UndoableEditEvent`.
    ///
    /// - Parameters:
    ///   - source: The object that generated the event.
    ///   - edit:   The undoable edit that occurred.
    public init(_ source: AnyObject, _ edit: any UndoableEdit) {
      self.edit = edit
      super.init(source)
    }

    /// Returns the undoable edit.
    public func getEdit() -> any UndoableEdit { edit }
  }

  // ---------------------------------------------------------------------------
  // MARK: UndoableEdit protocol (minimal JFC 1.0 surface)
  // ---------------------------------------------------------------------------

  /// Represents a single undoable operation.
  ///
  /// Minimal port of `javax.swing.undo.UndoableEdit` sufficient for JFC 1.0.
  ///
  /// - Since: Java 1.2
  public protocol UndoableEdit: AnyObject {

    /// Undoes the edit.
    func undo()

    /// Redoes the edit.
    func redo()

    /// Returns `true` if the edit can currently be undone.
    func canUndo() -> Bool

    /// Returns `true` if the edit can currently be redone.
    func canRedo() -> Bool

    /// Returns a human-readable description of the undo action.
    func getUndoPresentationName() -> String

    /// Returns a human-readable description of the redo action.
    func getRedoPresentationName() -> String

    /// Returns `true` if the edit is significant (should appear in the undo
    /// menu). Insignificant edits (e.g. style changes) can be merged.
    func isSignificant() -> Bool

    /// Attempts to absorb `anEdit` into this edit.
    /// Returns `true` if successful.
    func addEdit(_ anEdit: any UndoableEdit) -> Bool

    /// Attempts to replace this edit with `anEdit`.
    /// Returns `true` if successful.
    func replaceEdit(_ anEdit: any UndoableEdit) -> Bool

    /// Discards all stored state; the edit can no longer be undone or redone.
    func die()
  }
}
