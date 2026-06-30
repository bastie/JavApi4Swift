/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.dnd {

  /// Event fired while a drag is in progress over a compatible drop target —
  /// mirrors `java.awt.dnd.DragSourceDragEvent`.
  ///
  /// - Since: Java 1.2
  public final class DragSourceDragEvent: DragSourceEvent {

    /// The drop action currently selected by the user.
    public private(set) var dropAction: Int

    /// The action(s) supported by the drag source.
    public private(set) var gestureModifiersEx: Int

    /// The action(s) accepted by the target.
    public private(set) var targetActions: Int

    /// Creates a `DragSourceDragEvent`.
    public init(_ dragSourceContext: DragSourceContext,
                dropAction: Int,
                action: Int,
                modifiers: Int) {
      self.dropAction = dropAction
      self.gestureModifiersEx = modifiers
      self.targetActions = action
      super.init(dragSourceContext)
    }

    /// Creates a `DragSourceDragEvent` with cursor location.
    public init(_ dragSourceContext: DragSourceContext,
                dropAction: Int,
                action: Int,
                modifiers: Int,
                x: Int,
                y: Int) {
      self.dropAction = dropAction
      self.gestureModifiersEx = modifiers
      self.targetActions = action
      super.init(dragSourceContext, x, y)
    }

    /// The user drop action.
    public func getUserAction() -> Int { dropAction }

    /// The target-accepted actions.
    public func getTargetActions() -> Int { targetActions }
  }
}
