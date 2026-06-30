/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.dnd {

  /// Mouse-based drag gesture recogniser — mirrors `java.awt.dnd.MouseDragGestureRecognizer`.
  ///
  /// In headless mode this class installs no listeners and never fires a gesture.
  /// Platform-specific subclasses (Step 2+) will override `registerListeners()` and
  /// `unregisterListeners()` to hook into native mouse events.
  ///
  /// - Since: Java 1.2
  open class MouseDragGestureRecognizer: DragGestureRecognizer {

    /// Creates a `MouseDragGestureRecognizer` (headless).
    public override init(dragSource: DragSource,
                         component: java.awt.Component,
                         dragAction: Int) {
      super.init(dragSource: dragSource, component: component, dragAction: dragAction)
    }

    /// Installs mouse listeners on `component` (headless: no-op).
    open override func registerListeners() {}

    /// Removes mouse listeners from `component` (headless: no-op).
    open override func unregisterListeners() {}
  }
}
