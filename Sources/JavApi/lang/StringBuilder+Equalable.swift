/*
 * SPDX-FileCopyrightText: 2024 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension StringBuilder : Equatable {
  
  public static func == (lhs: StringBuilder, rhs: StringBuilder) -> Bool {
    return lhs === rhs
  }
}
