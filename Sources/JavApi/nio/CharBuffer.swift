/*
 * SPDX-FileCopyrightText: 2025 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.nio {
  
  public typealias CharBuffer = JavApi.CharBuffer
  
}

/// Abstract type for working with bytes
open class CharBuffer {
  
  /// byte buffer
  internal var content : [Character] = []
  
  
  open func put (_ char : Character) throws -> CharBuffer {
    self.content.append(char)
    return self
  }
  
  open func put (_ chars : [Character]) throws -> CharBuffer {
    for char in chars {
      _ = try self.put(char)
    }
    return self
  }
  
  open func length() -> Int {
    return self.content.count
  }
  
  open func put (_ chars : [Character], _ offset : Int, _ length : Int) throws -> CharBuffer {
    guard offset > -1 && offset < chars.count else {
      throw Throwable.IndexOutOfBoundsException(offset, "illegal start position \(offset)")
    }
    guard length > -1 && length <= (chars.count-offset) else {
      throw Throwable.IndexOutOfBoundsException(offset, "illegal length \(length)")
    }
    for i in offset..<(offset+length) {
      try _ = self.put(chars[i])
    }
    
    return self
  }
}
