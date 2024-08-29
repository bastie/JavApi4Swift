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
}

