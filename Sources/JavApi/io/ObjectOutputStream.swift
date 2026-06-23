/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.io {

  /// Serializes primitive data and objects to an `OutputStream`.
  ///
  /// Mirrors `java.io.ObjectOutputStream`.  In JavApi⁴Swift, full object-graph
  /// serialization is **not** implemented.  The class exists so that ported
  /// Java code compiles; `writeObject(_:)` always throws
  /// ``NotActiveException``.
  ///
  /// - Since: Java 1.1
  public class ObjectOutputStream : OutputStream {

    private let sink: OutputStream

    /// Creates an `ObjectOutputStream` that writes to `outputStream`.
    ///
    /// - Parameter outputStream: The underlying byte sink.
    /// - Since: Java 1.1
    public init(_ outputStream: OutputStream) throws {
      self.sink = outputStream
      super.init()
    }

    // MARK: - OutputStream overrides

    public override func write(_ b: Int) throws {
      try sink.write(b)
    }

    public override func flush() throws {
      try sink.flush()
    }

    public override func close() throws {
      try sink.close()
    }

    // MARK: - Object serialization (stub)

    /// Writes an object to the stream.
    ///
    /// - Throws: ``NotActiveException`` — not yet implemented.
    /// - Since: Java 1.1
    public func writeObject(_ obj: AnyObject?) throws {
      throw NotActiveException("ObjectOutputStream.writeObject() is not implemented")
    }
  }
}
