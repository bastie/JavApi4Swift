/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: Apache-2.0
 */

import Foundation

// MARK: - Random conforms to RandomGenerator (Java 17 retrofit)

extension java.util.Random: java.util.random.RandomGenerator {

  // nextInt(), nextLong(), nextDouble(), nextBoolean(), nextFloat(),
  // nextGaussian(), nextBytes() are already on java.util.Random —
  // the protocol default implementations delegate to them automatically.

  // MARK: New overloads with bound (Java 17)

  /// Returns an `Int` in `[0, bound)`.
  /// Already declared on `java.util.Random` — satisfies the protocol requirement.

  // MARK: New overloads with origin and bound (Java 17)

  /// Returns an `Int64` in `[0, bound)`.
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

  /// Returns an `Int64` in `[origin, bound)`.
  public func nextLong(_ origin: Int64, _ bound: Int64) throws(IllegalArgumentException) -> Int64 {
    guard origin < bound else { throw IllegalArgumentException() }
    return origin + (try nextLong(bound - origin))
  }

  /// Returns an `Int` in `[origin, bound)`.
  public func nextInt(_ origin: Int, _ bound: Int) throws(IllegalArgumentException) -> Int {
    guard origin < bound else { throw IllegalArgumentException() }
    return origin + (try nextInt(bound - origin))
  }

  /// Returns a `Double` in `[0.0, bound)`.
  public func nextDouble(_ bound: Double) throws(IllegalArgumentException) -> Double {
    guard bound > 0, bound.isFinite else { throw IllegalArgumentException() }
    return nextDouble() * bound
  }

  /// Returns a `Double` in `[origin, bound)`.
  public func nextDouble(_ origin: Double, _ bound: Double) throws(IllegalArgumentException) -> Double {
    guard origin < bound, bound.isFinite, origin.isFinite else { throw IllegalArgumentException() }
    return origin + nextDouble() * (bound - origin)
  }

  /// Returns a `Float` in `[0.0, bound)`.
  public func nextFloat(_ bound: Float) throws(IllegalArgumentException) -> Float {
    guard bound > 0, bound.isFinite else { throw IllegalArgumentException() }
    return nextFloat() * bound
  }

  /// Returns a `Float` in `[origin, bound)`.
  public func nextFloat(_ origin: Float, _ bound: Float) throws(IllegalArgumentException) -> Float {
    guard origin < bound, bound.isFinite, origin.isFinite else { throw IllegalArgumentException() }
    return origin + nextFloat() * (bound - origin)
  }

  /// Returns a Gaussian value with given mean and standard deviation.
  public func nextGaussian(_ mean: Double, _ stddev: Double) -> Double {
    return mean + stddev * nextGaussian()
  }

  /// Returns an exponentially distributed `Double` with mean 1.0 (Java 17).
  public func nextExponential() -> Double {
    var u: Double
    repeat { u = nextDouble() } while u == 0.0
    return -Foundation.log(u)
  }
}
