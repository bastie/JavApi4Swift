/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt {

  // ---------------------------------------------------------------------------
  // MARK: - Stroke
  // ---------------------------------------------------------------------------

  /// Defines the interface for rendering the outline of a `Shape`.
  ///
  /// Mirrors `java.awt.Stroke`. `BasicStroke` is the standard implementation.
  ///
  /// - Since: JavaApi > 0.x (Java 1.2)
  public protocol Stroke: AnyObject {

    /// Returns a new `Shape` representing the stroked outline of `shape`.
    ///
    /// - Note: Full implementation requires `Path2D`/`GeneralPath`, which are
    ///   not yet available. Conforming types may return a stub until then.
    func createStrokedShape(_ shape: any java.awt.Shape) -> any java.awt.Shape
  }
}
