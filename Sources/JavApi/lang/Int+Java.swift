/*
 * SPDX-FileCopyrightText: 2023-2025 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension Int {
  
  /// Reverse the bytes of Int32 in result of Java int is 32-bits long
  ///
  /// ** The method is Java-like only for 32-bit implemented. ** Use `Int.byteSwapped` for Swift and of course 64-bit Int types.
  /// https://stackoverflow.com/questions/56222323/what-is-the-equivelent-to-javas-integer-reversebytes-in-swift?rq=3 :
  
  /// A Java int is always 32 bits, so Integer.reverseBytes turns 0x00801600 into 0x00168000.
  ///
  /// A Swift Int is 32 bits on 32-bit platforms and 64 bits on 64-bit platforms (which is most current platforms). So on a 32-bit platform, i.byteSwapped turns 0x00801600 into 0x00168000, but on a 64-bit platform, i.byteSwapped turns 0x0000000000801600 into 0x0016800000000000.
  ///
  public static func reverseBytes (_ value : Int) -> Int {
    return Int (Int32(value).byteSwapped)
  }
  
  public func compareTo(_ other : Int) -> Int {
    return self > other ? 1 : (self < other ? -1 : 0)
  }
  
  public init (_ char : Character) {
    self.init (try! Int.codePointAt([char], 0))
  }
  
  /// - Since: JavaApi &gt; 0.22.0 (Java 5)
  public static func codePointAt (_ char : [Character], _ index : Int) throws -> Int {
    guard index >= 0 && index < char.count else {
      throw Throwable.IndexOutOfBoundsException(index)
    }
    var character: Character = "𝄞" // Beispiel: Musikalisches Symbol ( außerhalb der BMP)
    character = char[index]
    
    // UTF-16-Darstellung des Zeichens abrufen
    let utf16CodeUnits = "\(character)".utf16
    
    // Überprüfen, ob das Zeichen ein einzelnes UTF-16-Code-Unit ist (kein Surrogate Pair)
    if utf16CodeUnits.count == 1 {
      let codeUnit = utf16CodeUnits.first!//[0]
      let codePoint = Int(codeUnit)
      
      return codePoint
    } else if utf16CodeUnits.count == 2 {
      // Behandlung von Surrogate Pairs (falls erforderlich)
      let highSurrogate = utf16CodeUnits.first!//[0]
      let lowSurrogate = utf16CodeUnits.last!//[1]
                                             // ... Logik zur Berechnung des Int32-Werts aus den Surrogate Pairs
      let codePoint : Int = (Int(highSurrogate) - 0xD800) * 0x400 + (Int(lowSurrogate) - 0xDC00) + 0x10000
      
      return codePoint
    } else {
      throw Throwable.UnknownError("Never ever reached position in source Int+java.swift:codePointAt()")
    }
  }
  
}
