/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

extension java.math.BigDecimal {
  public func setScale (_ newScale : Int, _ roundingMode : Int) -> java.math.BigDecimal {
    let before = self.exponent
    var stringValue = ""
    if before < 0 { // -2 = to chars after point
      stringValue = "\((self as NSDecimalNumber).doubleValue)"
      
      // trim to scale
      var newStringValue = ""
      var dotPosition = -1
      
      for char in stringValue {
        if char == "." { // found
          dotPosition += 1
        }
        else {
          if dotPosition < 0 { // before dot
            newStringValue.append(char)
          }
          else {
            if dotPosition * -1 > before { // in the scale
              newStringValue.append(char)
            }
            dotPosition += 1 // next position after dot
          }
        }
        // trimmed
        stringValue = newStringValue
      }
      
    }
    else { // FIXME: not real implemented
      stringValue = "\((self as NSDecimalNumber).int64Value)"
    }
    
    let result = java.math.BigDecimal (string: stringValue)!
    
    let roundMode : NSDecimalNumber.RoundingMode = switch (roundingMode) {
    case 4 /* ROUND_HALF_UP */ : .plain
    case 0 /* ROUND_UP */ : .up
    case 1 /* ROUND_DOWN */ : .down
    default : .bankers // FIXME: Java knows some more
    }
    
    
    _ = _BigDecimal.savedRoundMode [result, default: roundMode]
    return result
  }
}

internal class _BigDecimal {
  internal static var savedRoundMode : [java.math.BigDecimal: NSDecimalNumber.RoundingMode] = [:]
}
