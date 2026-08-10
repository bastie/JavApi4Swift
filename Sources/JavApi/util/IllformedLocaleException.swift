/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.util {

  /// Thrown by `Locale.Builder` when a locale or subtag is syntactically invalid.
  ///
  /// - Since: Java 7
  open class IllformedLocaleException : RuntimeException, @unchecked Sendable {

    private let _errorIndex: Int

    /// Creates an `IllformedLocaleException` with the given message and error index.
    ///
    /// - Parameters:
    ///   - message: A human-readable description of the problem.
    ///   - errorIndex: The index in the input string where the problem was detected,
    ///                 or -1 if the index is not applicable.
    public init(_ message: String, _ errorIndex: Int) {
      self._errorIndex = errorIndex
      super.init(message)
    }

    /// Creates an `IllformedLocaleException` without a specific error index (-1).
    public convenience override init(_ message: String) {
      self.init(message, -1)
    }

    /// Returns the index in the input string at which the error was found,
    /// or -1 if the index is not applicable.
    public func getErrorIndex() -> Int {
      return _errorIndex
    }
  }
}
