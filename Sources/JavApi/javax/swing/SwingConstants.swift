/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@://github.com>
 * SPDX-License-Identifier: MIT
 */


public enum SwingConstants {
  public static var LEFT:     Int { 2 }
  public static var CENTER:   Int { 0 }
  public static var RIGHT:    Int { 4 }
  public static var TOP:      Int { 1 }
  public static var BOTTOM:   Int { 3 }
  public static var LEADING:  Int { 10 }
  public static var TRAILING: Int { 11 }
}


extension javax.swing {
  public protocol SwingConstants {}
  
}

extension javax.swing.SwingConstants {
  public static var LEFT:     Int { 2 }
  public static var CENTER:   Int { 0 }
  public static var RIGHT:    Int { 4 }
  public static var TOP:      Int { 1 }
  public static var BOTTOM:   Int { 3 }
  public static var LEADING:  Int { 10 }
  public static var TRAILING: Int { 11 }
  
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
  default: return false
  }
}
