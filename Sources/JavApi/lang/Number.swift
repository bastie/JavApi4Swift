/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: 0BSD
 */

public typealias Number = Numeric

extension Numeric where Self: BinaryInteger {
  func intValue() -> Int { return Int(self) }
  func longValue() -> Int64 { return Int64(self) }
  func floatValue() -> Float { return Float(self) }
  func doubleValue() -> Double { return Double(self) }
}

extension Numeric where Self: BinaryFloatingPoint {
  func intValue() -> Int { return Int(self.rounded(.towardZero)) }
  func longValue() -> Int64 { return Int64(self.rounded(.towardZero)) }
  func floatValue() -> Float { return Float(self) }
  func doubleValue() -> Double { return Double(self) }
}
