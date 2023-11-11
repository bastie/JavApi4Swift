/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

extension java.nio {
  
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
  }
}
