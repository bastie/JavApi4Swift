/*
 * SPDX-FileCopyrightText: 2024 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

/// Java-like 64-bit long Integer type
public class Long {
  
  public static let MAX_VALUE = Int64.max
  public static let MIN_VALUE = Int64.min
  
  public static func numberOfLeadingZeros(_ number : long) -> Int {
    return Int64.numberOfLeadingZeros(long: number)
  }
  
  public static func numberOfTrailingZeros (_ number : long) -> Int {
    return Int64.numberOfTrailingZeros(long: number)
  }
}
