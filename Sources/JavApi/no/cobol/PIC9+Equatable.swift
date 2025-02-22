/*
 * SPDX-FileCopyrightText: 2025 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

// needed to use ==
extension PIC9 : Equatable {
  /// Implementing the ```Equatable``` protocol to use ```==``` in Code
  public static func == (lhs: PIC9, rhs: PIC9) -> Bool {
    return lhs.value == rhs.value
  }

  static public func == (lhs: PIC9, rhs: any UnsignedInteger) -> Bool {
    let rhs = PIC9(count: lhs.count, value: rhs)
    return lhs.value == rhs.value
  }
  static public func == (lhs: any UnsignedInteger, rhs: PIC9) -> Bool {
    let lhs = PIC9(count: rhs.count, value: lhs)
    return lhs.value == rhs.value
  }
}
