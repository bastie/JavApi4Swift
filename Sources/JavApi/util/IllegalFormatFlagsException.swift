/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
extension java.util {

  /// Thrown when an illegal combination of flags is given in a format
  /// specifier.
  ///
  /// Mirrors `java.util.IllegalFormatFlagsException` (Java 5).
  ///
  /// - Since: Java 5
  open class IllegalFormatFlagsException : IllegalFormatException, @unchecked Sendable {

    private let _flags: String

    /// - Parameter flags: The illegal combination of flags.
    public override init (_ flags: String) {
      _flags = flags
      super.init("Flags = '\(flags)'")
    }

    /// The illegal combination of flags.
    public func getFlags () -> String { _flags }
  }
}
