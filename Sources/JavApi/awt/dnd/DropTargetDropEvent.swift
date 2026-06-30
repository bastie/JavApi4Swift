/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.dnd {

  /// Event fired when a drop occurs on a drop target —
  /// mirrors `java.awt.dnd.DropTargetDropEvent`.
  ///
  /// - Since: Java 1.2
  public final class DropTargetDropEvent: DropTargetEvent {

    /// The drop action chosen by the user.
    public private(set) var dropAction: Int

    /// The source-supported actions.
    public private(set) var sourceActions: Int

    /// The cursor location relative to the target component (headless: 0,0).
    public private(set) var location: java.awt.Point

    /// Whether the drop is local (source and target in same JVM).
    public private(set) var isLocalTransfer: Bool

    /// Creates a `DropTargetDropEvent`.
    public init(_ dropTargetContext: DropTargetContext,
                cursorLocation: java.awt.Point,
                dropAction: Int,
                srcActions: Int,
                isLocal: Bool = false) {
      self.location = cursorLocation
      self.dropAction = dropAction
      self.sourceActions = srcActions
      self.isLocalTransfer = isLocal
      super.init(dropTargetContext)
    }

    /// Returns the cursor location within the target component.
    public func getLocation() -> java.awt.Point { location }

    /// Returns the drop action.
    public func getDropAction() -> Int { dropAction }

    /// Returns the source-supported actions.
    public func getSourceActions() -> Int { sourceActions }

    /// Whether this is a local (intra-JVM) transfer.
    public func getIsLocalTransfer() -> Bool { isLocalTransfer }

    /// Accepts the drop with the given action (no-op in headless mode).
    public func acceptDrop(_ dropAction: Int) {}

    /// Rejects the drop (no-op in headless mode).
    public func rejectDrop() {}

    /// Signals that the drop handling is complete (no-op in headless mode).
    public func dropComplete(_ success: Bool) {}
  }
}
