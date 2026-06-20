/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt {

  // ---------------------------------------------------------------------------
  // MARK: - Transparency
  // ---------------------------------------------------------------------------

  /// Defines constants and a query method for objects that have transparency.
  ///
  /// Mirrors `java.awt.Transparency`.
  ///
  /// - Since: Java 1.2
  public protocol Transparency: AnyObject {
    /// Returns one of `OPAQUE`, `BITMASK`, or `TRANSLUCENT`.
    func getTransparency() -> Int
  }
}

extension java.awt.Transparency {
  /// The object is fully opaque (no alpha blending).
  public static var OPAQUE:      Int { 1 }
  /// The object has 1-bit transparency (fully on or off).
  public static var BITMASK:     Int { 2 }
  /// The object has arbitrary alpha values (0–255).
  public static var TRANSLUCENT: Int { 3 }
}
