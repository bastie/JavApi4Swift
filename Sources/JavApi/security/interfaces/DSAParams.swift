/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.security.interfaces {

  /// DSA domain parameters (p, q, g).
  ///
  /// Mirrors `java.security.interfaces.DSAParams` (Java 1.1).
  ///
  /// - Since: JavaApi > 0.x (Java 1.1)
  public protocol DSAParams {
    /// Returns the prime `p`.
    func getP() -> java.math.BigInteger
    /// Returns the sub-prime `q`.
    func getQ() -> java.math.BigInteger
    /// Returns the base `g`.
    func getG() -> java.math.BigInteger
  }
}
