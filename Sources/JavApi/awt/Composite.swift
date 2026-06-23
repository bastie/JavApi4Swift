/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt {

  /// Defines how a source is composited onto a destination.
  ///
  /// Mirrors `java.awt.Composite`. `AlphaComposite` is the standard
  /// implementation. The `createContext` method (needs `ColorModel`) is
  /// deferred until that type is available.
  ///
  /// - Since: Java 1.2
  public protocol Composite: AnyObject {}

}
