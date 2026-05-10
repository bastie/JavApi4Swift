/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

// Extending Array for me
extension Array where Element == UInt4 {
  /// Convert ```[UInt4]``` to ```[UInt8]```
  ///
  /// - Returns: ```[UInt8]```
  public func convertToUInt8Array() -> [UInt8] {
    var uint8Array: [UInt8] = []
    
    var currentUInt8Value: UInt8 = 0
    var isHighNibble = true
    
    for int4Value in self {
      if isHighNibble {
        currentUInt8Value = UInt8(int4Value) << 4
      } else {
        currentUInt8Value |= UInt8(int4Value)
        uint8Array.append(currentUInt8Value)
      }
      
      isHighNibble.toggle()
    }
    
    // Wenn die Schleife beendet ist und isHighNibble noch auf "false" steht,
    // fügen wir den aktuellen Int8-Wert trotzdem hinzu, da er unvollständig ist.
    if !isHighNibble {
      uint8Array.append(currentUInt8Value)
    }
    
    return uint8Array
  }
}


// Other Extending Array with a littlebit more generic
extension Array where Element == UInt4 {
  /// Convert ```[UInt4]``` to other BinaryInteger type
  public func convert<T : BinaryInteger>(to targetType: T.Type) -> [T] {
    let uint8Array = self.convertToUInt8Array()
    return uint8Array.map { T($0) }
  }
}
