/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension UInt4: LosslessStringConvertible {
  public init?(_ description: String) {
    guard let intValue = UInt8(description, radix: 16), intValue <= UInt8(UInt4.max) else {
      return nil
    }
    self.init(intValue)
  }
}
