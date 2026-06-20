/*
 * SPDX-FileCopyrightText: 2023,2024 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

extension java.nio.charset {
  
  /// - Since: Java 1.4
  open class Charset  {
    
    private var delegate : String.Encoding
    
    public init() {
      self.delegate = Charset.defaultCharset()
    }
    
    public func name () -> String {
      switch self.delegate {
      case .ascii : return "US-ASCII"
      case .isoLatin1 : return "ISO-8859-1"
      case .utf16 : return "UTF-16"
      case .utf16BigEndian : return "UTF-16BE"
      case .utf16LittleEndian : return "UTF-16LE"
      case .iso2022JP : return "ISO-2022-JP"
      case .isoLatin2 : return "ISO-8859-2"
      case .japaneseEUC : return "EUC-JP"
      case .macOSRoman : return "x-MacOS-Roman"
      case .nextstep : return "x-Nextstep"
      case .nonLossyASCII : return "x-UTF-8"
      case .shiftJIS : return "Shift_JIS"
      case .symbol : return "x-Symbol"
      case .unicode : return "UTF-16"
      case .utf32 : return "UTF-32"
      case .utf32BigEndian : return "UTF-32BE"
      case .utf32LittleEndian : return "UTF-32LE"
      case .utf8 : return "UTF-8"
      case .windowsCP1250 : return "Windows-1250"
      case .windowsCP1251 : return "Windows-1251"
      case .windowsCP1252 : return "Windows-1252"
      case .windowsCP1253 : return "Windows-1253"
      case .windowsCP1254 : return "Windows-1254"
      default : break
      }
#if !os(visionOS)
      if #available(macOS 26.4, iOS 26.4, tvOS 26.4, watchOS 26.4, *) {
        return self.delegate.ianaName ?? "unknown"
      } else {
        return "unknown"
      }
#else
      return "unknown"
#endif
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
    /// - Since: Java 1.4
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
      case "ISO-8859-2" :
        result.delegate = .isoLatin2
      default:
        throw java.nio.charset.UnsupportedCharsetException (name)
      }
      return result
    }
  }
}
