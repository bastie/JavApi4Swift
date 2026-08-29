/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
extension java.util {

  /// Thrown when an unknown conversion character is given, i.e. a
  /// conversion character that is not one of the characters defined by
  /// `java.util.Formatter`.
  ///
  /// Mirrors `java.util.UnknownFormatConversionException` (Java 5).
  ///
  /// - Since: Java 5
  open class UnknownFormatConversionException : IllegalFormatException, @unchecked Sendable {

    private let _conversion: String

    /// - Parameter s: The unknown conversion character (or character
    ///   sequence, for `%t`/`%T` sub-specifiers).
    public override init (_ s: String) {
      _conversion = s
      super.init("Conversion = '\(s)'")
    }

    /// The unknown conversion character.
    public func getConversion () -> String { _conversion }
  }
}
