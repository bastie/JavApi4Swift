/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
extension java.util {

  /// Thrown upon attempted use of a `Formatter` that has been closed via
  /// `close()`.
  ///
  /// Unlike the `IllegalFormatException` hierarchy, this extends
  /// `IllegalStateException`, matching the real JDK.
  ///
  /// Mirrors `java.util.FormatterClosedException` (Java 5).
  ///
  /// - Since: Java 5
  open class FormatterClosedException : IllegalStateException, @unchecked Sendable {

    public override init () {
      super.init()
    }

    public override init (_ message: String) {
      super.init(message)
    }

    public override init (_ newMessage : String, _ newCause : Throwable) {
      super.init(newMessage, newCause)
    }

    public override init (_ newCause : Throwable) {
      super.init(newCause)
    }
  }
}
