/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: 0BSD
 */

typealias Number = Numeric

extension Numeric where Self: BinaryInteger {
  func intValue() -> Int { return Int(self) }
  func doubleValue() -> Double { return Double(self) }
}

extension Numeric where Self: BinaryFloatingPoint {
  func intValue() -> Int { return Int(self.rounded(.towardZero)) }
  func doubleValue() -> Double { return Double(self) }
}
