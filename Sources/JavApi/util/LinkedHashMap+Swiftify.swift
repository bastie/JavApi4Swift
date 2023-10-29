/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.util.LinkedHashMap {
  
  /// Create new instance with given dictionary
  /// - Parameters with dictionary
  public convenience init(with dictionary: Dictionary<KeyType, ValueType>) {
    self.init()
    delegateDictionary = dictionary
    sortedKeyCollection = dictionary.keys.map { $0 }
  }
  
  /// The count of elements in this collection
  var count: Int {
    get {
      delegateDictionary.count
    }
  }
  
  /// The keys of this collections
  var keys: [KeyType] {
    get {
      sortedKeyCollection
    }
  }
  
  /// The values of this collection
  var values: Array<ValueType> {
    get {
      sortedKeyCollection.map { delegateDictionary[$0]! }
    }
  }

  /// working like normal dictionary in Swift
  subscript(key: KeyType) -> ValueType? {
    get {
      self.delegateDictionary[key]
    }
    set {
      if newValue == nil {
        let _ = self.remove(key)
      } else {
        _ = self.put(key, newValue!)
      }
    }
  }
  
}
