/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.security {

  /// Abstract base class for asymmetric key-pair generators.
  ///
  /// Use `getInstance(algorithm:)` to obtain a concrete implementation from
  /// the registered providers, then call `initialize` to set up key sizes or
  /// parameters before generating key pairs.
  ///
  /// Mirrors `java.security.KeyPairGenerator` (Java 1.1).
  ///
  /// ### Example
  /// ```swift
  /// let kpg = try java.security.KeyPairGenerator.getInstance("DSA")
  /// kpg.initialize(1024)
  /// let kp = kpg.generateKeyPair()
  /// ```
  ///
  /// - Since: JavaApi > 0.x (Java 1.1)
  open class KeyPairGenerator: @unchecked Sendable {

    // MARK: - Fields

    private let algorithm: String

    // MARK: - Constructor

    /// Designated constructor for subclasses.
    ///
    /// - Parameter algorithm: The standard name of the algorithm this
    ///   generator produces key pairs for (e.g. `"DSA"`, `"RSA"`).
    public init(_ algorithm: String) {
      self.algorithm = algorithm
    }

    // MARK: - Algorithm

    /// Returns the standard name of the algorithm this generator uses.
    public func getAlgorithm() -> String { algorithm }

    // MARK: - Factory

    /// Returns a `KeyPairGenerator` for the named algorithm from the first
    /// provider that supports it.
    ///
    /// - Parameter algorithm: The standard algorithm name (e.g. `"DSA"`).
    /// - Throws: `NoSuchAlgorithmException` if no provider supports the
    ///   requested algorithm.
    public static func getInstance(_ algorithm: String) throws (NoSuchAlgorithmException) -> KeyPairGenerator {
      // Search registered providers
      for provider in Security.getProviders() {
        for (svcAlg, factory) in provider._keyPairGeneratorFactories {
          if svcAlg == algorithm {
            return factory()
          }
        }
      }
      throw NoSuchAlgorithmException("No KeyPairGenerator for algorithm: \(algorithm)")
    }

    // MARK: - Initialisation

    /// Initialises this generator for the given key size using a default source
    /// of randomness.
    ///
    /// - Parameter keysize: The key size in bits.
    open func initialize(_ keysize: Int) {
      initialize(keysize, java.security.SecureRandom())
    }

    /// Initialises this generator for the given key size and source of
    /// randomness.
    ///
    /// Subclasses must override this method.
    ///
    /// - Parameters:
    ///   - keysize: The key size in bits.
    ///   - random:  The source of randomness.
    open func initialize(_ keysize: Int, _ random: SecureRandom) {
      // Abstract — subclass must override
      fatalError("KeyPairGenerator.initialize(_:_:) not implemented in \(type(of: self))")
    }

    // MARK: - Generation

    /// Generates a key pair.
    ///
    /// Subclasses must override this method.
    open func generateKeyPair() -> KeyPair {
      fatalError("KeyPairGenerator.generateKeyPair() not implemented in \(type(of: self))")
    }

    /// Alias for `generateKeyPair()` — Java 1.1 compat.
    public final func genKeyPair() -> KeyPair {
      generateKeyPair()
    }
  }
}
