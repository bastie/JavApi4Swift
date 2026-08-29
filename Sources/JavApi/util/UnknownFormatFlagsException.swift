/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
extension java.util {

  /// Thrown when an unknown flag is given.
  ///
  /// Mirrors `java.util.UnknownFormatFlagsException` (Java 5).
  ///
  /// - Since: Java 5
  open class UnknownFormatFlagsException : IllegalFormatException, @unchecked Sendable {

    private let _flags: String

    /// - Parameter f: The set of format flags which contain an unknown flag.
    public override init (_ f: String) {
      _flags = f
      super.init("Flags = \(f)")
    }

    /// The set of format flags which contain an unknown flag.
    public func getFlags () -> String { _flags }
  }
}
