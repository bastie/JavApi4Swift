/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

// this helps also in the IDE but only on one side :-(
extension UInt4 : ExpressibleByIntegerLiteral {
  public typealias UIntegerLiteralType = UInt8
  
  public init(integerLiteral value: UIntegerLiteralType) {
    guard value <= 0x0F else {
      fatalError("Invalid value for UInt4. Value must be between 0 and 15.")
    }
    guard value >= 0x00 else {
      fatalError("Invalid value for UInt4. Value must be between 0 and 15.")
    }
    self.value = value
  }
}
