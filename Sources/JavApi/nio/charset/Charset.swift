/*
 * SPDX-FileCopyrightText: 2023,2024 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

extension java.nio.charset {
  
  /// - Since: JavaApi &gt; 0.16.0 (Java 1.4)
  open class Charset  {
    
    private var delegate : String.Encoding
    
    public init() {
      self.delegate = Charset.defaultCharset()
    }
    
    public static func defaultCharset () -> String.Encoding {
      switch System.getProperty("file.encoding", "UTF-8").uppercased() {
      case "UTF-8" : return .utf8
      default :
        fatalError("Not supported encoding from property file.encoding=\(System.getProperty("file.encoding", "UTF-8"))")
      }
    }
    
    /// Final function to encode a String into a ByteBuffer
    ///
    /// - Since: JavaApi &gt; 0.16.0 (Java 1.4)
    public func encode (_ what : String) -> java.nio.ByteBuffer {
      let result : java.nio.ByteBuffer = java.nio.ByteBuffer()
      result.content = [UInt8] (what.data(using: self.delegate, allowLossyConversion: true)!)
      return result
    }
    
    public static func forName (_ name : String) throws -> Charset {
      let result = Charset ()
      switch name.uppercased() {
      case "UTF-8" :
        result.delegate = .utf8
      case "UTF-16" :
        result.delegate = .utf16
      case "UTF-16BE" :
        result.delegate = .utf16BigEndian
      case "UFT-16LE" :
        result.delegate = .utf16LittleEndian
      case "US-ASCII" :
        result.delegate = .ascii
      case "ISO-8859-1" :
        result.delegate = .isoLatin1
      default:
        throw java.nio.charset.Throwable.UnsupportedCharsetException (name)
      }
      return result
    }
  }
}
