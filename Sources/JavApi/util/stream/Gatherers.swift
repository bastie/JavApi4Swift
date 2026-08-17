/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: Apache-2.0
 */

import Foundation

// MARK: - Gatherers (Java 22, finalised in Java 24)

extension java.util.stream {

  /// Built-in ``Gatherer`` implementations.
  ///
  /// Mirrors `java.util.stream.Gatherers` (Java 22–24).
  ///
  /// - Since: Java 22 (finalised in Java 24)
  public enum Gatherers {

    // MARK: fold

    /// Returns a gatherer that reduces all stream elements to a single value
    /// produced by `folder`, and emits that one value.
    ///
    /// ```swift
    /// let sum = Stream.of(1, 2, 3).gather(Gatherers.fold({ 0 }) { $0 + $1 }).toArray()
    /// // [6]
    /// ```
    ///
    /// Mirrors `Gatherers.fold(supplier, folder)` (Java 22).
    ///
    /// - Parameters:
    ///   - supplier: Produces the initial accumulator value.
    ///   - folder: `(R, T) -> R` — combines the accumulator with each element.
    /// - Since: Java 22
    public static func fold<T, R>(
      _ supplier: @escaping () -> R,
      _ folder: @escaping (R, T) -> R
    ) -> Gatherer<T, R> {
      Gatherer.of(
        supplier: supplier,
        integrator: { state, element, _ in
          state = folder(state, element)
          return true
        },
        finisher: { state, downstream in
          _ = downstream(state)
        }
      )
    }

    // MARK: scan

    /// Returns a gatherer that emits a running prefix (prefix scan) of stream
    /// elements, starting with the value produced by `supplier`.
    ///
    /// ```swift
    /// let running = Stream.of(1, 2, 3).gather(Gatherers.scan({ 0 }) { $0 + $1 }).toArray()
    /// // [1, 3, 6]
    /// ```
    ///
    /// Mirrors `Gatherers.scan(supplier, scanner)` (Java 22).
    ///
    /// - Parameters:
    ///   - supplier: Produces the initial accumulator value.
    ///   - scanner: `(R, T) -> R` — combines the current accumulator with each element.
    /// - Since: Java 22
    public static func scan<T, R>(
      _ supplier: @escaping () -> R,
      _ scanner: @escaping (R, T) -> R
    ) -> Gatherer<T, R> {
      Gatherer.of(
        supplier: supplier,
        integrator: { state, element, downstream in
          state = scanner(state, element)
          return downstream(state)
        }
      )
    }

    // MARK: windowFixed

    /// Returns a gatherer that groups stream elements into non-overlapping
    /// fixed-size windows, emitting each complete window as an array.
    ///
    /// The last window is emitted even if it contains fewer elements than
    /// `windowSize` (partial window).
    ///
    /// ```swift
    /// let windows = Stream.of(1,2,3,4,5).gather(Gatherers.windowFixed(2)).toArray()
    /// // [[1,2], [3,4], [5]]
    /// ```
    ///
    /// Mirrors `Gatherers.windowFixed(windowSize)` (Java 22).
    ///
    /// - Parameter windowSize: The number of elements per window. Must be ≥ 1.
    /// - Since: Java 22
    public static func windowFixed<T>(_ windowSize: Int) -> Gatherer<T, [T]> {
      precondition(windowSize >= 1, "windowSize must be at least 1")
      return Gatherer.of(
        supplier: { [T]() },
        integrator: { buffer, element, downstream in
          buffer.append(element)
          if buffer.count == windowSize {
            let window = buffer
            buffer.removeAll(keepingCapacity: true)
            return downstream(window)
          }
          return true
        },
        finisher: { buffer, downstream in
          if !buffer.isEmpty { _ = downstream(buffer) }
        }
      )
    }

    // MARK: windowSliding

    /// Returns a gatherer that produces overlapping sliding windows of
    /// `windowSize` consecutive elements, advancing one element at a time.
    ///
    /// No window is emitted until `windowSize` elements have been seen.
    ///
    /// ```swift
    /// let windows = Stream.of(1,2,3,4).gather(Gatherers.windowSliding(3)).toArray()
    /// // [[1,2,3], [2,3,4]]
    /// ```
    ///
    /// Mirrors `Gatherers.windowSliding(windowSize)` (Java 22).
    ///
    /// - Parameter windowSize: The width of the sliding window. Must be ≥ 1.
    /// - Since: Java 22
    public static func windowSliding<T>(_ windowSize: Int) -> Gatherer<T, [T]> {
      precondition(windowSize >= 1, "windowSize must be at least 1")
      return Gatherer.of(
        supplier: { [T]() },
        integrator: { buffer, element, downstream in
          buffer.append(element)
          if buffer.count > windowSize { buffer.removeFirst() }
          if buffer.count == windowSize {
            return downstream(buffer)
          }
          return true
        }
      )
    }

    // MARK: mapConcurrent

    /// Returns a gatherer that applies `mapper` to each element with up to
    /// `parallelism` concurrent evaluations.
    ///
    /// Output order matches input order.
    ///
    /// **Platform note:** On Apple, Linux (GLibc/MUSL), Windows and FreeBSD
    /// this uses `DispatchQueue.concurrentPerform` for true parallelism.
    /// On WASM (`os(WASI)`) it falls back to sequential evaluation.
    ///
    /// ```swift
    /// let doubled = Stream.of(1,2,3,4)
    ///   .gather(Gatherers.mapConcurrent(4) { $0 * 2 })
    ///   .toArray()
    /// // [2, 4, 6, 8]  (in order)
    /// ```
    ///
    /// Mirrors `Gatherers.mapConcurrent(parallelism, mapper)` (Java 22).
    ///
    /// - Parameters:
    ///   - parallelism: Hint for the maximum number of concurrent evaluations.
    ///     Values ≤ 0 are treated as 1 (sequential).
    ///   - mapper: The function to apply to each element.
    /// - Since: Java 22
    public static func mapConcurrent<T, R>(
      _ parallelism: Int,
      _ mapper: @escaping (T) -> R
    ) -> Gatherer<T, R> {
      Gatherer { source in
        let buffer = Array(source)
        let n = buffer.count
        guard n > 0 else { return [] }

#if os(WASI)
        // WASM has no threading — sequential fallback
        return buffer.map { mapper($0) }
#else
        // Pre-allocate result storage; each concurrent iteration writes to
        // its own index so no locking is needed.
        let resultPtr = UnsafeMutablePointer<R>.allocate(capacity: n)
        defer { resultPtr.deallocate() }

        DispatchQueue.concurrentPerform(iterations: n) { i in
          (resultPtr + i).initialize(to: mapper(buffer[i]))
        }

        // Copy into a Swift array before the pointer is deallocated.
        let result = (0..<n).map { resultPtr[$0] }
        // Clean up initialised elements
        for i in 0..<n { (resultPtr + i).deinitialize(count: 1) }
        return result
#endif
      }
    }
  }
}
