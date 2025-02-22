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
  
  /// - Since: JavaApi &gt; 0.22.1 (Java 5)
  public static func toChars(_ codePoint: Int) throws -> [Character] {
    /// parts from codestral:22b
    guard codePoint > 0 else {
      throw Throwable.IllegalArgumentException("Unicode codepoint must be greater than 0")
    }
    if let scalar = UnicodeScalar(UInt16(codePoint)) {
      return "\(scalar)".toCharArray()
    }
    else {
      let lead = (codePoint - 0x10000) >> 10 &+ 0xD800
      let trail = (codePoint - 0x10000) & 0x3FF | 0xDC00

      return ["\(UnicodeScalar(lead)!.description)".charAt(0), "\(UnicodeScalar(trail)!.description)".charAt(0)]
    }
  }
  
  /// If given parameter `codepoint` greater or equals 0x10000 returns 2 otherwise 1
  /// - Parameter codepoint
  /// - Returns 2 or 1, unchecked valid codepoint
  /// - Since: JavaApi &gt; 0.22.1 (Java 5)
  public static func charCount (_ codepoint : Int) -> Int {
    return codepoint >= 0x10000 ? 2 : 1
  }
  
  /// - Since: JavaApi &gt; 0.23.0 (Java 5)
  public static func codePointAt (_ char : [Character], _ index : Int) throws -> Int {
    guard index >= 0 && index < char.count else {
      throw Throwable.IndexOutOfBoundsException(index)
    }
    //var character: Character = "𝄞" // Beispiel: Musikalisches Symbol ( außerhalb der BMP)
    let character : Character = char[index]
    
    // UTF-16-Darstellung des Zeichens abrufen
    let utf16CodeUnits = "\(character)".utf16
    
    // Überprüfen, ob das Zeichen ein einzelnes UTF-16-Code-Unit ist (kein Surrogate Pair)
    if utf16CodeUnits.count == 1 {
      let codeUnit = utf16CodeUnits.first!//[0]
      let codePoint = Int(codeUnit)
      
      return codePoint
    }
    else if utf16CodeUnits.count == 2 {
      // Behandlung von Surrogate Pairs (falls erforderlich)
      let highSurrogate = utf16CodeUnits.first!//[0]
      let lowSurrogate = utf16CodeUnits.last!//[1]
      // ... Logik zur Berechnung des Int32-Werts aus den Surrogate Pairs
      let codePoint : Int = (Int(highSurrogate) - 0xD800) * 0x400 + (Int(lowSurrogate) - 0xDC00) + 0x10000
      
      return codePoint
    }
    else {
      throw Throwable.UnknownError("Never ever reached position in source Int+java.swift:codePointAt()")
    }
  }
  
  public static func codePointAt(_ text: String, _ offset: Int) throws -> Int {
    return try codePointAt(text.toCharArray(), offset)
  }
  
  ///   Converts the give surrogate pair to its supplementary Unicode.Scalar code point value, without validation
  /// - Parameters:
  /// - Parameter high - high-surrogate code unit
  /// - Parameter low - low-surrogate code unit
  /// - Returns: the supplementary code point computed by parameters
  /// - Since: JavaApi &gt; 0.22.1 (Java 5)
  public static func toCodePoint(_ high: Int, _ low: Int) -> Int {
    // from XCode generated
    return ((high & 0x3FF) << 10) | (low & 0x3FF) | 0x10000
  }
}
