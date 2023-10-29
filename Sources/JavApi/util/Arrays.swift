/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
extension java.util {
  
  /// Utility type to work with Arrays
  public class Arrays {

    /// Fill the given array with element on all indices
    /// - Parameters:
    ///     - array to fill
    ///     - element
    func fill<T>(_ array: inout [T], _ element: T) {
      for i in array.indices {
        array[i] = element
      }
    }
    public static func copyOf (_ original : [Int], _ newCount : Int) -> [Int] {
      return Array (original: original, count: newCount)
    }
    
    public static func binarySearch (_ a : Array<Any>, _ e : ((Any) -> Bool)) -> Int {
      do {
        let index : Int = try a.binarySearch(predicate: e)
        return index
      }
      catch {
        return -1
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
