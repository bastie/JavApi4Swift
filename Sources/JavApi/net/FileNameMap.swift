/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.net {

  /// A simple interface which provides a mechanism to map between a file name
  /// and a MIME type string.
  ///
  /// Mirrors `java.net.FileNameMap` (Java 1.1). A `FileNameMap` is typically
  /// obtained from `URLConnection.getFileNameMap()` and used to guess a
  /// content type from a file name's extension.
  ///
  /// - Since: JavaApi > 0.20.0 (Java 1.1)
  public protocol FileNameMap: Sendable {

    /// Returns the MIME type string for the given file name, or `nil` if it is
    /// not known.
    ///
    /// - Parameter fileName: The file name whose content type is requested.
    /// - Returns: The guessed MIME type, or `nil`.
    /// - Since: JavaApi > 0.20.0 (Java 1.1)
    func getContentTypeFor(_ fileName: String) -> String?
  }
}
