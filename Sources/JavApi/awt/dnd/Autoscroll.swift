/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.dnd {

  /// Interface for components that want autoscrolling during drag operations —
  /// mirrors `java.awt.dnd.Autoscroll`.
  ///
  /// - Since: Java 1.2
  public protocol Autoscroll: AnyObject {

    /// Returns the insets that define the autoscroll region.
    func getAutoscrollInsets() -> java.awt.Insets

    /// Called periodically while the drag cursor is within the autoscroll region.
    func autoscroll(_ cursorLocation: java.awt.Point)
  }
}
