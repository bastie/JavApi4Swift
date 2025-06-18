/*
 * SPDX-FileCopyrightText: 2025 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
extension java.util.Observer {
  
  public static func == (lhs : Self, rhs : any java.util.Observer) -> Bool {
    return false
  }
  
  public static func == (lhs : any java.util.Observer, rhs : Self) -> Bool {
    return false
  }
}
