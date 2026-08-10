/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.util {

  /// Thrown when the next token does not match the expected type, or is out of range.
  ///
  /// `Scanner` throws this exception from `nextInt()`, `nextLong()`, `nextDouble()`,
  /// and `nextBoolean()` when the next token cannot be interpreted as the requested type.
  ///
  /// Extends `NoSuchElementException` — mirrors `java.util.InputMismatchException` (Java 5).
  ///
  /// - Since: Java 5
  open class InputMismatchException: java.util.NoSuchElementException, @unchecked Sendable {

    public override init() {
      super.init()
    }

    public override init(_ message: String) {
      super.init(message)
    }

    public override init(_ message: String, _ cause: Throwable) {
      super.init(message, cause)
    }

    public override init(_ cause: Throwable) {
      super.init(cause)
    }
  }
}
