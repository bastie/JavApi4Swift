/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

extension java.io {

  /// Output end of a pipe, mirroring `java.io.PipedOutputStream`.
  ///
  /// Must be connected to a `PipedInputStream` before use.
  /// Backed by `Foundation.Pipe`.
  public class PipedOutputStream : java.io.OutputStream {

    internal var pipe: Foundation.Pipe?
    private var connected: PipedInputStream?

    public override init() {}

    /// Creates a `PipedOutputStream` already connected to `snk`.
    public init(_ snk: PipedInputStream) throws(IOException) {
      super.init()
      try connect(snk)
    }

    /// Connects this output stream to `snk`.
    public func connect(_ snk: PipedInputStream) throws(IOException) {
      guard connected == nil else { throw IOException("Already connected") }
      let p = Foundation.Pipe()
      self.pipe = p
      snk.pipe = p
      self.connected = snk
    }

    public override func write(_ b: Int) throws {
      guard let fh = pipe?.fileHandleForWriting else {
        throw IOException("Pipe not connected")
      }
      let byte = UInt8(b & 0xFF)
      fh.write(Data([byte]))
    }

    public override func write(_ b: [UInt8], _ off: Int, _ len: Int) throws {
      guard let fh = pipe?.fileHandleForWriting else {
        throw IOException("Pipe not connected")
      }
      fh.write(Data(b[off..<(off + len)]))
    }

    public override func close() throws {
      try? pipe?.fileHandleForWriting.close()
    }
  }
}
