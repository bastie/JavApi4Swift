/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

public class Math {
  
  public static let PI = Double.pi
  public static let E = M_E
  public static let TAU = PI * 2
  
  public static func abs (_ value : Double) -> Double {
    switch value {
    case .nan : return .nan
    case .signalingNaN : return .nan
    case .infinity : return .infinity
    default:
      if value < .zero {
        return -1 * value
      }
      return value
    }
  }
  public static func acos (_ value : Double) -> Double {
    return Foundation.acos(value)
  }
  public static func asin (_ value : Double) -> Double {
    return Foundation.asin(value)
  }
  public static func atan (_ value : Double) -> Double {
    return Foundation.atan(value)
  }
  public static func cbrt (_ value : Double) -> Double {
    return Foundation.cbrt(value)
  }
  public static func ceil (_ value : Double) -> Double {
    return Foundation.ceil(value)
  }
  public static func cos (_ value : Double) -> Double {
    return Foundation.cos(value)
  }
  public static func cosh (_ value : Double) -> Double {
    return Foundation.cosh(value)
  }
  public static func exp (_ value : Double) -> Double {
    return Foundation.exp(value)
  }
  public static func expm1 (_ value : Double) -> Double {
    return Foundation.expm1(value)
  }
  public static func floor (_ value : Double) -> Double {
    return Foundation.floor(value)
  }
  public static func log (_ value : Double) -> Double {
    return Foundation.log(value)
  }
  public static func log10 (_ value : Double) -> Double {
    return Foundation.log10(value)
  }
  public static func log1p (_ value : Double) -> Double {
    return Foundation.log1p(value)
  }
  public static func pow (_ value : Double, _ value2 : Double) -> Double {
    return Foundation.pow(value,value2)
  }
  public static func sin (_ value : Double) -> Double {
    return Foundation.sin(value)
  }
  public static func sinh (_ value : Double) -> Double {
    return Foundation.sinh(value)
  }
  public static func sqrt (_ value : Double) -> Double {
    return Foundation.sqrt(value)
  }
  public static func tan (_ value : Double) -> Double {
    return Foundation.tan(value)
  }
  public static func tanh (_ value : Double) -> Double {
    return Foundation.tanh(value)
  }
  public static func toRadians (_ value : Double) -> Double {
    return value * PI / 180
  }
  public static func toDegrees (_ value : Double) -> Double {
    return value * PI / 180
  }
}
