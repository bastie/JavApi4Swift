/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.security {

  /// Marker protocol for cryptographic keys.
  ///
  /// All keys in JavApi⁴Swift conform to this protocol, which mirrors
  /// `java.security.Key`. A key has an algorithm name, an encoding format, and
  /// an optional raw-byte encoding.
  ///
  /// - Since: JavaApi > 0.x (Java 1.1)
  public protocol Key : java.io.Serializable {
    /// Returns the standard algorithm name for this key (e.g. `"DSA"`, `"RSA"`).
    func getAlgorithm() -> String
    /// Returns the name of the primary encoding format (e.g. `"X.509"`, `"PKCS#8"`),
    /// or `nil` if the key does not support encoding.
    func getFormat() -> String?
    /// Returns the key in its primary encoding format, or `nil` if not encodable.
    func getEncoded() -> [UInt8]?
  }
}
