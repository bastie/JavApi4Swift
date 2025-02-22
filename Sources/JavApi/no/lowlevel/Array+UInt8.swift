/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

// Extending Array for me
extension Array where Element == UInt8 {
  /// Convert ```[UInt8]``` to ```[UInt4]```
  ///
  /// - Returns: ```[UInt4]```
  public func convertToInt4Array() -> [UInt4] {
    var uint4Array: [UInt4] = []
    
    for uint8Value in self {
      var nibble1 = UInt4()
      var nibble2 = UInt4()
      
      nibble1.setValue(UInt8(uint8Value) >> 4)
      nibble2.setValue(UInt8(uint8Value) & 0x0F)
      
      uint4Array.append(nibble1)
      uint4Array.append(nibble2)
    }
    
    return uint4Array
  }
}

