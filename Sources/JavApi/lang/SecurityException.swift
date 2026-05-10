/*
 * SPDX-FileCopyrightText: 2023-2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

open class SecurityException : RuntimeException, @unchecked Sendable {
  
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
