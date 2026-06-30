/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.dnd {

  /// Manages the drop-target side of a drag-and-drop operation —
  /// mirrors `java.awt.dnd.DropTargetContext`.
  ///
  /// In headless mode all operations are no-ops.
  ///
  /// - Since: Java 1.2
  public final class DropTargetContext {

    /// The `DropTarget` that owns this context.
    public private(set) var dropTarget: DropTarget

    /// Creates a `DropTargetContext`.
    init(dropTarget: DropTarget) {
      self.dropTarget = dropTarget
    }

    /// Returns the component associated with this context.
    public func getComponent() -> java.awt.Component? {
      dropTarget.getComponent()
    }

    /// Accepts the drop with the given action (no-op in headless mode).
    public func acceptDrop(_ dropAction: Int) {}

    /// Rejects the drop (no-op in headless mode).
    public func rejectDrop() {}

    /// Signals that drop handling is complete (no-op in headless mode).
    public func dropComplete(_ success: Bool) {}

    /// Invalidates this context (no-op in headless mode).
    public func invalidate() {}
  }
}
