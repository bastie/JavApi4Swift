/*
 * SPDX-FileCopyrightText: 2024 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension ComparableJ {
  
  /// Returns `true` when `lhs` is less than or equal to `rhs`.
  /// Derived from `compareTo` and `==`; conforming types need only implement those two.
  public static func <= (lhs: Self, rhs: Self) -> Bool {
    if lhs == rhs {
      return true
    }
    return lhs < rhs
  }
  
  /// Returns `true` when `lhs` is greater than or equal to `rhs`.
  /// Derived from `compareTo` and `==`; conforming types need only implement those two.
  public static func >= (lhs: Self, rhs: Self) -> Bool {
    if lhs == rhs {
      return true
    }
    return lhs > rhs
  }
  
  /// Returns `true` when `lhs` is strictly greater than `rhs` according to `compareTo`.
  public static func > (lhs: Self, rhs: Self) -> Bool {
    return try! lhs.compareTo((rhs as! Self.ComparableJ)) > 0
  }
  
  /// Returns `true` when `lhs` is strictly less than `rhs` according to `compareTo`.
  public static func < (lhs: Self, rhs: Self) -> Bool {
    return try! lhs.compareTo((rhs as! Self.ComparableJ)) < 0
  }
  
}
