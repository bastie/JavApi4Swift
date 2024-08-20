/*
 * SPDX-FileCopyrightText: 2024 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.io {
  open class InputStream {
    /// The number of available bytes in this stream or 0 if end of stream is reached
    ///
    /// - Returns: Number of readable bytes
    /// - Note: by default returns 0
    public func available() throws -> Int {
      return 0
    }
    
    public func close () {
      // do nothing
    }
    
    public func read() throws -> Int {
      fatalError("not yet implemented")
    }
    public func read(_ array : inout [UInt8]) throws -> Int {
      return try read(&array, 0, array.count)
    }
    public func read(_ array : inout [UInt8], _ offset : Int, _ length : Int) throws -> Int {
      fatalError("not yet implemented")
    }

    /// Create and return an `InputStream` that returns no bytes. See `NilInputStream` for functionality.
    ///
    /// - Returns: empty `InputStream`
    public static func nullInputStream () -> InputStream {
      let result = NilInputStream()
      return result;
    }
    
  }
}

