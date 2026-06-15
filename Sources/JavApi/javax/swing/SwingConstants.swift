/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@://github.com>
 * SPDX-License-Identifier: MIT
 */


public enum SwingConstants {
  public static var LEFT:       Int { 2 }
  public static var CENTER:     Int { 0 }
  public static var RIGHT:      Int { 4 }
  public static var TOP:        Int { 1 }
  public static var BOTTOM:     Int { 3 }
  public static var LEADING:    Int { 10 }
  public static var TRAILING:   Int { 11 }
  public static var HORIZONTAL: Int { 0 }
  public static var VERTICAL:   Int { 1 }
  public static var NORTH:      Int { 21 }
  public static var SOUTH:      Int { 22 }
  public static var EAST:       Int { 23 }
  public static var WEST:       Int { 24 }
}


extension javax.swing {
  public protocol SwingConstants {}
  
}

extension javax.swing.SwingConstants {
  public static var LEFT:       Int { 2 }
  public static var CENTER:     Int { 0 }
  public static var RIGHT:      Int { 4 }
  public static var TOP:        Int { 1 }
  public static var BOTTOM:     Int { 3 }
  public static var LEADING:    Int { 10 }
  public static var TRAILING:   Int { 11 }
  public static var HORIZONTAL: Int { 0 }
  public static var VERTICAL:   Int { 1 }
  public static var NORTH:      Int { 21 }
  public static var SOUTH:      Int { 22 }
  public static var EAST:       Int { 23 }
  public static var WEST:       Int { 24 }

}

public func ~= (lhs: any javax.swing.SwingConstants.Type, rhs: Int) -> Bool {
  switch rhs {
  case SwingConstants.LEFT:     return true
  case SwingConstants.CENTER:   return true
  case SwingConstants.RIGHT:    return true
  case SwingConstants.TOP:      return true
  case SwingConstants.BOTTOM:   return true
  case SwingConstants.LEADING:  return true
  case SwingConstants.TRAILING: return true
  case SwingConstants.HORIZONTAL: return true
  case SwingConstants.VERTICAL: return true
  case SwingConstants.NORTH:    return true
  case SwingConstants.SOUTH:    return true
  case SwingConstants.EAST:     return true
  case SwingConstants.WEST:     return true
  default: return false
  }
}
