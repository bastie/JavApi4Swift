/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension UInt4: Numeric {
  public typealias Magnitude = UInt8
  
  public var magnitude: Magnitude {
    return value
  }
  
  public static func + (lhs: UInt4, rhs: UInt4) -> UInt4 {
    var result = lhs
    result.value = (lhs.value + rhs.value) & 0x0F
    return result
  }
  
  public static func - (lhs: UInt4, rhs: UInt4) -> UInt4 {
    var result = lhs
    result.value = (lhs.value - rhs.value) & 0x0F
    return result
  }
  
  public static func * (lhs: UInt4, rhs: UInt4) -> UInt4 {
    var result = lhs
    result.value = (lhs.value * rhs.value) & 0x0F
    return result
  }
  
  public static func *= (lhs: inout UInt4, rhs: UInt4) {
    lhs = lhs * rhs
  }
  
  public init?<T>(exactly source: T) where T: BinaryFloatingPoint {
    guard let UIntValue = UInt8(exactly: source), UIntValue <= UInt4.max else {
      return nil
    }
    value = UIntValue
  }
}
