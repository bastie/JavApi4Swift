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
  }
}
