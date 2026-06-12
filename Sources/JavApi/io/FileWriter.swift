/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.io {

  /// A convenience `Writer` for writing character files using the default charset (UTF-8).
  ///
  /// Mirrors `java.io.FileWriter` from Java 1.1. A thin wrapper around
  /// ``OutputStreamWriter`` over a ``FileOutputStream``.
  ///
  /// ```swift
  /// let writer = try java.io.FileWriter("/path/to/file.txt")
  /// let bw     = java.io.BufferedWriter(writer)
  /// try bw.write("Hello, World!")
  /// try bw.flush()
  /// ```
  ///
  /// - Since: JavaApi (Java 1.1)
  open class FileWriter : OutputStreamWriter, @unchecked Sendable {

    // MARK: - Initialisers

    /// Creates a `FileWriter` for the file at the given path (overwrites existing content).
    ///
    /// - Parameter fileName: The path of the file to open or create.
    /// - Throws: `IOException` if the file cannot be opened for writing.
    /// - Since: Java 1.1
    public init(_ fileName: String) throws {
      let fos = try java.io.FileOutputStream(fileName)
      super.init(fos)
    }

    /// Creates a `FileWriter` for the given `File` object (overwrites existing content).
    ///
    /// - Parameter file: The `File` to open or create.
    /// - Throws: `IOException` if the file cannot be opened for writing.
    /// - Since: Java 1.1
    public init(_ file: java.io.File) throws {
      let fos = try java.io.FileOutputStream(file)
      super.init(fos)
    }
  }
}
