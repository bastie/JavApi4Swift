/*
 * SPDX-FileCopyrightText: 2024 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.geom.Point2D : Hashable {
  
  public var hashValue: Int {
    var hasher = Hasher()
    hash(into: &hasher)
    return hasher.finalize()
  }
  
  public func hash(into hasher: inout Hasher) {
    hasher.combine(System.identityHashCode(self))
    hasher.combine(self.getX())
    hasher.combine(self.getY())
  }
  
  // the Java method
  public func hashCode () -> Int {
    return hashValue
  }
}
