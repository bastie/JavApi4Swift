/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

extension java.math.BigDecimal {

  public static let ZERO = java.math.BigDecimal(0.0)
  public static let ONE = java.math.BigDecimal(1.0)
  public static let ROUND_UP = 0
  public static let ROUND_DOWN = 1

  public func setScale (_ newScale : Int, _ roundingMode : Int) -> java.math.BigDecimal {
    
    var result = self
    var doubleValue = (self as NSDecimalNumber).doubleValue
    switch roundingMode {
    case java.math.BigDecimal.ROUND_DOWN :
      let string = String(format: "%.\(newScale)f" ,doubleValue)
      result = java.math.BigDecimal.valueOf(string)!
    case java.math.BigDecimal.ROUND_UP :
      let factor = switch newScale {
      case 0 : {return Double(1)}
      case 1 : {return Double(10)}
      default : {
        var computedFactor = 10
        for _ in 1..<newScale { computedFactor *= 10 }
        return Double(computedFactor)
      }
      }
      doubleValue = ceil(doubleValue * factor()) / factor()
      let string = String(format: "%.\(newScale)f" ,doubleValue)
      result = java.math.BigDecimal.valueOf(string)!
    default:
      fatalError("Please help! Not yet implemented round method.")
      break;
    }
    
    return result
  }
}
