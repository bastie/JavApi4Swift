/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
extension java.util {

  /// Thrown when a character with an invalid Unicode code point, as defined
  /// by `Character.isValidCodePoint(Int)`, is passed to the `%c` conversion.
  ///
  /// Mirrors `java.util.IllegalFormatCodePointException` (Java 5).
  ///
  /// - Since: Java 5
  open class IllegalFormatCodePointException : IllegalFormatException, @unchecked Sendable {

    private let _codePoint: Int

    /// - Parameter codePoint: The invalid Unicode code point.
    public init (_ codePoint: Int) {
      _codePoint = codePoint
      super.init("Code point = 0x" + String(codePoint, radix: 16, uppercase: true))
    }

    /// The invalid Unicode code point.
    public func getCodePoint () -> Int { _codePoint }
  }
}
