/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.io {

  /// An `InputStream` that reads sequentially from two or more streams.
  ///
  /// Mirrors `java.io.SequenceInputStream` from Java 1.0. When the first
  /// stream reaches end-of-stream it is closed and reading continues from
  /// the next stream.
  ///
  /// When constructed with an `Enumeration`, streams are fetched **lazily**
  /// as each preceding stream is exhausted — matching Java's original
  /// behaviour. This means the enumeration is not drained at construction
  /// time, so lazy or side-effect-producing enumerations work correctly.
  ///
  /// ```swift
  /// let a = java.io.ByteArrayInputStream([1, 2, 3])
  /// let b = java.io.ByteArrayInputStream([4, 5, 6])
  /// let seq = java.io.SequenceInputStream(a, b)
  /// // reads 1, 2, 3, 4, 5, 6
  /// ```
  ///
  /// - Since: JavaApi (Java 1.0)
  open class SequenceInputStream : InputStream {

    // MARK: - Storage

    /// Remaining streams from the enumeration (lazy path), or `nil` when the
    /// two-stream constructor was used.
    private var enumeration: (any java.util.Enumeration<java.io.InputStream>)?

    /// Current active stream.
    private var currentStream: java.io.InputStream?

    // MARK: - Initialisers

    /// Creates a `SequenceInputStream` from two streams.
    ///
    /// - Parameters:
    ///   - s1: The first stream to read from.
    ///   - s2: The second stream to read from after `s1` is exhausted.
    /// - Since: JavaApi (Java 1.0)
    public init(_ s1: java.io.InputStream, _ s2: java.io.InputStream) {
      // Wrap both streams in a simple array-backed enumeration so the
      // same lazy advance logic works for both constructors.
      enumeration = TwoStreamEnumeration(s1, s2)
      currentStream = nil
      super.init()
      advance()
    }

    /// Creates a `SequenceInputStream` from an `Enumeration` of streams.
    ///
    /// Streams are fetched **lazily** from `e` — `nextElement()` is only
    /// called when the previous stream reaches end-of-stream, matching Java
    /// semantics exactly.
    ///
    /// - Parameter e: An enumeration of `InputStream` instances.
    /// - Since: JavaApi (Java 1.0)
    public init(_ e: any java.util.Enumeration<java.io.InputStream>) {
      enumeration = e
      currentStream = nil
      super.init()
      advance()
    }

    // MARK: - Private helpers

    /// Closes the current stream and fetches the next one from the enumeration.
    private func advance() {
      try? currentStream?.close()
      currentStream = nil
      guard var e = enumeration else { return }
      guard e.hasMoreElements() else {
        enumeration = nil
        return
      }
      currentStream = try? e.nextElement()
      enumeration = e   // write back — Swift value-type copy needs re-assignment
    }

    // MARK: - InputStream overrides

    /// Reads a single byte from the current stream, advancing to the next when exhausted.
    ///
    /// - Returns: The byte value (0–255), or -1 when all streams are exhausted.
    /// - Since: JavaApi (Java 1.0)
    public override func read() throws -> Int {
      while let stream = currentStream {
        let b = try stream.read()
        if b != -1 { return b }
        advance()
      }
      return -1
    }

    /// Reads up to `length` bytes into `array` starting at `offset`.
    /// - Since: Java 1.0
    public override func read(_ array: inout [UInt8], _ offset: Int, _ length: Int) throws -> Int {
      guard offset >= 0, length >= 0, offset + length <= array.count else {
        throw IOException("", IndexOutOfBoundsException())
      }
      guard length > 0 else { return 0 }

      while let stream = currentStream {
        let n = try stream.read(&array, offset, length)
        if n > 0 { return n }
        advance()
      }
      return -1
    }

    /// Returns the number of bytes available in the current stream.
    /// - Since: JavaApi (Java 1.0)
    public override func available() throws -> Int {
      guard let stream = currentStream else { return 0 }
      return try stream.available()
    }

    /// Closes the current stream and discards the enumeration.
    /// - Since: JavaApi (Java 1.0)
    public override func close() throws {
      // Drain and close all remaining streams
      while currentStream != nil {
        advance()
      }
      enumeration = nil
    }
  }
}

// MARK: - Internal helper

/// A two-element `Enumeration` used by the two-stream constructor.
private final class TwoStreamEnumeration : java.util.Enumeration {
  public typealias Element = java.io.InputStream

  private var streams: [java.io.InputStream]
  private var index: Int = 0

  init(_ s1: java.io.InputStream, _ s2: java.io.InputStream) {
    streams = [s1, s2]
  }

  public func hasMoreElements() -> Bool { return index < streams.count }

  public func nextElement() throws -> java.io.InputStream {
    guard index < streams.count else { throw java.util.NoSuchElementException() }
    defer { index += 1 }
    return streams[index]
  }

  public func next() -> java.io.InputStream? {
    guard hasMoreElements() else { return nil }
    return try? nextElement()
  }

  public func makeIterator() -> TwoStreamEnumeration { return self }
}
