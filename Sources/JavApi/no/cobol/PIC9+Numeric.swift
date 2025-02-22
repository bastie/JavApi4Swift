/*
 * SPDX-FileCopyrightText: 2025 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension PIC9 : Numeric {
  public typealias Magnitude = UInt128
  
  public var magnitude: Magnitude {
    return value
  }
  
  public static func + (lhs: PIC9, rhs: PIC9) -> PIC9 {
    let value = lhs.value + rhs.value
    return PIC9 (count: lhs.count, value: UInt128(value))
  }
  
  public static func - (lhs: PIC9, rhs: PIC9) -> PIC9 {
    return PIC9 (count: lhs.count, value: lhs.value - rhs.value)
  }
  
  public static func * (lhs: PIC9, rhs: PIC9) -> PIC9 {
    return PIC9 (count: lhs.count, value: lhs.value * rhs.value)
  }
  
  public static func *= (lhs: inout PIC9, rhs: PIC9) {
    lhs = lhs * rhs
  }
  
  public init?<T>(exactly source: T) where T: BinaryFloatingPoint {
    guard let UIntValue = UInt128(exactly: source), UIntValue <= UInt128.max else {
      return nil
    }
    let count = "\(UInt128 (source))".count
    self.init(count: count, value: UInt128(source))
  }

  public init?<T>(exactly source: T) where T : BinaryInteger {
    guard let UIntValue = UInt128(exactly: source), UIntValue <= UInt128.max else {
      return nil
    }
    let count = "\(UInt128 (source))".count
    self.init(count: count, value: UInt128(source))
  }
  
}
