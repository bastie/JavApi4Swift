/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension UInt4: ExpressibleByStringLiteral {
  public typealias StringLiteralType = String
  
  public init(stringLiteral value: String) {
    guard let intValue = UInt8(value, radix: 16), intValue <= 0x0F else {
      fatalError("Invalid value for UInt4. Value must be between 0 and 15.")
    }
    self.value = intValue
  }
}
