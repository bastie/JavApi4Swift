/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
infix operator >>> : BitwiseShiftPrecedence

public func >>> (lhs: Int, rhs: Int) -> Int {
  return Int(bitPattern: UInt(bitPattern: lhs) >> UInt(rhs))
}
public func >>> (lhs: Int64, rhs: Int64) -> Int64 {
  return Int64(bitPattern: UInt64(bitPattern: lhs) >> UInt64(rhs))
}
public func >>> (lhs: Int32, rhs: Int32) -> Int32 {
  return Int32(bitPattern: UInt32(bitPattern: lhs) >> UInt32(rhs))
}
public func >>> (lhs: Int16, rhs: Int16) -> Int16 {
  return Int16(bitPattern: UInt16(bitPattern: lhs) >> UInt16(rhs))
}
public func >>> (lhs: Int8, rhs: Int8) -> Int8 {
  return Int8(bitPattern: UInt8(bitPattern: lhs) >> UInt8(rhs))
}
