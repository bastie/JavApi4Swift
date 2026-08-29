/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
extension java.util {

  /// Thrown when the argument corresponding to a format specifier is of an
  /// incompatible type.
  ///
  /// Mirrors `java.util.IllegalFormatConversionException` (Java 5).
  ///
  /// **API deviation:** Java's constructor takes a `Class<?>` for the
  /// offending argument's type. This project's `java.lang.Class` wraps an
  /// Objective-C `AnyClass` and therefore cannot represent arbitrary Swift
  /// value types (`Int`, `String`, `Double`, …) that are the common case
  /// for format arguments. This port takes a Swift `Any.Type` instead, and
  /// exposes it as a descriptive name via `getArgumentClass()` rather than
  /// as a `java.lang.Class` instance.
  ///
  /// - Since: Java 5
  open class IllegalFormatConversionException : IllegalFormatException, @unchecked Sendable {

    private let _conversion: Character
    private let _argumentType: Any.Type

    /// - Parameters:
    ///   - conversion:   The inapplicable conversion character.
    ///   - argumentType: The Swift type of the mismatched argument.
    public init (_ conversion: Character, _ argumentType: Any.Type) {
      _conversion = conversion
      _argumentType = argumentType
      super.init("Conversion = \(conversion), provided argument type = \(String(describing: argumentType))")
    }

    /// The inapplicable conversion character.
    public func getConversion () -> Character { _conversion }

    /// The descriptive name of the mismatched argument's Swift type
    /// (see the API-deviation note on this class for why this is a
    /// `String` rather than a `java.lang.Class`).
    public func getArgumentClass () -> String { String(describing: _argumentType) }
  }
}
