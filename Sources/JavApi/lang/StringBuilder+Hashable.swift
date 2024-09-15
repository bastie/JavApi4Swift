/*
 * SPDX-FileCopyrightText: 2024 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

extension StringBuilder : Hashable {
  
  public var hashValue: Int {
    var hasher = Hasher()
    hash(into: &hasher)
    return hasher.finalize()
  }
 
  public func hash(into hasher: inout Hasher) {
    hasher.combine(System.identityHashCode(self))
    hasher.combine(self.content)
  }
 
  // the Java method
  public func hashCode () -> Int {
    return hashValue
  }
}
