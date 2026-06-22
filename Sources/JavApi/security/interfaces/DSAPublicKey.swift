/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.security.interfaces {

  /// A DSA public key.
  ///
  /// Mirrors `java.security.interfaces.DSAPublicKey` (Java 1.1). Combines
  /// ``DSAKey`` (domain parameters) with ``java.security.PublicKey`` (key
  /// classification) and adds the public value `y`.
  ///
  /// - Since: JavaApi > 0.x (Java 1.1)
  public protocol DSAPublicKey : DSAKey, java.security.PublicKey {
    /// Returns the public value `y`.
    func getY() -> java.math.BigInteger
  }
}
