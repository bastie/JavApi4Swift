/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.io {
  /// Filter for filenames, used with File.list(FilenameFilter)
  ///
  /// Mirrors `java.io.FilenameFilter` from Java 1.0.
  ///
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  public protocol FilenameFilter {
    /// Tests if a specified file should be included in a file list.
    ///
    /// - Parameters:
    ///   - dir: The directory in which the file was found.
    ///   - name: The name of the file.
    /// - Returns: `true` if the file should be included.
    func accept(_ dir: java.io.File, _ name: String) -> Bool
  }
}
