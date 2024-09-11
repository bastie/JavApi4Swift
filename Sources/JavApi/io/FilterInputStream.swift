/*
 * SPDX-FileCopyrightText: 2024 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.io {
  open class FilterInputStream : InputStream {
    
    public var `in` : java.io.InputStream
    
    /// Default constructor
    /// - Parameter newBaseInputStream the underlying ``InputStream``
    public init (_ newBaseInputStream : InputStream?){
      if let newBaseInputStream {
        self.in = newBaseInputStream
      }
      else {
        self.in = NilInputStream()
      }
    }
 
    open override func available() throws -> Int {
      return try self.in.available()
    }
    
    open override func close () throws {
      try self.in.close()
    }
    
    open override func read() throws -> Int {
      return try self.in.read()
    }
    open override func read(_ array : inout [UInt8]) throws -> Int {
      return try read(&array, 0, array.count)
    }
    open override func read(_ array : inout [UInt8], _ offset : Int, _ length : Int) throws -> Int {
      return try self.in.read(&array, offset, length)
    }
    
  }
}
