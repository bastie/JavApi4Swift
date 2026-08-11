/*
 * SPDX-License-Identifier: Apache-2.0
 */
import Testing
@testable import JavApi

struct JavApi_util_Random_Tests {

  @Test("default constructor creates a usable Random instance")
  func testConstructor() {
    _ = java.util.Random()
    // no assertion needed — the absence of a crash is the test
  }

  @Test("two Randoms with the same seed produce identical sequences")
  func testSameSeedProducesIdenticalSequence() {
    let r1 = java.util.Random(Int64(8_409_238))
    let r2 = java.util.Random(Int64(8_409_238))
    for _ in 0..<100 {
      #expect(r1.nextInt() == r2.nextInt())
    }
  }

  @Test("nextBoolean produces both true and false within 100 calls")
  func testNextBoolean() {
    let r = java.util.Random()
    var sawTrue = false, sawFalse = false
    for _ in 0..<100 {
      if r.nextBoolean() { sawTrue  = true }
      else               { sawFalse = true }
    }
    #expect(sawTrue,  "100 calls to nextBoolean() produced only false")
    #expect(sawFalse, "100 calls to nextBoolean() produced only true")
  }

  @Test("nextBytes fills array with varying values")
  func testNextBytes() {
    let r = java.util.Random()
    var bytes: [byte] = Array(repeating: byte(), count: 100)
    r.nextBytes(&bytes)
    let first = bytes[0]
    let allSame = bytes.dropFirst().allSatisfy { $0 == first }
    #expect(!allSame)
  }

  @Test("nextDouble produces values in [0, 1) with variation")
  func testNextDouble() {
    let r = java.util.Random()
    var last = r.nextDouble()
    var someDifferent = false
    for _ in 0..<100 {
      let next = r.nextDouble()
      #expect(next >= 0.0 && next < 1.0)
      if next != last { someDifferent = true }
      last = next
    }
    #expect(someDifferent)
  }

  @Test("nextFloat produces values in [0, 1) with variation")
  func testNextFloat() {
    let r = java.util.Random()
    var last = r.nextFloat()
    var someDifferent = false
    for _ in 0..<100 {
      let next = r.nextFloat()
      #expect(next >= 0.0 && next < 1.0)
      if next != last { someDifferent = true }
      last = next
    }
    #expect(someDifferent)
  }

  @Test("nextGaussian produces variation and values within 1 std deviation")
  func testNextGaussian() {
    let r = java.util.Random()
    var last = r.nextGaussian()
    var someDifferent = false
    var someInStd = false
    for _ in 0..<100 {
      let next = r.nextGaussian()
      if next != last { someDifferent = true }
      if next >= -1.0 && next <= 1.0 { someInStd = true }
      last = next
    }
    #expect(someDifferent)
    #expect(someInStd)
  }

  @Test("nextInt produces variation across 100 calls")
  func testNextInt() {
    let r = java.util.Random()
    var last = r.nextInt()
    var someDifferent = false
    for _ in 0..<100 {
      let next = r.nextInt()
      if next != last { someDifferent = true }
      last = next
    }
    #expect(someDifferent)
  }

  @Test("nextInt(range) stays within [0, range) with variation")
  func testNextIntRange() throws {
    let r = java.util.Random()
    let range = 10
    var last = try r.nextInt(range)
    var someDifferent = false
    for _ in 0..<100 {
      let next = try r.nextInt(range)
      #expect(next >= 0 && next < range)
      if next != last { someDifferent = true }
      last = next
    }
    #expect(someDifferent)
  }

  @Test("nextLong produces variation across 100 calls")
  func testNextLong() {
    let r = java.util.Random()
    var last = r.nextLong()
    var someDifferent = false
    for _ in 0..<100 {
      let next = r.nextLong()
      if next != last { someDifferent = true }
      last = next
    }
    #expect(someDifferent)
  }

  @Test("setSeed resets sequence to match original")
  func testSetSeed() {
    let seed: Int64 = 1_000
    let r1 = java.util.Random()
    let r2 = java.util.Random()
    let r3 = java.util.Random()
    r1.setSeed(seed)
    r2.setSeed(seed)

    var saved = [Int64]()
    var someDifferentFromR3 = false
    for _ in 0..<100 {
      let v1 = r1.nextLong()
      let v2 = r2.nextLong()
      #expect(v1 == v2)
      saved.append(v1)
      if v1 != r3.nextLong() { someDifferentFromR3 = true }
    }
    #expect(someDifferentFromR3)

    r1.setSeed(seed)
    for i in 0..<saved.count {
      #expect(r1.nextLong() == saved[i])
    }
  }

  @Test("two Randoms created at different times produce different values")
  func testConcurrentRandomsDiffer() throws {
    var anyDifferent = false
    for _ in 0..<20 {
      let r1 = java.util.Random()
      Thread.sleep(1)
      let r2 = java.util.Random()
      if r1.nextLong() != r2.nextLong() {
        anyDifferent = true
        break
      }
    }
    #expect(anyDifferent)
  }

  // MARK: - Additional coverage

  @Test("nextInt(1) always returns 0")
  func testNextIntBoundOne() throws {
    let r = java.util.Random(42)
    for _ in 0..<50 {
      #expect(try r.nextInt(1) == 0)
    }
  }

  @Test("nextInt(bound) never returns negative value")
  func testNextIntBoundNeverNegative() throws {
    let r = java.util.Random()
    for _ in 0..<200 {
      #expect(try r.nextInt(100) >= 0)
    }
  }

  @Test("nextInt(bound) never returns value >= bound")
  func testNextIntBoundRespected() throws {
    let r = java.util.Random()
    let bound = 7
    for _ in 0..<200 {
      #expect(try r.nextInt(bound) < bound)
    }
  }

  @Test("nextInt(0) throws IllegalArgumentException")
  func testNextIntZeroBoundThrows() {
    let r = java.util.Random()
    #expect(throws: IllegalArgumentException.self) {
      try r.nextInt(0)
    }
  }

  @Test("nextDouble mean over 1000 samples is near 0.5")
  func testNextDoubleMean() {
    let r = java.util.Random(12345)
    let sum = (0..<1000).reduce(0.0) { acc, _ in acc + r.nextDouble() }
    let mean = sum / 1000.0
    // Allow ±0.05 tolerance
    #expect(mean > 0.45 && mean < 0.55)
  }

  @Test("nextFloat never returns 1.0")
  func testNextFloatNeverOne() {
    let r = java.util.Random()
    for _ in 0..<1000 {
      #expect(r.nextFloat() < 1.0)
    }
  }

  @Test("nextBytes fills array — different seeds produce different bytes")
  func testNextBytesDifferentSeeds() {
    let r1 = java.util.Random(1)
    let r2 = java.util.Random(2)
    var b1: [byte] = Array(repeating: 0, count: 32)
    var b2: [byte] = Array(repeating: 0, count: 32)
    r1.nextBytes(&b1)
    r2.nextBytes(&b2)
    #expect(b1 != b2)
  }

  @Test("same seed produces same nextGaussian sequence")
  func testSameSeedGaussian() {
    let r1 = java.util.Random(999)
    let r2 = java.util.Random(999)
    for _ in 0..<20 {
      #expect(r1.nextGaussian() == r2.nextGaussian())
    }
  }
}
