/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt {

  /// Thrown when code that is dependent on a keyboard, display, or mouse is
  /// called in an environment that does not support them (headless mode).
  ///
  /// Mirrors `java.awt.HeadlessException`.
  ///
  /// - Since: JavaApi > 0.x (Java 1.4)
  open class HeadlessException: java.lang.UnsupportedOperationException, @unchecked Sendable {

    public override init() {
      super.init()
    }

    public override init(_ message: String) {
      super.init(message)
    }

    public override init(_ newMessage: String, _ newCause: Throwable) {
      super.init(newMessage, newCause)
    }

    public override init(_ newCause: Throwable) {
      super.init(newCause)
    }
  }
}
