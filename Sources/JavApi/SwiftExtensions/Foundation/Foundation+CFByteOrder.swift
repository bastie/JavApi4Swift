/*
 * SPDX-FileCopyrightText: 2025 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: Apache-2.0
 */


#if os(Linux) || os(Android) || os(Windows) || os(FreeBSD) || os(WASI)
public typealias CFIndex = Int
public typealias CFByteOrder = CFIndex

public enum _CFByteOrder: Int {
  case unknown = 0
  case littleEndian = 1
  case bigEndian = 2
}

public func CFByteOrderGetCurrent() -> CFByteOrder {
#if _endian(big)
  return _CFByteOrder.bigEndian.rawValue
#else
  #if _endian(little)
  return _CFByteOrder.littleEndian.rawValue
  #else
  return _CFByteOrder.unknown.rawValue
  #endif
#endif
}
#endif
