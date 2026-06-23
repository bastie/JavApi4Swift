/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.security.interfaces {

  /// A DSA private key.
  ///
  /// Mirrors `java.security.interfaces.DSAPrivateKey` (Java 1.1). Combines
  /// ``DSAKey`` (domain parameters) with ``java.security.PrivateKey`` (key
  /// classification) and adds the private value `x`.
  ///
  /// - Since: JavaApi > 0.x (Java 1.1)
  public protocol DSAPrivateKey : DSAKey, java.security.PrivateKey {
    /// Returns the private value `x`.
    func getX() -> java.math.BigInteger
  }
}
