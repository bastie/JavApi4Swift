/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: 0BSD
 */
extension java.security {
  
  /// - Note: abstact class
  open class MessageDigest : MessageDigestSPI {
    
    public override init() {}
    
    /// - Note: subclass must be implement this method
    open func update (_ byteArray: [UInt8]) {
      fatalError("not implemented")
    }
    
    open func update (_ byte : UInt8) {
      self.update([byte])
    }
    
    open func update (_ byteArray: [UInt8], _ off: Int, _ len: Int) {
      self.update(Array(byteArray[off..<off+len]))
    }
    
    open func digest () -> [UInt8] {
      fatalError("not implemented")
    }
    
    open func digest (_ byteArray : [UInt8]) -> [UInt8] {
      self.update(byteArray)
      return self.digest()
    }
    
    open func reset () {
      fatalError("not implemented")
    }
  }
}
