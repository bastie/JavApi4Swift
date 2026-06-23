/*
 * SPDX-FileCopyrightText: 2024 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.io {
  
  /// - Since: JavaApi &lt; 0.18.0 (Java 1.0)
  open class ByteArrayInputStream : java.io.InputStream {
    
    public let data : [UInt8]
    public var pos : Int
    public let count : Int
    public var mark : Int
    
    public init(_ newData : [UInt8]) {
      self.data = newData
      self.pos = 0
      self.count = self.data.count
      self.mark = 0
    }
    
    public init(_ newData : [UInt8], _ offset : Int, _ length : Int) {
      self.data = newData
      self.pos = max(offset, 0)
      // count = min(offset + length, data.count), but ensure >= 0
      self.count = max(0, min(offset + length, newData.count))
      self.mark = offset
    }
    
    public override func read() throws -> Int {
      guard pos < self.count else {
        return -1
      }
      pos += 1
      return Int(self.data[pos - 1])
    }
    
    internal func readUInt8() -> Result<UInt8,Error> {
      guard pos < self.count else {
        return .failure(java.io.IOException())
      }
      pos += 1
      return .success(self.data[pos - 1])
    }
    
    public override func read(_ array: inout [UInt8], _ offset: Int, _ length: Int) throws -> Int {
      guard offset >= 0, length >= 0, length <= (array.count - offset) else {
        throw IndexOutOfBoundsException()
      }
      // If length is 0, return 0 immediately
      if length == 0 {
        return 0
      }
      let k = min (length, (self.count - pos))
      guard k > 0 else { return -1 }  // EOF — Java spec: return -1, not 0

      for i in 0..<k {
        switch self.readUInt8() {
        case .success(let value):
          array[offset+i] = value
        case .failure(let error):
          throw error
        }
      }
      return k
    }
    
    public func skip (_ requestCount : Int64) throws -> Int64 {
      guard requestCount > 0 else { return 0 }
      let k = min (requestCount, Int64(self.count - self.pos))
      self.pos += Int(k)
      return k
    }
    
    open override func available() throws -> Int {
      return self.count - self.pos
    }
    
    open func markSupported () -> Bool {
      return true
    }
    
    open func mark (_ readAheadLimit : Int) {
      self.mark = self.pos
    }
    
    open func reset () {
      self.pos = self.mark
    }
    
    override open func close() throws {
      // its weekend, I do nothing 😎
    }
  }
}
