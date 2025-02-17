/*
 * SPDX-FileCopyrightText: 2023-2025 - Sebastian Ritter <bastie@users.noreply.github.com>
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
      throw java.io.Throwable.UnsupportedEncodingException("Unsupported encoding \(encoding)")
    }
  }
  
  /// Returns the bytes of String in given encoding
  /// - Parameter encoding as String
  /// - Returns byte array
  public func getBytes (_ encoding : String) throws -> [UInt8] {
    switch encoding.uppercased() {
    case "ISO-8859-1" :
      if let data = self.data(using: .isoLatin1) { return  [UInt8](data) }
    case "UFT-8" : fallthrough
    default:
      if let data = self.data(using: .utf8) { return  [UInt8](data) }
    }
    throw java.io.Throwable.UnsupportedEncodingException("Unsupported encoding \(encoding)")
  }
  
  public func endsWith (_ suffix : String) -> Bool {
    return self.hasSuffix(suffix)
  }
  
  /// Check equals of String to other String
  ///
  /// - Parameter other String instance
  /// - Returns true if equals
  public func equals (_ other : String) -> Bool {
    return self == other
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
  /// - Parameters index
  /// - Returns char at index
  public func charAt (_ index : Int) -> Character { // TODO: perhaps better results with Swift native but now and first it works
    return toCharArray()[index]
  }
  
  public func lastIndexOf (_ char : Character) -> Int {
    guard self.contains(char) else {
      return -1
    }
    return distance(from: startIndex, to: self.lastIndex(of: char)!)
  }
  
  func lastIndexOf(_ substring: String) -> Int {
    guard let range = range(of: substring, options: .backwards) else {
      return -1
    }
    return distance(from: startIndex, to: range.lowerBound)
  }
  
  /// The count of String elements
  @inlinable
  public func lenght () -> Int {
    return self.count
  }
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
  public func replaceFirts (_ pattern : String, _ with : String) -> String{
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
    for i in offset..<length {
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
    for i in offset..<length {
      slowImpl.append("\(array[i])")
    }
    return slowImpl
  }
  
  public static func valueOf (_ char : Character) -> String {
    return String ("\(char)")
  }
  
  /// Returns self
  /// - Returns self
  public func toString () -> String {
    return self
  }

  /// Hashcode of ``String``
  public func hashCode () -> Int {
    return self.hashValue
  }
}

fileprivate let TRIM_CHARACTER_SET = CharacterSet(charactersIn : "\u{0000}\u{0001}\u{0002}\u{0003}\u{0004}\u{0005}\u{0006}\u{0007}\u{0008}\u{0009}\u{000A}\u{000B}\u{000C}\u{000D}\u{000E}\u{000F}\u{0010}\u{0011}\u{0012}\u{0013}\u{0014}\u{0015}\u{0016}\u{0017}\u{0018}\u{0019}\u{001A}\u{001B}\u{001C}\u{001D}\u{001E}\u{001F}\u{0020}") // different to strip can be readed f.e. here: (https://stackoverflow.com/questions/51266582/difference-between-string-trim-and-strip-methods-in-java-11)


// TODO: Incubation
extension String? {
  @inlinable
  public func length () -> Int? {
    return self?.count ?? nil
  }
}

