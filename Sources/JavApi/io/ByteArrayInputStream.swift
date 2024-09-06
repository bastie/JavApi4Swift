/*
 * SPDX-FileCopyrightText: 2024 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.io {
  
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
      self.pos = max (offset, 0)
      self.count = min (offset+length, length)
      self.mark = offset
    }
    
    public override func read() throws -> Int {
      guard pos < self.data.count else {
        return -1
      }
      pos += 1
      return Int(self.data[pos - 1])
    }
    
    internal func readUInt8() -> Result<UInt8,Error> {
      guard pos < self.data.count else {
        return .failure(java.io.Throwable.IOException())
      }
      pos += 1
      return .success(self.data[pos - 1])
    }
    
    public override func read(_ array: inout [UInt8], _ offset: Int, _ length: Int) throws -> Int {
      guard offset >= 0, length >= 0, length <= (array.count - offset) else {
        throw java.lang.Throwable.IndexOutOufBoundsException()
      }
      let k = min (length, (self.count - pos))
      
      for _ in 0..<k {
        switch self.readUInt8() {
        case .success(let value):
          array[offset+k] = value
        case .failure(let error):
          throw error
        }
      }
      return k
    }
    
    public func skip (_ requestCount : Int64) -> Int64 {
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
    
    override open func close() {
      // its weekend, I do nothing 😎
    }
  }
}
