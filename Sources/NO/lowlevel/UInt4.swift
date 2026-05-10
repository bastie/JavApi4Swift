/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

///
///  UInt4.swift
///
/// Example UInt4-Array
/// ```Swift
///    var uint4Array: [UInt4] = [2, 3, 1]
/// ```
///
/// Use convert function to [UInt8]
/// ```Swift
///    let uint8Array = uint4Array.convert(to: UInt8.self)
///    print(uint8Array) // Output: [35, 10]
/// ```
///
/// Convert [UInt4] from [UInt8]
/// ```Swift
///    let input : [UInt8] = [255]
///    print(input)
///    uint4Array = input.convertToInt4Array()
///    print(uint4Array)
/// ```
///
/// Use all values over helper range
/// ```Swift
///     for value in UInt4.allValues {
///     }
/// ```
///
public struct UInt4 : Sendable {
  internal var value: UInt8 = 0 // 4-Bit-Field
  
  public init() {} // Init
  
  public mutating func setValue(_ newValue: UInt8) {
    let _ : UInt8 = 255 - 16 + value
    guard newValue <= 0xF else {
      fatalError("Invalid value for UInt4. Value must be between 0 and 15.")
    }
    value = newValue
  }
  
  public func getValue() -> UInt8 {
    return value
  }
}
typealias Nibble = UInt4

extension UInt4 {
  /// Combine two ```UInt4``` to ```UInt8```
  /// - Parameters:
  ///    - nibble1: ```UInt4``` high value
  ///    - nibble2: ```UInt4``` low value
  /// - Returns: ```UInt8```
  public static func combineNibblesToByte(_ nibble1: UInt4, _ nibble2: UInt4) -> UInt8 {
    let byte: UInt8 = (nibble1.getValue() << 4) | nibble2.getValue()
    return byte
  }
  
  /// Convert a ```UInt8``` to UInt4 Tupel
  ///
  /// - Parameters:
  ///    - byte: ```UInt8```
  /// - Returns: ```(UInt4, UInt4) ```
  public static func splitByteIntoNibbles(_ byte: UInt8) -> (UInt4, UInt4) {
    var nibble1 = UInt4()
    var nibble2 = UInt4()
    
    nibble1.setValue(byte >> 4)       // Erste 4 Bits (höhere Bits)
    nibble2.setValue(byte & 0x0F)     // Letzte 4 Bits (niedrigere Bits)
    
    return (nibble1, nibble2)
  }
  
  /// Convert [UInt4] to [UInt8]
  ///
  /// - Parameters:
  ///   - int4Array: [UInt4]
  ///
  /// - Returns:[UInt8]
  public static func convertUInt4ArrayToUInt8Array(_ int4Array: [UInt4]) -> [UInt8] {
    var uint8Array: [UInt8] = []
    
    var currentUInt8Value: UInt8 = 0
    var isHighNibble = true
    
    for int4Value in int4Array {
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
