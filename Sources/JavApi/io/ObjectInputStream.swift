/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.io {

  /// Deserializes primitive data and objects previously written with
  /// ``ObjectOutputStream``.
  ///
  /// Mirrors `java.io.ObjectInputStream`.  In JavApi⁴Swift, full object-graph
  /// deserialization is **not** implemented.  The class exists so that ported
  /// Java code compiles; `readObject()` always throws
  /// ``NotActiveException``.
  ///
  /// - Since: Java 1.1
  public class ObjectInputStream : InputStream {

    private let source: InputStream

    /// Creates an `ObjectInputStream` that reads from `inputStream`.
    ///
    /// - Parameter inputStream: The underlying byte source.
    /// - Since: Java 1.1
    public init(_ inputStream: InputStream) throws {
      self.source = inputStream
      super.init()
    }

    // MARK: - InputStream overrides

    public override func read() throws -> Int {
      return try source.read()
    }

    public override func close() throws {
      try source.close()
    }

    // MARK: - Object deserialization (stub)

    /// Reads the next object from the stream.
    ///
    /// - Throws: ``NotActiveException`` — not yet implemented.
    /// - Since: Java 1.1
    public func readObject() throws -> AnyObject? {
      throw NotActiveException("ObjectInputStream.readObject() is not implemented")
    }

    // MARK: - Validation

    /// Registers a callback for post-deserialization validation.
    ///
    /// Stored but never called in this stub implementation.
    ///
    /// - Since: Java 1.1
    public func registerValidation(_ obj: ObjectInputValidation, _ prio: Int) throws {
      // stub: validation callbacks are not invoked in this implementation
    }
  }
}
