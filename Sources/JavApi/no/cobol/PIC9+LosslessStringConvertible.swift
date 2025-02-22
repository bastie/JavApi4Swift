/*
 * SPDX-FileCopyrightText: 2025 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension PIC9 : LosslessStringConvertible {
  public init?(_ description: String) {
    guard let intValue = UInt128(description), intValue <= PIC9.max else {
      return nil
    }
    self.init(intValue)
  }
}
