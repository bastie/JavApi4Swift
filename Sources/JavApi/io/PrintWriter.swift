/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

extension java.io {
  
  open class PrintWriter : java.io.Writer {
    private var delegateStream : java.io.OutputStream?
    private var autoflush : Bool
    
    public init(_ delegate: java.io.OutputStream, _ autoflush : Bool = true) {
      self.delegateStream = delegate
      self.autoflush = autoflush
      super.init()
    }
    
    open func println(_ line: String) {
      do {
        let asData = [UInt8] (line.data(using: .utf8)!)
        try delegateStream?.write(asData, 0, asData.count)
        if autoflush {
          try delegateStream?.flush()
        }
      }
      catch _ {}
    }
    
    open override func close() {
      do {
        try delegateStream?.close()
      }
      catch _ {}
    }
  }
  
  public static func nullWriter() -> java.io.PrintWriter {
    return NullWriter()
  }
  
}

