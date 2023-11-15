/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension Dictionary {
  
  public func get (_ name : Key) throws -> Value? {
    return self[name]
  }
  
  public mutating func putAll (_ map : Dictionary<Key,Value>) {
    for (key, value) in map {
      self[key] = value
    }
  }
}
