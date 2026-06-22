/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.security {

  /// Abstract base class for digital-signature engines.
  ///
  /// A `Signature` object goes through three states:
  ///
  /// | State | Meaning |
  /// |-------|---------|
  /// | `UNINITIALIZED` | freshly obtained from `getInstance` |
  /// | `SIGN` | after `initSign` |
  /// | `VERIFY` | after `initVerify` |
  ///
  /// Call `update` to feed data into the engine, then either `sign()` or
  /// `verify(_:)` to finish the operation.
  ///
  /// Mirrors `java.security.Signature` (Java 1.1).
  ///
  /// ### Example
  /// ```swift
  /// let sig = try java.security.Signature.getInstance("SHA256withDSA")
  /// sig.initSign(keyPair.getPrivate())
  /// sig.update(data)
  /// let bytes = try sig.sign()
  /// ```
  ///
  /// - Since: JavaApi > 0.x (Java 1.1)
  open class Signature: @unchecked Sendable {

    // MARK: - State constants

    /// The signature engine has not yet been initialised.
    public static let UNINITIALIZED: Int = 0
    /// The engine is initialised for signing.
    public static let SIGN:          Int = 2
    /// The engine is initialised for verification.
    public static let VERIFY:        Int = 3

    // MARK: - Fields

    private let algorithm: String
    /// Current engine state (one of the constants above).
    public private(set) var state: Int = UNINITIALIZED

    // MARK: - Constructor

    /// Designated constructor for subclasses.
    ///
    /// - Parameter algorithm: The standard algorithm name (e.g. `"SHA256withDSA"`).
    public init(_ algorithm: String) {
      self.algorithm = algorithm
    }

    // MARK: - Factory

    /// Returns a `Signature` object that implements the specified algorithm.
    ///
    /// - Parameter algorithm: The standard algorithm name.
    /// - Throws: `NoSuchAlgorithmException` if no provider supports it.
    public static func getInstance(_ algorithm: String) throws (NoSuchAlgorithmException) -> Signature {
      for provider in Security.getProviders() {
        for (svcAlg, factory) in provider._signatureFactories {
          if svcAlg == algorithm {
            return factory()
          }
        }
      }
      throw NoSuchAlgorithmException("No Signature for algorithm: \(algorithm)")
    }

    // MARK: - Algorithm

    /// Returns the algorithm name for this `Signature` object.
    public func getAlgorithm() -> String { algorithm }

    // MARK: - Initialisation

    /// Initialises this object for signing with the given private key.
    ///
    /// - Parameter privateKey: The private key of the identity whose
    ///   signature is going to be generated.
    /// - Throws: `InvalidKeyException` if the key is invalid.
    open func initSign(_ privateKey: any PrivateKey) throws {
      state = Signature.SIGN
    }

    /// Initialises this object for signing with the given private key and
    /// a specific source of randomness.
    open func initSign(_ privateKey: any PrivateKey, _ random: SecureRandom) throws {
      try initSign(privateKey)
    }

    /// Initialises this object for verification with the given public key.
    ///
    /// - Parameter publicKey: The public key of the identity whose signature
    ///   is going to be verified.
    /// - Throws: `InvalidKeyException` if the key is invalid.
    open func initVerify(_ publicKey: any PublicKey) throws {
      state = Signature.VERIFY
    }

    // MARK: - Update

    /// Updates the data to be signed or verified using the specified byte.
    open func update(_ b: UInt8) throws {
      try update([b])
    }

    /// Updates the data to be signed or verified using the specified bytes.
    open func update(_ data: [UInt8]) throws {
      fatalError("Signature.update(_:) not implemented in \(type(of: self))")
    }

    /// Updates the data to be signed or verified using the specified subarray.
    open func update(_ data: [UInt8], _ offset: Int, _ length: Int) throws {
      try update(Array(data[offset..<offset + length]))
    }

    // MARK: - Sign / Verify

    /// Returns the signature bytes of all the data updated.
    ///
    /// - Returns: The signature bytes.
    open func sign() throws -> [UInt8] {
      fatalError("Signature.sign() not implemented in \(type(of: self))")
    }

    /// Stores the signature in `outbuf` starting at `offset` for up to `length`
    /// bytes.
    ///
    /// - Returns: The number of bytes placed into `outbuf`.
    open func sign(_ outbuf: inout [UInt8], _ offset: Int, _ length: Int) throws -> Int {
      let bytes = try sign()
      let n = Swift.min(bytes.count, length)
      for i in 0..<n { outbuf[offset + i] = bytes[i] }
      return n
    }

    /// Verifies the passed-in signature.
    ///
    /// - Parameter signature: The signature bytes to be verified.
    /// - Returns: `true` if the signature was verified, `false` otherwise.
    open func verify(_ signature: [UInt8]) throws -> Bool {
      fatalError("Signature.verify(_:) not implemented in \(type(of: self))")
    }
  }
}
