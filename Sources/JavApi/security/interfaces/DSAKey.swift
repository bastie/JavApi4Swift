/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.security.interfaces {

  /// A DSA cryptographic key (public or private).
  ///
  /// Mirrors `java.security.interfaces.DSAKey` (Java 1.1). Conforming types
  /// expose the DSA domain parameters via ``getParams()``.
  ///
  /// - Since: JavaApi > 0.x (Java 1.1)
  public protocol DSAKey {
    /// Returns the DSA domain parameters, or `nil` if not initialised.
    func getParams() -> (any DSAParams)?
  }
}
