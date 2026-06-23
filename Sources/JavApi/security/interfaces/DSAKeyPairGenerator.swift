/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.security.interfaces {

  /// An optional interface for DSA key-pair generators.
  ///
  /// Mirrors `java.security.interfaces.DSAKeyPairGenerator` (Java 1.1).
  /// A `KeyPairGenerator` that also conforms to this protocol allows callers
  /// to initialise it directly with DSA domain parameters or a key-size.
  ///
  /// Per the Java spec this interface is *optional* — a provider need not
  /// implement it, but if it does callers can avoid the generic
  /// `AlgorithmParameterSpec` path and pass `DSAParams` directly.
  ///
  /// - Since: JavaApi > 0.x (Java 1.1)
  public protocol DSAKeyPairGenerator {
    /// Initialises this generator with the given DSA domain parameters.
    ///
    /// - Parameters:
    ///   - params: The DSA domain parameters (p, q, g).
    ///   - random: A source of randomness.
    /// - Throws: ``java.security.InvalidParameterException`` if the parameters
    ///   are inappropriate for this generator.
    func initialize(_ params: any DSAParams, _ random: java.security.SecureRandom) throws

    /// Initialises this generator for the given modulus-length.
    ///
    /// - Parameters:
    ///   - modlen: The modulus length in bits (typically 512, 768, or 1024).
    ///   - genParams: If `true`, new DSA parameters are generated for this
    ///     modulus length; if `false`, pre-computed parameters are used.
    ///   - random: A source of randomness.
    /// - Throws: ``java.security.InvalidParameterException`` if `modlen` is
    ///   not supported.
    func initialize(_ modlen: Int, _ genParams: Bool, _ random: java.security.SecureRandom) throws
  }
}
