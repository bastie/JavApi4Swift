/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: Apache-2.0
 */

import Foundation

// MARK: - RandomGenerator (Java 17)

extension java.util.random {

  /// A common interface for all random number generators (Java 17).
  ///
  /// Mirrors `java.util.random.RandomGenerator`.
  public protocol RandomGenerator {

    // MARK: Required primitives (at least one of nextInt/nextLong must be overridden)

    /// Returns the next uniformly distributed `Int` value.
    func nextInt() -> Int

    /// Returns the next uniformly distributed `Int64` value.
    func nextLong() -> Int64

    /// Returns the next uniformly distributed `Double` in `[0.0, 1.0)`.
    func nextDouble() -> Double

    // MARK: Optional – provided with defaults

    /// Returns `true` or `false` with equal probability.
    func nextBoolean() -> Bool

    /// Fills `bytes` with random bytes.
    func nextBytes(_ bytes: inout [byte])

    /// Returns an `Int` in `[0, bound)`.
    func nextInt(_ bound: Int) throws(IllegalArgumentException) -> Int

    /// Returns an `Int` in `[origin, bound)`.
    func nextInt(_ origin: Int, _ bound: Int) throws(IllegalArgumentException) -> Int

    /// Returns an `Int64` in `[0, bound)`.
    func nextLong(_ bound: Int64) throws(IllegalArgumentException) -> Int64

    /// Returns an `Int64` in `[origin, bound)`.
    func nextLong(_ origin: Int64, _ bound: Int64) throws(IllegalArgumentException) -> Int64

    /// Returns a `Float` in `[0.0, 1.0)`.
    func nextFloat() -> Float

    /// Returns a `Float` in `[0.0, bound)`.
    func nextFloat(_ bound: Float) throws(IllegalArgumentException) -> Float

    /// Returns a `Float` in `[origin, bound)`.
    func nextFloat(_ origin: Float, _ bound: Float) throws(IllegalArgumentException) -> Float

    /// Returns a `Double` in `[0.0, bound)`.
    func nextDouble(_ bound: Double) throws(IllegalArgumentException) -> Double

    /// Returns a `Double` in `[origin, bound)`.
    func nextDouble(_ origin: Double, _ bound: Double) throws(IllegalArgumentException) -> Double

    /// Returns a normally distributed `Double` with mean 0 and std-dev 1.
    func nextGaussian() -> Double

    /// Returns a normally distributed `Double` with given mean and std-dev.
    func nextGaussian(_ mean: Double, _ stddev: Double) -> Double

    /// Returns an exponentially distributed `Double` with mean 1.
    func nextExponential() -> Double

    /// Returns `true` if this generator is deprecated.
    func isDeprecated() -> Bool

    /// Returns an instance of `RandomGenerator` for the named algorithm.
    static func of(_ algorithmName: String) throws(IllegalArgumentException) -> any java.util.random.RandomGenerator
  }
}

// MARK: - Default implementations

extension java.util.random.RandomGenerator {

  public func nextBoolean() -> Bool {
    return nextInt() & 1 != 0
  }

  public func nextBytes(_ bytes: inout [byte]) {
    var i = 0
    while i < bytes.count {
      var rand = nextInt()
      var j = 0
      while j < 4 && i < bytes.count {
        bytes[i] = byte(truncatingIfNeeded: rand & 0xFF)
        rand >>= 8
        i += 1
        j += 1
      }
    }
  }

  public func nextInt(_ bound: Int) throws(IllegalArgumentException) -> Int {
    guard bound > 0 else { throw IllegalArgumentException() }
    if (bound & -bound) == bound {
      return Int((Int64(bound) * Int64(nextInt() & Int.max)) >> 31)
    }
    var bits: Int
    var val: Int
    repeat {
      bits = nextInt() & Int.max
      val  = bits % bound
    } while bits - val + (bound - 1) < 0
    return val
  }

  public func nextInt(_ origin: Int, _ bound: Int) throws(IllegalArgumentException) -> Int {
    guard origin < bound else { throw IllegalArgumentException() }
    let range = bound - origin
    return origin + (try nextInt(range))
  }

  public func nextLong(_ bound: Int64) throws(IllegalArgumentException) -> Int64 {
    guard bound > 0 else { throw IllegalArgumentException() }
    var bits: Int64
    var val: Int64
    repeat {
      bits = nextLong() & Int64.max
      val  = bits % bound
    } while bits - val + (bound - 1) < 0
    return val
  }

  public func nextLong(_ origin: Int64, _ bound: Int64) throws(IllegalArgumentException) -> Int64 {
    guard origin < bound else { throw IllegalArgumentException() }
    let range = bound - origin
    return origin + (try nextLong(range))
  }

  public func nextFloat() -> Float {
    return Float(nextInt() & 0x00FF_FFFF) / Float(1 << 24)
  }

  public func nextFloat(_ bound: Float) throws(IllegalArgumentException) -> Float {
    guard bound > 0, bound.isFinite else { throw IllegalArgumentException() }
    return nextFloat() * bound
  }

  public func nextFloat(_ origin: Float, _ bound: Float) throws(IllegalArgumentException) -> Float {
    guard origin < bound, bound.isFinite, origin.isFinite else { throw IllegalArgumentException() }
    return origin + nextFloat() * (bound - origin)
  }

  public func nextDouble(_ bound: Double) throws(IllegalArgumentException) -> Double {
    guard bound > 0, bound.isFinite else { throw IllegalArgumentException() }
    return nextDouble() * bound
  }

  public func nextDouble(_ origin: Double, _ bound: Double) throws(IllegalArgumentException) -> Double {
    guard origin < bound, bound.isFinite, origin.isFinite else { throw IllegalArgumentException() }
    return origin + nextDouble() * (bound - origin)
  }

  public func nextGaussian(_ mean: Double, _ stddev: Double) -> Double {
    return mean + stddev * nextGaussian()
  }

  public func nextExponential() -> Double {
    // Inverse transform sampling: -ln(U) where U ∈ (0,1)
    var u: Double
    repeat { u = nextDouble() } while u == 0.0
    return -Foundation.log(u)
  }

  public func isDeprecated() -> Bool { false }

  public static func of(_ algorithmName: String) throws(IllegalArgumentException) -> any java.util.random.RandomGenerator {
    switch algorithmName {
    case "Random", "Legacy":
      return java.util.Random()
    default:
      throw IllegalArgumentException()
    }
  }
}

// MARK: - Sub-protocols

extension java.util.random {

  /// A `RandomGenerator` that supports splitting into independent sub-generators (Java 17).
  public protocol SplittableRandomGenerator: java.util.random.RandomGenerator {
    /// Returns a new independent `SplittableRandomGenerator`.
    func split() -> any SplittableRandomGenerator
  }

  /// A `RandomGenerator` that supports jump operations (Java 17).
  public protocol JumpableRandomGenerator: java.util.random.RandomGenerator {
    /// Advances the internal state as if `jumpDistance()` calls to `nextLong()` were made.
    func jump()
    /// Returns the distance covered by one jump.
    func jumpDistance() -> Double
    /// Returns a copy of this generator and then advances this generator by one jump.
    func copyAndJump() -> any JumpableRandomGenerator
  }

  /// A `RandomGenerator` that supports both jump and leap operations (Java 17).
  public protocol LeapableRandomGenerator: java.util.random.JumpableRandomGenerator {
    /// Advances the internal state as if `leapDistance()` calls to `nextLong()` were made.
    func leap()
    /// Returns the distance covered by one leap.
    func leapDistance() -> Double
    /// Returns a copy of this generator and then advances this generator by one leap.
    func copyAndLeap() -> any LeapableRandomGenerator
  }

  /// A `RandomGenerator` that can jump an arbitrary distance (Java 17).
  public protocol ArbitrarilyJumpableRandomGenerator: java.util.random.LeapableRandomGenerator {
    /// Jumps forward by `2^logDistance` steps.
    func jumpPowerOfTwo(_ logDistance: Int)
    /// Jumps forward by the given `distance`.
    func jump(_ distance: Double)
  }

  /// A `RandomGenerator` that provides stream-of-values methods (Java 17).
  public protocol StreamableRandomGenerator: java.util.random.RandomGenerator {
    /// Returns a stream of random `Int` values.
    func ints(_ streamSize: Int64) -> java.util.stream.Stream<Int>
    /// Returns a stream of random `Int` values in `[origin, bound)`.
    func ints(_ streamSize: Int64, _ origin: Int, _ bound: Int) throws(IllegalArgumentException) -> java.util.stream.Stream<Int>
    /// Returns a stream of random `Int64` values.
    func longs(_ streamSize: Int64) -> java.util.stream.Stream<Int64>
    /// Returns a stream of random `Int64` values in `[origin, bound)`.
    func longs(_ streamSize: Int64, _ origin: Int64, _ bound: Int64) throws(IllegalArgumentException) -> java.util.stream.Stream<Int64>
    /// Returns a stream of random `Double` values.
    func doubles(_ streamSize: Int64) -> java.util.stream.Stream<Double>
    /// Returns a stream of random `Double` values in `[origin, bound)`.
    func doubles(_ streamSize: Int64, _ origin: Double, _ bound: Double) throws(IllegalArgumentException) -> java.util.stream.Stream<Double>
  }
}

// MARK: - StreamableRandomGenerator default implementations

extension java.util.random.StreamableRandomGenerator {

  public func ints(_ streamSize: Int64) -> java.util.stream.Stream<Int> {
    var values: [Int] = []
    for _ in 0..<Int(streamSize) { values.append(nextInt()) }
    return java.util.stream.Stream(values)
  }

  public func ints(_ streamSize: Int64, _ origin: Int, _ bound: Int) throws(IllegalArgumentException) -> java.util.stream.Stream<Int> {
    guard origin < bound else { throw IllegalArgumentException() }
    var values: [Int] = []
    for _ in 0..<Int(streamSize) { values.append(try nextInt(origin, bound)) }
    return java.util.stream.Stream(values)
  }

  public func longs(_ streamSize: Int64) -> java.util.stream.Stream<Int64> {
    var values: [Int64] = []
    for _ in 0..<Int(streamSize) { values.append(nextLong()) }
    return java.util.stream.Stream(values)
  }

  public func longs(_ streamSize: Int64, _ origin: Int64, _ bound: Int64) throws(IllegalArgumentException) -> java.util.stream.Stream<Int64> {
    guard origin < bound else { throw IllegalArgumentException() }
    var values: [Int64] = []
    for _ in 0..<Int(streamSize) { values.append(try nextLong(origin, bound)) }
    return java.util.stream.Stream(values)
  }

  public func doubles(_ streamSize: Int64) -> java.util.stream.Stream<Double> {
    var values: [Double] = []
    for _ in 0..<Int(streamSize) { values.append(nextDouble()) }
    return java.util.stream.Stream(values)
  }

  public func doubles(_ streamSize: Int64, _ origin: Double, _ bound: Double) throws(IllegalArgumentException) -> java.util.stream.Stream<Double> {
    guard origin < bound else { throw IllegalArgumentException() }
    var values: [Double] = []
    for _ in 0..<Int(streamSize) { values.append(try nextDouble(origin, bound)) }
    return java.util.stream.Stream(values)
  }
}
