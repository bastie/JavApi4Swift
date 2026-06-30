/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.dnd {

  /// Event fired while a drag is over a drop target —
  /// mirrors `java.awt.dnd.DropTargetDragEvent`.
  ///
  /// - Since: Java 1.2
  public final class DropTargetDragEvent: DropTargetEvent {

    /// The current drop action.
    public private(set) var dropAction: Int

    /// The source-supported actions.
    public private(set) var sourceActions: Int

    /// The cursor location relative to the drop-target component (headless: 0,0).
    public private(set) var location: java.awt.Point

    /// Creates a `DropTargetDragEvent`.
    public init(_ dropTargetContext: DropTargetContext,
                cursorLocation: java.awt.Point,
                dropAction: Int,
                srcActions: Int) {
      self.location = cursorLocation
      self.dropAction = dropAction
      self.sourceActions = srcActions
      super.init(dropTargetContext)
    }

    /// Returns the cursor location within the target component.
    public func getLocation() -> java.awt.Point { location }

    /// Returns the current drop action.
    public func getDropAction() -> Int { dropAction }

    /// Returns the source-supported actions.
    public func getSourceActions() -> Int { sourceActions }

    /// Accepts the drag with the given action (no-op in headless mode).
    public func acceptDrag(_ dragOperation: Int) {}

    /// Rejects the drag (no-op in headless mode).
    public func rejectDrag() {}
  }
}
