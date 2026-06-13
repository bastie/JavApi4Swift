/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.io {

  /// A convenience `Reader` for reading character files using the default charset (UTF-8).
  ///
  /// Mirrors `java.io.FileReader` from Java 1.1. A thin wrapper around
  /// ``InputStreamReader`` over a ``FileInputStream``.
  ///
  /// ```swift
  /// let reader = try java.io.FileReader("/path/to/file.txt")
  /// let line   = try java.io.BufferedReader(reader).readLine()
  /// ```
  ///
  /// - Since: Java 1.1
  open class FileReader : InputStreamReader, @unchecked Sendable {
    public typealias Readable = FileReader

    // MARK: - Initialisers

    /// Creates a `FileReader` for the file at the given path.
    ///
    /// - Parameter fileName: The path of the file to open.
    /// - Throws: `FileNotFoundException` if the file does not exist or cannot be opened.
    /// - Since: Java 1.1
    public init(_ fileName: String) throws {
      let fis = try java.io.FileInputStream(fileName)
      super.init(fis)
    }

    /// Creates a `FileReader` for the given `File` object.
    ///
    /// - Parameter file: The `File` to open.
    /// - Throws: `FileNotFoundException` if the file does not exist or cannot be opened.
    /// - Since: Java 1.1
    public init(_ file: java.io.File) throws {
      let fis = try java.io.FileInputStream(file)
      super.init(fis)
    }
  }
}
