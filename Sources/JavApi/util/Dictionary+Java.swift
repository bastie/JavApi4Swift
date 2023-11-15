/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension Dictionary {
  
  public func get (_ name : Key?) throws -> Value? {
    if let name {
      return self[name]
    }
    
    throw Throwable.NullPointerException("In result of key is nil, NullPointerException ist throwing")
  }
  
  public mutating func put (_ name : Key?, _ value : Value?) throws -> Value? {
    let oldValue = try get(name)
    self[name!] = value
    return oldValue
  }
  
  public mutating func clear () {
    self.removeAll()
  }

  public func containsKey (_ key : Key) -> Bool {
    return self.keys.contains(key)
  }
  
  public mutating func putAll (_ map : Dictionary<Key,Value>?) throws {
    if let map {
      for (key, value) in map {
        self[key] = value
      }
    }
    else {
      throw Throwable.NullPointerException("In result of parameter is nil.")
    }
  }
}
