/*
 * SPDX-FileCopyrightText: 2023-2025 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension Int32 {
  public static func reverseByte (_ value : Int32) -> Int32 {
    return value.byteSwapped
  }
  public func compareTo(_ other : Int32) -> Int {
    return self > other ? 1 : (self < other ? -1 : 0)
  }
  
  public static func parseInt (_ decimalNumber : Int32) -> String {
    return Integer.toHexString (decimalNumber)
  }
  
  public init (_ char : Character) {
    self.init (Int(char))
  }
}
