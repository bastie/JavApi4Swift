/*
 * SPDX-FileCopyrightText: 2024 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

extension java.io {
  /// - Since: JavaApi &gt; 0.18.0 (Java 1.0)
  open class FileOutputStream : OutputStream {
    
    private let handle : FileHandle
    
    /// - Since: JavaApi &gt; 0.18.0 (Java 1.0)
    public init (_ file: java.io.File) throws {
      if let newFileHandle = FileHandle(forWritingAtPath: file.getAbsolutePath()) {
        self.handle = newFileHandle
      }
      else {
        throw java.io.Throwable.IOException("Could not open file: \(file.getAbsolutePath()) for writing")
      }
    }
    
    // FIXME: it looks like a FileDesciptor in Java can also be an Connection and create a FileOutputStream over connection - did it?
    /// - Since: JavaApi &gt; 0.18.0 (Java 1.0)
    public init (_ fileDescriptor: java.io.FileDescriptor) throws {
      if let newFileHandle = fileDescriptor.fileHandle {
        self.handle = newFileHandle
      }
      throw java.io.Throwable.IOException("Could not open file descriptor: \(fileDescriptor) for writing")
    }
    
    /// - Since: JavaApi &gt; 0.18.0 (Java 1.0)
    public init (_ path : String) throws {
      if let newFileHandle = FileHandle(forWritingAtPath: path) {
        self.handle = newFileHandle
      }
      else {
        throw java.io.Throwable.IOException("Could not open file: \(path) for writing")
      }

    }
    
    /// - Since: JavaApi &gt; 0.18.0 (Java 1.0)
    open override func close() throws {
      do {
        try self.handle.close()
      }
      catch {
        throw java.io.Throwable.IOException(error.localizedDescription)
      }
    }
    /// - Since: JavaApi &gt; 0.18.0 (Java 1.0)
    open func finalize() throws{
      try self.close()
    }
    /// - Since: JavaApi &gt; 0.18.0 (Java 1.0)
    public func getFD () -> java.io.FileDescriptor {
      return java.io.FileDescriptor.init(handle: self.handle)
    }
    /// - Since: JavaApi &gt; 0.18.0 (Java 1.0)
    open override func write (_ b: [UInt8]) throws {
      try self.write(b, 0, b.count)
    }
    /// - Since: JavaApi &gt; 0.18.0 (Java 1.0)
    open override func write (_ b: [UInt8], _ off: Int, _ len: Int) throws {
      let dataToWrite = Data(b[off..<off+len])
      self.handle.write(dataToWrite)
    }
    /// - Since: JavaApi &gt; 0.18.0 (Java 1.0)
    open override func write (_ b: Int) throws {
      try self.write([UInt8](repeating: UInt8(b), count: 1))
    }    
  }
}
