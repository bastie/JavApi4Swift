/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
extension java.util {

  /// Thrown when the format width is a negative value other than `-1`, or a
  /// value that is otherwise unsupported.
  ///
  /// Mirrors `java.util.IllegalFormatWidthException` (Java 5).
  ///
  /// - Since: Java 5
  open class IllegalFormatWidthException : IllegalFormatException, @unchecked Sendable {

    private let _width: Int

    /// - Parameter width: The illegal width value.
    public init (_ width: Int) {
      _width = width
      super.init(String(width))
    }

    /// The illegal width value.
    public func getWidth () -> Int { _width }
  }
}
