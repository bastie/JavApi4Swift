/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension PIC9 : UnsignedInteger {
  
  // magnitude is implemented by Numeric extension
  
  public static var isSigned: Bool {
    return false
  }
  
}
