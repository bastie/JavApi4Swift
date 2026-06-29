/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

extension java.util.Vector {
  
  /// Swift-style read subscript.
  ///
  /// ```swift
  /// let first = try v[0]
  /// ```
  ///
  /// - Throws: `java.lang.ArrayIndexOutOfBoundsException` when `index` is out of range.
  public subscript(index: Int) -> E {
    get throws { try elementAt(index) }
  }
  
  /// The number of elements (Swift alias for `size()`).
  public var count: Int { size() }
  
  /// Appends `element` using the `+=` operator.
  ///
  /// ```swift
  /// v += myObject
  /// ```
  public static func += (lhs: java.util.Vector<E>, rhs: E) {
    lhs.addElement(rhs)
  }
  
  /// Converts this vector to a plain Swift `Array`.
  public func toSwiftArray() -> [E] { toArray().compactMap { $0 } }
}

