/*
 * SPDX-FileCopyrightText: 2011 - ymnk, JCraft,Inc.
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: BSD-3-Clause
 */
/*
Copyright (c) 2011 ymnk, JCraft,Inc. All rights reserved.
Copyright (c) 2023 Sebastian Ritter

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

  1. Redistributions of source code must retain the above copyright notice,
     this list of conditions and the following disclaimer.

  2. Redistributions in binary form must reproduce the above copyright 
     notice, this list of conditions and the following disclaimer in 
     the documentation and/or other materials provided with the distribution.

  3. The names of the authors may not be used to endorse or promote products
     derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESSED OR IMPLIED WARRANTIES,
INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL JCRAFT,
INC. OR ANY CONTRIBUTORS TO THIS SOFTWARE BE LIABLE FOR ANY DIRECT, INDIRECT,
INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA,
OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
/*
 * This program is based on zlib-1.1.3, so all credit should go authors
 * Jean-loup Gailly(jloup@gzip.org) and Mark Adler(madler@alumni.caltech.edu)
 * and contributors of zlib.
 */

extension java.util.zip {
  
  /// Protocol that represent a checksum over given data
  public typealias Checksum = JavApi.Checksum

}

/// Protocol that represent a checksum over given data
public protocol Checksum {
  associatedtype Checksum: java.util.zip.Checksum

  /// Reset the checksum to initiale valze
  func reset()

  /// Return the current checksum value
  ///
  /// - Returns current checksum value
  func getValue() -> Int64;

  /// Update the checksum with the given byte slice
  ///
  /// - Parameters:
  ///    - buf of byte array
  ///    - index as start offset in byte array
  ///    - len as count of elements beginning from start offset
  func update(_ buf : [UInt8], _ index : Int, _ len : Int)

  /// Update the checksum with the given bytes
  /// - Parameter byte array
  func update(_ buffer : [UInt8])
  
  // In different to Java we need to add explicit the optional parameter function
  /// Update the checksum with the maybe given bytes
  /// - Throws: Throwable.NullPointerException
  /// - Parameter byte array
  func update(_ buffer : [UInt8]?) throws
  
  /// Update the cheksum with the given byte
  /// - Parameters:
  func update(_ b : Int)
  
  /// Update the checksum with the given ByteBuffer content
  func update (_ buffer : java.nio.ByteBuffer)
  
}

// default implementations like Java
extension Checksum {
  
  public func update (_ buffer : [UInt8]) {
    self.update(buffer, 0, buffer.count)
  }
  public func update (_ buffer : [UInt8]?) throws {
    if let buffer {
      self.update(buffer, 0, buffer.count)
    }
    else {
      throw Throwable.NullPointerException()
    }
  }
  public func update (_ buffer : java.nio.ByteBuffer) {
    try! self.update(buffer.array())
  }
}

