/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.io {

  /// Abstract base class for readers that wrap another `Reader`.
  ///
  /// Mirrors `java.io.FilterReader` from Java 1.1. All methods delegate to the
  /// underlying `Reader` stored in ``in``. Subclasses override individual methods
  /// to add filtering behaviour. Character-stream counterpart to ``FilterInputStream``.
  ///
  /// - Since: JavaApi (Java 1.1)
  open class FilterReader : Reader, @unchecked Sendable {

    /// The underlying reader.
    public var `in`: java.io.Reader

    /// Creates a `FilterReader` wrapping `reader`.
    ///
    /// - Parameter reader: The underlying `Reader`.
    /// - Since: JavaApi (Java 1.1)
    public init(_ reader: java.io.Reader) {
      self.in = reader
      super.init()
    }

    // MARK: - Reader overrides (all delegate to `in`)

    /// - Since: JavaApi (Java 1.1)
    public override func read() throws -> Int {
      return try `in`.read()
    }

    /// - Since: JavaApi (Java 1.1)
    public override func read(_ cbuf: inout [Character], _ offset: Int, _ count: Int) throws -> Int {
      return try `in`.read(&cbuf, offset, count)
    }

    /// - Since: JavaApi (Java 1.1)
    public override func skip(_ count: Int64) throws -> Int64 {
      return try `in`.skip(count)
    }

    /// - Since: JavaApi (Java 1.1)
    public override func ready() throws -> Bool {
      return try `in`.ready()
    }

    /// - Since: JavaApi (Java 1.1)
    public override func markSupported() -> Bool {
      return `in`.markSupported()
    }

    /// - Since: JavaApi (Java 1.1)
    public override func mark(_ readAheadLimit: Int) throws {
      try `in`.mark(readAheadLimit)
    }

    /// - Since: JavaApi (Java 1.1)
    public override func reset() throws {
      try `in`.reset()
    }

    /// - Since: JavaApi (Java 1.1)
    public override func close() throws {
      try `in`.close()
    }
  }
}
