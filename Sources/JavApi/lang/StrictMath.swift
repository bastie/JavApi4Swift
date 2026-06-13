/*
 * SPDX-FileCopyrightText: 2026- Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

/// - Since: Java 1.3
public struct StrictMath {
  
  public static let PI = 3.141592653589793 // value from Javadoc
  public static let E = 2.718281828459045 // value from Javadoc
  public static let TAU = 6.283185307179586 // value from Javadoc

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
  public static func abs<T: Numeric & Comparable>(_ value: T) -> T {
    if value < .zero {
      return -1 * value
    }
    return value
  }
  
  // TODO: public static func absExact(_ value : Int) -> Int
  // TODO: public static func absExact(_ value : Int64) -> Int64

  public static func acos (_ value : Double) -> Double {
    return Foundation.acos(value)
  }

  // TODO: public static func addExact(_ x : Int, _ y : Int) -> Int
  // TODO: public static func addExact(_ x : Int64, _ y : Int64) -> Int64

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
  
  // TODO: ceilDiv
  // TODO: ceilDiv
  // TODO: ceilDivExact
  // TODO: ceilDivExact
  // TODO: ceilDivMod
  // TODO: ceilDivMod
  // TODO: ceilDivMod
  // TODO: clamp
  // TODO: clamp
  // TODO: clamp
  // TODO: clamp
  // TODO: copySign
  // TODO: copySign

  public static func cos (_ value : Double) -> Double {
    return Foundation.cos(value)
  }
  public static func cosh (_ value : Double) -> Double {
    return Foundation.cosh(value)
  }

  // TODO: decrementExact
  // TODO: decrementExact
  // TODO: divideExact
  // TODO: divideExact

  public static func exp (_ value : Double) -> Double {
    return Foundation.exp(value)
  }
  public static func expm1 (_ value : Double) -> Double {
    return Foundation.expm1(value)
  }
  public static func floor (_ value : Double) -> Double {
    return Foundation.floor(value)
  }
  
  // TODO: floorDiv
  // TODO: floorDiv
  // TODO: floorDiv
  // TODO: floorDivExact
  // TODO: floorDivExact
  // TODO: floorMod
  // TODO: floorMod
  // TODO: floorMod
  // TODO: fma
  // TODO: fma
  // TODO: getExponent
  // TODO: getExponent
  // TODO: hypot

  /// IEEE remainder: f1 - (round(f1/f2) * f2)
  /// - Since: Java 1.3
  public static func IEEEremainder(_ f1: Double, _ f2: Double) -> Double {
    return Foundation.remainder(f1, f2)
  }

  // TODO: incrementExact
  // TODO: incrementExact

  public static func log (_ value : Double) -> Double {
    return Foundation.log(value)
  }
  public static func log10 (_ value : Double) -> Double {
    return Foundation.log10(value)
  }
  public static func log1p (_ value : Double) -> Double {
    return Foundation.log1p(value)
  }
  
  @inlinable
  public static func max<T>(_ x: T, _ y: T) -> T where T : Comparable {
    Swift.max(x, y)
  }

  @inlinable
  public static func min<T>(_ x: T, _ y: T) -> T where T : Comparable {
    Swift.min(x, y)
  }

  // TODO: multiplyExact
  // TODO: multiplyExact
  // TODO: multiplyExact
  // TODO: multiplyFull
  // TODO: multiplyHigh
  // TODO: negateExact
  // TODO: negateExact
  // TODO: nextAfter
  // TODO: nextAfter
  // TODO: nextDown
  // TODO: nextDown
  // TODO: nextUp
  // TODO: nextUp

  public static func pow (_ value : Double, _ value2 : Double) -> Double {
    return Foundation.pow(value,value2)
  }
  
  // TODO: powExact
  // TODO: random

  /// Returns the double closest to a that is a mathematical integer, rounding to even
  /// - Since: Java 1.3
  public static func rint(_ a: Double) -> Double {
    return Foundation.rint(a)
  }

  public static func round (_ d : Double) -> Int64 {
    return Foundation.llround(d)
  }
  public static func round (_ f : Float) -> Int {
    return Int(Foundation.lroundf(f)) // fix because on Windows Foundation.lroundf returns Int32 also on aarch64
  }

  // TODO: scalb
  // TODO: scalb
  // TODO: signum
  // TODO: signum

  public static func sin (_ value : Double) -> Double {
    return Foundation.sin(value)
  }
  public static func sinh (_ value : Double) -> Double {
    return Foundation.sinh(value)
  }
  public static func sqrt (_ value : Double) -> Double {
    return Foundation.sqrt(value)
  }
  
  // TODO: subtractExact
  // TODO: subtractExact

  public static func tan (_ value : Double) -> Double {
    return Foundation.tan(value)
  }
  public static func tanh (_ value : Double) -> Double {
    return Foundation.tanh(value)
  }
  
  public static func toDegrees (_ value : Double) -> Double {
    return value * PI / 180
  }

  // TODO: toIntExact

  public static func toRadians (_ value : Double) -> Double {
    return value * PI / 180
  }
  
  // TODO: ulp
  // TODO: ulp
  // TODO: unsignedMultiplyExact
  // TODO: unsignedMultiplyExact
  // TODO: unsignedMultiplyExact
  // TODO: unsignedMultiplyHigh
  // TODO: unsignedPowExact
  // TODO: unsignedPowExact
}
