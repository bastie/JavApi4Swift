/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: Apache-2.0
 */

// MARK: - RandomGeneratorFactory<T> (Java 17)

extension java.util.random {

  /// A factory for instances of `RandomGenerator` identified by algorithm name (Java 17).
  ///
  /// Mirrors `java.util.random.RandomGeneratorFactory<T>`.
  ///
  /// Currently only the `"Random"` algorithm (legacy LCG) is registered.
  public final class RandomGeneratorFactory<T: java.util.random.RandomGenerator>: @unchecked Sendable {

    private let _name: String
    private let _group: String
    private let _creator: () -> T

    private init(name: String, group: String, creator: @escaping () -> T) {
      self._name  = name
      self._group = group
      self._creator = creator
    }

    // MARK: Factory methods

    /// Returns a factory for the given algorithm name.
    ///
    /// - Throws: `IllegalArgumentException` if the algorithm is not available.
    public static func of(_ algorithmName: String) throws(IllegalArgumentException) -> RandomGeneratorFactory<java.util.Random> {
      switch algorithmName {
      case "Random", "Legacy":
        return RandomGeneratorFactory<java.util.Random>(
          name: "Random", group: "Legacy"
        ) { java.util.Random() }
      default:
        throw IllegalArgumentException()
      }
    }

    /// Returns all available factories.
    public static func all() -> [RandomGeneratorFactory<java.util.Random>] {
      return [
        RandomGeneratorFactory<java.util.Random>(
          name: "Random", group: "Legacy"
        ) { java.util.Random() }
      ]
    }

    // MARK: Instance methods

    /// Creates a new instance of the generator.
    public func create() -> T { _creator() }

    /// The name of the algorithm.
    public func name() -> String { _name }

    /// The group of the algorithm (e.g. `"Legacy"`, `"Xoroshiro"`, `"LXM"`).
    public func group() -> String { _group }

    // MARK: Properties

    /// Returns `true` if this algorithm is deprecated.
    public func isDeprecated() -> Bool { _name == "Random" }

    /// Returns `true` if the generator is statistical (uses a PRNG algorithm).
    public func isStatistical() -> Bool { true }

    /// Returns `true` if the generator is stochastic (output is unpredictable without knowing the state).
    public func isStochastic() -> Bool { false }

    /// Returns `true` if the generator uses hardware entropy.
    public func isHardware() -> Bool { false }

    /// Returns `true` if the generator supports `SplittableRandomGenerator`.
    public func isSplittable() -> Bool { false }

    /// Returns `true` if the generator supports `JumpableRandomGenerator`.
    public func isJumpable() -> Bool { false }

    /// Returns `true` if the generator supports `LeapableRandomGenerator`.
    public func isLeapable() -> Bool { false }

    /// Returns `true` if the generator supports `ArbitrarilyJumpableRandomGenerator`.
    public func isArbitrarilyJumpable() -> Bool { false }

    /// Returns `true` if the generator supports `StreamableRandomGenerator`.
    public func isStreamable() -> Bool { false }

    /// The number of bits of state used by the generator (`48` for `Random`).
    public var stateBits: Int { 48 }

    /// The equidistribution dimension (`1` for the legacy LCG).
    public var equidistribution: Int { 1 }
  }
}
