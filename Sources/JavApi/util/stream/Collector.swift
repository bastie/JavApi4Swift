/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

// MARK: - Collector<T, R>

extension java.util.stream {

  /// A reduction operation that accumulates stream elements into a result.
  ///
  /// Mirrors the user-facing contract of `java.util.stream.Collector<T,?,R>` (Java 8).
  ///
  /// In Java, `Collector<T,A,R>` exposes the intermediate accumulator type `A` —
  /// a design choice that Java itself routinely hides with the wildcard `Collector<T,?,R>`.
  /// JavApi⁴Swift omits `A` from the public protocol to avoid leaking internal
  /// implementation types into the module's public API.  The behaviour is identical:
  /// call sites only care about `T` (input element type) and `R` (result type).
  ///
  /// Use ``AnyCollector`` for ad-hoc closure-based implementations, or use the
  /// ready-made factories on ``Collectors``.
  ///
  /// - Since: Java 8
  public protocol Collector<T, R> {
    /// The type of input elements to collect.
    associatedtype T
    /// The type of the collection result.
    associatedtype R

    /// Performs the complete reduction over `sequence` and returns the result.
    func collect(_ sequence: AnySequence<T>) -> R
  }
}

// MARK: - AnyCollector<T, R>

extension java.util.stream {

  /// A closure-based ``Collector`` for ad-hoc reduction operations.
  ///
  /// ```swift
  /// let sumCollector = java.util.stream.AnyCollector<Int, Int> { seq in
  ///   seq.reduce(0, +)
  /// }
  /// let sum = stream.collect(sumCollector)
  /// ```
  ///
  /// - Since: Java 8
  public struct AnyCollector<T, R>: java.util.stream.Collector {
    private let _collect: (AnySequence<T>) -> R

    /// Creates a collector from a single reduction closure.
    public init(_ collect: @escaping (AnySequence<T>) -> R) {
      _collect = collect
    }

    public func collect(_ sequence: AnySequence<T>) -> R { _collect(sequence) }
  }
}

// MARK: - Collectors

extension java.util.stream {

  /// Factory methods for common ``Collector`` implementations.
  ///
  /// Mirrors `java.util.stream.Collectors` (Java 8).
  ///
  /// - Since: Java 8
  public enum Collectors {

    // MARK: toList

    /// Returns a `Collector` that accumulates elements into a `java.util.List`.
    ///
    /// - Since: Java 8
    public static func toList<T: Equatable>()
      -> some java.util.stream.Collector<T, any java.util.List<T>>
    {
      AnyCollector<T, any java.util.List<T>> { sequence in
        let list = java.util.ArrayList<T>()
        for element in sequence { _ = try? list.add(element) }
        return list
      }
    }

    // MARK: counting

    /// Returns a `Collector` that counts the number of input elements.
    ///
    /// - Since: Java 8
    public static func counting<T>()
      -> some java.util.stream.Collector<T, Int64>
    {
      AnyCollector<T, Int64> { sequence in
        var count: Int64 = 0
        for _ in sequence { count += 1 }
        return count
      }
    }

    // MARK: joining

    /// Returns a `Collector` that concatenates `String` elements.
    ///
    /// - Parameters:
    ///   - delimiter: Inserted between each element (default: `""`).
    ///   - prefix: Prepended to the result (default: `""`).
    ///   - suffix: Appended to the result (default: `""`).
    /// - Since: Java 8
    public static func joining(
      _ delimiter: String = "",
      _ prefix: String = "",
      _ suffix: String = ""
    ) -> some java.util.stream.Collector<String, String> {
      AnyCollector<String, String> { sequence in
        var parts: [String] = []
        for s in sequence {
          if !parts.isEmpty { parts.append(delimiter) }
          parts.append(s)
        }
        return prefix + parts.joined() + suffix
      }
    }
  }
}
