/*
 * SPDX-FileCopyrightText: 2024 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

extension java.io {
  /// - Since: JavaApi &gt; 0.19.1 (Java 1.0)
  open class FileInputStream : InputStream {
    
    internal let fileHandle : FileHandle
    
    /// - Since: JavaApi &gt; 0.19.1 (Java 1.0)
    public init (_ file : java.io.File) throws {
      let newFileHandle = FileHandle(forReadingAtPath: file.getAbsolutePath())
      if newFileHandle == nil {
        throw java.io.Throwable.IOException("Could not open file '\(file.getAbsolutePath())' for reading")
      }
      else {
        self.fileHandle = newFileHandle!
      }
    }
    
    /// - Since: JavaApi &gt; 0.19.1 (Java 1.0)
    public init (_ file : String) throws {
      let newFileHandle = FileHandle(forReadingAtPath: file)
      if newFileHandle == nil {
        throw java.io.Throwable.IOException("Could not open file '\(file)' for reading")
      }
      else {
        self.fileHandle = newFileHandle!
      }
    }
    
    /// - Since: JavaApi &gt; 0.19.1 (Java 1.0)
    open override func read() throws -> Int {
      do {
        if let readData = try fileHandle.read(upToCount: 1) {
          let byte : UInt8 = UInt8(readData[0])
          return Int (byte)
        }
        else {
          return -1 // TODO: test it
        }
      }
      catch {
        throw java.io.Throwable.IOException(error.localizedDescription)
      }
    }
    
    /// - Since: JavaApi &gt; 0.19.1 (Java 1.0)
    open override func read(_ array: inout [UInt8]) throws -> Int {
      do {
        if let readData = try fileHandle.read(upToCount: array.count) {
          let returnValue = readData.count
          for i in 0..<returnValue {
            array[i] = UInt8(readData[i])
          }
          return returnValue
        }
        else {
          return -1 // TODO: test it
        }
      }
      catch {
        throw java.io.Throwable.IOException(error.localizedDescription)
      }
    }
    
    /// - Since: JavaApi &gt; 0.19.1 (Java 1.0)
    open override func read(_ array: inout [UInt8], _ offset: Int, _ length: Int) throws -> Int {
      guard length > 0 else {
        throw java.io.Throwable.IOException("Length must be greater than zero")
      }
      guard offset >= 0 && offset < array.count else {
        let message = "Offset must be between 0 and \(array.count)"
        throw java.io.Throwable.IOException(message)
      }
      let maxRead = min(length, array.count - offset)
      
      do {
        if let readData = try fileHandle.read(upToCount: maxRead) {
          let returnValue = readData.count
          for i in 0..<returnValue {
            array[offset+i] = UInt8(readData[i])
          }
          return returnValue
        }
        else {
          return -1 // TODO: test it
        }
      }
      catch {
        throw java.io.Throwable.IOException(error.localizedDescription)
      }
    }
    
    /// - Since: JavaApi &gt; 0.19.1 (Java 1.0)
    open override func skip(_ n: Int) throws -> Int {
      guard n >= 0 else {
        let message = "Length must be greater than or equal to zero"
        throw java.io.Throwable.IOException(message)
      }
      var ignored : [UInt8] = Array(repeating: 0, count: n)
      return try self.read(&ignored)
    }
    
    /// - Since: JavaApi &gt; 0.19.1 (Java 1.0)
    open override func close() throws {
      fileHandle.closeFile()
    }
  }
}
