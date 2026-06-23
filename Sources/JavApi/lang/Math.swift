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
  public static func abs<T: Numeric & Comparable>(_ value: T) -> T {
    if value < .zero {
      return -1 * value
    }
    return value
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
    return value * 180 / PI
  }
  @inlinable
  public static func min<T>(_ x: T, _ y: T) -> T where T : Comparable {
    Swift.min(x, y)
  }
  @inlinable
  public static func max<T>(_ x: T, _ y: T) -> T where T : Comparable {
    Swift.max(x, y)
  }
  
  /// Java spec: round(a) = (long) floor(a + 0.5) — half-up rounding (not banker's rounding).
  public static func round (_ d : Double) -> Int64 {
    if d.isNaN { return 0 }
    if d >= Double(Int64.max) { return Int64.max }
    if d < Double(Int64.min) { return Int64.min }
    return Int64(Foundation.floor(d + 0.5))
  }

  /// Java spec: round(a) = (int) floor(a + 0.5f) — half-up rounding.
  public static func round (_ f : Float) -> Int {
    if f.isNaN { return 0 }
    return Int(Foundation.floorf(f + 0.5))
  }

  /// IEEE remainder: f1 - (round(f1/f2) * f2)
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  public static func IEEEremainder(_ f1: Double, _ f2: Double) -> Double {
    return Foundation.remainder(f1, f2)
  }

  /// Returns the double closest to a that is a mathematical integer, rounding to even
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  public static func rint(_ a: Double) -> Double {
    return Foundation.rint(a)
  }

  /// Returns the angle theta from the conversion of rectangular coordinates (x, y) to polar (r, theta)
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  public static func atan2(_ a: Double, _ b: Double) -> Double {
    return Foundation.atan2(a, b)
  }
}
