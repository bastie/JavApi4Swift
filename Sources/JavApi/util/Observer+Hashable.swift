/*
 * SPDX-FileCopyrightText: 2025 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.util.Observer {
  public var hashValue: Int {
    var hasher = Hasher()
    hash(into: &hasher)
    return hasher.finalize()
  }
  
  public func hash(into hasher: inout Hasher) {
    hasher.combine(System.identityHashCode(self.observerInstance()))
  }
  
  // the Java method
  public func hashCode () -> Int {
    return hashValue
  }  
}
