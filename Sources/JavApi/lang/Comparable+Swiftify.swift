/*
 * SPDX-FileCopyrightText: 2024 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension ComparableJ {
  
  public static func <= (lhs: Self, rhs: Self) -> Bool {
    if lhs == rhs {
      return true
    }
    return lhs < rhs
  }
  
  public static func >= (lhs: Self, rhs: Self) -> Bool {
    if lhs == rhs {
      return true
    }
    return lhs > rhs
  }
  
  public static func > (lhs: Self, rhs: Self) -> Bool {
    return try! lhs.compareTo((rhs as! Self.ComparableJ)) > 0
  }
  
  public static func < (lhs: Self, rhs: Self) -> Bool {
    return try! lhs.compareTo((rhs as! Self.ComparableJ)) < 0
  }
  
}
