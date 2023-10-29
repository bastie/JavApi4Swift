/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension Int32 {
  public static func reverseByte (_ value : Int32) -> Int32 {
    return value.byteSwapped
  }
}
