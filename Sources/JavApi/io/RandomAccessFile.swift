/*
 * SPDX-FileCopyrightText: 2024 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

extension java.io {
  /// - Since: JavaApi &gt; 0.18.0 (Java 1.0)
  open class RandomAccessFile {
    
    let fileDescriptor : FileHandle
    let fileMode : String
    
    /// - Since: JavaApi &lt; 0.18.0 (Java 1.0)
    public init (_ file : java.io.File, _ mode : String) throws {
      if let fd = FileHandle(forReadingAtPath: file.getAbsolutePath()) {
        self.fileDescriptor = fd
        self.fileMode = mode
      }
      else {
        throw java.io.Throwable.IOException()
      }
    }
    
    /// - Since: JavaApi &lt; 0.18.0 (Java 1.0)
    public func getFD () throws -> java.io.FileDescriptor {
      return java.io.FileDescriptor(handle: fileDescriptor)
    }
    
    /// - Since: JavaApi &gt; 0.18.0 (Java 1.0)
    open func seek (_ newPos : Int64) throws {
      do {
        try fileDescriptor.seek(toOffset: UInt64(newPos))
      }
      catch {
        throw java.io.Throwable.IOException(error.localizedDescription)
      }
    }
  }
}
