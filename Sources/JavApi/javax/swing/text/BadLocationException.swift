/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.text {

  /// Thrown when a `Document` operation is given an invalid offset or range.
  ///
  /// - Since: Java 1.2
  public final class BadLocationException: java.lang.Exception, @unchecked Sendable {

    /// The invalid offset that caused this exception.
    public let offsetRequestedJ: Int

    public init(_ message: String, _ offset: Int) {
      self.offsetRequestedJ = offset
      super.init(message)
    }

    /// Returns the invalid offset.
    public func offsetRequested() -> Int { offsetRequestedJ }
  }
}
