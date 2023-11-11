/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension String {
  
  /// Returns the bytes of String in given encoding
  /// - Returns byte array
  public func getBytes () -> [UInt8] {
    return [UInt8](self.data(using: .utf8)!)
  }
}
