/*
 * SPDX-FileCopyrightText: 2024 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

/// Java-like 64-bit long Integer type
public final class Long : Number {
  public static func *= (lhs: inout Long, rhs: Long) {
    lhs.value *= rhs.value
  }
  
  public let magnitude: Int64.Magnitude
  
  public static func - (lhs: Long, rhs: Long) -> Self {
    return .init(exactly: lhs.value - rhs.value)!
  }
  
  public required init(integerLiteral value: Int64) {
    self.value = value
    self.magnitude = Int64.Magnitude(value)
  }
  
  public typealias Magnitude = Int64.Magnitude
  
  internal var value : Int64
  
  public required init?<T>(exactly source: T) where T : BinaryInteger {
    self.value = Int64(exactly: source)!
    self.magnitude = Int64.Magnitude(self.value)
  }
  
  public static func * (lhs: Long, rhs: Long) -> Self {
    return .init(exactly: lhs.value * rhs.value)!
  }
  
  public static func + (lhs: Long, rhs: Long) -> Self {
    return .init(exactly: lhs.value + rhs.value)!
  }
  
  public typealias IntegerLiteralType = Int64
  
  public static func == (lhs: Long, rhs: Long) -> Bool {
    return lhs.value == rhs.value
  }
  
  
  public static let MAX_VALUE = Int64.max
  public static let MIN_VALUE = Int64.min
  
  public static func numberOfLeadingZeros(_ number : long) -> Int {
    return Int64.numberOfLeadingZeros(long: number)
  }
  
  public static func numberOfTrailingZeros (_ number : long) -> Int {
    return Int64.numberOfTrailingZeros(long: number)
  }
}
