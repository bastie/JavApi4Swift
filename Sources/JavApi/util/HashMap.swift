/*
 * SPDX-FileCopyrightText: 2025 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
extension java.util {
  
  open class HashMap<K: Hashable, V> {
    public var delegate : [K : V] = [:]
    
    open func put(_ key: K, _ value: V) -> V? {
      let oldValue = delegate[key]
      delegate[key] = value
      return oldValue
    }
    
    open func get(_ key: K) -> V? {
      return delegate[key]
    }
    
    open func containsKey(_ key: K) -> Bool {
      return delegate.keys.contains(key)
    }
    
    public init() {}
  }
  
}

