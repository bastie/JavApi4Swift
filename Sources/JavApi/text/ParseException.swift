/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.text {

  /// Signals that an error has been reached unexpectedly while parsing.
  ///
  /// - Since: Java 1.1
  open class ParseException: Exception, @unchecked Sendable {

    private let errorOffset: Int

    /// Creates a `ParseException` with the specified detail message and offset.
    ///
    /// - Parameters:
    ///   - s: The detail message.
    ///   - errorOffset: The position where the error was found while parsing.
    public init(_ s: String, _ errorOffset: Int) {
      self.errorOffset = errorOffset
      super.init(s)
    }

    /// Returns the position where the error was found.
    public func getErrorOffset() -> Int {
      return errorOffset
    }
  }
}
