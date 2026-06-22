/*
 * SPDX-FileCopyrightText: 2023, 2025 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

#if canImport(Security)
import Security

extension java.security {
  
  /// Type to create secure random values
  open class SecureRandom : java.util.Random {
    
    /// Fill the given byte array with random data
    /// - Parameters byte array to fill
    public override func nextBytes(_ bytes : inout [UInt8]) {
      guard 0 < bytes.count else {
        return
      }
      
      // Fill bytes with secure random data
      let _ = SecRandomCopyBytes(
        kSecRandomDefault,
        bytes.count,
        &bytes
      )
    }
    
    /// Create a random int value. As fallback a pseudo random value is creating
    /// - Returns a random int value or on internal error a pseudo random int value
    /// 
    override public func nextInt() -> Int {
      let count = MemoryLayout<Int>.size
      var bytes = [Int8](repeating: 0, count: count)
      
      // Fill bytes with secure random data
      let status = SecRandomCopyBytes(
        kSecRandomDefault,
        count,
        &bytes
      )
      
      // A status of errSecSuccess indicates success
      if status == errSecSuccess {
        // Convert bytes to Int
        let int = bytes.withUnsafeBytes { pointer in
          return pointer.load(as: Int.self)
        }
        
        return int
      }
      else {
        return super.nextInt()
      }
    }
  }
}
#else
import Foundation
extension java.security {
  
  /// Type to create secure random values
  open class SecureRandom : java.util.Random {
    
    // Ein zentraler, thread-sicherer System-Zufallsgenerator
    private var generator = SystemRandomNumberGenerator()
    
    /// Fill the given byte array with random data
    /// - Parameters byte array to fill
    public override func nextBytes(_ bytes : inout [UInt8]) {
      guard 0 < bytes.count else {
        return
      }
      
      // Befüllt das Array direkt über den kryptografisch sicheren Systemgenerator
      for i in 0..<bytes.count {
        bytes[i] = generator.next()
      }
    }
    
    /// Create a random int value.
    /// - Returns a random int value
    override public func nextInt() -> Int {
      // SystemRandomNumberGenerator liefert direkt UInt64 Werte.
      // Für einen Standard-Int (32-Bit oder 64-Bit je nach Architektur)
      // generieren wir hier die passenden Zufallsbits.
      let randomUInt = generator.next()
      
      // Sicherer Cast in einen signed Int via Bit-Muster
      return Int(bitPattern: UInt(truncatingIfNeeded: randomUInt))
    }
  }
}
#endif // canImport(Security)
