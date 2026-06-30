/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.dnd {

  /// Manages the drag-source side of a drag-and-drop operation —
  /// mirrors `java.awt.dnd.DragSourceContext`.
  ///
  /// In headless mode all operations are no-ops.
  ///
  /// - Since: Java 1.2
  public final class DragSourceContext {

    /// The component from which the drag originated.
    public private(set) var component: java.awt.Component

    /// The transferable data carried by the drag.
    public private(set) var transferable: any java.awt.datatransfer.Transferable

    /// The registered `DragSourceListener`, if any.
    private var listener: (any DragSourceListener)?

    /// Creates a `DragSourceContext` (headless).
    public init(component: java.awt.Component,
                transferable: any java.awt.datatransfer.Transferable) {
      self.component = component
      self.transferable = transferable
    }

    /// Adds a `DragSourceListener` (no-op in headless mode).
    public func addDragSourceListener(_ dsl: any DragSourceListener) {
      listener = dsl
    }

    /// Removes the `DragSourceListener` (no-op in headless mode).
    public func removeDragSourceListener(_ dsl: any DragSourceListener) {
      if let l = listener, ObjectIdentifier(l) == ObjectIdentifier(dsl) {
        listener = nil
      }
    }

    /// Sets the cursor for the drag (no-op in headless mode).
    public func setCursor(_ cursor: java.awt.Cursor?) {}

    /// Returns the current cursor (headless: always the default cursor).
    public func getCursor() -> java.awt.Cursor { java.awt.Cursor.getDefaultCursor() }

    /// Transfers the data of this drag (headless: returns nil).
    public func transferData(_ flavor: java.awt.datatransfer.DataFlavor) throws
      -> Any? { nil }
  }
}
