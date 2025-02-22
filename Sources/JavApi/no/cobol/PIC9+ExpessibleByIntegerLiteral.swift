/*
 * SPDX-FileCopyrightText: 2025 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

// this helps also in the IDE but only on one side :-(
extension PIC9 : ExpressibleByIntegerLiteral {
  public typealias UIntegerLiteralType = UInt128
  
  public init (integerLiteral value: UIntegerLiteralType) {
    let count = "\(value)".count
    self.init(count: count, value: value)
  }
}
