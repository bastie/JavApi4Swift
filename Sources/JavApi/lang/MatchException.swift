/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

/// - Since: Java 21
open class MatchException : RuntimeException, @unchecked Sendable {
  
  public override init (_ message: String, _ cause: Throwable?) {
    if let cause {
      super.init(message, cause)
    }
    else {
      super.init(message)
    }
  }
}
