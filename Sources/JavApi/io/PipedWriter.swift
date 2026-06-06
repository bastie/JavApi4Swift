/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

extension java.io {

  /// Output end of a character pipe, mirroring `java.io.PipedWriter`.
  ///
  /// Must be connected to a ``PipedReader`` before use.
  /// Characters are encoded as UTF-8 bytes and written through a `Foundation.Pipe`.
  ///
  /// ```swift
  /// let reader = java.io.PipedReader()
  /// let writer = try java.io.PipedWriter(reader)
  /// try writer.write("Hello")
  /// try writer.flush()
  /// let line = try java.io.BufferedReader(reader).readLine()  // "Hello"
  /// ```
  ///
  /// - Since: JavaApi (Java 1.1)
  public class PipedWriter : java.io.Writer, @unchecked Sendable {

    internal var pipe: Foundation.Pipe?
    private var connected: PipedReader?

    /// Creates an unconnected `PipedWriter`.
    /// - Since: JavaApi (Java 1.1)
    public override init() {
      super.init()
    }

    /// Creates a `PipedWriter` already connected to `snk`.
    ///
    /// - Parameter snk: The `PipedReader` to connect to.
    /// - Throws: `IOException` if `snk` is already connected.
    /// - Since: JavaApi (Java 1.1)
    public init(_ snk: PipedReader) throws {
      super.init()
      try connect(snk)
    }

    /// Connects this writer to `snk`.
    ///
    /// - Parameter snk: The `PipedReader` to connect to.
    /// - Throws: `IOException` if already connected.
    /// - Since: JavaApi (Java 1.1)
    public func connect(_ snk: PipedReader) throws {
      guard connected == nil else { throw IOException("Already connected") }
      let p = Foundation.Pipe()
      self.pipe      = p
      snk.pipe       = p
      self.connected = snk
    }

    // MARK: - Writer overrides

    /// Writes `len` characters from `cbuf` starting at `offset`.
    /// - Since: JavaApi (Java 1.1)
    public override func write(_ cbuf: [Character], _ offset: Int, _ len: Int) throws {
      guard let fh = pipe?.fileHandleForWriting else {
        throw IOException("Pipe not connected")
      }
      guard offset >= 0, len >= 0, offset + len <= cbuf.count else {
        throw IndexOutOfBoundsException()
      }
      let str = String(cbuf[offset..<offset + len])
      guard let data = str.data(using: .utf8) else {
        throw IOException("Cannot encode characters as UTF-8")
      }
      fh.write(data)
    }

    /// Writes a single character.
    /// - Since: JavaApi (Java 1.1)
    public override func write(_ oneChar: Character) throws {
      guard let fh = pipe?.fileHandleForWriting else {
        throw IOException("Pipe not connected")
      }
      guard let data = String(oneChar).data(using: .utf8) else {
        throw IOException("Cannot encode character as UTF-8")
      }
      fh.write(data)
    }

    /// Flushes — no-op since `Foundation.Pipe` writes are immediate.
    /// - Since: JavaApi (Java 1.1)
    public override func flush() throws {
      guard pipe != nil else { throw IOException("Pipe not connected") }
    }

    /// Closes the write end of the pipe.
    /// - Since: JavaApi (Java 1.1)
    public override func close() throws {
      try? pipe?.fileHandleForWriting.close()
    }
  }
}
