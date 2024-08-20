/*
 * SPDX-FileCopyrightText: 2024 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.io.InputStream {
  
  /// Create and return an `InputStream` that returns no bytes.
  /// - Returns: empty `InputStream`
  public static func nilInputStream () -> java.io.InputStream {
    return nullInputStream()
  }
}

extension java.io {
  
  public class NilInputStream : InputStream {
    private var streamIsOpen = true
    public override func close () {
      streamIsOpen = false
    }
    public func mark (_ readLimit : Int) {
      // do nothing
    }
    public func markSupported () -> Bool {
      return false
    }
    public override func read() throws -> Int {
      guard streamIsOpen else {
        throw Throwable.IOException("read after NilInputStream is closed")
      }
      return 0
    }
    public override func read(_ array : inout [UInt8], _ offset : Int, _ length : Int) throws -> Int {
      guard streamIsOpen else {
        throw Throwable.IOException("read after NilInputStream is closed")
      }
      return 0
    }
    public func readAllBytes() throws -> [UInt8]{
      guard streamIsOpen else {
        throw Throwable.IOException("read after NilInputStream is closed")
      }
      return [UInt8]()
    }
    public func readNBytes(_ array : inout [UInt8], _ offset : Int, _ length : Int) throws -> Int {
      guard streamIsOpen else {
        throw Throwable.IOException("read after NilInputStream is closed")
      }
      return 0
    }
    public func readNBytes(_ length : Int) throws -> [UInt8] {
      guard streamIsOpen else {
        throw Throwable.IOException("read after NilInputStream is closed")
      }
      return [UInt8]()
    }
    public func reset () throws {
      throw Throwable.IOException("read after NilInputStream is closed")
    }
    public func skip(_ times : Int64) throws -> Int64 {
      guard streamIsOpen else {
        throw Throwable.IOException("read after NilInputStream is closed")
      }
      return 0
    }
    public func skipNBytes(_ times : Int64) throws {
      guard streamIsOpen else {
        throw Throwable.IOException("read after NilInputStream is closed")
      }
    }
    public func transferTo(_ outputStreamInstance : OutputStream) throws -> Int64 {
      guard streamIsOpen else {
        throw Throwable.IOException("read after NilInputStream is closed")
      }
    }
    
  }
}
