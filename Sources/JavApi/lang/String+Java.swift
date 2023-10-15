/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

extension String {
  
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
      throw Throwable.UnsupportedEncodingException("Unsupported encoding \(encoding)")
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
    throw Throwable.UnsupportedEncodingException("Unsupported encoding \(encoding)")
  }
  
  /// Check equals of String to other String
  ///
  /// - Parameter other String instance
  /// - Returns true if equals
  public func equals (_ other : String) -> Bool {
    return self == other
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
}
