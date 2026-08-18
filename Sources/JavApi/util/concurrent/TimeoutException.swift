/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.util.concurrent {

  /// Thrown when a blocking operation times out.
  ///
  /// Mirrors `java.util.concurrent.TimeoutException` (Java 5).
  ///
  /// - Since: Java 5
  open class TimeoutException: Exception, @unchecked Sendable {

    public override init() {
      super.init()
    }

    public override init(_ message: String) {
      super.init(message)
    }
  }
}
