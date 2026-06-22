/*
 * SPDX-FileCopyrightText: 2023, 2024 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
extension java.io {
  open class OutputStream : java.io.Flushable, java.io.Closeable {
    public typealias Flushable = OutputStream
    public typealias Closeable = OutputStream
    
    /// Default constructor
    public init(){}
    
    open func close() throws {
    }
    
    open func flush() throws {
    }
    
    /// Abstract — subclasses must override this method.
    open func write (_ b : Int) throws {
      throw java.io.IOException("write(Int) not implemented")
    }
    open func write (_ b : UInt8) throws {
      try write(Int(b))
    }
    /// Delegates to write(buffer, 0, value.count)
    open func write (_ value : [byte]) throws {
      try write(value, 0, value.count)
    }
    /// Default: write one byte at a time via write(Int). Subclasses should override.
    open func write (_ buffer : [UInt8], _ pos : Int, _ length : Int) throws {
      for i in pos..<min(pos + length, buffer.count) {
        try write(Int(buffer[i]))
      }
    }

    /// Returns an OutputStream that discards all bytes written to it
    /// - Since: Java 1.0
    public static func nullOutputStream () -> OutputStream {
      return java.io.NullOutputStream()
    }
  }
}
