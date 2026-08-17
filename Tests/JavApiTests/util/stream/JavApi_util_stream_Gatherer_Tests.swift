/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: Apache-2.0
 */
import Testing
@testable import JavApi

// MARK: - Gatherer factory + andThen

struct JavApi_util_stream_Gatherer_Tests {

  @Test("Gatherer.of(integrator:) — passthrough collects all elements")
  func testOfIntegratorPassthrough() {
    let passthrough = java.util.stream.Gatherer<Int, Int>.of { element, downstream in
      _ = downstream(element)
      return true
    }
    let result = java.util.stream.Stream.of(1, 2, 3).gather(passthrough).toArray()
    #expect(result == [1, 2, 3])
  }

  @Test("Gatherer.of(integrator:) — short-circuit stops early")
  func testOfIntegratorShortCircuit() {
    let takeTwo = java.util.stream.Gatherer<Int, Int>.of { element, downstream in
      _ = downstream(element)
      return element < 2   // stop after 2
    }
    let result = java.util.stream.Stream.of(1, 2, 3, 4).gather(takeTwo).toArray()
    #expect(result == [1, 2])
  }

  @Test("Gatherer.of(supplier:integrator:) — stateful running index")
  func testOfSupplierIntegrator() {
    // Tag each element with its 1-based index
    let indexed = java.util.stream.Gatherer<String, String>.of(
      supplier: { 0 },
      integrator: { index, element, downstream in
        index += 1
        return downstream("\(index):\(element)")
      }
    )
    let result = java.util.stream.Stream.of("a", "b", "c").gather(indexed).toArray()
    #expect(result == ["1:a", "2:b", "3:c"])
  }

  @Test("Gatherer.of(supplier:integrator:finisher:) — finisher flushes remainder")
  func testOfWithFinisher() {
    // Emit pairs; finisher emits last odd element with a placeholder
    let pairs = java.util.stream.Gatherer<Int, String>.of(
      supplier: { [Int]() },
      integrator: { buf, element, downstream in
        buf.append(element)
        if buf.count == 2 {
          let pair = "\(buf[0]),\(buf[1])"
          buf.removeAll()
          return downstream(pair)
        }
        return true
      },
      finisher: { buf, downstream in
        if !buf.isEmpty { _ = downstream("\(buf[0]),-") }
      }
    )
    let result = java.util.stream.Stream.of(1, 2, 3).gather(pairs).toArray()
    #expect(result == ["1,2", "3,-"])
  }

  @Test("Gatherer.andThen — compose two gatherers")
  func testAndThen() {
    // scan then filter even results
    let runningSum = java.util.stream.Gatherers.scan({ 0 }) { $0 + $1 }
    let keepEven = java.util.stream.Gatherer<Int, Int>.of { element, downstream in
      if element % 2 == 0 { return downstream(element) }
      return true
    }
    let composed = runningSum.andThen(keepEven)
    let result = java.util.stream.Stream.of(1, 2, 3, 4, 5).gather(composed).toArray()
    // Running sums: 1, 3, 6, 10, 15  →  even: 6, 10
    #expect(result == [6, 10])
  }

  @Test("Gatherer.ofSequential — equivalent to of(integrator:)")
  func testOfSequential() {
    let doubler = java.util.stream.Gatherer<Int, Int>.ofSequential { element, downstream in
      return downstream(element * 2)
    }
    let result = java.util.stream.Stream.of(1, 2, 3).gather(doubler).toArray()
    #expect(result == [2, 4, 6])
  }
}

// MARK: - Gatherers utility

struct JavApi_util_stream_Gatherers_Tests {

  @Test("Gatherers.fold — sums all elements into one")
  func testFoldSum() {
    let result = java.util.stream.Stream.of(1, 2, 3, 4, 5)
      .gather(java.util.stream.Gatherers.fold({ 0 }) { $0 + $1 })
      .toArray()
    #expect(result == [15])
  }

  @Test("Gatherers.fold — empty stream emits initial value")
  func testFoldEmpty() {
    let result = java.util.stream.Stream<Int>.empty()
      .gather(java.util.stream.Gatherers.fold({ 42 }) { $0 + $1 })
      .toArray()
    #expect(result == [42])
  }

  @Test("Gatherers.scan — running sum")
  func testScanRunningSum() {
    let result = java.util.stream.Stream.of(1, 2, 3, 4)
      .gather(java.util.stream.Gatherers.scan({ 0 }) { $0 + $1 })
      .toArray()
    #expect(result == [1, 3, 6, 10])
  }

  @Test("Gatherers.scan — single element")
  func testScanSingleElement() {
    let result = java.util.stream.Stream.of(7)
      .gather(java.util.stream.Gatherers.scan({ 0 }) { $0 + $1 })
      .toArray()
    #expect(result == [7])
  }

  @Test("Gatherers.scan — empty stream produces no output")
  func testScanEmpty() {
    let result = java.util.stream.Stream<Int>.empty()
      .gather(java.util.stream.Gatherers.scan({ 0 }) { $0 + $1 })
      .toArray()
    #expect(result.isEmpty)
  }

  @Test("Gatherers.windowFixed — exact multiples")
  func testWindowFixedExact() {
    let result = java.util.stream.Stream.of(1, 2, 3, 4, 5, 6)
      .gather(java.util.stream.Gatherers.windowFixed(2))
      .toArray()
    #expect(result == [[1, 2], [3, 4], [5, 6]])
  }

  @Test("Gatherers.windowFixed — partial last window")
  func testWindowFixedPartial() {
    let result = java.util.stream.Stream.of(1, 2, 3, 4, 5)
      .gather(java.util.stream.Gatherers.windowFixed(2))
      .toArray()
    #expect(result == [[1, 2], [3, 4], [5]])
  }

  @Test("Gatherers.windowFixed — window larger than input")
  func testWindowFixedLargerThanInput() {
    let result = java.util.stream.Stream.of(1, 2)
      .gather(java.util.stream.Gatherers.windowFixed(5))
      .toArray()
    #expect(result == [[1, 2]])
  }

  @Test("Gatherers.windowSliding — basic 3-element window")
  func testWindowSlidingBasic() {
    let result = java.util.stream.Stream.of(1, 2, 3, 4, 5)
      .gather(java.util.stream.Gatherers.windowSliding(3))
      .toArray()
    #expect(result == [[1, 2, 3], [2, 3, 4], [3, 4, 5]])
  }

  @Test("Gatherers.windowSliding — no window emitted until full")
  func testWindowSlidingNotEnoughElements() {
    let result = java.util.stream.Stream.of(1, 2)
      .gather(java.util.stream.Gatherers.windowSliding(3))
      .toArray()
    #expect(result.isEmpty)
  }

  @Test("Gatherers.windowSliding — window size 1 emits each element wrapped")
  func testWindowSlidingSize1() {
    let result = java.util.stream.Stream.of(1, 2, 3)
      .gather(java.util.stream.Gatherers.windowSliding(1))
      .toArray()
    #expect(result == [[1], [2], [3]])
  }

  @Test("Gatherers.mapConcurrent — preserves order")
  func testMapConcurrentOrder() {
    let result = java.util.stream.Stream.of(1, 2, 3, 4, 5)
      .gather(java.util.stream.Gatherers.mapConcurrent(4) { $0 * 10 })
      .toArray()
    #expect(result == [10, 20, 30, 40, 50])
  }

  @Test("Gatherers.mapConcurrent — empty stream")
  func testMapConcurrentEmpty() {
    let result = java.util.stream.Stream<Int>.empty()
      .gather(java.util.stream.Gatherers.mapConcurrent(4) { $0 * 2 })
      .toArray()
    #expect(result.isEmpty)
  }

  @Test("Gatherers.mapConcurrent — parallelism 1 behaves sequentially")
  func testMapConcurrentSingle() {
    let result = java.util.stream.Stream.of(10, 20, 30)
      .gather(java.util.stream.Gatherers.mapConcurrent(1) { $0 + 1 })
      .toArray()
    #expect(result == [11, 21, 31])
  }

  @Test("Stream.gather — chained gather calls")
  func testChainedGather() {
    let result = java.util.stream.Stream.of(1, 2, 3, 4, 5, 6)
      .gather(java.util.stream.Gatherers.windowFixed(2))
      .gather(java.util.stream.Gatherers.fold({ [Int]() }) { acc, window in acc + window })
      .toArray()
    // Windows: [1,2], [3,4], [5,6]  →  fold: [1,2,3,4,5,6]
    #expect(result == [[1, 2, 3, 4, 5, 6]])
  }
}
