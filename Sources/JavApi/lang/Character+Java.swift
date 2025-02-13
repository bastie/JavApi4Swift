/*
 * SPDX-FileCopyrightText: 2023,2024 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

/// This type alias provides the char keyword for characters, but you need double quotes instead single quotes.
public typealias char = Character

extension Character {
  
  /// https://www.unicode.org/glossary/#high_surrogate_code_unit
  /// - Since: JavaApi &gt; 0.22.0 (Java 5)
  public static let MAX_HIGH_SURROGATE : Int = 0xDBFF
  
  /// https://www.unicode.org/glossary/#high_surrogate_code_unit
  /// - Since: JavaApi &gt; 0.22.0 (Java 5)
  public static let MIN_HIGH_SURROGATE : Int = 0xD800
  
  /// https://www.unicode.org/glossary/#low_surrogate_code_unit
  /// - Since: JavaApi &gt; 0.22.0 (Java 5)
  public static let MIN_LOW_SURROGATE : Int = 0xDC00
  
  /// https://www.unicode.org/glossary/#low_surrogate_code_unit
  /// - Since: JavaApi &gt; 0.22.0 (Java 5)
  public static let MAX_LOW_SURROGATE : Int = 0xDFFF
  
  /// - Since: JavaApi &gt; 0.16.0 (Java 1.0)
  public init (_ charValue : Swift.Character) {
    self.init(unicodeScalarLiteral: charValue)
  }
  
  /// Returns (a copy of) self value
  /// - Since: JavaApi &gt; 0.16.0 (Java 1.0)
  public func charValue () -> Swift.Character { // TODO: is copyOf needed?
    return "copyOf\(self)".charAt(6)
  }
  
  /// Return the numeric value of Unicode character, f.e. ``\u{216D}`` returns  100.
  ///
  /// - Parameters: char
  /// - Returns: numeric value or 10 to 35 for A-Z or -2 for fractions or -1 for all others
  /// - Since: JavaApi &lt; 0.16.0 (Java 1.1)
  public static func getNumericValue (_ char : Character) -> Int { // FIXME: this implementation must be checked against supported Unicode version of Java versions
    switch char {
    case "0" : return 0
    case "1" : return 1
    case "2" : return 2
    case "3" : return 3
    case "4" : return 4
    case "5" : return 5
    case "6" : return 6
    case "7" : return 7
    case "8" : return 8
    case "9" : return 9
    case "A", "a", "\u{FF21}", "\u{FF41}" : return 10
    case "B", "b", "\u{FF22}", "\u{FF42}" : return 11
    case "C", "c", "\u{FF23}", "\u{FF43}" : return 12
    case "D", "d", "\u{FF24}", "\u{FF44}" : return 13
    case "E", "e", "\u{FF25}", "\u{FF45}" : return 14
    case "F", "f", "\u{FF26}", "\u{FF46}" : return 15
    case "G", "g", "\u{FF27}", "\u{FF47}" : return 16
    case "H", "h", "\u{FF28}", "\u{FF48}" : return 17
    case "I", "i", "\u{FF29}", "\u{FF49}" : return 18
    case "J", "j", "\u{FF2A}", "\u{FF4A}" : return 19
    case "K", "k", "\u{FF2B}", "\u{FF4B}" : return 20
    case "L", "l", "\u{FF2C}", "\u{FF4C}" : return 21
    case "M", "m", "\u{FF2D}", "\u{FF4D}" : return 22
    case "N", "n", "\u{FF2E}", "\u{FF4E}" : return 23
    case "O", "o", "\u{FF2F}", "\u{FF4F}" : return 24
    case "P", "p", "\u{FF30}", "\u{FF50}" : return 25
    case "Q", "q", "\u{FF31}", "\u{FF51}" : return 26
    case "R", "r", "\u{FF32}", "\u{FF52}" : return 27
    case "S", "s", "\u{FF33}", "\u{FF53}" : return 28
    case "T", "t", "\u{FF34}", "\u{FF54}" : return 29
    case "U", "u", "\u{FF35}", "\u{FF55}" : return 30
    case "V", "v", "\u{FF36}", "\u{FF56}" : return 31
    case "W", "w", "\u{FF37}", "\u{FF57}" : return 32
    case "X", "x", "\u{FF38}", "\u{FF58}" : return 33
    case "Y", "y", "\u{FF39}", "\u{FF59}" : return 34
    case "Z", "z", "\u{FF3A}", "\u{FF5A}" : return 35
      // fractions
    case "\u{00BC}", "\u{00BD}", "\u{00BE}" : return -2
    case "\u{2150}", "\u{2151}", "\u{2152}",
      "\u{2153}", "\u{2154}", "\u{2155}",
      "\u{2156}", "\u{2157}", "\u{2158}",
      "\u{2159}", "\u{215A}", "\u{215B}",
      "\u{215C}", "\u{215D}", "\u{215E}" : return -2
    case "\u{215F}" : return 1
    case "\u{2189}" : return 0
    default:
      if let number = char.wholeNumberValue {
        return number
      }
      return -1
    }
  }  /// - Since: JavaApi &lt; 0.16.0 (Java 1.0)
  public static func isDigit (_ char : char) -> Bool{
    return char.isNumber
  }
  
  /// - Since: JavaApi &lt; 0.16.0 (Java 5)
  public static func isDigit (_ codePoint : Int) -> Bool{
    var asString = ""
    let asArray : [UnicodeScalar] = [UnicodeScalar(codePoint)!]
    asString = String(String.UnicodeScalarView(asArray))
    return isDigit(asString.toCharArray()[0])
  }
  
  /// - Since: JavaApi &lt; 0.16.0 (Java 1.0)
  public static func isLetter (_ char : char) -> Bool {
    return char.isLetter
  }
  
  /// - Since: JavaApi &lt; 0.16.0 (Java 5)
  public static func isLetter (_ codePoint : Int) -> Bool{
    var asString = ""
    let asArray : [UnicodeScalar] = [UnicodeScalar(codePoint)!]
    asString = String(String.UnicodeScalarView(asArray))
    return isLetter(asString.toCharArray()[0])
  }
  
  /// - Since: JavaApi &lt; 0.16.0 (Java 1.1)
  public static func isWhitespace (_ char : char) -> boolean {
    return char.isWhitespace
  }
  
  public static let MAX_RADIX : Int = 36
  public static let MAX_VALUE : Character = "\u{FFFF}"
  public static let MIN_RADIX : Int = 2
  public static let MIN_VALUE : Character = "\u{0000}"
  
  
  public func digit(_ character: Character, _ radix: Int) -> Int {
    let stringValue = String(character)
    if let digit = Int(stringValue, radix: radix) {
      return digit
    }
    return -1
  }
  
  public func forDigit(_ digit: Int, _ radix: Int) -> Character {
    let chars = String(digit, radix: radix, uppercase: false)
    return chars.charAt(0)
  }
  
  /// - Since: JavaApi &gt; 0.22.0 (Java 5)
  public static func isHighSurrogate(_ character : Character) -> Bool {
    let integer = Int(character)
    return (   MIN_HIGH_SURROGATE <= integer
               && MAX_HIGH_SURROGATE >= integer)
  }
  
  /// - Since: JavaApi &gt; 0.22.0 (Java 5)
  public static func isLowSurrogate(_ character : Character) -> Bool {
    let integer = Int(character)
    return (   MIN_LOW_SURROGATE <= integer
               && MAX_LOW_SURROGATE >= integer)
  }
}
