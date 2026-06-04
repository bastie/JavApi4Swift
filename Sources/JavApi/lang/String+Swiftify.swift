/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension String {
  
  // overwrite Foundation.String hashValue with Java like hashCode
  var hashValue : Int {
    var hash = 0
    for character in self.reversed() {
      hash = 31 * hash + Int(character.asciiValue!)
    }
    return hash
  }
  
  /// Returns the bytes of String in given encoding
  /// - Returns byte array
  public func getBytes () -> [UInt8] {
    return [UInt8](self.data(using: .utf8)!)
  }
  

  /// Copies characters from this string into the destination array.
  ///
  /// Equivalent to Java's `String.getChars(int srcBegin, int srcEnd, char[] dst, int dstBegin)`.
  /// The characters at index `start` up to (but not including) `end` are placed into `array`
  /// starting at `dstStart`.
  ///
  /// - Parameters:
  ///   - start: Index of the first character to copy (inclusive).
  ///   - end: Index after the last character to copy (exclusive).
  ///   - array: Destination character array.
  ///   - dstStart: Start offset in the destination array.
  public func getChars (_ start : Int, _ end : Int, _ array : inout [Character], _ dstStart : Int) {
    let startIdx = self.index(self.startIndex, offsetBy: start)
    let endIdx = self.index(startIdx, offsetBy: end)
    let range = startIdx..<endIdx //
    
    // Substring erstellen
    let substring = self[range]
    
    // Substring in ein Character-Array konvertieren
    let characterArray: [Character] = Array(substring)
    array = characterArray
  }
}
