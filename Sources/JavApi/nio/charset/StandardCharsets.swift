/*
 * SPDX-FileCopyrightText: 2024 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

extension java.nio.charset {
  
  /// final Utility type for working with standard charsets, whose ever provided
  ///
  /// - Since: Java 7
  public class StandardCharsets {
    fileprivate init(){}
    
    /// The Latin-1 charset
    /// - Since: Java 7
    public let ISO_8859_1 : java.nio.charset.Charset = try! Charset.forName("ISO-8859-1")
    /// The ASCII charset
    /// - Since: Java 7
    public let US_ASCII : java.nio.charset.Charset = try! Charset.forName("US-ASCII")
    /// - Since: Java 7
    public let UTF_16 : java.nio.charset.Charset = try! Charset.forName("UTF-16")
    /// - Since: Java 7
    public let UTF_16BE : java.nio.charset.Charset = try! Charset.forName("UTF-16BE")
    /// - Since: Java 7
    public let UTF_16LE : java.nio.charset.Charset = try! Charset.forName("UTF-16LE")
    /// - Since: Java 7
    public let UTF_8 : java.nio.charset.Charset = try! Charset.forName("UTF-8")
  }
}

