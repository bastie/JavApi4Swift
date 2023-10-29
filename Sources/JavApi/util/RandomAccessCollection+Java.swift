/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

// Implementation based on  https://stackoverflow.com/questions/31904396/swift-binary-search-for-standard-array

extension RandomAccessCollection {
  /// Finds such index N that predicate is true for all elements up to  but not including the index N, and is false for all elements  starting with index N.
  /// Behavior is undefined if there is no such N.
  ///
  /// - Parameters Element to looking for
  /// - Returns index
  public func binarySearch(predicate: (Element) -> Bool) throws -> Index {
    if self.contains(where: predicate) {
      var low = startIndex
      var high = endIndex
      while low != high {
        let mid = index(low, offsetBy: distance(from: low, to: high)/2)
        if predicate(self[mid]) {
          low = index(after: mid)
        } else {
          high = mid
        }
      }
      return low
    }
    else {
      throw java.util.Throwable.NoSuchElementException()
    }
  }
}


