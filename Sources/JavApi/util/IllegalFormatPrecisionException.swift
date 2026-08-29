/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
extension java.util {

  /// Thrown when the precision is a negative value other than `-1`, or a
  /// value that is otherwise unsupported for the given conversion.
  ///
  /// Mirrors `java.util.IllegalFormatPrecisionException` (Java 5).
  ///
  /// - Since: Java 5
  open class IllegalFormatPrecisionException : IllegalFormatException, @unchecked Sendable {

    private let _precision: Int

    /// - Parameter precision: The illegal precision value.
    public init (_ precision: Int) {
      _precision = precision
      super.init(String(precision))
    }

    /// The illegal precision value.
    public func getPrecision () -> Int { _precision }
  }
}
