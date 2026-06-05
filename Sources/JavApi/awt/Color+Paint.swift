/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

// MARK: - Color: Transparency + Paint

extension java.awt.Color: java.awt.Transparency {
  /// Returns `TRANSLUCENT` when alpha < 1, otherwise `OPAQUE`.
  public func getTransparency() -> Int {
    // Access constants through the concrete type, not the protocol metatype.
    // java.awt.Transparency.OPAQUE would fail: static protocol extension
    // members are not accessible on (any Protocol).Type in Swift.
    getAlpha() == 255
      ? java.awt.Color.OPAQUE
      : java.awt.Color.TRANSLUCENT
  }
}

extension java.awt.Color: java.awt.Paint {}
