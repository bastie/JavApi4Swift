/*
 * SPDX-FileCopyrightText: 2025 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension PIC9 : BinaryInteger, Comparable {
  
  public init<T>(_ source: T) where T : BinaryInteger {
    let count = "\(source)".count
    let value = UInt128(source)
    self.init (count: count, value: value)
  }
  
  public init<T>(_ source: T) where T : BinaryFloatingPoint {
    let count = "\(source)".count
    let value = UInt128(source)
    self.init (count: count, value: value)
  }
  
  public var words: UInt128.Words {
    return self.value.words
  }
  
  public typealias Words = UInt128.Words
  
  public init<T>(truncatingIfNeeded bits: T) where T: BinaryInteger {
    let clampedValue = UInt128(truncatingIfNeeded: bits)
    let count = "\(clampedValue)".count
    self.init(count: count, value: clampedValue)
  }
  
  public init<T>(clamping source: T) where T: BinaryInteger {
    let clampedValue = Swift.max(UInt128(0), Swift.min(UInt128(source), UInt128(PIC9.max)))
    let count = "\(clampedValue)".count
    self.init(count: count, value: clampedValue)
  }
  
  public init(_ from: PIC9) {
    self.init(count: from.count, value: from.value)
  }
  
  public func wordsFullWidth() -> UInt128.Words {
    return words
  }
  
  public var bitWidth: Int {
    return UInt128.bitWidth
  }
  
  public var trailingZeroBitCount: Int {
    return value.trailingZeroBitCount
  }

  public static func / (lhs: PIC9, rhs: PIC9) -> PIC9 {
    let result = lhs.value / rhs.value
    return PIC9(count: lhs.count, value: result)
  }
  public static func /= (lhs: inout PIC9, rhs: PIC9) {
    lhs.value = UInt128(lhs.trim(value: lhs.value / rhs.value, toCount: lhs.count))
  }
  
  public static func % (lhs: PIC9, rhs: PIC9) -> PIC9 {
    guard rhs != 0 else {
      fatalError("Division by zero")
    }
    
    let result = PIC9(count: lhs.count, value: UInt128(lhs.value) % UInt128(rhs.value))
    return result
  }
  
  public static func %= (lhs: inout PIC9, rhs: PIC9) {
    lhs.value = UInt128(lhs.trim(value: lhs.value % rhs.value, toCount: lhs.count))
  }
  
  public static func & (lhs: PIC9, rhs: PIC9) -> PIC9 {
    let result = PIC9(count: lhs.count, value: lhs.value & rhs.value)
    return result
  }
  
  public static func &= (lhs: inout PIC9, rhs: PIC9) {
    lhs.value = UInt128(lhs.trim(value: lhs.value & rhs.value, toCount: lhs.count))
  }
  
  public static func | (lhs: PIC9, rhs: PIC9) -> PIC9 {
    let result = PIC9(count: lhs.count, value: lhs.value | rhs.value)
    return result
  }
  public static func |= (lhs: inout PIC9, rhs: PIC9) {
    lhs.value = UInt128(lhs.trim(value: lhs.value | rhs.value, toCount: lhs.count))
  }
  
  public static func ^ (lhs: PIC9, rhs: PIC9) -> PIC9 {
    let result = PIC9(count: lhs.count, value: lhs.value ^ rhs.value)
    return result
  }
  public static func ^= (lhs: inout PIC9, rhs: PIC9) {
    lhs.value = UInt128(lhs.trim(value: lhs.value ^ rhs.value, toCount: lhs.count))
  }

  public static prefix func ~ (rhs: PIC9) -> PIC9 {
    return PIC9 (count: rhs.count, value: ~rhs.value)
  }
  
  public static func >>= <RHS>(lhs: inout PIC9, rhs: RHS) where RHS : BinaryInteger {
    var value = lhs.value
    value >>= rhs
    let count = "\(value)".count
    lhs.count = count
    lhs.value = value
  }
  public static func <<= <RHS>(lhs: inout PIC9, rhs: RHS) where RHS : BinaryInteger {
    var value = lhs.value
    value <<= rhs
    let count = "\(value)".count
    lhs.count = count
    lhs.value = value
  }
}
