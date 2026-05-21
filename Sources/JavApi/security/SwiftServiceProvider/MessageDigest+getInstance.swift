/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: 0BSD
 */

extension java.security.MessageDigest {
  
  /// - Note: subclass need to implements this function
  public static func getInstance(_ algorithm: String) throws -> java.security.MessageDigest {
    guard SwiftMessageDigestProvidedAlgorithm.provides (algorithm: algorithm) else {
      throw java.security.NoSuchAlgorithmException ("Swift MessageDigest service provider do not support \(algorithm)")
    }
    if let instance = SwiftMessageDigestProvidedAlgorithm.getInstance(algorithm: algorithm) {
      return instance
    }
    fatalError() // never be here
  }
}
