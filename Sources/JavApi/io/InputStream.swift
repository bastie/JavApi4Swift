/*
 * SPDX-FileCopyrightText: 2024 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.io {
  /// - Since: JavaApi &gt; 0.18.0 (Java 1.0)
  open class InputStream {
    
    /// Default constructor
    public init(){}
    
    /// The number of available bytes in this stream or 0 if end of stream is reached
    ///
    /// - Returns: Number of readable bytes
    /// - Note: by default returns 0
    /// - Since: JavaApi &lt; 0.18.0 (Java 1.0)
    open func available() throws -> Int {
      return 0
    }
    
    /// - Since: JavaApi &lt; 0.18.0 (Java 1.0)
    open func close () throws {
      // do nothing
    }
    
    /// - Since: JavaApi &lt; 0.18.0 (Java 1.0)
    open func read() throws -> Int {
      throw java.io.Throwable.EOFException("not yet implemented")
    }
    /// - Since: JavaApi &lt; 0.18.0 (Java 1.0)
    open func read(_ array : inout [UInt8]) throws -> Int {
      return try read(&array, 0, array.count)
    }
    /// - Since: JavaApi &lt; 0.18.0 (Java 1.0)
    open func read(_ array : inout [UInt8], _ offset : Int, _ length : Int) throws -> Int {
      throw java.io.Throwable.EOFException("not yet implemented")
    }
    
    /// Skip a number of bytes in the Stream
    /// - Parameter n number of bytes to skip
    /// - Returns the number of bytes skipped
    /// - Throws IOException if something with I/O is wrong
    /// - Since: JavaApi &gt; 0.18.0 (Java 1.0)
    open func skip(_ n : Int) throws -> Int {
      var ignored : [UInt8] = Array(repeating: 0, count: n)
      var count = 0
      do {
        count += try read(&ignored)
      }
      catch {}
      return count
    }

    /// Create and return an `InputStream` that returns no bytes. See `NilInputStream` for functionality.
    ///
    /// - Returns: empty `InputStream`
    /// - Since: JavaApi &lt; 0.18.0 (Java 1.0)
    public static func nullInputStream () -> InputStream {
      let result = NilInputStream()
      return result;
    }
    
  }
}

