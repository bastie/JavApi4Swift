/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
extension java.util {

  /// Thrown when the format width is required but is not provided in the
  /// format specifier.
  ///
  /// Mirrors `java.util.MissingFormatWidthException` (Java 5).
  ///
  /// - Since: Java 5
  open class MissingFormatWidthException : IllegalFormatException, @unchecked Sendable {

    private let _formatSpecifier: String

    /// - Parameter s: The specifier that is missing a width.
    public override init (_ s: String) {
      _formatSpecifier = s
      super.init(s)
    }

    /// The specifier that is missing a width.
    public func getFormatSpecifier () -> String { _formatSpecifier }
  }
}
