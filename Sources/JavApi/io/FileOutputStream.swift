/*
 * SPDX-FileCopyrightText: 2024 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

extension java.io {
  /// - Since: Java 1.0
  open class FileOutputStream : OutputStream {

    private let handle : FileHandle
    private var isClosed : Bool = false
    
    /// - Since: Java 1.0
    public convenience init (_ file: java.io.File) throws {
      try self.init(file, false)
    }

    /// - Since: Java 1.0
    public convenience init (_ file: java.io.File, _ append : Bool) throws {
      try self.init(file.getAbsolutePath(), append)
    }
    
    // FIXME: it looks like a FileDesciptor in Java can also be an Connection and create a FileOutputStream over connection - did it?
    /// - Since: Java 1.0
    public init (_ fileDescriptor: java.io.FileDescriptor) throws {
      if let newFileHandle = fileDescriptor.fileHandle {
        self.handle = newFileHandle
      }
      throw java.io.IOException("Could not open file descriptor: \(fileDescriptor) for writing")
    }
    
    /// - Since: Java 1.0
    public convenience init (_ path : String) throws {
      try self.init(path, false)
    }

    /// - Since: Java 1.0
    public init (_ path : String, _ append : Bool) throws {
      let fileManager = FileManager.default

      // Create file if it doesn't exist
      if !fileManager.fileExists(atPath: path) {
        fileManager.createFile(atPath: path, contents: Data(), attributes: nil)
      }

      if append {
        // Append mode: open for writing at end of file
        if let newFileHandle = FileHandle(forWritingAtPath: path) {
          newFileHandle.seekToEndOfFile()
          self.handle = newFileHandle
        } else {
          throw java.io.FileNotFoundException("Could not open file: \(path) for writing")
        }
      } else {
        // Overwrite mode: truncate existing file
        if let newFileHandle = FileHandle(forWritingAtPath: path) {
          newFileHandle.truncateFile(atOffset: 0)
          self.handle = newFileHandle
        } else {
          throw java.io.FileNotFoundException("Could not open file: \(path) for writing")
        }
      }
    }
    
    /// - Since: Java 1.0
    open override func close() throws {
      guard !isClosed else { return }
      isClosed = true
      do {
        try self.handle.close()
      }
      catch {
        throw java.io.IOException(error.localizedDescription)
      }
    }
    /// - Since: Java 1.0
    open func finalize() throws{
      try self.close()
    }
    /// - Since: Java 1.0
    public func getFD () -> java.io.FileDescriptor {
      return java.io.FileDescriptor.init(handle: self.handle)
    }
    /// - Since: Java 1.0
    open override func write (_ b: [UInt8]) throws {
      try self.write(b, 0, b.count)
    }
    /// - Since: Java 1.0
    open override func write (_ b: [UInt8], _ off: Int, _ len: Int) throws {
      guard !isClosed else {
        throw java.io.IOException("Stream is closed")
      }
      let dataToWrite = Data(b[off..<off+len])
      self.handle.write(dataToWrite)
    }
    /// - Since: Java 1.0
    open override func write (_ b: Int) throws {
      try self.write([UInt8](repeating: UInt8(b), count: 1))
    }    
  }
}
