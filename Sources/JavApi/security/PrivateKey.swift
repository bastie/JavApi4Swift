/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.security {

  /// Marker protocol for private keys.
  ///
  /// Mirrors `java.security.PrivateKey` (Java 1.1). Extends ``Key`` with no
  /// additional methods — conformance alone signals that a key is the private
  /// half of an asymmetric key pair.
  ///
  /// - Since: JavaApi > 0.x (Java 1.1)
  public protocol PrivateKey : Key {}
}
