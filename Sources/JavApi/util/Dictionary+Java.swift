/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension Dictionary {
  
  public func get (_ name : Key?) throws (NullPointerException) -> Value? {
    if let name {
      return self[name]
    }
    
    throw NullPointerException("In result of key is nil, NullPointerException ist throwing")
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
  
  public mutating func putAll (_ map : Dictionary<Key,Value>?) throws (NullPointerException) {
    if let map {
      for (key, value) in map {
        self[key] = value
      }
    }
    else {
      throw NullPointerException("In result of parameter is nil.")
    }
  }

  /// Returns `true` if this dictionary contains no key-value mappings.
  /// - Since: JavaApi (Java 1.0)
  public func isEmpty () -> Bool {
    return self.count == 0
  }

  /// Returns the number of key-value mappings.
  /// - Since: JavaApi (Java 1.0)
  public func size () -> Int {
    return self.count
  }

  /// Removes the mapping for `key` and returns the previous value, or `nil`.
  /// - Since: JavaApi (Java 1.0)
  @discardableResult
  public mutating func remove (_ key : Key) -> Value? {
    return self.removeValue(forKey: key)
  }

  /// Returns an `Enumeration` over the keys of this dictionary.
  /// - Since: JavaApi (Java 1.0)
  public func keys () -> any java.util.Enumeration<Key> {
    return HashtableEnumeration(Array(self.keys))
  }

  /// Returns an `Enumeration` over the values of this dictionary.
  /// - Since: JavaApi (Java 1.0)
  public func elements () -> any java.util.Enumeration<Value> {
    return HashtableEnumeration(Array(self.values))
  }
}
