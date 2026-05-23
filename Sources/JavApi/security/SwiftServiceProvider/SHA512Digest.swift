/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: 0BSD
 */

#if canImport(CryptoKit)
import CryptoKit
import Foundation

public class SwiftSHA512Digest : java.security.MessageDigest {
  
  var delegate: SHA512
  
  internal override init() {
    self.delegate = SHA512()
    super.init()
  }
  
  open override func update(_ byteArray: [UInt8]) {
    self.delegate.update(data: Data(byteArray))
  }
  
  open override func digest() -> [UInt8] {
    let digest = self.delegate.finalize()
    let result : [UInt8] = Array(digest)
    self.reset()
    return result
  }
  
  open override func reset() {
    self.delegate = SHA512()
  }
}
#endif
