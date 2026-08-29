/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
extension java.util {

  /// Common base class for all exceptions thrown when a format string
  /// contains an illegal syntax or a format specifier that is incompatible
  /// with the given arguments.
  ///
  /// Mirrors `java.util.IllegalFormatException` (Java 5). Unlike the
  /// reference JDK — where this class has only a package-private
  /// constructor and cannot be instantiated or subclassed outside
  /// `java.util` — this port exposes the usual four standard initializers,
  /// consistent with the other `RuntimeException` bases in this project.
  ///
  /// - Since: Java 5
  open class IllegalFormatException : IllegalArgumentException, @unchecked Sendable {

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
