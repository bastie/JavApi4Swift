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
#endif // canImport(Security)
