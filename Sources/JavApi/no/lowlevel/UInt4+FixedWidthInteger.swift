/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension UInt4: FixedWidthInteger {
  
  public static var bitWidth: Int {
    return 4
  }
  
  public init<T>(_ source: T) where T: BinaryInteger {
    let clampedValue = UInt8(truncatingIfNeeded: source) & 0x0F
    value = clampedValue
  }
  
  public func addingReportingOverflow(_ rhs: UInt4) -> (partialValue: UInt4, overflow: Bool) {
    let result = UInt4(truncatingIfNeeded: UInt(self) + UInt(rhs))
    let overflow = (result.value & 0xF0) != 0
    return (result, overflow)
  }
  
  public func subtractingReportingOverflow(_ rhs: UInt4) -> (partialValue: UInt4, overflow: Bool) {
    let result = UInt4(truncatingIfNeeded: UInt(self) - UInt(rhs))
    let overflow = (result.value & 0xF0) != 0
    return (result, overflow)
  }
  
  public func multipliedReportingOverflow(by rhs: UInt4) -> (partialValue: UInt4, overflow: Bool) {
    let result = UInt4(truncatingIfNeeded: UInt(self) * UInt(rhs))
    let overflow = (result.value & 0xF0) != 0
    return (result, overflow)
  }
  
  public func dividedReportingOverflow(by rhs: UInt4) -> (partialValue: UInt4, overflow: Bool) {
    if rhs == 0 {
      return (0, true) // Division by zero
    }
    let result = UInt4(truncatingIfNeeded: UInt(self) / UInt(rhs))
    return (result, false)
  }
  
  public func remainderReportingOverflow(dividingBy rhs: UInt4) -> (partialValue: UInt4, overflow: Bool) {
    if rhs == 0 {
      return (0, true) // Division by zero
    }
    let result = UInt4(truncatingIfNeeded: UInt(self) % UInt(rhs))
    return (result, false)
  }
  
  public func dividingFullWidth(_ dividend: (high: UInt4, low: UInt8)) -> (quotient: UInt4, remainder: UInt4) {
    let dividendValue = UInt(dividend.high) << 8 + UInt(dividend.low)
    let quotient = UInt4(truncatingIfNeeded: dividendValue / UInt(self))
    let remainder = UInt4(truncatingIfNeeded: dividendValue % UInt(self))
    return (quotient, remainder)
  }
  
  public var nonzeroBitCount: Int {
    return value.nonzeroBitCount
  }
  
  public var leadingZeroBitCount: Int {
    return value.leadingZeroBitCount
  }
  
  public var byteSwapped: UInt4 {
    return UInt4(truncatingIfNeeded: value.byteSwapped)
  }
}
