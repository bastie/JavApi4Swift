/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt {

  /// Thrown when an AWT component is not in an appropriate state for the
  /// requested operation — mirrors `java.awt.IllegalComponentStateException`.
  ///
  /// Typical example: calling `getLocale()` on a component that has not yet
  /// been added to a container with a locale set.
  ///
  /// - Since: Java 1.1
  public class IllegalComponentStateException : IllegalStateException, @unchecked Sendable {

    public override init(_ message: String = "") {
      super.init(message)
    }
  }
}
