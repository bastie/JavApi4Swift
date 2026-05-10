/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

// "toString()" implementation
extension UInt4: CustomStringConvertible {
    
  
  public var description: String {
    return String(value, radix: 16).uppercased()
  }
}
