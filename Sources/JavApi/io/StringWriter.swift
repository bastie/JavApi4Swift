/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.io {

  /// A `Writer` that writes characters into a `StringBuffer`.
  ///
  /// Mirrors `java.io.StringWriter` from Java 1.1. The buffer grows
  /// automatically; `close()` and `flush()` are no-ops and never throw.
  ///
  /// ```swift
  /// let sw = java.io.StringWriter()
  /// try sw.write("Hello")
  /// try sw.write(", World!")
  /// print(sw.toString())   // "Hello, World!"
  /// ```
  ///
  /// - Since: JavaApi (Java 1.1)
  open class StringWriter : Writer, @unchecked Sendable {

    private var buf: StringBuffer

    // MARK: - Initialisers

    /// Creates a `StringWriter` with a default initial buffer capacity (16).
    ///
    /// - Since: JavaApi (Java 1.1)
    public override init() {
      buf = StringBuffer()
      super.init()
    }

    /// Creates a `StringWriter` with the given initial buffer capacity.
    ///
    /// - Parameter initialSize: The initial capacity hint (≥ 0).
    /// - Since: JavaApi (Java 1.1)
    public init(_ initialSize: Int) {
      buf = StringBuffer(initialSize)
      super.init()
    }

    // MARK: - Writer overrides

    /// Writes a single character (low 16 bits of `oneChar`).
    /// - Since: JavaApi (Java 1.1)
    public override func write(_ oneChar: Character) throws {
      buf.append(oneChar)
    }

    /// Writes `len` characters from `c` starting at `offset`.
    /// - Since: JavaApi (Java 1.1)
    public override func write(_ c: [Character], _ offset: Int, _ len: Int) throws {
      guard offset >= 0, len >= 0, offset + len <= c.count else {
        throw IndexOutOfBoundsException()
      }
      if len == 0 { return }
      buf.append(String(c[offset..<offset + len]))
    }

    /// Writes the entire string `str`.
    /// - Since: JavaApi (Java 1.1)
    public override func write(_ str: String) throws {
      buf.append(str)
    }

    /// Writes `len` characters from `str` starting at `offset`.
    /// - Since: JavaApi (Java 1.1)
    public override func write(_ str: String, _ offset: Int, _ len: Int) throws {
      guard offset >= 0, len >= 0, offset + len <= str.count else {
        throw StringIndexOutOfBoundsException(-1)
      }
      buf.append(str.substring(offset, offset + len))
    }

    // MARK: - append (fluent)

    /// Appends `c` and returns `self`.
    /// - Since: JavaApi (Java 1.1)
    @discardableResult
    public override func append(_ c: Character) throws -> StringWriter {
      buf.append(c)
      return self
    }

    /// Appends `csq` (or `"null"`) and returns `self`.
    /// - Since: JavaApi (Java 1.1)
    @discardableResult
    public override func append(_ csq: (any CharSequence)?) throws -> StringWriter {
      buf.append(csq?.toString() ?? TOKEN_NULL)
      return self
    }

    /// Appends the subsequence `csq[start..<end]` (or from `"null"`) and returns `self`.
    /// - Since: JavaApi (Java 1.1)
    @discardableResult
    public override func append(_ csq: (any CharSequence)?, _ start: Int, _ end: Int) throws -> StringWriter {
      let s = csq?.toString() ?? TOKEN_NULL
      guard start >= 0, end >= 0, start <= end, end <= s.count else {
        throw IndexOutOfBoundsException()
      }
      buf.append(s.substring(start, end))
      return self
    }

    // MARK: - StringWriter-specific API

    /// Returns the internal `StringBuffer`.
    ///
    /// - Returns: The buffer accumulated so far.
    /// - Since: JavaApi (Java 1.1)
    public func getBuffer() -> StringBuffer {
      return buf
    }

    /// Returns the accumulated characters as a `String`.
    /// - Since: JavaApi (Java 1.1)
    public func toString() -> String {
      return buf.toString()
    }

    // MARK: - No-op lifecycle

    /// No-op — `StringWriter` has no underlying resource.
    /// - Since: JavaApi (Java 1.1)
    public override func flush() throws { /* no-op */ }

    /// No-op — `StringWriter` has no underlying resource.
    /// - Since: JavaApi (Java 1.1)
    public override func close() throws { /* no-op */ }
  }
}
