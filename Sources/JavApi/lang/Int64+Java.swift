/*
 * SPDX-FileCopyrightText: 2024 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension Int64 {
  public static func numberOfLeadingZeros (long : Int64) -> Int {
    return long.leadingZeroBitCount
  }
  
  public static func numberOfTrailingZeros (long : Int64) -> Int {
    return long.trailingZeroBitCount
  }
  
  public func compareTo(_ other : Int64) -> Int {
    return self > other ? 1 : (self < other ? -1 : 0)
  }
  
  public static func parseInt (_ decimalNumber : Int64) -> String {
    return Integer.toHexString (decimalNumber)
  }
}

