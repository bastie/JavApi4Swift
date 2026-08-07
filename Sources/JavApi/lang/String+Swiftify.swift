/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension String {

  // Java's String.hashCode() algorithm: s[0]*31^(n-1) + s[1]*31^(n-2) + ... + s[n-1]
  // Uses UTF-16 code units (matching Java's char type) and wrapping arithmetic (Java int semantics).
  internal func _javaHashCode() -> Int {
    var h: Int = 0
    for unit in self.utf16 {
      h = 31 &* h &+ Int(unit)
    }
    return h
  }

  // Override hash(into:) — the single Hashable protocol requirement Swift dispatches through.
  // Feeding the Java hash into the Hasher ensures that both direct .hashValue access
  // and generic T: Hashable dispatch (e.g. Objects.hashCode, HashMap keys) produce
  // a consistent result.
  public func hash(into hasher: inout Hasher) {
    hasher.combine(_javaHashCode())
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
