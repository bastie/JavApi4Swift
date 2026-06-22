/*
 * SPDX-FileCopyrightText: 2023-2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

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
