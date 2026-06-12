/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

/// - Since: Java 19
open class WrongThreadException : RuntimeException, @unchecked Sendable {
  
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
