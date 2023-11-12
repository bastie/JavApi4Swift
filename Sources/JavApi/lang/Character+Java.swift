/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension Character {
  
  public static func isDigit (_ char : char) -> Bool{
    return char.isNumber
  }
  
  public static func isWhitespace (_ char : char) -> boolean {
    return char.isWhitespace
  }
}
