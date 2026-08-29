/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
extension java.util {

  /// Thrown when a conversion and a flag are incompatible with one another.
  ///
  /// Mirrors `java.util.FormatFlagsConversionMismatchException` (Java 5).
  ///
  /// - Since: Java 5
  open class FormatFlagsConversionMismatchException : IllegalFormatException, @unchecked Sendable {

    private let _flag: String
    private let _conversion: Character

    /// - Parameters:
    ///   - flag:       The incompatible flag.
    ///   - conversion: The conversion character.
    public init (_ flag: String, _ conversion: Character) {
      _flag = flag
      _conversion = conversion
      super.init("Conversion = \(conversion), Flags = \(flag)")
    }

    /// The incompatible flag.
    public func getFlags () -> String { _flag }

    /// The conversion character.
    public func getConversion () -> Character { _conversion }
  }
}
