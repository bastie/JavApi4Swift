/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt {

  /// Defines how colors or patterns are applied to shapes.
  ///
  /// Mirrors `java.awt.Paint`. `Color`, `GradientPaint`, etc. implement it.
  /// The `createContext` method (which needs `PaintContext`/`ColorModel`) is
  /// deferred until those types are available.
  ///
  /// - Since: Java 1.2
  public protocol Paint: java.awt.Transparency {}
}
