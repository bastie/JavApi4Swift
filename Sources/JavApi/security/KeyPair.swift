/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.security {

  /// A simple holder for a public/private key pair.
  ///
  /// Mirrors `java.security.KeyPair` (Java 1.1).
  ///
  /// - Since: JavaApi > 0.x (Java 1.1)
  public final class KeyPair: @unchecked Sendable {

    private let publicKey:  any PublicKey
    private let privateKey: any PrivateKey

    /// Creates a `KeyPair` from the given public and private keys.
    ///
    /// - Parameters:
    ///   - publicKey:  The public key.
    ///   - privateKey: The private key.
    public init(_ publicKey: any PublicKey, _ privateKey: any PrivateKey) {
      self.publicKey  = publicKey
      self.privateKey = privateKey
    }

    /// Returns the public key.
    public func getPublic() -> any PublicKey { publicKey }

    /// Returns the private key.
    public func getPrivate() -> any PrivateKey { privateKey }
  }
}
