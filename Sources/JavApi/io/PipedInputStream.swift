/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

extension java.io {

  /// Input end of a pipe, mirroring `java.io.PipedInputStream`.
  ///
  /// Must be connected to a `PipedOutputStream` before use.
  /// Backed by `Foundation.Pipe`.
  public class PipedInputStream : java.io.InputStream {

    internal var pipe: Foundation.Pipe?

    public override init() {}

    /// Creates a `PipedInputStream` already connected to `src`.
    public init(_ src: PipedOutputStream) throws(IOException) {
      super.init()
      try src.connect(self)
    }

    /// Connects this input stream to `src`.
    public func connect(_ src: PipedOutputStream) throws(IOException) {
      try src.connect(self)
    }

    public override func read() throws (IOException) -> Int {
      guard let fh = pipe?.fileHandleForReading else {
        throw IOException("Pipe not connected")
      }
      let data = fh.availableData
      if data.isEmpty { return -1 }
      return Int(data[0])
    }

    public override func read(_ b: inout [UInt8], _ off: Int, _ len: Int) throws (IOException) -> Int {
      guard let fh = pipe?.fileHandleForReading else {
        throw IOException("Pipe not connected")
      }
      let data = fh.availableData
      if data.isEmpty { return -1 }
      let count = Swift.min(len, data.count)
      data.copyBytes(to: &b[off], count: count)
      return count
    }

    public override func close() throws {
      try? pipe?.fileHandleForReading.close()
    }
  }
}
