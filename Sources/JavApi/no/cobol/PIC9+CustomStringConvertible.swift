/*
 * SPDX-FileCopyrightText: 2025 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
extension PIC9 : CustomStringConvertible {
  public var description: String {
    var result = "\(self.value)"
    while result.count < self.count {
      result.insert("0", at: result.startIndex)
    }
    return result
  }
}
