/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.dnd {

  /// Event fired when a drop has completed — mirrors `java.awt.dnd.DragSourceDropEvent`.
  ///
  /// - Since: Java 1.2
  public final class DragSourceDropEvent: DragSourceEvent {

    /// The drop action that was performed.
    public private(set) var dropAction: Int

    /// Whether the drop was accepted.
    public private(set) var dropSuccess: Bool

    /// Creates a `DragSourceDropEvent` (headless: drop not accepted).
    public override init(_ dragSourceContext: DragSourceContext) {
      self.dropAction = DnDConstants.ACTION_NONE
      self.dropSuccess = false
      super.init(dragSourceContext)
    }

    /// Creates a `DragSourceDropEvent` with result information.
    public init(_ dragSourceContext: DragSourceContext,
                dropAction: Int,
                success: Bool) {
      self.dropAction = dropAction
      self.dropSuccess = success
      super.init(dragSourceContext)
    }

    /// Creates a `DragSourceDropEvent` with result information and cursor location.
    public init(_ dragSourceContext: DragSourceContext,
                dropAction: Int,
                success: Bool,
                x: Int,
                y: Int) {
      self.dropAction = dropAction
      self.dropSuccess = success
      super.init(dragSourceContext, x, y)
    }

    /// Whether the drop was successful.
    public func getDropSuccess() -> Bool { dropSuccess }

    /// The drop action that was performed.
    public func getDropAction() -> Int { dropAction }
  }
}
