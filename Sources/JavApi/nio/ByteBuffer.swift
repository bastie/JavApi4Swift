/*
 * SPDX-FileCopyrightText: 2023, 2024 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.nio {
  
  public typealias ByteBuffer = JavApi.ByteBuffer
    
}

/// Abstract type for working with bytes
open class ByteBuffer {
  
  /// The default byte order of ``ByteBuffer`` is `BIG_ENDIAN`.
  private var SELF_BYTE_ORDER = java.nio.ByteOrder.BIG_ENDIAN
  
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
  
  /// Returns the order of this ``ByteBuffer``. The default value is ``java.nio.ByteOrder.BIG_ENDIAN``
  /// - Returns order of ``ByteBuffer``
  /// - Since: JavaApi &gt; 0.17.0 (Java 1.4)
  open func order () -> java.nio.ByteOrder {
    return SELF_BYTE_ORDER
  }
  
  /// Modify the order of ``ByteBuffer`` if required
  /// - Parameter order the new order of bytes
  /// - Returns ``ByteBuffer`` self
  /// - Since: JavaApi &gt; 0.17.0 (Java 1.4)
  open func order(_ order: java.nio.ByteOrder) -> ByteBuffer {
    guard SELF_BYTE_ORDER != order else {
      return self
    }
    guard SELF_BYTE_ORDER == .BIG_ENDIAN || SELF_BYTE_ORDER == .LITTLE_ENDIAN else {
      /// FIXME: create a log message
      return self
    }
    
    // reverse byte order
    self.content.reverse()
    if SELF_BYTE_ORDER == .LITTLE_ENDIAN {
      self.SELF_BYTE_ORDER = .BIG_ENDIAN
    }
    else {
      self.SELF_BYTE_ORDER = .LITTLE_ENDIAN
    }
    return self
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
      throw Throwable.IndexOutOfBoundsException(offset, "illegal start position \(offset)")
    }
    guard length > -1 && length <= (bytes.count-offset) else {
      throw Throwable.IndexOutOfBoundsException(offset, "illegal length \(length)")
    }
    for i in offset..<(offset+length) {
      try _ = self.put(bytes[i])
    }
    
    return self
  }
}

