/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.io {

  /// Abstract base class for writers that wrap another `Writer`.
  ///
  /// Mirrors `java.io.FilterWriter` from Java 1.1. All methods delegate to the
  /// underlying `Writer` stored in ``out``. Subclasses override individual methods
  /// to add filtering behaviour. Character-stream counterpart to ``FilterOutputStream``.
  ///
  /// - Since: JavaApi (Java 1.1)
  open class FilterWriter : Writer, @unchecked Sendable {

    /// The underlying writer.
    public var out: java.io.Writer

    /// Creates a `FilterWriter` wrapping `writer`.
    ///
    /// - Parameter writer: The underlying `Writer`.
    /// - Since: JavaApi (Java 1.1)
    public init(_ writer: java.io.Writer) {
      self.out = writer
      super.init()
    }

    // MARK: - Writer overrides (all delegate to `out`)

    /// - Since: JavaApi (Java 1.1)
    public override func write(_ oneChar: Character) throws {
      try out.write(oneChar)
    }

    /// - Since: JavaApi (Java 1.1)
    public override func write(_ cbuf: [Character], _ offset: Int, _ count: Int) throws {
      try out.write(cbuf, offset, count)
    }

    /// - Since: JavaApi (Java 1.1)
    public override func write(_ str: String, _ offset: Int, _ count: Int) throws {
      try out.write(str, offset, count)
    }

    /// - Since: JavaApi (Java 1.1)
    public override func flush() throws {
      try out.flush()
    }

    /// - Since: JavaApi (Java 1.1)
    public override func close() throws {
      try out.close()
    }
  }
}
