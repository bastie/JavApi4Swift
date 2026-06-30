/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.dnd {

  /// Base event fired by a drop target — mirrors `java.awt.dnd.DropTargetEvent`.
  ///
  /// - Since: Java 1.2
  public class DropTargetEvent {

    /// The `DropTargetContext` that fired this event.
    public private(set) var dropTargetContext: DropTargetContext

    /// Creates a `DropTargetEvent`.
    public init(_ dropTargetContext: DropTargetContext) {
      self.dropTargetContext = dropTargetContext
    }

    /// Returns the `DropTargetContext`.
    public func getDropTargetContext() -> DropTargetContext { dropTargetContext }
  }
}
