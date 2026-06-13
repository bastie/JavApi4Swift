/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

extension java.io {

  /// Input end of a character pipe, mirroring `java.io.PipedReader`.
  ///
  /// Must be connected to a ``PipedWriter`` before use.
  /// Bytes received through the `Foundation.Pipe` are decoded as UTF-8 characters.
  ///
  /// ```swift
  /// let reader = java.io.PipedReader()
  /// let writer = try java.io.PipedWriter(reader)
  /// try writer.write("Hello")
  /// try writer.flush()
  /// let line = try java.io.BufferedReader(reader).readLine()  // "Hello"
  /// ```
  ///
  /// - Since: Java 1.1
  public class PipedReader : java.io.Reader, @unchecked Sendable {
    public typealias Readable = PipedReader

    internal var pipe: Foundation.Pipe?

    /// Decoded characters waiting to be returned.
    private var charBuf: [Character] = []
    private var charPos: Int = 0

    /// Creates an unconnected `PipedReader`.
    /// - Since: Java 1.1
    public override init() {
      super.init()
    }

    /// Creates a `PipedReader` already connected to `src`.
    ///
    /// - Parameter src: The `PipedWriter` to connect to.
    /// - Throws: `IOException` if `src` is already connected.
    /// - Since: Java 1.1
    public init(_ src: PipedWriter) throws {
      super.init()
      try src.connect(self)
    }

    /// Connects this reader to `src`.
    ///
    /// - Parameter src: The `PipedWriter` to connect to.
    /// - Throws: `IOException` if already connected.
    /// - Since: Java 1.1
    public func connect(_ src: PipedWriter) throws {
      try src.connect(self)
    }

    // MARK: - Private helpers

    /// Reads available bytes from the pipe and decodes them into `charBuf`.
    /// Returns `false` if no data is available (EOF / pipe closed).
    private func refill() -> Bool {
      guard let fh = pipe?.fileHandleForReading else { return false }
      let data = fh.availableData
      guard !data.isEmpty else { return false }
      if let str = String(data: data, encoding: .utf8) {
        charBuf.append(contentsOf: str)
      }
      return charPos < charBuf.count
    }

    // MARK: - Reader overrides

    /// Reads a single character; returns -1 when no data is available.
    /// - Since: Java 1.1
    public override func read() throws -> Int {
      guard pipe != nil else { throw IOException("Pipe not connected") }
      if charPos >= charBuf.count {
        charBuf.removeAll(keepingCapacity: true)
        charPos = 0
        guard refill() else { return -1 }
      }
      let ch = charBuf[charPos]
      charPos += 1
      return Int(ch.unicodeScalars.first?.value ?? 0)
    }

    /// Reads up to `len` characters into `cbuf` starting at `offset`.
    /// - Since: Java 1.1
    public override func read(_ cbuf: inout [Character], _ offset: Int, _ len: Int) throws -> Int {
      guard pipe != nil else { throw IOException("Pipe not connected") }
      guard offset >= 0, len >= 0, offset + len <= cbuf.count else {
        throw IndexOutOfBoundsException()
      }
      if charPos >= charBuf.count {
        charBuf.removeAll(keepingCapacity: true)
        charPos = 0
        guard refill() else { return -1 }
      }
      let available = charBuf.count - charPos
      let toCopy    = Swift.min(available, len)
      cbuf[offset..<offset + toCopy] = charBuf[charPos..<charPos + toCopy]
      charPos += toCopy
      return toCopy
    }

    /// Returns `true` if decoded characters are buffered.
    /// - Since: Java 1.1
    public override func ready() throws -> Bool {
      guard pipe != nil else { throw IOException("Pipe not connected") }
      return charPos < charBuf.count
    }

    /// Closes the read end of the pipe.
    /// - Since: Java 1.1
    public override func close() throws {
      try? pipe?.fileHandleForReading.close()
    }
  }
}
