/*
 * SPDX-FileCopyrightText: 2024 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension Long : Hashable {
  
  public func hash(into hasher: inout Hasher) {
    hasher.combine(value)
  }
  
  public var hashValue: Int {
    var hasher = Hasher()
    hash(into: &hasher)
    return hasher.finalize()
  }
  
  public func hashCode() -> Int {
    return hashValue
  }

}
