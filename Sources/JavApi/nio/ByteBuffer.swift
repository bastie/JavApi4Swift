/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.nio {
  
  public typealias ByteBuffer = JavApi.ByteBuffer
    
}

/// Abstract type for working with bytes
public class ByteBuffer {
  
  /// byte buffer
  internal var content : [UInt8] = []
  
  public init (){}
  /// Note: Implementation did not allocate space at this time
  public static func allocate (_ count : Int) throws -> ByteBuffer {
    guard count > -1 else {
      throw Throwable.IllegalArgumentException("sorry for my failure master, I cant not create a ByteBuffer with negative count of bytes")
    }
    let buffer = ByteBuffer()
    //buffer.content = Array(repeating: 0, count: count)
    return buffer
  }
  
  /// Return the underlying byte buffer as byte array
  /// - Returns byte buffer
  open func array () throws -> [UInt8] {
    return self.content
  }
  
  open func put (_ byte : UInt8) throws -> ByteBuffer {
    self.content.append(byte)
    return self
  }
  
  open func put (_ bytes : [UInt8]) throws -> ByteBuffer {
    for byte in bytes {
      _ = try self.put(byte)
    }
    return self
  }
  
  open func put (_ bytes : [UInt8], _ offset : Int, _ length : Int) throws -> ByteBuffer {
    guard offset > -1 && offset < bytes.count else {
      throw Throwable.IndexOutOufBoundsException(offset, "illegal start position \(offset)")
    }
    guard length > -1 && length <= (bytes.count-offset) else {
      throw Throwable.IndexOutOufBoundsException(offset, "illegal length \(length)")
    }
    for i in offset..<(offset+length) {
      try _ = self.put(bytes[i])
    }
    
    return self
  }
}

