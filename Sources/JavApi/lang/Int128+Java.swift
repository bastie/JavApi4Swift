/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: 0BSD
 */

extension Int128 {
  public static func numberOfLeadingZeros(_ value: Int64) -> Int {
    return value.leadingZeroBitCount
  }
  
  public static func numberOfTrailingZeros(_ value: Int64) -> Int {
    return value.trailingZeroBitCount
  }
}
