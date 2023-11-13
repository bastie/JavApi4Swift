/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension Character {
  
  public static func isDigit (_ char : char) -> Bool{
    return char.isNumber
  }
  
  public static func isDigit (_ codePoint : Int) -> Bool{
    var asString = ""
    let asArray : [UnicodeScalar] = [UnicodeScalar(codePoint)!]
    asString = String(String.UnicodeScalarView(asArray))
    return isDigit(asString.toCharArray()[0])
  }
  
  public static func isLetter (_ char : char) -> Bool {
    return char.isLetter
  }
  
  public static func isLetter (_ codePoint : Int) -> Bool{
    var asString = ""
    let asArray : [UnicodeScalar] = [UnicodeScalar(codePoint)!]
    asString = String(String.UnicodeScalarView(asArray))
    return isLetter(asString.toCharArray()[0])
  }
    
  public static func isWhitespace (_ char : char) -> boolean {
    return char.isWhitespace
  }
}
