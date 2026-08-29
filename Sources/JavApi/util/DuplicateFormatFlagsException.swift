/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
extension java.util {

  /// Thrown when a format string contains a flag character more than once.
  ///
  /// Mirrors `java.util.DuplicateFormatFlagsException` (Java 5).
  ///
  /// - Since: Java 5
  open class DuplicateFormatFlagsException : IllegalFormatException, @unchecked Sendable {

    private let _flags: String

    /// - Parameter flags: The set of duplicate flags, as they appeared in
    ///   the offending format specifier.
    public override init (_ flags: String) {
      _flags = flags
      super.init("Flags = '\(flags)'")
    }

    /// The set of duplicate flags.
    public func getFlags () -> String { _flags }
  }
}
