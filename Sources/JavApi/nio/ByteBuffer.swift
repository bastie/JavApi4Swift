/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.nio {
  
  public typealias ByteBuffer = JavApi.ByteBuffer
    
}

/// Abstract type for working with bytes
public protocol ByteBuffer {
  associatedtype ByteBuffer: java.nio.ByteBuffer

  /// byte buffer
  var content : [UInt8]  { get set }

}

extension ByteBuffer {
  
  /// Return the underlying byte buffer as byte array
  /// - Returns byte buffer
  public func array () throws -> [UInt8] {
    return self.content
  }
}
