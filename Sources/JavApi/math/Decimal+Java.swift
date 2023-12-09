/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

extension Decimal {
  
  public static let ZERO = java.math.BigDecimal(0)
  public static let ONE = java.math.BigDecimal(1)
  public static let ROUND_UP = 0
  public static let ROUND_DOWN = 1
  
  // exponent is the internal field of accurance
  
  /// NOTE: Same as Java is a bad idea using a double to initialize a BigDecimal value. Better use ``valueOf:(String)`` because the internal information exponent is set correct
  public static func valueOf (_ newValue : Double) -> java.math.BigDecimal {
    return java.math.BigDecimal(floatLiteral: newValue)
  }
  
  public static func valueOf (_ newValue : String) throws -> Decimal {
    if let result = Decimal(string: newValue) {
      return result
    }
    throw Throwable.NumberFormatException("In result of \"\(newValue)\" is not a number throw a NumberFormatException")
  }
  
  public static func valueOf (_ newValue : Int) -> java.math.BigDecimal {
    return java.math.BigDecimal(integerLiteral: newValue)
  }
  
  public func divide (_ by : Decimal) -> Decimal {
    return self / by
  }
  
  public func add (_ summand: Decimal) -> Decimal {
    return self + summand
  }
  
  
  public static func valueOf (_ newValue : Int64) -> Decimal {
    return Decimal(newValue)
  }
  
  public func subtract (_ other : Decimal) -> Decimal {
    return self - other
  }
  
  public func multiply (_ other : Decimal) -> Decimal{
    return self * other
  }
  
  public func divide (_ bd : java.math.BigDecimal, _ accuracy : Int, _ round : Int) -> Decimal {
    
    let roundMode : NSDecimalNumber.RoundingMode = switch (round) {
    case 4 /* ROUND_HALF_UP */ : .plain
    case 0 /* ROUND_UP */ : .up
    case 1 /* ROUND_DOWN */ : .down
    default : .bankers // FIXME: Java knows some more
    }
    
    let decimalNumberHandler = NSDecimalNumberHandler(
      roundingMode: roundMode,     // Rundungsmodus
      scale: Int16(accuracy),           // Anzahl der Dezimalstellen
      raiseOnExactness: false,
      raiseOnOverflow: false,
      raiseOnUnderflow: false,
      raiseOnDivideByZero: true
    )
    
    let result = (self as NSDecimalNumber).dividing(by: bd as NSDecimalNumber,withBehavior: decimalNumberHandler)
    
    return result as Decimal
  }
  
  
  public func compareTo (_ other : Decimal) -> Int {
    if self < other { return -1 }
    if self > other { return 1 }
    return 0
  }
  
  public func longValue () -> Int64 {
    let delegate = self as NSDecimalNumber
    return delegate.int64Value
  }
}
