/*
 * SPDX-FileCopyrightText: 2024 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension Int16 {
  public func compareTo(_ other : Int16) -> Int {
    return self > other ? 1 : (self < other ? -1 : 0)
  }
  public static func parseInt (_ decimalNumber : Int16) -> String {
    return Integer.toHexString (decimalNumber)
  }
}
