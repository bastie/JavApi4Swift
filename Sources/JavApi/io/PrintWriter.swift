/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

extension java.io {
  
  open class PrintWriter : java.io.Writer {
    private var delegateStream : java.io.OutputStream?
    private var delegateWriter : java.io.Writer?
    private var autoflush : Bool

    // MARK: - OutputStream-based constructors (Java 1.1)

    public init(_ delegate: java.io.OutputStream, _ autoflush : Bool = true) {
      self.delegateStream = delegate
      self.delegateWriter = nil
      self.autoflush = autoflush
      super.init()
    }

    // MARK: - Writer-based constructors (Java 1.1)

    public init(_ delegate: java.io.Writer, _ autoflush : Bool = false) {
      self.delegateWriter = delegate
      self.delegateStream = nil
      self.autoflush = autoflush
      super.init()
    }

    // MARK: - Methods

    // print methods (no newline)
    open func print(_ value: String) {
      do {
        if let w = delegateWriter {
          try w.write(value)
          if autoflush { try w.flush() }
        } else {
          let asData = [UInt8](value.data(using: .utf8)!)
          try delegateStream?.write(asData, 0, asData.count)
          if autoflush { try delegateStream?.flush() }
        }
      }
      catch _ {}
    }

    open func print(_ value: Int) {
      print(String(value))
    }

    open func print(_ value: Double) {
      print(String(value))
    }

    open func print(_ value: Float) {
      print(String(value))
    }

    open func print(_ value: Bool) {
      print(String(value))
    }

    // println methods (with newline)
    open func println(_ line: String) {
      do {
        if let w = delegateWriter {
          try w.write(line)
          try w.write("\n")
          if autoflush { try w.flush() }
        } else {
          let asData = [UInt8](line.data(using: .utf8)!)
          try delegateStream?.write(asData, 0, asData.count)
          let newline = [UInt8]("\n".utf8)
          try delegateStream?.write(newline, 0, newline.count)
          if autoflush { try delegateStream?.flush() }
        }
      }
      catch _ {}
    }

    open func println(_ value: Int) {
      println(String(value))
    }

    open func println(_ value: Double) {
      println(String(value))
    }

    open func println(_ value: Float) {
      println(String(value))
    }

    open func println(_ value: Bool) {
      println(String(value))
    }

    open func println() {
      println("")
    }

    open override func write(_ buf: [Character], _ offset: Int, _ count: Int) throws {
      if let w = delegateWriter {
        try w.write(buf, offset, count)
      } else if let s = delegateStream {
        let str = String(buf[offset ..< offset + count])
        let bytes = [UInt8](str.data(using: .utf8) ?? Data())
        try s.write(bytes, 0, bytes.count)
      }
    }

    open override func flush() throws {
      if let w = delegateWriter { try w.flush() }
      else { try delegateStream?.flush() }
    }

    open override func close() {
      do {
        if let w = delegateWriter { try w.close() }
        else { try delegateStream?.close() }
      }
      catch _ {}
    }
  }
  
  public static func nullWriter() -> java.io.PrintWriter {
    return NullWriter()
  }
  
}

