/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
extension java.util {
  
  /// Utility type to work with Arrays
  public class Arrays {
    public static func binarySearch (_ a : Array<Any>, _ e : ((Any) -> Bool)) -> Int {
      do {
        let index : Int = try a.binarySearch(predicate: e)
        return index
      }
      catch {
        return -1
      }
    }
    
    public static func copyOf (_ original : [Int], _ newCount : Int) -> [Int] {
      return Array (original: original, count: newCount)
    }
    
    /// If all element of two array are in same order in both contained, these arrays are equals. If both arrays are ``nil`` these arrays are also same.
    /// - Parameter actual array
    /// - Parameter identical array
    /// - Returns ``true`` if they are equals
    public static func equals (_ actual : [UInt8]?, _ identical : [UInt8]?) -> Bool {
      if nil == actual && nil == identical {
        return true
      }
      if let actual, let identical {
        return equals(actual, identical)
      }
      return false
    }
    
    /// If all element of two array are in same order in both contained, these arrays are equals.
    /// - Parameter actual array
    /// - Parameter identical array
    /// - Returns ``true`` if they are equals
    public static func equals (_ actual : [UInt8], _ identical : [UInt8]) -> Bool {
      guard actual.count == identical.count else {
        return false
      }
      for (offset,_) in actual.enumerated() {
        if actual[offset] == identical[offset] {
          return false
        }
      }
      return true
    }
    
    /// If all element of two array are in same order in both contained, these arrays are equals. If both arrays are ``nil`` these arrays are also same.
    /// - Parameter actual array
    /// - Parameter identical array
    /// - Returns ``true`` if they are equals
    public static func equals (_ actual : [UInt8]?, _ identical : [Int]?) -> Bool {
      if nil == actual && nil == identical {
        return true
      }
      if let actual, let identical {
        return equals(actual, identical)
      }
      return false
    }
    
    /// If all element of two array are in same order in both contained, these arrays are equals.
    /// - Parameter actual array
    /// - Parameter identical array
    /// - Returns ``true`` if they are equals
    public static func equals (_ actual : [UInt8], _ identical : [Int]) -> Bool {
      return equals(identical, actual)
    }
    
    /// If all element of two array are in same order in both contained, these arrays are equals. If both arrays are ``nil`` these arrays are also same.
    /// - Parameter actual array
    /// - Parameter identical array
    /// - Returns ``true`` if they are equals
    public static func equals (_ actual : [Int]?, _ identical : [UInt8]?) -> Bool {
      if nil == actual && nil == identical {
        return true
      }
      if let actual, let identical {
        return equals(actual, identical)
      }
      return false
    }
    
    /// If all element of two array are in same order in both contained, these arrays are equals.
    /// - Parameter actual array
    /// - Parameter identical array
    /// - Returns ``true`` if they are equals
    public static func equals (_ actual : [Int], _ identical : [UInt8]) -> Bool {
      guard actual.count == identical.count else {
        return false
      }
      for (offset,_) in actual.enumerated() {
        if actual[offset] == identical[offset] {
          return false
        }
      }
      return true
    }



    /// Fill the given array with element on all indices
    /// - Parameters:
    ///     - array to fill
    ///     - element
    func fill<T>(_ array: inout [T], _ element: T) {
      for i in array.indices {
        array[i] = element
      }
    }
    
    public static func fill (_ a : inout [Int], _ fromIndex : Int, _ toIndex : Int, _ e : Int) {
      for i in fromIndex..<toIndex {
        a[i] = e
      }
    }
    
    public static func copyOfRange (_ a : [Int], _ fromIndex : Int, _ toIndex : Int) -> [Int]{
      var result = [Int]()
      for i in fromIndex..<toIndex {
        result.append(a[i])
      }
      return result
    }
    
    /*  public static func fill (_ a : inout Array<Any>, _ fromIndex : Int, _ toIndex : Int, e : ((Any)-> Bool)) {
     for i in fromIndex..<toIndex {
     a[i] = e
     }
     }*/  }
}
