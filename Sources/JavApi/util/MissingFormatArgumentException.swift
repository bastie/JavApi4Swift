/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
extension java.util {

  /// Thrown when there is a format specifier which has no corresponding
  /// argument, or whose index refers to an argument that does not exist.
  ///
  /// Mirrors `java.util.MissingFormatArgumentException` (Java 5).
  ///
  /// - Since: Java 5
  open class MissingFormatArgumentException : IllegalFormatException, @unchecked Sendable {

    private let _formatSpecifier: String

    /// - Parameter s: The specifier that has no corresponding argument.
    public override init (_ s: String) {
      _formatSpecifier = s
      super.init("Format specifier '\(s)'")
    }

    /// The specifier that has no corresponding argument.
    public func getFormatSpecifier () -> String { _formatSpecifier }
  }
}
