/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: Apache-2.0
 */
import Testing
@testable import JavApi

// MARK: - RandomGenerator protocol conformance

struct JavApi_util_random_RandomGenerator_Tests {

  // Random conforms to RandomGenerator
  @Test("Random conforms to RandomGenerator")
  func testRandomConformsToProtocol() {
    let r: any java.util.random.RandomGenerator = java.util.Random()
    _ = r.nextInt()   // must compile and run
  }

  @Test("RandomGenerator.of returns a Random for algorithm 'Random'")
  func testOfReturnsRandom() throws {
    let rg = try java.util.Random.of("Random")
    _ = rg.nextLong()
  }

  @Test("RandomGenerator.of throws for unknown algorithm")
  func testOfThrowsForUnknown() {
    #expect(throws: IllegalArgumentException.self) {
      try java.util.Random.of("NonExistentAlgorithmXYZ")
    }
  }

  // MARK: - nextInt(bound) via protocol

  @Test("nextInt(bound) via protocol stays in [0, bound)")
  func testNextIntBoundViaProtocol() throws {
    let rg: any java.util.random.RandomGenerator = java.util.Random()
    for _ in 0..<200 {
      let v = try rg.nextInt(50)
      #expect(v >= 0 && v < 50)
    }
  }

  @Test("nextInt(origin, bound) via protocol stays in [origin, bound)")
  func testNextIntOriginBoundViaProtocol() throws {
    let rg: any java.util.random.RandomGenerator = java.util.Random()
    for _ in 0..<200 {
      let v = try rg.nextInt(10, 20)
      #expect(v >= 10 && v < 20)
    }
  }

  @Test("nextInt(origin, bound) throws when origin >= bound")
  func testNextIntOriginBoundThrows() {
    let rg: any java.util.random.RandomGenerator = java.util.Random()
    #expect(throws: IllegalArgumentException.self) {
      try rg.nextInt(20, 10)
    }
  }

  // MARK: - nextLong overloads

  @Test("nextLong(bound) stays in [0, bound)")
  func testNextLongBound() throws {
    let r = java.util.Random(42)
    for _ in 0..<100 {
      let v = try r.nextLong(1000)
      #expect(v >= 0 && v < 1000)
    }
  }

  @Test("nextLong(origin, bound) stays in [origin, bound)")
  func testNextLongOriginBound() throws {
    let r = java.util.Random(7)
    for _ in 0..<100 {
      let v = try r.nextLong(100, 200)
      #expect(v >= 100 && v < 200)
    }
  }

  @Test("nextLong(0) throws IllegalArgumentException")
  func testNextLongZeroBoundThrows() {
    let r = java.util.Random()
    #expect(throws: IllegalArgumentException.self) {
      try r.nextLong(0)
    }
  }

  // MARK: - nextDouble overloads

  @Test("nextDouble(bound) stays in [0.0, bound)")
  func testNextDoubleBound() throws {
    let r = java.util.Random(1)
    for _ in 0..<100 {
      let v = try r.nextDouble(5.0)
      #expect(v >= 0.0 && v < 5.0)
    }
  }

  @Test("nextDouble(origin, bound) stays in [origin, bound)")
  func testNextDoubleOriginBound() throws {
    let r = java.util.Random(2)
    for _ in 0..<100 {
      let v = try r.nextDouble(1.0, 3.0)
      #expect(v >= 1.0 && v < 3.0)
    }
  }

  @Test("nextDouble(bound) throws for negative bound")
  func testNextDoubleBoundThrows() {
    let r = java.util.Random()
    #expect(throws: IllegalArgumentException.self) {
      try r.nextDouble(-1.0)
    }
  }

  // MARK: - nextFloat overloads

  @Test("nextFloat(bound) stays in [0.0, bound)")
  func testNextFloatBound() throws {
    let r = java.util.Random(3)
    for _ in 0..<100 {
      let v = try r.nextFloat(10.0)
      #expect(v >= 0.0 && v < 10.0)
    }
  }

  @Test("nextFloat(origin, bound) stays in [origin, bound)")
  func testNextFloatOriginBound() throws {
    let r = java.util.Random(4)
    for _ in 0..<100 {
      let v = try r.nextFloat(2.0, 4.0)
      #expect(v >= 2.0 && v < 4.0)
    }
  }

  // MARK: - nextGaussian(mean, stddev)

  @Test("nextGaussian(mean, stddev) shifts the distribution")
  func testNextGaussianMeanStddev() {
    let r = java.util.Random(42)
    let mean = 10.0
    let stddev = 2.0
    let samples = (0..<1000).map { _ in r.nextGaussian(mean, stddev) }
    let avg = samples.reduce(0.0, +) / Double(samples.count)
    // Allow generous tolerance (±1.0)
    #expect(avg > 9.0 && avg < 11.0)
  }

  // MARK: - nextExponential

  @Test("nextExponential returns positive value")
  func testNextExponentialPositive() {
    let r = java.util.Random(99)
    for _ in 0..<200 {
      #expect(r.nextExponential() > 0.0)
    }
  }

  @Test("nextExponential mean over 10000 samples is near 1.0")
  func testNextExponentialMean() {
    let r = java.util.Random(12345)
    let sum = (0..<10_000).reduce(0.0) { acc, _ in acc + r.nextExponential() }
    let mean = sum / 10_000.0
    // Exponential with rate 1 has mean 1.0; allow ±0.1
    #expect(mean > 0.9 && mean < 1.1)
  }

  // MARK: - isDeprecated default

  @Test("isDeprecated returns false by default")
  func testIsDeprecatedDefault() {
    let r: any java.util.random.RandomGenerator = java.util.Random()
    #expect(r.isDeprecated() == false)
  }
}

// MARK: - RandomGeneratorFactory tests

struct JavApi_util_random_RandomGeneratorFactory_Tests {

  @Test("RandomGeneratorFactory.all() returns at least one factory")
  func testAllReturnsNonEmpty() {
    let factories = java.util.random.RandomGeneratorFactory<java.util.Random>.all()
    #expect(!factories.isEmpty)
  }

  @Test("RandomGeneratorFactory.of('Random') returns a working factory")
  func testOfRandom() throws {
    let factory = try java.util.random.RandomGeneratorFactory<java.util.Random>.of("Random")
    let rg = factory.create()
    _ = rg.nextInt()   // must not crash
  }

  @Test("RandomGeneratorFactory.of throws for unknown algorithm")
  func testOfThrowsForUnknown() {
    #expect(throws: IllegalArgumentException.self) {
      try java.util.random.RandomGeneratorFactory<java.util.Random>.of("NoSuchAlgo")
    }
  }

  @Test("RandomGeneratorFactory name() and group() are non-empty")
  func testNameAndGroup() throws {
    let f = try java.util.random.RandomGeneratorFactory<java.util.Random>.of("Random")
    #expect(!f.name().isEmpty)
    #expect(!f.group().isEmpty)
  }

  @Test("RandomGeneratorFactory stateBits is positive")
  func testStateBits() throws {
    let f = try java.util.random.RandomGeneratorFactory<java.util.Random>.of("Random")
    #expect(f.stateBits > 0)
  }

  @Test("RandomGeneratorFactory isStatistical is true for Random")
  func testIsStatistical() throws {
    let f = try java.util.random.RandomGeneratorFactory<java.util.Random>.of("Random")
    #expect(f.isStatistical())
  }

  @Test("RandomGeneratorFactory isHardware is false for Random")
  func testIsHardware() throws {
    let f = try java.util.random.RandomGeneratorFactory<java.util.Random>.of("Random")
    #expect(!f.isHardware())
  }
}
