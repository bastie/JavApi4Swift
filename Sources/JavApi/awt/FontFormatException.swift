/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt {

  /// Thrown when a font file cannot be parsed.
  ///
  /// Mirrors `java.awt.FontFormatException`.
  ///
  /// - Since: JavaApi > 0.x (Java 1.2)
  open class FontFormatException: java.lang.Exception, @unchecked Sendable {

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
