/*
 * SPDX-FileCopyrightText: 2024-2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.geom.Point2D : Hashable {
  
  public var hashValue: Int {
    var hasher = Hasher()
    hash(into: &hasher)
    return hasher.finalize()
  }
  
  public func hash(into hasher: inout Hasher) {
    hasher.combine(self.getX())
    hasher.combine(self.getY())
  }
  
  // the Java method
  public func hashCode () -> Int {
    return hashValue
  }
}
