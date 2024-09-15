/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension String {
  
  // overwrite Foundation.String hashValue with Java like hashCode
  var hashValue : Int {
    var hash = 0
    for character in self.reversed() {
      hash = 31 * hash + Int(character.asciiValue!)
    }
    return hash
  }
  
  /// Returns the bytes of String in given encoding
  /// - Returns byte array
  public func getBytes () -> [UInt8] {
    return [UInt8](self.data(using: .utf8)!)
  }
}
