/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: Apache-2.0
 */

// MARK: - Gatherer<T, R> (Java 22, finalised in Java 24)

extension java.util.stream {

  /// A composable stateful transformation of a stream of elements.
  ///
  /// Mirrors `java.util.stream.Gatherer<T, A, R>` (Java 22–24).
  ///
  /// The intermediate accumulator type `A` is hidden inside the implementation
  /// closures — matching how Java itself exposes `Gatherer<T, ?, R>` at usage
  /// sites. Only the input element type `T` and output element type `R` are
  /// visible in the public API.
  ///
  /// Use the factory methods ``of(integrator:)``, ``of(supplier:integrator:)``,
  /// ``of(supplier:integrator:finisher:)``, or ``ofSequential(_:_:)`` to create
  /// instances, or use the ready-made gatherers from ``Gatherers``.
  ///
  /// Compose two gatherers with ``andThen(_:)``.
  ///
  /// ```swift
  /// // Running sum via scan
  /// let runningSum = java.util.stream.Gatherers.scan({ 0 }) { acc, x in acc + x }
  /// let result = java.util.stream.Stream.of(1, 2, 3, 4)
  ///   .gather(runningSum)
  ///   .toArray()
  /// // [1, 3, 6, 10]
  /// ```
  ///
  /// - Since: Java 22 (finalised in Java 24)
  public struct Gatherer<T, R> {

    // The entire logic — source sequence → output array — lives in one closure.
    // This erases the intermediate state type `A`, matching the Java `?` wildcard.
    internal let _process: (AnySequence<T>) -> [R]

    // MARK: - Factory methods

    /// Creates a stateless gatherer driven by `integrator` alone.
    ///
    /// The integrator receives each source element and a `downstream` closure it
    /// can call zero or more times to push output elements. Return `true` to
    /// continue processing, `false` to stop the stream early (short-circuit).
    ///
    /// - Parameter integrator: `(T, (R) -> Bool) -> Bool`
    /// - Since: Java 22
    public static func of(
      integrator: @escaping (T, (R) -> Bool) -> Bool
    ) -> Gatherer<T, R> {
      Gatherer { source in
        var results: [R] = []
        let downstream: (R) -> Bool = { r in results.append(r); return true }
        for element in source {
          if !integrator(element, downstream) { break }
        }
        return results
      }
    }

    /// Creates a stateful gatherer with `supplier` (initial state) and `integrator`.
    ///
    /// - Parameters:
    ///   - supplier: Produces the initial mutable state `A`.
    ///   - integrator: `(inout A, T, (R) -> Bool) -> Bool`
    /// - Since: Java 22
    public static func of<A>(
      supplier: @escaping () -> A,
      integrator: @escaping (inout A, T, (R) -> Bool) -> Bool
    ) -> Gatherer<T, R> {
      Gatherer { source in
        var state = supplier()
        var results: [R] = []
        let downstream: (R) -> Bool = { r in results.append(r); return true }
        for element in source {
          if !integrator(&state, element, downstream) { break }
        }
        return results
      }
    }

    /// Creates a stateful gatherer with `supplier`, `integrator`, and `finisher`.
    ///
    /// The finisher is called after all source elements are processed and may push
    /// additional output elements (e.g. flush a partial buffer).
    ///
    /// - Parameters:
    ///   - supplier: Produces the initial mutable state `A`.
    ///   - integrator: `(inout A, T, (R) -> Bool) -> Bool`
    ///   - finisher: `(inout A, (R) -> Bool) -> Void`
    /// - Since: Java 22
    public static func of<A>(
      supplier: @escaping () -> A,
      integrator: @escaping (inout A, T, (R) -> Bool) -> Bool,
      finisher: @escaping (inout A, (R) -> Bool) -> Void
    ) -> Gatherer<T, R> {
      Gatherer { source in
        var state = supplier()
        var results: [R] = []
        let downstream: (R) -> Bool = { r in results.append(r); return true }
        for element in source {
          if !integrator(&state, element, downstream) { break }
        }
        finisher(&state, downstream)
        return results
      }
    }

    /// Creates a sequential-only stateless gatherer driven by `integrator`.
    ///
    /// Equivalent to ``of(integrator:)`` — documents that no combiner is provided.
    ///
    /// - Since: Java 22
    public static func ofSequential(
      _ integrator: @escaping (T, (R) -> Bool) -> Bool
    ) -> Gatherer<T, R> {
      of(integrator: integrator)
    }

    /// Creates a sequential-only stateful gatherer.
    ///
    /// Equivalent to ``of(supplier:integrator:)`` — documents that no combiner is provided.
    ///
    /// - Since: Java 22
    public static func ofSequential<A>(
      _ supplier: @escaping () -> A,
      _ integrator: @escaping (inout A, T, (R) -> Bool) -> Bool
    ) -> Gatherer<T, R> {
      of(supplier: supplier, integrator: integrator)
    }

    /// Creates a sequential-only stateful gatherer with a finisher.
    ///
    /// - Since: Java 22
    public static func ofSequential<A>(
      _ supplier: @escaping () -> A,
      _ integrator: @escaping (inout A, T, (R) -> Bool) -> Bool,
      _ finisher: @escaping (inout A, (R) -> Bool) -> Void
    ) -> Gatherer<T, R> {
      of(supplier: supplier, integrator: integrator, finisher: finisher)
    }

    // MARK: - Composition

    /// Returns a composed gatherer that first applies this gatherer and then
    /// applies `downstream` to each output element.
    ///
    /// Mirrors `Gatherer.andThen(Gatherer<? super R, ?, RR>)` (Java 22).
    ///
    /// - Parameter downstream: A gatherer to apply to this gatherer's output.
    /// - Returns: A composed gatherer whose output type is `V`.
    /// - Since: Java 22
    public func andThen<V>(_ downstream: Gatherer<R, V>) -> Gatherer<T, V> {
      let first = self
      let second = downstream
      return Gatherer<T, V> { source in
        let intermediate = first._process(source)
        return second._process(AnySequence(intermediate))
      }
    }
  }
}
