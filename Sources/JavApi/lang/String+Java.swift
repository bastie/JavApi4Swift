/*
 * SPDX-FileCopyrightText: 2023-2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

extension String {
  
  public init (_ bytes : [UInt8], _ start : Int, _ end : Int, _ encoding : String) throws {
    try self.init (Array(bytes [start..<end]), encoding)
  }

    
    /// Initialize the String with given encoding.
  ///
  /// Like Java the encoding is given as String instance.
  ///
  /// - Parameters:
  ///    - bytes of data
  ///    - encoding as String
  public init (_ bytes : [UInt8], _ encoding : String) throws {
    /// Swift is more definsive programming with enumeration for encoding, Java has more flexibility for new or own encodings
    /// In result of a non-failable initializer can not call a failable initializer this works over a test (first switch) and if it works use the ! to initialize self
    var isInitializable : String? = nil
    switch (encoding.uppercased()) {
    case "ISO-8859-1" :     isInitializable = String (bytes: bytes, encoding: .isoLatin1)
    case "UTF-8" :          isInitializable = String (bytes: bytes, encoding: .utf8)
    default:                isInitializable = String (bytes: bytes, encoding: .utf8)
    }
    if isInitializable != nil {
      switch (encoding.uppercased()) {
      case "ISO-8859-1" :     self.init (bytes: bytes, encoding: .isoLatin1)!
      case "UTF-8" :          self.init (bytes: bytes, encoding: .utf8)!
      default:                self.init (bytes: bytes, encoding: .utf8)!
      }
    }
    else {
      throw java.io.UnsupportedEncodingException("Unsupported encoding \(encoding)")
    }
  }
  
  /// Returns the bytes of String in given encoding
  /// - Parameter encoding as String
  /// - Returns byte array
  public func getBytes (_ encoding : String) throws -> [UInt8] {
    switch encoding.uppercased() {
    case "ISO-8859-1" :
      if let data = self.data(using: .isoLatin1) { return  [UInt8](data) }
    case "UTF-8" : fallthrough
    default:
      if let data = self.data(using: .utf8) { return  [UInt8](data) }
    }
    throw java.io.UnsupportedEncodingException("Unsupported encoding \(encoding)")
  }
  
  public func endsWith (_ suffix : String) -> Bool {
    return self.hasSuffix(suffix)
  }

  // ---------------------------------------------------------------------------
  // MARK: Java-compatible static format method
  // ---------------------------------------------------------------------------

  /// Formats a string using a Java-style format string.
  ///
  /// Equivalent to Java's `String.format(String, Object...)`.
  /// The format string is first translated by `Java2SwiftFormatter` to map
  /// Java specifiers (`%s`, `%n`, `%b`, `%,d`, `%tY`, `%1$s` …) to their
  /// Swift equivalents, then handed to `String(format:)`.
  ///
  /// - Parameters:
  ///   - format: A Java-style format string.
  ///   - args:   Arguments referenced by the format string.
  /// - Returns: The formatted string.
  /// - Throws: An appropriate `java.util.IllegalFormatException` subclass —
  ///   see `Java2SwiftFormatter.format(_:args:)`.
  public static func format(_ format: String, _ args: Any?...) throws -> String {
    try Java2SwiftFormatter.format(format, args: args)
  }

  /// Varargs-array overload — matches Java's `String.format(String, Object[])`.
  ///
  /// - Throws: An appropriate `java.util.IllegalFormatException` subclass —
  ///   see `Java2SwiftFormatter.format(_:args:)`.
  public static func format(_ format: String, args: [Any?]) throws -> String {
    try Java2SwiftFormatter.format(format, args: args)
  }

  /// Formats a string using a Java-style format string and an explicit
  /// `Locale`, independent of the global `java.util.Locale.getDefault()`.
  ///
  /// Equivalent to Java's `String.format(Locale, String, Object...)`. Per
  /// the Java API contract, passing `nil` for `locale` means *"no
  /// localization is applied"* — number formatting falls back to a fixed,
  /// locale-independent convention ('.' decimal separator, ',' grouping
  /// separator), matching `Locale.ROOT` behaviour, instead of consulting
  /// the global default.
  ///
  /// - Parameters:
  ///   - locale: The `Locale` to format with, or `nil` for no localization.
  ///   - format: A Java-style format string.
  ///   - args:   Arguments referenced by the format string.
  /// - Returns: The formatted string.
  /// - Throws: An appropriate `java.util.IllegalFormatException` subclass —
  ///   see `Java2SwiftFormatter.format(_:args:locale:)`.
  public static func format(_ locale: java.util.Locale?, _ format: String, _ args: Any?...) throws -> String {
    try Java2SwiftFormatter.format(format, args: args, locale: locale)
  }

  /// Varargs-array overload — matches Java's
  /// `String.format(Locale, String, Object[])`.
  ///
  /// - Throws: An appropriate `java.util.IllegalFormatException` subclass —
  ///   see `Java2SwiftFormatter.format(_:args:locale:)`.
  public static func format(_ locale: java.util.Locale?, _ format: String, args: [Any?]) throws -> String {
    try Java2SwiftFormatter.format(format, args: args, locale: locale)
  }

  /// Check equals of String to other String
  ///
  /// - Parameter other String instance
  /// - Returns true if equals
  public func equals (_ other : String) -> Bool {
    return self == other
  }

  /// Compares this string to `other`, ignoring case considerations.
  ///
  /// Mirrors `java.lang.String.equalsIgnoreCase(String)`.
  /// - Since: Java 1.0
  public func equalsIgnoreCase (_ other : String) -> Bool {
    return self.lowercased() == other.lowercased()
  }

  /// Concatenates the specified string to the end of this string.
  ///
  /// Mirrors `java.lang.String.concat(String)`.
  /// - Since: Java 1.0
  public func concat (_ str : String) -> String {
    return self + str
  }

  /// Returns a canonical representation for this string.
  ///
  /// Swift's `String` has no string-pool/interning concept, so this is
  /// effectively a no-op that returns `self` unchanged.
  ///
  /// Mirrors `java.lang.String.intern()`.
  /// - Since: Java 1.0
  public func intern () -> String {
    return self
  }

  /// Tests if the substring of this string beginning at `toffset` with
  /// length `len` matches the substring of `other` beginning at `ooffset`
  /// with the same length.
  ///
  /// Mirrors `java.lang.String.regionMatches(int, String, int, int)`.
  /// - Since: Java 1.0
  public func regionMatches (_ toffset : Int, _ other : String, _ ooffset : Int, _ len : Int) -> Bool {
    return regionMatches(false, toffset, other, ooffset, len)
  }

  /// `regionMatches(_:_:_:_:)`, optionally ignoring case.
  ///
  /// Mirrors `java.lang.String.regionMatches(boolean, int, String, int, int)`.
  /// - Since: Java 1.0
  public func regionMatches (_ ignoreCase : Bool, _ toffset : Int, _ other : String, _ ooffset : Int, _ len : Int) -> Bool {
    guard toffset >= 0, ooffset >= 0, len >= 0 else { return false }
    guard toffset + len <= self.count, ooffset + len <= other.count else { return false }
    let selfStart = self.index(self.startIndex, offsetBy: toffset)
    let selfEnd = self.index(selfStart, offsetBy: len)
    let otherStart = other.index(other.startIndex, offsetBy: ooffset)
    let otherEnd = other.index(otherStart, offsetBy: len)
    let selfSlice = self[selfStart..<selfEnd]
    let otherSlice = other[otherStart..<otherEnd]
    if ignoreCase {
      return selfSlice.lowercased() == otherSlice.lowercased()
    }
    return selfSlice == otherSlice
  }
  
  public func indexOf (_ part : String) -> Int {
    if let range = self.range(of: part) {
      let startPosition = self.distance(from: self.startIndex, to: range.lowerBound)
      //let endPosition = self.distance(from: self.startIndex, to: range.upperBound)
      return startPosition
    }
    return -1
  }
  public func indexOf (_ part : Character) -> Int {
    if let indexOfPart = self.firstIndex(of: part) {
      return self.distance(from: self.startIndex, to: indexOfPart)
    }
    return -1
  }

  /// Returns the index of the first occurrence of `part` at or after
  /// `fromIndex`, or -1 if there is none. A negative `fromIndex` is
  /// treated as 0.
  ///
  /// Mirrors `java.lang.String.indexOf(String, int)`.
  /// - Since: Java 1.0
  public func indexOf (_ part : String, _ fromIndex : Int) -> Int {
    let length = self.count
    let clampedFrom = max(0, fromIndex)
    if part.isEmpty {
      return clampedFrom > length ? length : clampedFrom
    }
    guard clampedFrom < length else { return -1 }
    let searchStart = self.index(self.startIndex, offsetBy: clampedFrom)
    guard let range = self.range(of: part, range: searchStart..<self.endIndex) else {
      return -1
    }
    return self.distance(from: self.startIndex, to: range.lowerBound)
  }

  /// `indexOf(String, int)` counterpart for a single `Character`.
  ///
  /// Mirrors `java.lang.String.indexOf(int, int)` (Java's `char`-valued
  /// overload).
  /// - Since: Java 1.0
  public func indexOf (_ part : Character, _ fromIndex : Int) -> Int {
    let length = self.count
    let clampedFrom = max(0, fromIndex)
    guard clampedFrom < length else { return -1 }
    let searchStart = self.index(self.startIndex, offsetBy: clampedFrom)
    guard let idx = self[searchStart...].firstIndex(of: part) else { return -1 }
    return self.distance(from: self.startIndex, to: idx)
  }

  /// Check the string contains only whitspaces (or nothing)
  /// - Returns true if only whitespaces included
  @inlinable
  public func isBlank () -> Bool {
    return 0 == self.trimmingCharacters(in: .whitespacesAndNewlines).count
  }
  
  /// Check the string has zero characters
  /// - Returns true if string length is zero
  @inlinable
  public func isEmpty () -> Bool {
    return 0 == self.count
  }
  
  /// Remove whitespaces and newlines from beginning and end and create a new string as result
  /// - Returns new string without leading and trailing whitespaces
  @inlinable
  public func strip () -> String {
    return self.trimmingCharacters(in: .whitespacesAndNewlines)
  }
  
  /// Returns a array of characters build by contents of String
  /// - Returns [Character] array
  public func toCharArray () -> [Character] {
    var result : [Character] = []
    let split = self.split("") 
    
    for i in 0..<split.count{
      result.append(Character(split[i]))
    }
    
    return result
  }
  
  /// Returns the character on given offset
  ///
  /// Internal it use toCharArray. If it possible cache the result of toCharArray instead often call this function.
  ///
  /// Bugfix: matches Java's `String.charAt(int)`, which throws
  /// `StringIndexOutOfBoundsException` for a negative or out-of-range
  /// `index` instead of crashing the process — see Java2Swift.md's
  /// throws-not-fatalError convention.
  ///
  /// - Parameters index
  /// - Returns char at index
  /// - Throws: `StringIndexOutOfBoundsException` if `index` is negative or
  ///   greater than or equal to `length()`.
  public func charAt (_ index : Int) throws -> Character {
    guard index >= 0, index < self.count else {
      throw StringIndexOutOfBoundsException(index)
    }
    return self[self.index(self.startIndex, offsetBy: index)]
  }
  
  public func lastIndexOf (_ char : Character) -> Int {
    guard self.contains(char) else {
      return -1
    }
    return distance(from: startIndex, to: self.lastIndex(of: char)!)
  }
  
  public func lastIndexOf(_ substring: String) -> Int {
    guard let range = range(of: substring, options: .backwards) else {
      return -1
    }
    return distance(from: startIndex, to: range.lowerBound)
  }

  /// Returns the index of the last occurrence of `substring` such that the
  /// occurrence starts at or before `fromIndex`, or -1 if there is none.
  ///
  /// Mirrors `java.lang.String.lastIndexOf(String, int)`.
  /// - Since: Java 1.0
  public func lastIndexOf (_ substring : String, _ fromIndex : Int) -> Int {
    let length = self.count
    if substring.isEmpty {
      return max(0, min(fromIndex, length))
    }
    guard fromIndex >= 0 else { return -1 }
    let searchEndOffset = min(fromIndex + substring.count, length)
    guard searchEndOffset >= substring.count else { return -1 }
    let searchEnd = self.index(self.startIndex, offsetBy: searchEndOffset)
    guard let range = self.range(of: substring, options: .backwards, range: self.startIndex..<searchEnd) else {
      return -1
    }
    return self.distance(from: self.startIndex, to: range.lowerBound)
  }

  /// `lastIndexOf(String, int)` counterpart for a single `Character`.
  ///
  /// Mirrors `java.lang.String.lastIndexOf(int, int)` (Java's `char`-valued
  /// overload).
  /// - Since: Java 1.0
  public func lastIndexOf (_ char : Character, _ fromIndex : Int) -> Int {
    let length = self.count
    guard fromIndex >= 0 else { return -1 }
    let searchEndOffset = min(fromIndex + 1, length)
    guard searchEndOffset > 0 else { return -1 }
    let searchEnd = self.index(self.startIndex, offsetBy: searchEndOffset)
    guard let idx = self[self.startIndex..<searchEnd].lastIndex(of: char) else { return -1 }
    return self.distance(from: self.startIndex, to: idx)
  }
  
  /// The count of String elements
  @inlinable
  public func length () -> Int {
    return self.count
  }

  /// - Note: Deprecated — use ``length()`` instead (typo fix).
  @available(*, deprecated, renamed: "length")
  @inlinable
  public func lenght () -> Int { length() }
  // trim the String
  public func trim () -> String {
    return self.trimmingCharacters(in: TRIM_CHARACTER_SET)
  }
  public func replace (_ original : String, _ with : String) -> String {
    return String(self.replacingOccurrences(of: original, with: with))
  }
  public func replaceAll (_ original : String, _ with : String) -> String {
    return String(self.replacingOccurrences(of: original, with: with))
  }
  public func replace (_ original : Character, _ with : Character) -> String {
    return self.replace("\(original)", "\(with)")
  }
  public func replaceFirst (_ pattern : String, _ with : String) -> String{
    if let range = self.range(of:pattern) {
      return self.replacingCharacters(in: range, with: with)
    }
    return self
  }
  public func split (_ separator : String) -> [String]{
    return self.split(separator: separator).map{String($0)}
  }
  
  public func startsWith (_ prefix : String) -> Bool {
    return self.hasPrefix(prefix)
  }

  public init (_ bytes : [UInt8]) {
    try! self.init(bytes, "UTF-8")
  }

  public init (_ array : [Character], _ offset : Int, _ length : Int) {
    var slowImpl = ""
    for i in offset..<offset+length {
      slowImpl.append("\(array[i])")
    }
    self.init(slowImpl)
  }

  public func toUpperCase () -> String {
    return self.uppercased()
  }

  public func toLowerCase () -> String {
    return self.lowercased()
  }
  
  public static func valueOf (_ array : [Character], _ offset : Int, _ length : Int) -> String {
    var slowImpl = ""
    for i in offset..<offset+length {
      slowImpl.append("\(array[i])")
    }
    return slowImpl
  }

  /// Returns a String composed of the given `Character` array.
  ///
  /// Alias of `valueOf(_:)`, matching Java's separate `copyValueOf` entry
  /// point.
  ///
  /// Mirrors `java.lang.String.copyValueOf(char[])`.
  /// - Since: Java 1.0
  public static func copyValueOf (_ data : [Character]) -> String {
    return valueOf(data, 0, data.count)
  }

  /// Returns a String composed of `count` characters of `data`, starting
  /// at `offset`.
  ///
  /// Alias of `valueOf(_:_:_:)`, matching Java's separate `copyValueOf`
  /// entry point.
  ///
  /// Mirrors `java.lang.String.copyValueOf(char[], int, int)`.
  /// - Since: Java 1.0
  public static func copyValueOf (_ data : [Character], _ offset : Int, _ count : Int) -> String {
    return valueOf(data, offset, count)
  }
  
  public static func valueOf (_ char : Character) -> String {
    return String ("\(char)")
  }

  public static func valueOf (_ value : Int) -> String {
    return String(value)
  }

  public static func valueOf (_ value : Int64) -> String {
    return String(value)
  }

  public static func valueOf (_ value : Float) -> String {
    return String(value)
  }

  public static func valueOf (_ value : Double) -> String {
    return String(value)
  }

  public static func valueOf (_ value : Bool) -> String {
    return value ? "true" : "false"
  }

  public static func valueOf (_ value : Any?) -> String {
    guard let value else { return "null" }
    return "\(value)"
  }

  /// Fluent Java like append function
  /// - Parameter string: to append
  public mutating func appendJ (_ string : String) -> String {
    self.append(string)
    return self
  }
  
  /// Returns self
  /// - Returns self
  public func toString () -> String {
    return self
  }

  /// Hashcode of ``String``
  ///
  /// Returns Java's deterministic hash: s[0]*31^(n-1) + … + s[n-1] over UTF-16 code units.
  /// Unlike `hashValue`, this value is stable across process runs.
  public func hashCode () -> Int {
    return self._javaHashCode()
  }

  // MARK: - java.util.stream bridges (Java 8/11)

  /// Returns an `IntStream` of `char` values (UTF-16 code units) from this string.
  ///
  /// Unlike most of this port's `char`-related APIs — which follow the
  /// simplified `char[]` → `[Character]` (grapheme cluster) convention
  /// documented in Java2Swift.md — `chars()` is specified by Java strictly
  /// in terms of UTF-16 code units, so this uses `self.utf16` directly.
  /// This means a character outside the Basic Multilingual Plane produces
  /// two `Int` elements (a surrogate pair), exactly matching real Java,
  /// even though it would be a single `Character`/grapheme cluster in
  /// `toCharArray()`.
  ///
  /// Mirrors `java.lang.String.chars()`.
  /// - Since: Java 8
  public func chars() -> java.util.stream.IntStream {
    java.util.stream.IntStream(self.utf16.map { Int($0) })
  }

  /// Returns an `IntStream` of Unicode code points from this string.
  ///
  /// Unlike `chars()`, a code point maps 1:1 to a Swift `Unicode.Scalar`,
  /// so this has no BMP/surrogate-pair caveat.
  ///
  /// Mirrors `java.lang.String.codePoints()`.
  /// - Since: Java 8
  public func codePoints() -> java.util.stream.IntStream {
    java.util.stream.IntStream(self.unicodeScalars.map { Int($0.value) })
  }

  /// Returns a stream of lines extracted from this string, separated by
  /// line terminators (`"\n"`, `"\r"`, or `"\r\n"`); terminators are not
  /// included in the returned lines. The final line is included even
  /// without a trailing terminator, but a trailing terminator does not
  /// itself produce an extra empty trailing line — so `""` yields zero
  /// lines and `"a\n"` yields exactly one line, `"a"`.
  ///
  /// Relies on `"\r\n"` always being a single Swift `Character` (Unicode
  /// guarantees CR+LF never splits across an extended grapheme cluster
  /// boundary), so no manual two-character lookahead is needed here.
  ///
  /// Mirrors `java.lang.String.lines()`.
  /// - Since: Java 11
  public func lines() -> java.util.stream.Stream<String> {
    var result: [String] = []
    var current = ""
    for c in self {
      if c == "\n" || c == "\r" || c == "\r\n" {
        result.append(current)
        current = ""
      } else {
        current.append(c)
      }
    }
    if !current.isEmpty {
      result.append(current)
    }
    return java.util.stream.Stream<String>(result)
  }
}

fileprivate let TRIM_CHARACTER_SET = CharacterSet(charactersIn : "\u{0000}\u{0001}\u{0002}\u{0003}\u{0004}\u{0005}\u{0006}\u{0007}\u{0008}\u{0009}\u{000A}\u{000B}\u{000C}\u{000D}\u{000E}\u{000F}\u{0010}\u{0011}\u{0012}\u{0013}\u{0014}\u{0015}\u{0016}\u{0017}\u{0018}\u{0019}\u{001A}\u{001B}\u{001C}\u{001D}\u{001E}\u{001F}\u{0020}") // different to strip can be readed f.e. here: (https://stackoverflow.com/questions/51266582/difference-between-string-trim-and-strip-methods-in-java-11)



