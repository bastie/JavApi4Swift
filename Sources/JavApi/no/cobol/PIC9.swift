/*
 * SPDX-FileCopyrightText: 2025 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

/// `PIC9` Datatyp is a fixed-digits-count integer value with 1 to 31 digits.
///
public struct PIC9 : Sendable {
  public internal(set) var value: UInt128 = 0
  internal var count : Int = 1
  
  public static let max : UInt128 = 9_999_999_999_999_999_999_999_999_999_999
  public static let min : UInt128 = 0
  
  public init(count: Int = 1, value: any UnsignedInteger) {
    guard count >= 1 else {
      fatalError("Count must be at least 1")
    }
    self.count = count
    self.setValue(value)
  }
  
  public mutating func setValue(_ newValue: any UnsignedInteger) {
    self.value = UInt128(trim(value: newValue, toCount: self.count))
  }
    
  internal func trim(value : any UnsignedInteger, toCount : Int?) -> any UnsignedInteger {
    let newCount = toCount ?? self.count
    let asString = "\(value)"
    if newCount < asString.count {
      let endIndex = asString.index(asString.startIndex, offsetBy: newCount)
      switch value.bitWidth {
      case UInt8.bitWidth:
        return UInt8(asString[..<endIndex])!
      case UInt16.bitWidth:
        return UInt16(asString[..<endIndex])!
      case UInt32.bitWidth:
        return UInt32(asString[..<endIndex])!
      case UInt64.bitWidth:
        return UInt64(asString[..<endIndex])!
      // indeed
      case UInt128.bitWidth:
        fallthrough
      default:
        return UInt128(asString[..<endIndex])!
      }
    }
    else {
      return value
    }
  }
}
