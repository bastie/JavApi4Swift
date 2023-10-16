/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.util {
  /// A LinkedHashMap implementation
  public struct LinkedHashMap<KeyType: Hashable, ValueType> where ValueType: Equatable {
    /*
     the implementation use a dictionary for key-value pairs and an array for sorted keys
     */
    internal var delegateDictionary: Dictionary<KeyType, ValueType>
    internal var sortedKeyCollection: Array<KeyType>
    
    public init() {
      delegateDictionary = [:]
      sortedKeyCollection = []
    }
    
    public init(_ initialCpacity : Int) {
      delegateDictionary = Dictionary<KeyType, ValueType>(minimumCapacity: initialCpacity)
      sortedKeyCollection = Array<KeyType>()
    }
    
    public init(_ m : LinkedHashMap<KeyType, ValueType>) {
      self.delegateDictionary = m.delegateDictionary // Dictionary<KeyType, ValueType>(minimumCapacity: m._keys.count)
      self.sortedKeyCollection = m.sortedKeyCollection
    }
    
    mutating func clear () {
      sortedKeyCollection = []
      delegateDictionary = Dictionary<KeyType, ValueType>(minimumCapacity: 100)
    }
    
    mutating func put (_ key : KeyType, _ newValue : ValueType) -> ValueType? {
      let oldValue = self.delegateDictionary.updateValue(newValue, forKey: key)
      if nil == oldValue  {
        self.sortedKeyCollection.append(key)
      }
      return oldValue
    }
    
    mutating func remove (_ key : KeyType) -> ValueType? {
      guard self.sortedKeyCollection.contains(key) else {
        return nil
      }
      let oldValue = self.delegateDictionary[key]
      self.sortedKeyCollection = self.sortedKeyCollection.filter {
        key != $0
      }
      self.delegateDictionary.removeValue(forKey: key)
      return oldValue
    }
    
    public func containsKey (_ key : KeyType) -> Bool {
      return self.sortedKeyCollection.contains(key)
    }
    public func containsValue (_ value : ValueType) -> Bool {
      self.delegateDictionary.map{$0.value}.contains (value)
    }
    
    public func isEmpty () -> Bool {
      return self.sortedKeyCollection.isEmpty
    }
    
    public func size () -> Int {
      return delegateDictionary.count
    }
    

  }
  
  /// The iterator for Linked HashMap
  public struct LinkedHashMapIterator<KeyType: Hashable, ValueType>: IteratorProtocol {
    let sequence: Dictionary<KeyType, ValueType>
    let keys: Array<KeyType>
    var current = 0
    
    mutating public func next() -> (KeyType, ValueType)? {
      defer { current += 1 }
      guard current <= sequence.count else {
        return nil
      }
      
      let key = keys[current]
      if let value = sequence[key] {
        return (key, value)
      }
      else {
        return nil
      }
    }
    
  }
  
}

extension java.util.LinkedHashMap: Sequence {
  
  public func makeIterator() -> java.util.LinkedHashMapIterator<KeyType, ValueType> {
    java.util.LinkedHashMapIterator<KeyType, ValueType>(sequence: delegateDictionary, keys: sortedKeyCollection, current: 0)
  }
  
}

